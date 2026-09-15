# frozen_string_literal: true
require "minitest/autorun"
require "ostruct"
require_relative "../basegrid/cloud_connection"

module Basegrid
  module Main; end unless const_defined?(:Main)
end
module Sketchup
  def self.set_status_text(_text); end unless respond_to?(:set_status_text)
  def self.read_default(*) = nil unless respond_to?(:read_default)
  def self.write_default(*) = true unless respond_to?(:write_default)
end

class CloudStartupTest < Minitest::Test
  class Dialog
    attr_reader :state, :shown
    def update(**state) = @state = state
    def show = @shown = true
  end

  def setup
    @dialog = Dialog.new
    @drawing = Basegrid::CloudDrawing
    @previous = @drawing.instance_variables.to_h { |name| [name, @drawing.instance_variable_get(name)] }
    @drawing.instance_variables.each { |name| @drawing.remove_instance_variable(name) }
    @drawing.instance_variable_set(:@dialog, @dialog)
    @prefs = {}
    @oauth = OpenStruct.new(connected?: true, pending?: false)
    # Stub APIs at the external boundary, not the startup behaviour itself.
    @original_oauth = Basegrid::Main.method(:oauth_connection) if Basegrid::Main.respond_to?(:oauth_connection)
    oauth = @oauth
    Basegrid::Main.define_singleton_method(:oauth_connection) { oauth }
  end

  def teardown
    @drawing.instance_variables.each { |name| @drawing.remove_instance_variable(name) }
    @previous.each { |name, value| @drawing.instance_variable_set(name, value) }
    Basegrid::Main.singleton_class.remove_method(:oauth_connection)
    Basegrid::Main.define_singleton_method(:oauth_connection, @original_oauth) if @original_oauth
  end

  def with_preferences
    read = ->(_section, key, default) { @prefs.fetch(key, default) }
    write = ->(_section, key, value) { @prefs[key] = value }
    Sketchup.stub(:read_default, read) { Sketchup.stub(:write_default, write) { yield } }
  end

  def test_signed_out_startup_shows_sign_in_without_launching_browser
    @oauth[:connected?] = false
    with_preferences { @drawing.restore }
    assert @dialog.shown
    assert_equal "sign_in", @dialog.state[:action]
    assert_nil @drawing.instance_variable_get(:@connection)
  end

  def test_activity_snapshot_reports_sign_in_sync_and_connection_without_credentials
    @oauth[:pending?] = true
    @drawing.instance_variable_set(:@library_activity, { status: "running", stage: "textures", message: "Concrete", completed: 2, total: 5 })
    snapshot = @drawing.activity_snapshot
    rows = snapshot[:rows].to_h { |row| [row[:label],row[:value]] }
    assert_equal "Waiting for browser sign-in",rows["Account"]
    assert_equal "Disconnected",rows["Cloud drawing"]
    assert_includes rows["Sign-in sync"],"2/5 textures"
    refute snapshot[:cloud_running]
    refute_includes JSON.generate(snapshot),"access_token"
  end

  def test_explicit_disconnect_preserves_login_and_pauses_next_startup
    with_preferences do
      @drawing.stop
      @drawing.restore
    end
    assert @oauth.connected?
    assert_equal false, @prefs["cloud_drawing_enabled"]
    assert_nil @drawing.instance_variable_get(:@connection)
    assert_equal "reconnect", @dialog.state[:action]
  end

  def test_startup_defers_saved_token_refresh_to_worker
    connection = Object.new
    provider = nil
    connection.define_singleton_method(:start) { |oauth_token:, &_| provider = oauth_token }
    connection.define_singleton_method(:running?) { true }
    connection.define_singleton_method(:status) { "Connecting" }
    connection.define_singleton_method(:requires_sign_in?) { false }
    @oauth.define_singleton_method(:access_token) { raise "Network work ran on the startup UI thread" }
    with_preferences { Basegrid::CloudConnection.stub(:new, connection) { @drawing.restore } }
    assert provider.respond_to?(:call)
    assert_equal true, @prefs["cloud_drawing_enabled"]
    assert_equal "Connecting Basegrid", @dialog.state[:title]
    refute @dialog.shown
  end
end
