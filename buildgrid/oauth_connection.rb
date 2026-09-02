# frozen_string_literal: true

require "base64"
require "digest"
require "fileutils"
require "json"
require "net/http"
require "securerandom"
require "socket"
require "tempfile"
require "uri"

module Buildgrid
  class OAuthConnection
    CONFIG_URL = "https://buildgrid.overlandbuilders.co/api/v1/oauth/config"
    PREFERENCE_SECTION = "Buildgrid"
    TOKENS_KEY = "oauth_tokens"
    CALLBACK_TIMEOUT = 180
    EXPIRY_MARGIN = 60

    class HttpClient
      def get_json(url)
        request_json(Net::HTTP::Get.new(https_uri(url)), https_uri(url))
      end

      def post_form(url, values)
        uri = https_uri(url)
        request = Net::HTTP::Post.new(uri)
        request.set_form_data(values)
        request_json(request, uri)
      end

      private

      def request_json(request, uri)
        response = Net::HTTP.start(
          uri.host,
          uri.port,
          use_ssl: uri.is_a?(URI::HTTPS),
          open_timeout: 10,
          read_timeout: 30
        ) { |http| http.request(request) }
        payload = JSON.parse(response.body.to_s)
        return payload if response.code.to_i.between?(200, 299)

        detail = payload["error_description"] || payload["error"] || "HTTP #{response.code}"
        raise "OAuth request failed: #{detail}."
      rescue JSON::ParserError
        raise "OAuth service returned invalid JSON."
      end

      def https_uri(url)
        uri = URI.parse(url.to_s)
        allowed_local = uri.is_a?(URI::HTTP) && ["localhost", "127.0.0.1", "::1"].include?(uri.host)
        raise "OAuth service URLs must use HTTPS." unless uri.is_a?(URI::HTTPS) || allowed_local

        uri
      rescue URI::InvalidURIError
        raise "OAuth service URL is invalid."
      end
    end

    def initialize(client: HttpClient.new, token_path: nil)
      @client = client
      @token_path = token_path || File.join(MaterialLibrary.default_data_directory, "oauth-session.json")
      @pending = false
      @result = nil
      @result_mutex = Mutex.new
    end

    def connect(&completion)
      raise "A Buildgrid connection is already in progress." if @pending

      config = validated_config(@client.get_json(CONFIG_URL))
      redirect_uri = URI.parse(config.fetch("redirect_uri"))
      server = TCPServer.new(redirect_uri.host, redirect_uri.port)
      state = SecureRandom.urlsafe_base64(32, false)
      verifier = SecureRandom.urlsafe_base64(64, false)
      challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)
      authorization_url = authorization_url(config, state, challenge)

      @pending = true
      @result_mutex.synchronize { @result = nil }
      timer = UI.start_timer(0.25, true) { poll_completion(timer, completion) }
      Thread.new { complete_authorization(server, config, state, verifier) }
      UI.openURL(authorization_url)
      true
    rescue Errno::EADDRINUSE
      raise "OAuth callback port is already in use. Close the other Buildgrid connection attempt and try again."
    end

    def connected?
      !stored_tokens.empty?
    end

    def access_token
      tokens = stored_tokens
      return "" if tokens.empty?
      return tokens["access_token"].to_s if tokens["expires_at"].to_i > Time.now.to_i + EXPIRY_MARGIN

      refreshed = @client.post_form(tokens.fetch("token_endpoint"), {
        "grant_type" => "refresh_token",
        "refresh_token" => tokens.fetch("refresh_token"),
        "client_id" => tokens.fetch("client_id")
      })
      merged = tokens.merge(refreshed)
      validate_tokens!(merged)
      save_tokens(merged)
      stored_tokens.fetch("access_token").to_s
    end

    def save_tokens(tokens)
      normalized = tokens.dup
      normalized["expires_at"] = Time.now.to_i + normalized.fetch("expires_in").to_i
      write_token_file(JSON.generate(normalized))
      stored = JSON.parse(File.read(@token_path, encoding: "UTF-8"))
      raise "OAuth session could not be saved." unless stored["access_token"] == normalized["access_token"]

      Sketchup.write_default(PREFERENCE_SECTION, TOKENS_KEY, "")
      true
    end

    def disconnect
      File.delete(@token_path) if File.file?(@token_path)
      Sketchup.write_default(PREFERENCE_SECTION, TOKENS_KEY, "")
    end

    private

    def stored_tokens
      return JSON.parse(File.read(@token_path, encoding: "UTF-8")) if File.file?(@token_path)

      raw = Sketchup.read_default(PREFERENCE_SECTION, TOKENS_KEY, "").to_s
      return {} if raw.empty?

      parsed = JSON.parse(raw)
      write_token_file(raw)
      Sketchup.write_default(PREFERENCE_SECTION, TOKENS_KEY, "")
      parsed
    rescue JSON::ParserError, SystemCallError => e
      raise "The saved OAuth session cannot be read: #{e.message}"
    end

    def write_token_file(content)
      directory = File.dirname(@token_path)
      FileUtils.mkdir_p(directory)
      temporary = Tempfile.new([File.basename(@token_path), ".tmp"], directory)
      begin
        temporary.write(content)
        temporary.flush
        temporary.fsync
        temporary.close
        backup = "#{@token_path}.previous"
        File.delete(backup) if File.exist?(backup)
        File.rename(@token_path, backup) if File.exist?(@token_path)
        begin
          File.rename(temporary.path, @token_path)
          File.chmod(0o600, @token_path)
          File.delete(backup) if File.exist?(backup)
        rescue StandardError
          File.rename(backup, @token_path) if File.exist?(backup) && !File.exist?(@token_path)
          raise
        end
      ensure
        temporary.close!
      end
    end

    def validated_config(config)
      raise "OAuth is not enabled for Buildgrid yet." unless config.is_a?(Hash) && config["enabled"]

      %w[authorization_endpoint token_endpoint client_id redirect_uri].each do |key|
        raise "OAuth configuration is missing #{key}." if config[key].to_s.empty?
      end
      redirect = URI.parse(config.fetch("redirect_uri"))
      unless redirect.is_a?(URI::HTTP) && redirect.host == "127.0.0.1" && redirect.path == "/oauth/callback"
        raise "OAuth callback configuration is invalid."
      end

      unless redirect.port.between?(1024, 65_535)
        raise "OAuth callback port must be between 1024 and 65535."
      end
      %w[authorization_endpoint token_endpoint].each do |key|
        service_uri = URI.parse(config.fetch(key))
        local = service_uri.is_a?(URI::HTTP) && ["localhost", "127.0.0.1", "::1"].include?(service_uri.host)
        raise "OAuth #{key.tr('_', ' ')} must use HTTPS." unless service_uri.is_a?(URI::HTTPS) || local
      end

      config
    rescue URI::InvalidURIError
      raise "OAuth configuration contains an invalid URL."
    end

    def authorization_url(config, state, challenge)
      uri = URI.parse(config.fetch("authorization_endpoint"))
      uri.query = URI.encode_www_form(
        "response_type" => "code",
        "client_id" => config.fetch("client_id"),
        "redirect_uri" => config.fetch("redirect_uri"),
        "scope" => config.fetch("scope", "openid email profile"),
        "state" => state,
        "code_challenge" => challenge,
        "code_challenge_method" => "S256"
      )
      uri.to_s
    end

    def complete_authorization(server, config, expected_state, verifier)
      socket = wait_for_callback(server)
      params = callback_params(socket, config.fetch("redirect_uri"))
      raise "OAuth callback state did not match." unless secure_compare(params.fetch("state", ""), expected_state)
      raise params["error_description"] || params["error"] if params["error"]
      raise "OAuth callback did not include an authorization code." if params["code"].to_s.empty?

      tokens = @client.post_form(config.fetch("token_endpoint"), {
        "grant_type" => "authorization_code",
        "code" => params.fetch("code"),
        "client_id" => config.fetch("client_id"),
        "redirect_uri" => config.fetch("redirect_uri"),
        "code_verifier" => verifier
      })
      validate_tokens!(tokens)
      tokens["token_endpoint"] = config.fetch("token_endpoint")
      tokens["client_id"] = config.fetch("client_id")
      write_browser_response(socket, true)
      set_result(tokens: tokens)
    rescue StandardError => e
      write_browser_response(socket, false) if socket
      set_result(error: e)
    ensure
      socket.close if socket && !socket.closed?
      server.close unless server.closed?
    end

    def wait_for_callback(server)
      ready = IO.select([server], nil, nil, CALLBACK_TIMEOUT)
      raise "OAuth connection timed out. Try connecting again." unless ready

      server.accept
    end

    def callback_params(socket, redirect_uri)
      request_line = socket.gets.to_s
      method, target, = request_line.split(" ", 3)
      raise "OAuth callback request was invalid." unless method == "GET"

      uri = URI.parse(target)
      raise "OAuth callback path was invalid." unless uri.path == URI.parse(redirect_uri).path

      URI.decode_www_form(uri.query.to_s).to_h
    rescue URI::InvalidURIError
      raise "OAuth callback request was invalid."
    end

    def write_browser_response(socket, success)
      heading = success ? "Buildgrid is connected" : "Buildgrid could not connect"
      detail = success ? "You can close this tab and return to SketchUp." : "Return to SketchUp for details."
      body = "<!doctype html><meta charset=\"utf-8\"><title>#{heading}</title>" \
             "<body style=\"font:16px system-ui;padding:48px;color:#101614\"><h1>#{heading}</h1><p>#{detail}</p></body>"
      socket.write("HTTP/1.1 #{success ? '200 OK' : '400 Bad Request'}\r\n")
      socket.write("Content-Type: text/html; charset=utf-8\r\nContent-Length: #{body.bytesize}\r\nConnection: close\r\n\r\n#{body}")
    rescue IOError, SystemCallError
      nil
    end

    def secure_compare(left, right)
      return false unless left.bytesize == right.bytesize

      left.bytes.zip(right.bytes).reduce(0) { |memo, (a, b)| memo | (a ^ b) }.zero?
    end

    def validate_tokens!(tokens)
      unless tokens.is_a?(Hash) && !tokens["access_token"].to_s.empty? &&
             !tokens["refresh_token"].to_s.empty? && tokens["expires_in"].to_i.positive?
        raise "OAuth token response was incomplete."
      end
    end

    def set_result(value)
      @result_mutex.synchronize { @result = value }
    end

    def poll_completion(timer, completion)
      result = @result_mutex.synchronize { @result }
      return unless result

      UI.stop_timer(timer)
      @pending = false
      completion.call(result)
    end
  end
end
