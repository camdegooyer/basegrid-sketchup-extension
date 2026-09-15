# frozen_string_literal: true
require "minitest/autorun"
require "ostruct"
require_relative "../basegrid/starter_bar_tool"

module Sketchup
  InputPoint = Struct.new(:position) do
    def valid? = !position.nil?
  end unless const_defined?(:InputPoint)
  class << self
    attr_accessor :active_model, :defaults, :status_text
    def read_default(section, key, fallback) = (defaults || {}).fetch([section,key], fallback)
    def write_default(section, key, value) = (self.defaults ||= {})[[section,key]] = value
    def set_status_text(text) = self.status_text = text
  end
end

module UI
  class << self
    attr_accessor :timers
    def start_timer(_delay, _repeat, &block)
      (self.timers ||= []) << block
      timers.length
    end
  end
end

class StarterBarToolTest < Minitest::Test
  Point = Struct.new(:coordinates) do
    def to_a = coordinates
    def transform(_transform) = self
  end
  Vertex = Struct.new(:position)
  Edge = Struct.new(:start, :end) do
    def other_vertex(vertex) = vertex == start ? self.end : start
  end
  View = Struct.new(:tooltip) do
    def invalidate; end
  end

  def setup
    types = [{ "id" => "bars", "name" => "Reo Bar Processed", "uom" => "m" },
             { "id" => "chairs", "name" => "Bar Chairs", "uom" => "ea" },
             { "id" => "caps", "name" => "Reo Bar Safety Caps", "uom" => "each" },
             { "id" => "inactive", "name" => "Reo Bar Processed", "uom" => "m", "status" => "inactive" },
             { "id" => "bad", "name" => "Reo Bar Processed", "uom" => "m3" }]
    materials = [{ "id" => "n16", "name" => "N16", "material_type_id" => "bars", "dimensions_mm" => { "diameter_mm" => 16 } },
                 { "id" => "chair", "name" => "Chair", "material_type_id" => "chairs" },
                 { "id" => "cap", "name" => "Cap", "material_type_id" => "caps" },
                 { "id" => "gone", "name" => "Old N12", "material_type_id" => "bars", "status" => "inactive" },
                 { "id" => "wrong", "name" => "Wrong", "material_type_id" => "bad" },
                 { "id" => "old", "name" => "Old", "material_type_id" => "inactive" }]
    @tool = Basegrid::StarterBarTool.new(library: OpenStruct.new(material_types: types, materials: materials))
    UI.timers = []
    Sketchup.defaults = {}
  end

  def test_material_types_status_and_units_are_filtered
    assert_equal ["n16"], @tool.materials_for("bar").map { |m| m["id"] }
    assert_equal ["chair"], @tool.materials_for("chair").map { |m| m["id"] }
    assert_equal ["cap"], @tool.materials_for("cap").map { |m| m["id"] }
    settings, bindings = @tool.resolve("bar_material" => "n16")
    assert_equal 16, settings["diameter_mm"]
    assert_equal "n16", bindings["bar"]["id"]
    assert_raises(RuntimeError) { @tool.resolve("bar_material" => "gone") }
    assert_raises(RuntimeError) { @tool.resolve("chair_material" => "n16") }
  end

  def test_unassigned_materials_and_corrupt_preferences
    settings, bindings = @tool.resolve({})
    assert_equal 12, settings["diameter_mm"]
    assert bindings.values.all?(&:nil?)
    ["{bad", "null", "[]"].each do |value|
      Sketchup.write_default("Basegrid", "starter_bar_settings", value)
      assert_equal({}, @tool.saved_settings)
    end
    Sketchup.write_default("Basegrid", "starter_bar_settings", '{"spacing_mm":300}')
    assert_equal 300, @tool.saved_settings["spacing_mm"]
  end

  def test_path_ordering_is_deterministic_and_rejects_branches_and_disconnected_edges
    vertices = 4.times.map { |i| Vertex.new(Point.new([i*10,0,0])) }
    edges = vertices.each_cons(2).map { |a,b| Edge.new(a,b) }
    points = @tool.ordered_points(edges.reverse, nil)
    assert_equal [0,254,508,762], points.map(&:first)
    extra = Vertex.new(Point.new([10,10,0]))
    assert_raises(RuntimeError) { @tool.ordered_points(edges + [Edge.new(vertices[1],extra)], nil) }
    assert_raises(RuntimeError) { @tool.ordered_points([edges.first, edges.last], nil) }
  end

  def fixture
    owner = Object.new
    owner.define_singleton_method(:build) { |*args, **kwargs| (@builds ||= []) << [args,kwargs] }
    owner.define_singleton_method(:builds) { @builds || [] }
    model = OpenStruct.new(active_path: nil, selected_tools: [])
    view = View.new
    tool = Basegrid::StarterBarTool::PlacementTool.new(owner, model, [[0,0,0], [1200,0,0]], {})
    model.define_singleton_method(:select_tool) { |value| selected_tools << value; tool.deactivate(view) }
    Sketchup.active_model = model
    tool.activate
    [tool, model, view, owner]
  end

  def test_finish_is_deferred_and_duplicate_clicks_do_not_build_twice
    tool, model, _view, owner = fixture
    tool.finish
    tool.finish
    assert_nil tool.onKeyDown(9, 1, 0, View.new)
    assert_equal 0, tool.instance_variable_get(:@anchor)
    assert_equal 1, UI.timers.length
    assert_empty owner.builds
    UI.timers.shift.call
    assert_equal 1, owner.builds.length
    assert_empty model.selected_tools
    refute tool.onKeyDown(32,1,0,View.new)
    tool.finish
    assert_empty UI.timers
    tool.update_preview
    tool.finish
    UI.timers.shift.call
    assert_equal 2,owner.builds.length
  end

  def test_deactivation_or_changed_context_cancels_pending_build
    tool, _model, view, owner = fixture
    tool.finish
    tool.deactivate(view)
    UI.timers.shift.call
    assert_empty owner.builds
    tool, model, _view, owner = fixture
    tool.finish
    model.active_path = [:another_group]
    UI.timers.shift.call
    assert_empty owner.builds
  end

  def test_tab_cycles_endpoints_and_native_keys_are_unclaimed
    tool, _model, view, _owner = fixture
    assert tool.onKeyDown(9, 1, 0, view)
    assert_equal 1200, tool.instance_variable_get(:@anchor)
    tool.onKeyDown(9, 2, 0, view)
    assert_equal 1200, tool.instance_variable_get(:@anchor)
    tool.onKeyDown(9, 1, 0, view)
    assert_equal 0, tool.instance_variable_get(:@anchor)
    [16,37,38,39,40,8,127,85,68].each { |key| assert_nil tool.onKeyDown(key, 1, 0, view) }
  end

  def test_shared_dialog_contains_all_modes_and_escapes_saved_text
    html = @tool.settings_html({ "bar_material" => "</script><script>alert(1)</script>" })
    %w[straight tapered pins step_z].each { |mode| assert_includes html, "value=\"#{mode}\"" }
    assert_includes html, "input.disabled=!!input.closest('[hidden]')"
    refute_includes html, "</script><script>alert"
    refute_match(/<input[^>]+id=["']diameter_mm["']/, html)
    refute_includes html, "el('diameter_mm')"
  end

  def test_selected_material_requires_diameter_metadata
    library = OpenStruct.new(material_types: [{ "id" => "bars", "name" => "Reo Bar Processed", "uom" => "m" }],
                             materials: [{ "id" => "missing", "name" => "Incomplete bar", "material_type_id" => "bars" }])
    tool = Basegrid::StarterBarTool.new(library: library)
    error = assert_raises(RuntimeError) { tool.resolve("bar_material" => "missing") }
    assert_includes error.message, "diameter metadata"
  end

  def test_synced_bar_diameter_key
    library = OpenStruct.new(material_types: [{ "id" => "bars", "name" => "Reo Bar Processed", "uom" => "m" }],
                             materials: [{ "id" => "n20", "name" => "N20", "material_type_id" => "bars", "dimensions_mm" => { "diameter" => 20 } }])
    settings, = Basegrid::StarterBarTool.new(library: library).resolve("bar_material" => "n20")
    assert_equal 20, settings["diameter_mm"]
  end
end
