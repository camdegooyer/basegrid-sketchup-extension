# frozen_string_literal: true
require 'minitest/autorun'
require_relative '../basegrid/keyboard_shortcuts'

module Sketchup
  class << self
    attr_accessor :shortcut_entries
    def get_shortcuts = shortcut_entries || []
    unless method_defined?(:read_default)
      def read_default(section,key,fallback) = (@shortcut_preferences || {}).fetch([section,key],fallback)
      def write_default(section,key,value) = (@shortcut_preferences ||= {})[[section,key]] = value
    end
  end
end

class KeyboardShortcutsTest < Minitest::Test
  K = Basegrid::KeyboardShortcuts
  def setup
    Sketchup.shortcut_entries = []
    Sketchup.write_default('Basegrid',K::PREFERENCE_KEY,'{}')
  end
  def teardown = setup

  def test_defaults_and_platform_key_codes
    assert_equal 'step_down',K.action_for(219,mac:false)
    assert_equal 'step_up',K.action_for(93,mac:true)
    assert_nil K.action_for(85,mac:false)
    assert_nil K.action_for(37,mac:false)
  end

  def test_saves_restores_and_disables_actions
    bindings = {'step_down'=>'J','step_up'=>'U','step_height'=>''}
    K.save(bindings)
    assert_equal bindings,K.saved
    assert_equal 'step_down',K.action_for(74,mac:true)
    assert_equal 'step_up',K.action_for(85,mac:false)
    assert_nil K.action_for(219,mac:false)
    assert_equal 'Unassigned',K.label('step_height')
    K.save(K.defaults)
    assert_equal K.defaults,K.saved
  end

  def test_blocks_reserved_keys_duplicates_and_registered_conflicts
    %w[L Tab ArrowUp 1 - . Enter Escape Backspace].each do |key|
      assert_raises(RuntimeError) { K.save(K.defaults.merge('step_up'=>key)) }
    end
    assert_raises(RuntimeError) { K.save(K.defaults.merge('step_up'=>'[')) }
    Sketchup.shortcut_entries = ["U\tExtensions/Other Tool", "Ctrl+J\tEdit/Other"]
    assert_match(/Other Tool/,assert_raises(RuntimeError) { K.save(K.defaults.merge('step_up'=>'U')) }.message)
    K.save(K.defaults.merge('step_up'=>'J'))
    assert_equal 'J',K.label('step_up')
  end

  def test_conflicts_added_after_saving_disable_only_the_conflicting_action
    K.save(K.defaults.merge('step_up'=>'U'))
    Sketchup.shortcut_entries = ["U\tExtensions/Other"]
    assert_nil K.action_for(85,mac:false)
    assert_equal 'step_down',K.action_for(219,mac:false)
    assert_equal 'U',K.saved['step_up']
    Sketchup.stub(:get_shortcuts,-> { raise 'unavailable' }) do
      assert_nil K.action_for(219,mac:false)
      assert_raises(RuntimeError) { K.save(K.defaults) }
    end
  end

  def test_invalid_saved_data_is_safe_and_html_escapes_command_names
    Sketchup.write_default('Basegrid',K::PREFERENCE_KEY,'invalid')
    assert_equal K.defaults,K.saved
    Sketchup.write_default('Basegrid',K::PREFERENCE_KEY,'{"step_up":7}')
    assert_nil K.action_for(7,mac:false)
    Sketchup.shortcut_entries = ["U\t</script><script>alert(1)</script>"]
    refute_includes K.html,'</script><script>alert'
    assert_raises(RuntimeError) { K.save({}) }
  end
end
