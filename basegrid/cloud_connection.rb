# frozen_string_literal: true

require "json"
require "net/http"
require "securerandom"
require "socket"
require "time"
require "uri"
require_relative "api"

module Basegrid
  # Outbound HTTPS only. The network thread never calls the SketchUp API.
  class CloudConnection
    class Client
      class Unauthorized < StandardError; end

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
        raise "Basegrid cloud returned HTTP #{response.code}." unless response.code.to_i.between?(200, 299)
        raise "Cloud response is too large." if response.body.to_s.bytesize > 1_100_000
        JSON.parse(response.body)
      end
    end

    attr_reader :device_id

    def initialize(client: Client.new, model: -> { Sketchup.active_model }, mode: -> { LocalAPI.mode }, handler: nil)
      @client, @model, @mode, @handler = client, model, mode, handler
      @registry = ObjectReferences.new
      @mutex = Mutex.new
      @condition = ConditionVariable.new
      @running = false
      @state = "Disconnected"
      @seen = {}
    end

    def running? = @running
    def status = @mutex.synchronize { @state }

    def start(oauth_token:, schedule: true)
      return self if running?
      raise "Connect your Basegrid account first." if oauth_token.to_s.empty?
      @ui_thread = Thread.current
      @device_id = SecureRandom.uuid
      @running = true
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
      @mutex.synchronize { @state = "Connecting" }
      registration = @client.post("/api/v1/sketchup/register", @snapshot.merge(
        "id" => @device_id, "name" => Socket.gethostname[0, 120], "version" => Basegrid::EXTENSION_VERSION
      ), oauth_token)
      token = registration.fetch("device_token")
      retry_seconds = 2.0
      while running?
        begin
          payload = @mutex.synchronize { @snapshot.merge(@completed ? { "completed" => @completed } : {}) }
          response = @client.post("/api/v1/sketchup/poll", payload, token)
          @mutex.synchronize do
            @completed = nil if payload["completed"]
            @state = "Connected"
            if response["command"] && @running
              @pending = response.fetch("command")
              @condition.wait(@mutex, 1.0) while @running && !@completed
            elsif @running
              @condition.wait(@mutex, 2.0)
            end
          end
          retry_seconds = 2.0
        rescue Client::Unauthorized
          raise
        rescue StandardError => e
          # Retry delivery of the *result*, never the geometry execution.
          @mutex.synchronize do
            @state = "Reconnecting: #{e.message}"
            @condition.wait(@mutex, retry_seconds) if @running
          end
          retry_seconds = [retry_seconds * 2, 30.0].min
        end
      end
    rescue StandardError => e
      @mutex.synchronize { @state = e.message; @running = false; @pending = nil; @condition.broadcast }
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
  end

  module CloudDrawing
    def self.start
      return if @connection&.running?
      @connection&.stop
      @connection = CloudConnection.new
      @connection.start(oauth_token: Main.oauth_connection.access_token)
    rescue StandardError => e
      UI.messagebox("Cloud drawing could not connect.\n\n#{e.message}")
    end

    def self.connect
      if Main.oauth_connection.connected?
        Sketchup.write_default("Basegrid", "cloud_drawing_enabled", true)
        start
      else
        Main.connect_materials do
          Sketchup.write_default("Basegrid", "cloud_drawing_enabled", true)
          start
        end
      end
    end

    def self.stop
      Sketchup.write_default("Basegrid", "cloud_drawing_enabled", false)
      @connection&.stop
    end

    def self.status
      UI.messagebox("Basegrid cloud drawing: #{@connection ? @connection.status : 'Disconnected'}\n\nConnector: https://app.basegrid.com.au/mcp\nPermissions: #{LocalAPI.mode}")
    end
  end
end
