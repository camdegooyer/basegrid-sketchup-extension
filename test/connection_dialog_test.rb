# frozen_string_literal: true
require "minitest/autorun"
require_relative "../basegrid/connection_dialog"

class ConnectionDialogTest < Minitest::Test
  class Surface
    attr_reader :scripts
    def initialize = @scripts = []
    def execute_script(script) = @scripts << script
  end

  def test_live_details_are_rendered_only_when_changed_and_safely_encoded
    value = "Connecting"
    dialog = Basegrid::ConnectionDialog.new(status_provider: -> { { rows: [{ label: "Cloud", value: value }] } }) { |_| }
    surface = Surface.new
    dialog.instance_variable_set(:@dialog,surface)
    dialog.update(title: "Connections",message: "Status")
    assert_includes surface.scripts.last,"Connecting"
    dialog.send(:render)
    assert_equal 1,surface.scripts.length
    value = "</script><script>example</script>"
    dialog.send(:render)
    assert_equal 2,surface.scripts.length
    refute_includes surface.scripts.last,"</script>"
    dialog.instance_variable_set(:@dialog,nil)
    dialog.send(:render)
    assert_equal 2,surface.scripts.length
  end
end
