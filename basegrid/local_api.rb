# frozen_string_literal: true

require "socket"
require "fileutils"
require "securerandom"
require_relative "api"

module Basegrid
  # Basegrid's own authenticated loopback transport. Socket threads only handle
  # bytes. The UI timer runs all SketchUp work, including reference resolution.
  class LocalAPIServer
    PORT = 9878
    MAX_BODY = 1_000_000
    MAX_RESPONSE = 8_000_000
    attr_reader :port, :mode

    def initialize(port: PORT, directory: MaterialLibrary.default_data_directory, handler: nil, job_timeout: 110.0)
      @port = port
      @directory = directory
      @handler = handler
      @job_timeout = job_timeout
      @mutex = Mutex.new
      @jobs = []
      @workers = []
      @mode = "edit"
      @running = false
      @references = ObjectReferences.new
    end

    def mode=(value)
      raise "Choose inspect, edit or full." unless %w[inspect edit full].include?(value)
      @mode = value
    end

    def running? = @running

    def start(schedule: true)
      return self if running?

      FileUtils.mkdir_p(@directory)
      token_path = File.join(@directory, "mcp-token.txt")
      if File.file?(token_path)
        @token = File.read(token_path).strip
        raise "Basegrid MCP token file is invalid." unless @token.match?(/\A[0-9a-f]{64}\z/)
      else
        @token = SecureRandom.hex(32)
        File.open(token_path, File::WRONLY | File::CREAT | File::EXCL, 0o600) { |file| file.write(@token) }
      end
      @socket = TCPServer.new("127.0.0.1", @port)
      @port = @socket.addr[1]
      @running = true
      @ui_thread = Thread.current
      @timer = UI.start_timer(0.05, true) { drain } if schedule
      @acceptor = Thread.new do
        while running?
          client = @socket.accept
          @workers.reject! { |thread| !thread.alive? }
          if @workers.length >= 8
            client.close
            next
          end
          @workers << Thread.new(client) { |connection| serve(connection) }
        end
      rescue IOError, SystemCallError
        # Closing the listener during stop releases accept.
      end
      self
    rescue StandardError
      stop
      raise
    end

    def stop
      @running = false
      @socket&.close rescue nil
      UI.stop_timer(@timer) if @timer
      @timer = nil
      @mutex.synchronize do
        @jobs.each do |job|
          job[:cancelled] = true
          job[:condition].broadcast
        end
        @jobs.clear
      end
    end

    def drain
      raise "Basegrid API must run on SketchUp's main thread." unless Thread.current == @ui_thread
      Thread.pass

      # One request per tick keeps drawing/UI responsive between API calls.
      job = @mutex.synchronize do
        candidate = @jobs.shift
        candidate[:started] = true if candidate && !candidate[:cancelled]
        candidate
      end
      return unless job && !job[:cancelled]

      begin
        result = @handler ? @handler.call(job[:payload], @mode) : API.new(registry: @references).call(
          job[:payload].fetch("name"), job[:payload].fetch("arguments", {}), permission_mode: @mode
        )
      rescue StandardError => e
        result = failure("API_ERROR", e.message)
      end
      @mutex.synchronize do
        job[:result] = result
        job[:done] = true
        job[:condition].broadcast
      end
    end

    private

    def failure(code, message)
      { "ok" => false, "error" => { "code" => code, "message" => message } }
    end

    def secure_token?(supplied)
      return false unless supplied.bytesize == @token.bytesize
      supplied.bytes.zip(@token.bytes).reduce(0) { |memo, (left, right)| memo | (left ^ right) }.zero?
    end

    def read_chunk(client, deadline)
      remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
      raise "Request read timed out." unless remaining.positive? && IO.select([client], nil, nil, remaining)
      client.readpartial(8192)
    end

    def serve(client)
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 5.0
      buffer = +""
      until buffer.include?("\r\n\r\n")
        buffer << read_chunk(client, deadline)
        raise "Request headers are too large." if buffer.bytesize > 16_384 && !buffer.include?("\r\n\r\n")
      end
      header_text, body = buffer.split("\r\n\r\n", 2)
      raise "Request headers are too large." if header_text.bytesize > 16_384
      lines = header_text.split("\r\n")
      method, path, version = lines.shift.split(" ")
      raise "Invalid HTTP request." unless version == "HTTP/1.1" || version == "HTTP/1.0"
      headers = {}
      lines.each do |line|
        key, value = line.split(":", 2)
        key = key.to_s.downcase
        raise "Duplicate or invalid HTTP header." if !value || headers.key?(key)
        headers[key] = value.strip
      end
      return respond(client, 403, failure("ORIGIN_REJECTED", "Browser page requests are not permitted.")) if headers.key?("origin")
      if method == "GET" && path == "/health"
        return respond(client, 200, { "ok" => true, "name" => "Basegrid", "port" => @port })
      end
      supplied = headers.fetch("authorization", "").delete_prefix("Bearer ")
      return respond(client, 401, failure("UNAUTHORIZED", "A valid Basegrid local API token is required.")) unless secure_token?(supplied)
      return respond(client, 405, failure("METHOD_NOT_ALLOWED", "Use POST.")) unless method == "POST"
      return respond(client, 404, failure("NOT_FOUND", "Unknown Basegrid endpoint.")) unless %w[/basegrid/tools /basegrid/call].include?(path)
      raise "Chunked requests are not supported." if headers.key?("transfer-encoding")
      raw_length = headers.fetch("content-length", "0")
      raise "Invalid content length." unless raw_length.match?(/\A\d+\z/)
      length = raw_length.to_i
      return respond(client, 413, failure("REQUEST_TOO_LARGE", "Request body exceeds 1 MB.")) if length > MAX_BODY
      body << read_chunk(client, deadline) while body.bytesize < length
      if path == "/basegrid/tools"
        return respond(client, 200, { "ok" => true, "tools" => API::TOOLS })
      end
      payload = JSON.parse(body.byteslice(0, length))
      unless payload.is_a?(Hash) && payload["name"].is_a?(String) && (payload.keys - %w[name arguments]).empty?
        raise "Expected name and arguments."
      end
      respond(client, 200, enqueue(payload))
    rescue StandardError => e
      respond(client, 400, failure("INVALID_REQUEST", e.message)) rescue nil
    ensure
      client.close rescue nil
    end

    def enqueue(payload)
      job = { payload: payload, condition: ConditionVariable.new }
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + @job_timeout
      @mutex.synchronize do
        @jobs << job
        until job[:done] || job[:cancelled]
          remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
          unless running? && remaining.positive?
            job[:cancelled] = true
            @jobs.delete(job)
            detail = job[:started] ? "Execution started; inspect the model before retrying." : "The command was cancelled before execution."
            return failure("TIMEOUT", detail)
          end
          job[:condition].wait(@mutex, remaining)
        end
        job[:result] || failure("STOPPED", "The Basegrid API was stopped before execution.")
      end
    end

    def respond(client, status, payload)
      body = JSON.generate(payload)
      if body.bytesize > MAX_RESPONSE
        status = 413
        body = JSON.generate(failure("RESPONSE_TOO_LARGE", "Request a smaller result or image."))
      end
      reason = { 200 => "OK", 400 => "Bad Request", 401 => "Unauthorized", 403 => "Forbidden", 404 => "Not Found", 405 => "Method Not Allowed", 413 => "Payload Too Large" }.fetch(status)
      bytes = "HTTP/1.1 #{status} #{reason}\r\nContent-Type: application/json\r\nContent-Length: #{body.bytesize}\r\nConnection: close\r\n\r\n#{body}"
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 10
      until bytes.empty?
        remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
        raise "Response write timed out." unless remaining.positive? && IO.select(nil, [client], nil, remaining)
        written = client.write_nonblock(bytes, exception: false)
        bytes = bytes.byteslice(written..) if written.is_a?(Integer)
      end
    end
  end

  module LocalAPI
    def self.mode
      @server ? @server.mode : "edit"
    end

    def self.start
      @server ||= LocalAPIServer.new
      @server.start
    rescue StandardError => e
      UI.messagebox("Basegrid MCP API could not start: #{e.message}")
    end

    def self.stop
      @server&.stop
    end

    def self.configure_permissions
      @server ||= LocalAPIServer.new
      values = UI.inputbox(["API permissions"], [@server.mode], ["inspect|edit|full"], "Basegrid MCP API")
      @server.mode = values.first if values
    end
  end
end
