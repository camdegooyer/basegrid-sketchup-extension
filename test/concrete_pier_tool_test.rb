# frozen_string_literal: true
require "minitest/autorun"
require "ostruct"
require_relative "../basegrid/concrete_pier_tool"

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

class ConcretePierToolTest < Minitest::Test
  class View
    attr_reader :locks, :invalidations
    def initialize
      @locks = []
      @invalidations = 0
    end
    def lock_inference(*args) = @locks << args
    def invalidate = @invalidations += 1
  end

  def setup
    @library = OpenStruct.new(concrete_materials: [{ "id" => "c25", "name" => "25 MPa", "material_type_id" => "concrete" }],
      material_types: [{ "id" => "bar", "name" => "Reo Bar Processed", "uom" => "m" }],
      materials: [{ "id" => "n20", "name" => "N20", "material_type_id" => "bar", "dimensions_mm" => { "diameter_mm" => 20 } }])
    @tool = Basegrid::ConcretePierTool.new(library: @library)
    UI.timers = []
    Sketchup.defaults = {}
  end

  def test_reference_defaults_and_material_diameter
    settings, materials = @tool.resolve("add_bar" => true, "bar_material" => "n20", "concrete_material" => "c25")
    assert_equal [450,600], settings.values_at("pier_diameter_mm", "pier_depth_mm")
    assert_equal 20, settings["bar_diameter_mm"]
    assert_equal "c25", materials["concrete"]["id"]
    assert_equal "n20", materials["bar"]["id"]
  end

  def test_rejects_invalid_inputs_before_geometry
    [nil, [], { "pier_diameter_mm" => 0 }, { "pier_depth_mm" => -1 }, { "pier_depth_mm" => Float::INFINITY },
     { "add_bar" => "yes" }, { "top_crank_dir" => "other" }, { "concrete_material" => "removed" },
     { "add_bar" => true, "bar_material" => "removed" }, { "add_bar" => true, "bar_diameter_mm" => 0 },
     { "add_bar" => true, "bar_above_mm" => 0, "bar_below_mm" => 0 }].each do |input|
      assert_raises(RuntimeError) { @tool.resolve(input) }
    end
  end

  def test_disabled_bar_does_not_require_archived_material
    settings, materials = @tool.resolve("add_bar" => false, "bar_material" => "removed")
    refute settings["add_bar"]
    assert_nil materials["bar"]
  end

  def test_bar_cranks_and_zero_crank_deduplication
    settings, = @tool.resolve({})
    assert_equal [[0,0,-500], [0,0,300]], @tool.bar_points(settings)
    settings.merge!("bottom_crank_mm" => 150, "bottom_crank_dir" => "out", "top_crank_mm" => 100)
    assert_equal [[-150,0,-500], [0,0,-500], [0,0,300], [100,0,300]], @tool.bar_points(settings)
  end

  def test_preferences_and_html_escape
    ["null", "[1]", "{bad"].each do |value|
      Sketchup.write_default("Basegrid", "pier_settings", value)
      assert_equal({}, @tool.saved_settings)
    end
    Sketchup.write_default("Basegrid", "pier_settings", '{"pier_depth_mm":900}')
    assert_equal 900, @tool.saved_settings["pier_depth_mm"]
    html = @tool.settings_html({ "bar_material" => "</script><script>alert(1)</script>" }, editing: true)
    refute_includes html, "</script><script>alert"
    assert_includes html, "Update pier"
    assert_includes html, "input.disabled=!el('add_bar').checked"
    refute_match(/<input[^>]+id=["']bar_diameter_mm["']/, html)
    assert_match(/<input[^>]+id=["']pier_diameter_mm["']/, html)
    refute_includes html, "el('bar_diameter_mm')"
  end

  def test_bar_material_requires_diameter_metadata
    @library.materials.first.delete("dimensions_mm")
    error = assert_raises(RuntimeError) { @tool.resolve("add_bar" => true, "bar_material" => "n20") }
    assert_includes error.message, "diameter metadata"
  end

  def test_synced_bar_diameter_key
    @library.materials.first["dimensions_mm"] = { "diameter" => 24 }
    settings, = @tool.resolve("add_bar" => true, "bar_material" => "n20")
    assert_equal 24, settings["bar_diameter_mm"]
  end

  def placement
    model = OpenStruct.new(active_path: nil, selections: [])
    model.define_singleton_method(:select_tool) { |value| selections << value }
    owner = Object.new
    owner.define_singleton_method(:build) { |*args, **kwargs| (@builds ||= []) << [args,kwargs] }
    owner.define_singleton_method(:builds) { @builds || [] }
    tool = Basegrid::ConcretePierTool::PlacementTool.new(owner, model, Basegrid::ConcretePierTool::DEFAULTS)
    Sketchup.active_model = model
    tool.activate
    [tool, model, owner, View.new]
  end

  def test_placement_is_deferred_and_duplicate_clicks_are_ignored
    tool, _model, owner, view = placement
    tool.place(:transform, view)
    tool.place(:transform, view)
    assert_empty owner.builds
    assert_equal 1, UI.timers.length
    UI.timers.shift.call
    assert_equal 1, owner.builds.length
    tool.place(:next_transform, view)
    UI.timers.shift.call
    assert_equal 2, owner.builds.length
  end

  def test_context_change_or_deactivation_blocks_pending_placement
    tool, model, owner, view = placement
    tool.place(:transform, view)
    model.active_path = [:changed]
    UI.timers.shift.call
    assert_empty owner.builds
    tool, _model, owner, view = placement
    tool.place(:transform, view)
    tool.deactivate(view)
    UI.timers.shift.call
    assert_empty owner.builds
  end

  def test_cancel_during_pending_placement_blocks_build
    tool, model, owner, view = placement
    tool.place(:transform, view)
    tool.onCancel(0, view)
    UI.timers.shift.call until UI.timers.empty?
    assert_empty owner.builds
    assert_equal [nil], model.selections
  end

  def test_cancelling_direction_returns_to_placement_without_creating_a_pier
    tool, model, owner, view = placement
    tool.instance_variable_set(:@center, :point)
    tool.onCancel(0, view)
    assert_nil tool.instance_variable_get(:@center)
    assert_empty owner.builds
    assert_empty model.selections
  end

  def test_failed_build_allows_retry
    tool, _model, owner, view = placement
    owner.define_singleton_method(:build) { |*args, **kwargs| raise "test failure" }
    tool.place(:transform, view)
    UI.timers.shift.call
    assert_includes Sketchup.status_text, "test failure"
    refute tool.instance_variable_get(:@busy)
    tool.place(:transform, view)
    assert_equal 1, UI.timers.length
  end

  def test_geometry_failure_aborts_the_single_operation
    entities = Object.new
    def entities.add_group = raise("geometry failure")
    model = OpenStruct.new(active_path: nil, active_entities: entities, operations: [])
    def model.start_operation(name, *) = operations << [:start, name]
    def model.abort_operation = operations << [:abort]
    frame = Object.new
    def frame.*(other) = other
    model.edit_transform = frame
    Sketchup.active_model = model
    error = assert_raises(RuntimeError) { @tool.build(model, {}, transform: :unchanged) }
    assert_equal "geometry failure", error.message
    assert_equal [[:start, "Create Concrete Pier"], [:abort]], model.operations
  end

  def test_nested_piers_are_unique_editable_roots_without_nested_operations
    face = OpenStruct.new(normal: OpenStruct.new(z: 1))
    def face.pushpull(_depth); end
    make_entities = nil
    make_entities = lambda do
      entities = []
      entities.define_singleton_method(:add_group) do
        group = OpenStruct.new(entities: make_entities.call, attributes: {})
        group.define_singleton_method(:set_attribute) { |dict,key,value| attributes[[dict,key]]=value }
        entities << group
        group
      end
      entities.define_singleton_method(:add_circle) { |*_| [] }
      entities.define_singleton_method(:add_face) { |*_| face }
      entities
    end
    model = OpenStruct.new(layers: [0])
    model.define_singleton_method(:start_operation) { |*_| raise "Nested transaction" }
    vector = Object.new
    vector.define_singleton_method(:cross) { |_| vector }
    vector.define_singleton_method(:dot) { |_| 1 }
    world = OpenStruct.new(xaxis: vector,yaxis: vector,zaxis: vector)
    settings,materials = @tool.resolve("pier_depth_mm"=>900)
    parent = make_entities.call
    bars = @tool.instance_variable_get(:@bars)
    Object.const_set(:Geom,Module.new) unless defined?(Geom)
    original = Geom.const_get(:Vector3d) if Geom.const_defined?(:Vector3d,false)
    Geom.send(:remove_const,:Vector3d) if original
    Geom.const_set(:Vector3d,Class.new { def initialize(*); end })
    @tool.stub(:decorate,->(*) {}) do
      bars.stub(:point,->(p) { p }) do
        first = @tool.build_in(model,parent,settings,materials,transform: :first,world: world)
        second = @tool.build_in(model,parent,settings,materials,transform: :second,world: world)
        refute_same first,second
        assert_equal "concrete.pier",first.attributes[["Basegrid","tool_id"]]
        assert_equal 900,JSON.parse(first.attributes[["Basegrid","parameters_json"]])["pier_depth_mm"]
        assert_equal :second,second.transformation
      end
    end
  ensure
    Geom.send(:remove_const,:Vector3d) if defined?(Geom) && Geom.const_defined?(:Vector3d,false)
    Geom.const_set(:Vector3d,original) if original
  end

  def test_locked_edit_is_rejected_before_starting_an_operation
    existing = Object.new
    def existing.valid? = true
    def existing.locked? = true
    model = OpenStruct.new(active_path: nil)
    Sketchup.active_model = model
    error = assert_raises(RuntimeError) { @tool.build(model, {}, transform: :unchanged, replace: existing) }
    assert_includes error.message, "locked"
  end
end
