# frozen_string_literal: true
require_relative "drawing_api_test"

class FootingReplacementTest < Minitest::Test
  def test_replacement_commits_only_after_successful_generation
    events, original, tool, model, plan = fixture
    Basegrid::StripFootingGeometry.stub(:plan,plan) do
      tool.build(model,[],{}, {},replace: original)
    end
    assert_equal ["Edit Strip Footing", :erase, :commit],events
  end

  def test_failed_generation_aborts_without_erasing_original
    events, original, tool, model, plan = fixture
    tool.define_singleton_method(:plain_group) { |*_| raise "geometry failed" }
    Basegrid::StripFootingGeometry.stub(:plan,plan) do
      error = assert_raises(RuntimeError) { tool.build(model,[],{}, {},replace: original) }
      assert_equal "geometry failed",error.message
    end
    assert_equal ["Edit Strip Footing", :abort],events
  end

  def fixture
    events = []
    original = BasegridAPITest::GeneratedGroup.new(Basegrid::StripFootingTool::TOOL_ID)
    original.define_singleton_method(:name) { "Existing footing" }
    original.define_singleton_method(:layer) { 0 }
    original.define_singleton_method(:erase!) { events << :erase }
    root = OpenStruct.new(entities: [])
    root.define_singleton_method(:set_attribute) { |*_| }
    entities = [original]
    entities.define_singleton_method(:add_group) { root }
    selection = []
    selection.define_singleton_method(:add) { |group| push(group) }
    model = OpenStruct.new(active_entities: entities, active_path: [], layers: [0],
      edit_transform: BasegridAPITest::DrawingFrame.new, selection: selection)
    model.define_singleton_method(:start_operation) { |name,*_| events << name }
    model.define_singleton_method(:commit_operation) { events << :commit }
    model.define_singleton_method(:abort_operation) { events << :abort }
    Sketchup.active_model = model
    tool = Basegrid::StripFootingTool.new(library: Object.new)
    tool.define_singleton_method(:validate_materials) { |_| {} }
    tool.define_singleton_method(:resolved_settings) { |*_| {} }
    tool.define_singleton_method(:plain_group) { |*_| root }
    plan = {settings: {},warnings: [],concrete_parts: [],volume_m3: 0,mesh_layers: [],z_bars: [],piers: []}
    [events,original,tool,model,plan]
  end

  def test_failed_slab_boundary_copy_aborts_without_erasing_original
    events, original, _, model, = fixture
    original.tool_id = Basegrid::ConcreteSlabTool::TOOL_ID
    tool = Basegrid::ConcreteSlabTool.new(library: Object.new)
    tool.define_singleton_method(:validate_face!) { |*_| }
    tool.define_singleton_method(:copy_face) { |*_| raise "invalid boundary" }
    error = assert_raises(RuntimeError) { tool.build(model,Object.new,150,{},[],replace: original) }
    assert_equal "invalid boundary",error.message
    assert_equal ["Edit Concrete Slab", :abort],events
  end
end
