# frozen_string_literal: true

require "json"
require "net/http"
require "securerandom"
require "socket"
require "time"
require "uri"
require_relative "api"
require_relative "oauth_connection"
require_relative "connection_dialog"

module Basegrid
  # Outbound HTTPS only. The network thread never calls the SketchUp API.
  class CloudConnection
    class Client
      class Unauthorized < StandardError; end
      class RequestError < StandardError
        attr_reader :status
        def initialize(status)
          @status = status
          super("Basegrid cloud returned HTTP #{status}.")
        end
      end

      def initialize(base_url: "https://app.basegrid.com.au")
        @base = URI.parse(base_url)
        local = @base.is_a?(URI::HTTP) && %w[127.0.0.1 localhost].include?(@base.host)
        raise "Cloud connection requires HTTPS." unless @base.is_a?(URI::HTTPS) || local
        raise "Invalid cloud address." if @base.userinfo || @base.query || @base.fragment || !["", "/"].include?(@base.path)
      end

      def post(path, payload, token)
        uri = @base + path
        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{token}"
        request["Content-Type"] = "application/json"
        request.body = JSON.generate(payload)
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.is_a?(URI::HTTPS), open_timeout: 10, read_timeout: 20) { |http| http.request(request) }
        raise Unauthorized, "Cloud drawing was disconnected. Use Connect Cloud Drawing to reconnect." if response.code.to_i == 401
        raise RequestError.new(response.code.to_i) unless response.code.to_i.between?(200, 299)
        raise "Cloud response is too large." if response.body.to_s.bytesize > 1_100_000
        JSON.parse(response.body)
      end
    end

    attr_reader :device_id

    def initialize(client: Client.new, model: -> { Sketchup.active_model }, mode: -> { LocalAPI.mode }, handler: nil, retry_delay: 2.0)
      @client, @model, @mode, @handler = client, model, mode, handler
      @registry = ObjectReferences.new
      @mutex = Mutex.new
      @condition = ConditionVariable.new
      @running = false
      @state = "Disconnected"
      @seen = {}
      @retry_delay = retry_delay
    end

    def running? = @running
    def status = @mutex.synchronize { @state }
    def requires_sign_in? = @requires_sign_in == true

    def start(oauth_token:, schedule: true, &status_changed)
      return self if running?
      raise "Connect your Basegrid account first." if oauth_token.to_s.empty?
      @ui_thread = Thread.current
      @device_id = SecureRandom.uuid
      @running = true
      @requires_sign_in = false
      @status_changed = status_changed
      @reported_state = nil
      @mutex.synchronize { @state = "Connecting" }
      @pending = @completed = nil
      snapshot!
      @timer = UI.start_timer(0.1, true) { drain } if schedule
      @worker = Thread.new { run(oauth_token) }
      self
    end

    def stop
      @mutex.synchronize do
        @running = false
        @pending = nil
        @state = "Disconnected"
        @condition.broadcast
      end
      UI.stop_timer(@timer) if @timer
      @timer = nil
    end

    def drain
      raise "Cloud drawing must run on SketchUp's main thread." unless Thread.current == @ui_thread
      # SketchUp can spend idle time outside Ruby. Explicitly yield so network
      # workers keep polling even when no Ruby console or modelling tool is busy.
      Thread.pass
      current_state = status
      if current_state != @reported_state
        @reported_state = current_state
        @status_changed&.call(current_state)
      end
      snapshot!
      job = @mutex.synchronize do
        next nil unless @running
        value = @pending
        @pending = nil
        value
      end
      return unless job

      result = execute(job)
      if JSON.generate(result).bytesize > 3_000_000
        result = failure("RESULT_TOO_LARGE", "Request fewer entities or a smaller viewport image.")
      end
      @mutex.synchronize do
        @completed = { "id" => job.fetch("id"), "result" => result }
        @condition.broadcast
      end
    end

    private

    def failure(code, message)
      { "ok" => false, "error" => { "code" => code, "message" => message } }
    end

    def snapshot!
      model = @model.call
      value = { "model_guid" => model ? model.guid.to_s : "", "model_title" => model ? model.title.to_s[0, 200] : "",
                "permission_mode" => @mode.call }
      @mutex.synchronize { @snapshot = value }
    end

    def execute(job)
      id = job.fetch("id")
      return failure("DUPLICATE_COMMAND", "This command was already received; inspect its original result.") if @seen[id]
      @seen[id] = true
      @seen.shift if @seen.length > 10_000
      return failure("COMMAND_EXPIRED", "Command expired before SketchUp could execute it.") if Time.iso8601(job.fetch("expires_at")) <= Time.now
      model = @model.call
      unless model && model.guid.to_s == job.fetch("model_guid")
        return failure("MODEL_CHANGED", "The active model changed. Inspect it before drawing.")
      end
      payload = job.fetch("payload")
      if @handler
        @handler.call(payload, @mode.call)
      else
        API.new(registry: @registry, model: model).call(payload.fetch("name"), payload.fetch("arguments", {}), permission_mode: @mode.call)
      end
    rescue StandardError => e
      failure("CLOUD_COMMAND_ERROR", e.message)
    end

    def run(oauth_token)
      token = nil
      registration = register(oauth_token)
      return unless registration
      token = registration.fetch("device_token")
      retry_seconds = @retry_delay
      while running?
        begin
          payload = @mutex.synchronize { @snapshot.merge(@completed ? { "completed" => @completed } : {}) }
          response = @client.post("/api/v1/sketchup/poll", payload, token)
          @mutex.synchronize do
            @completed = nil if payload["completed"]
            @state = "Connected" if @running
            if response["command"] && @running
              @pending = response.fetch("command")
              @condition.wait(@mutex, 1.0) while @running && !@completed
            elsif @running
              @condition.wait(@mutex, 2.0)
            end
          end
          retry_seconds = @retry_delay
        rescue Client::Unauthorized
          raise
        rescue StandardError => e
          # Retry delivery of the *result*, never the geometry execution.
          wait_to_retry(e, retry_seconds)
          retry_seconds = [retry_seconds * 2, 30.0].min
        end
      end
    rescue StandardError => e
      @mutex.synchronize { @state = e.message if @running; @running = false; @pending = nil; @condition.broadcast }
    ensure
      if token
        begin
          payload = @mutex.synchronize { @snapshot.merge("disconnect" => true).merge(@completed ? { "completed" => @completed } : {}) }
          @client.post("/api/v1/sketchup/poll", payload, token)
        rescue StandardError
          # Offline devices expire from the live list after 30 seconds.
        end
      end
    end

    def register(oauth_token)
      retry_seconds = @retry_delay
      while running?
        begin
          value = oauth_token.respond_to?(:call) ? oauth_token.call : oauth_token
          raise OAuthConnection::SignInRequired, "Sign in to your Basegrid account to connect." if value.to_s.empty?
          payload = @mutex.synchronize { @snapshot.merge("id" => @device_id, "name" => Socket.gethostname[0, 120], "version" => Basegrid::EXTENSION_VERSION) }
          return @client.post("/api/v1/sketchup/register", payload, value)
        rescue Client::Unauthorized, OAuthConnection::SignInRequired
          @requires_sign_in = true
          raise
        rescue StandardError => e
          raise if e.is_a?(Client::RequestError) && e.status < 500 && e.status != 429
          wait_to_retry(e, retry_seconds)
          retry_seconds = [retry_seconds * 2, 30.0].min
        end
      end
      nil
    end

    def wait_to_retry(error, seconds)
      @mutex.synchronize do
        if @running
          @state = "Reconnecting: #{error.message}"
          @condition.wait(@mutex, seconds)
        end
      end
    end
  end

  module CloudDrawing
    def self.restore
      if Main.oauth_connection.connected?
        return if Sketchup.read_default("Basegrid", "cloud_drawing_enabled", nil) == false
        Sketchup.write_default("Basegrid", "cloud_drawing_enabled", true)
        start(announce: true)
      else
        show_sign_in
      end
    rescue StandardError => e
      show_sign_in(e.message)
    end

    def self.start(announce: false)
      if @connection&.running?
        update_dialog
        notify(@connection.status) if announce
        return
      end
      @connection&.stop
      connection = @connection = CloudConnection.new
      oauth = Main.oauth_connection
      announced = false
      connection.start(oauth_token: -> { oauth.access_token }) do |state|
        next unless @connection.equal?(connection)
        Sketchup.set_status_text("Basegrid cloud drawing: #{state}")
        update_dialog
        if !connection.running?
          connection.requires_sign_in? ? show_sign_in(state) : dialog.show
        elsif announce && !announced && state == "Connected"
          announced = true
          notify(state)
        end
      end
      Sketchup.set_status_text("Connecting Basegrid cloud drawing…")
      update_dialog
    rescue StandardError => e
      show_sign_in(e.message)
    end

    def self.connect
      if Main.oauth_connection.connected?
        Sketchup.write_default("Basegrid", "cloud_drawing_enabled", true)
        start
        dialog.show
      else
        show_sign_in
      end
    end

    def self.sign_in(&connected)
      return if Main.oauth_connection.pending?
      @signing_in = true
      dialog.update(title: "Complete sign-in in your browser", message: "Return here after approving Basegrid. Your sign-in will be remembered on this computer.")
      dialog.show
      Main.oauth_connection.connect do |result|
        @signing_in = false
        if result[:error]
          show_sign_in(result[:error].message)
          next
        end
        begin
          # Successful account sign-in must survive an unrelated texture failure.
          Main.oauth_connection.save_tokens(result.fetch(:tokens))
          Sketchup.write_default("Basegrid", "materials_sync_token", "")
          Sketchup.write_default("Basegrid", "cloud_drawing_enabled", true)
          @connection&.stop
          start
          sync_library(result.fetch(:tokens).fetch("access_token"))
          connected&.call
        rescue StandardError => e
          show_sign_in(e.message)
        end
      end
    rescue StandardError => e
      @signing_in = false
      show_sign_in(e.message)
    end

    def self.stop
      Sketchup.write_default("Basegrid", "cloud_drawing_enabled", false)
      @connection&.stop
      Sketchup.set_status_text("Basegrid cloud drawing: Disconnected")
      update_dialog
    end

    def self.status
      update_dialog
      dialog.show
    end

    def self.connection_status
      { "status" => @connection ? @connection.status : "Disconnected",
        "connected" => @connection&.status == "Connected", "device_id" => @connection&.device_id }
    end

    def self.dialog
      @dialog ||= ConnectionDialog.new do |action|
        case action
        when "sign_in" then sign_in
        when "reconnect" then connect
        when "sign_out"
          stop
          Main.oauth_connection.disconnect
          Sketchup.write_default("Basegrid", "materials_sync_token", "")
          show_sign_in
        end
      end
    end

    def self.show_sign_in(message = nil)
      dialog.update(title: "Sign in to Basegrid", action: "sign_in",
        message: message || "Connect your materials and let Claude work with this SketchUp session. You will stay signed in between sessions.")
      dialog.show
    end

    def self.update_dialog
      return if @signing_in
      signed_in = Main.oauth_connection.connected?
      state = @connection ? @connection.status : "Disconnected"
      if !signed_in || @connection&.requires_sign_in?
        dialog.update(title: "Sign in to Basegrid", message: "Sign in once to restore your Basegrid connection on this computer.", action: "sign_in")
      elsif state == "Connected"
        dialog.update(title: "Basegrid is connected", message: "This SketchUp session is available in Claude. Keep SketchUp open while drawing.\n#{@library_message}", signed_in: true)
      elsif @connection&.running?
        dialog.update(title: state == "Connecting" ? "Connecting Basegrid" : "Reconnecting Basegrid",
          message: "Restoring your saved sign-in. Temporary connection failures retry automatically.\n#{state == 'Connecting' ? '' : state}", signed_in: true)
      else
        dialog.update(title: "Cloud drawing is disconnected", message: "#{state}\nYour Basegrid sign-in is saved. Reconnect to make this session available in Claude.", action: "reconnect", signed_in: true)
      end
    end

    def self.sync_library(token)
      return if @library_worker&.alive?
      @library_message = "Syncing your material library…"
      url = Main.material_library_url
      results = Queue.new
      @library_worker = Thread.new do
        result = MaterialLibrary.new.sync!(url: url, token: token)
        results << "#{result[:materials]} materials are available."
      rescue StandardError => e
        results << "Material sync could not finish: #{e.message} Your sign-in is saved; retry Materials → Sync."
      end
      timer = UI.start_timer(0.25, true) do
        Thread.pass
        unless results.empty?
          @library_message = results.pop
          UI.stop_timer(timer)
          update_dialog
        end
      end
    end

    def self.notify(state)
      message = state == "Connected" ? "Cloud drawing is connected. Keep SketchUp open while using Basegrid in Claude." : "Cloud drawing: #{state}"
      Sketchup.set_status_text(message)
      # Native notifications leave SketchUp's UI timer free to process commands.
      @notification = UI::Notification.new(Sketchup.extensions[Basegrid::EXTENSION_NAME], message)
      @notification.show
    end
    private_class_method :notify, :dialog, :show_sign_in, :update_dialog, :sync_library
  end
end
