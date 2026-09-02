# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"

module UI
end

module Sketchup
  class << self
    attr_accessor :preferences

    def read_default(section, key, default)
      self.preferences ||= {}
      preferences.fetch([section, key], default)
    end

    def write_default(section, key, value)
      self.preferences ||= {}
      preferences[[section, key]] = value
    end
  end
end

require_relative "../buildgrid/oauth_connection"

class OAuthConnectionTest < Minitest::Test
  class FakeClient
    attr_reader :forms

    def initialize(response)
      @response = response
      @forms = []
    end

    def post_form(url, values)
      forms << [url, values]
      @response
    end
  end

  def setup
    Sketchup.preferences = {}
    @directory = Dir.mktmpdir
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def test_refreshes_an_expired_access_token
    client = FakeClient.new(
      "access_token" => "new-access",
      "refresh_token" => "new-refresh",
      "expires_in" => 3600
    )
    connection = Buildgrid::OAuthConnection.new(
      client: client,
      token_path: File.join(@directory, "oauth-session.json")
    )
    connection.save_tokens(
      "access_token" => "old-access",
      "refresh_token" => "old-refresh",
      "expires_in" => 0,
      "token_endpoint" => "https://example.test/oauth/token",
      "client_id" => "client-1"
    )

    assert_equal "new-access", connection.access_token
    assert_equal "refresh_token", client.forms.fetch(0).fetch(1).fetch("grant_type")
    assert_equal "old-refresh", client.forms.fetch(0).fetch(1).fetch("refresh_token")
  end

  def test_disconnect_removes_stored_tokens
    connection = Buildgrid::OAuthConnection.new(
      client: FakeClient.new({}),
      token_path: File.join(@directory, "oauth-session.json")
    )
    connection.save_tokens("access_token" => "access", "expires_in" => 3600)

    connection.disconnect

    refute connection.connected?
    assert_equal "", connection.access_token
  end

  def test_persists_tokens_outside_sketchup_preferences
    path = File.join(@directory, "oauth-session.json")
    connection = Buildgrid::OAuthConnection.new(client: FakeClient.new({}), token_path: path)

    connection.save_tokens(
      "access_token" => "access",
      "refresh_token" => "refresh",
      "expires_in" => 3600
    )

    assert File.file?(path)
    assert_equal "", Sketchup.read_default("Buildgrid", "oauth_tokens", "")
    assert connection.connected?
  end
end
