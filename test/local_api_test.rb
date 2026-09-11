# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "net/http"
require_relative "../basegrid/local_api"

class LocalAPITest < Minitest::Test
  def setup
    @directory = Dir.mktmpdir("basegrid-api-test")
    @called = []
    @server = Basegrid::LocalAPIServer.new(port: 0, directory: @directory, job_timeout: 0.2, handler: lambda do |payload, mode|
      @called << Thread.current
      { "ok" => true, "name" => payload["name"], "mode" => mode }
    end).start(schedule: false)
    @token = File.read(File.join(@directory, "mcp-token.txt"))
  end

  def teardown
    @server.stop
    FileUtils.remove_entry(@directory)
  end

  def request(headers: {}, path: "/basegrid/call", body: '{"name":"basegrid_status","arguments":{}}', pump: true)
    caller = Thread.new do
      http = Net::HTTP.new("127.0.0.1", @server.port, nil)
      http.read_timeout = 3
      message = Net::HTTP::Post.new(path)
      message["Authorization"] = "Bearer #{@token}"
      message["Content-Type"] = "application/json"
      headers.each { |key, value| message[key] = value }
      message.body = body
      http.request(message)
    end
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 4
    while caller.alive? && Process.clock_gettime(Process::CLOCK_MONOTONIC) < deadline
      @server.drain if pump
      sleep 0.005
    end
    raise "Local API test timed out." if caller.alive?
    caller.value
  end

  def test_authenticated_request_runs_on_the_ui_thread
    response = request
    assert_equal "200", response.code
    assert_equal true, JSON.parse(response.body)["ok"]
    assert_equal [Thread.current], @called
    assert_match(/\A[0-9a-f]{64}\z/, @token)
  end

  def test_wrong_token_and_browser_origin_cannot_invoke_tools
    assert_equal "401", request(headers: { "Authorization" => "Bearer wrong" }).code
    assert_equal "403", request(headers: { "Origin" => "https://example.com" }).code
    assert_empty @called
  end

  def test_schemas_are_discoverable_without_model_work
    response = request(path: "/basegrid/tools", body: "{}")
    assert_equal Basegrid::API::TOOLS, JSON.parse(response.body)["tools"]
    assert_empty @called
  end

  def test_invalid_json_and_unknown_paths_do_not_queue_commands
    assert_equal "400", request(body: "invalid").code
    assert_equal "404", request(path: "/missing").code
    assert_empty @called
  end

  def test_timed_out_queued_write_never_runs_later
    response = request(pump: false, body: '{"name":"basegrid_create_slab","arguments":{}}')
    result = JSON.parse(response.body)
    assert_equal "TIMEOUT", result.dig("error", "code")
    assert_includes result.dig("error", "message"), "before execution"
    @server.drain
    assert_empty @called
  end

  def test_network_threads_cannot_drain_model_work
    error = Thread.new do
      @server.drain
    rescue StandardError => e
      e
    end.value
    assert_match(/main thread/, error.message)
  end
end
