# frozen_string_literal: true
require "minitest/autorun"
require_relative "../basegrid/cloud_connection"

class CloudConnectionTest < Minitest::Test
  Model = Struct.new(:guid, :title)
  class Client
    attr_reader :posts
    def initialize(job)
      @job, @posts, @sent = job, Queue.new, false
    end
    def post(path, body, token)
      @posts << [path, body, token, Thread.current]
      return { "device_token" => "device-test-token" } if path.end_with?("register")
      return {} if body["disconnect"]
      job = @sent ? nil : @job
      @sent = true
      { "command" => job }
    end
  end

  def job(id: "one", guid: "model-one", expires: Time.now + 30)
    { "id" => id, "model_guid" => guid, "expires_at" => expires.iso8601,
      "payload" => { "name" => "basegrid_status", "arguments" => {} } }
  end

  def setup
    @model = Model.new("model-one", "Fixture")
    @mode = "edit"
    @calls = []
    @connection = Basegrid::CloudConnection.new(model: -> { @model }, mode: -> { @mode },
      handler: ->(payload, mode) { @calls << [payload, mode, Thread.current]; { "ok" => true } })
  end

  def test_expired_changed_model_and_duplicate_jobs_never_draw
    assert_equal "COMMAND_EXPIRED", @connection.send(:execute, job(expires: Time.now - 10)).dig("error", "code")
    assert_equal "MODEL_CHANGED", @connection.send(:execute, job(id: "two", guid: "other")).dig("error", "code")
    assert_empty @calls
    assert @connection.send(:execute, job(id: "three"))["ok"]
    assert_equal "DUPLICATE_COMMAND", @connection.send(:execute, job(id: "three")).dig("error", "code")
    assert_equal 1, @calls.length
  end

  def test_permission_is_read_at_execution_time
    @mode = "inspect"
    @connection.send(:execute, job)
    assert_equal "inspect", @calls.first[1]
  end

  def test_network_worker_delivers_on_ui_thread_and_reports_result
    client = Client.new(job)
    @connection = Basegrid::CloudConnection.new(client: client, model: -> { @model }, mode: -> { @mode },
      handler: ->(payload, mode) { @calls << [payload, mode, Thread.current]; { "ok" => true, "result" => "done" } })
    @connection.start(oauth_token: "oauth-test-token", schedule: false)
    deadline = Time.now + 3
    @connection.drain while @calls.empty? && Time.now < deadline
    assert_equal 1, @calls.length
    assert_equal Thread.current, @calls.first[2]
    @connection.stop
    worker = @connection.instance_variable_get(:@worker)
    worker.join(3)
    posts = []
    posts << client.posts.pop until client.posts.empty?
    assert posts.any? { |path, body, _token, _thread| path.end_with?("poll") && body.dig("completed", "result", "ok") }
    assert posts.all? { |_path, _body, _token, thread| thread != Thread.current }
    assert_equal "oauth-test-token", posts.first[2]
    assert posts.drop(1).all? { |_path, _body, token, _thread| token == "device-test-token" }
  ensure
    @connection.stop
  end
end
