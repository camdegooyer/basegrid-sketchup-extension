# frozen_string_literal: true
require "minitest/autorun"
require "ostruct"
require_relative "../basegrid/strip_footing_tool"

module Sketchup
  InputPoint = Struct.new(:position) do
    def valid? = !position.nil?
    def pick(*) = true
    def tooltip = "Endpoint"
  end
  class << self
    attr_accessor :active_model, :status_text, :defaults

    def read_default(section, key, fallback) = (defaults || {}).fetch([section,key], fallback)
    def write_default(section, key, value) = (self.defaults ||= {})[[section,key]] = value

    def set_status_text(text) = self.status_text = text
    def platform = :platform_win
  end
end

module UI
  class << self
    attr_accessor :step_value, :last_message, :last_title, :timers
    def start_timer(_delay, _repeat, &block)
      (self.timers ||= []) << block
      timers.length
    end
    def inputbox(_labels, _defaults, title)
      self.last_title = title
      step_value
    end
    def messagebox(message) = self.last_message = message
  end
end

class StripFootingToolTest < Minitest::Test
  class DrawingView
    attr_accessor :tooltip
    attr_reader :locks
    def initialize = @locks = []
    def lock_inference(*points) = @locks << points
    def invalidate; end
  end

  def draw_tool
    tool = Basegrid::StripFootingTool::DrawTool.new(@tool, @tool.resolved_settings({}, {}), {})
    def tool.to_point(point) = point
    tool
  end

  def length_text(mm)
    length = Struct.new(:to_mm).new(mm)
    Struct.new(:to_l).new(length)
  end

  def test_backward_delete_undoes_points_on_both_platforms_and_keeps_drawing
    { platform_win: 8, platform_osx: 127 }.each do |platform, key|
      Sketchup.stub(:platform, platform) do
        tool, view = draw_tool, DrawingView.new
        tool.add_point([0,0,0], view)
        tool.add_point([3000,4000,0], view)
        tool.instance_variable_set(:@hover, [6000,8000,0])
        assert tool.onKeyDown(key, 1, 0, view)
        assert_equal [[[0,0,0]]], tool.instance_variable_get(:@paths)
        assert_nil tool.instance_variable_get(:@hover)
        assert_empty view.locks.last
        tool.onKeyDown(key, 2, 0, view)
        assert_equal [[[0,0,0]]], tool.instance_variable_get(:@paths), "holding the key must not remove extra points"
        tool.onKeyDown(key, 1, 0, view)
        tool.onKeyDown(key, 1, 0, view)
        assert_equal [[]], tool.instance_variable_get(:@paths)
        tool.add_point([20,30,40], view)
        assert_equal [[[20,30,40]]], tool.instance_variable_get(:@paths)
      end
    end
  end

  def completion_fixture(&build)
    view = DrawingView.new
    builder = Object.new
    builder.define_singleton_method(:build, &build)
    tool = Basegrid::StripFootingTool::DrawTool.new(builder, @tool.resolved_settings({}, {}), {})
    model = OpenStruct.new(active_path: nil, selected_tools: [])
    model.define_singleton_method(:select_tool) do |value|
      selected_tools << value
      tool.deactivate(view)
    end
    Sketchup.active_model = model
    tool.activate
    tool.add_point([0,0,0], view)
    tool.add_point([3000,0,0], view)
    UI.timers = []
    [tool, model, view]
  end

  def test_finish_is_deferred_once_and_never_opens_a_modal_after_retiring_tool
    builds = 0
    tool, model, view = completion_fixture do |*|
      builds += 1
      tool.onReturn(view)
      tool.draw(Object.new) # No native preview calls during construction.
      { warnings: ["Connections are not detailed."] }
    end
    UI.stub(:messagebox, ->(*) { flunk "Completion must not open a modal dialog" }) do
      assert_nil tool.onReturn(view)
      tool.onReturn(view)
      assert_equal 0, builds
      assert_equal 1, UI.timers.length
      assert_empty model.selected_tools
      UI.timers.first.call
    end
    assert_equal 1, builds
    assert_empty model.selected_tools
    assert_includes Sketchup.status_text, "Connections are not detailed"
    assert_equal [[]],tool.instance_variable_get(:@paths)
    refute tool.onKeyDown(32,1,0,view)
    tool.add_point([100,100,0],view)
    tool.add_point([3100,100,0],view)
    tool.onReturn(view)
    UI.timers.last.call
    assert_equal 2,builds
    tool.deactivate(view)
    tool.draw(Object.new) # A stale paint event must not access the retired view.
  end

  def test_deferred_finish_does_not_build_after_tool_is_deactivated
    tool, model, view = completion_fixture { |*| flunk "Inactive tool must not build" }
    tool.onReturn(view)
    tool.deactivate(view)
    UI.timers.first.call
    assert_empty model.selected_tools
  end

  def test_failed_deferred_build_keeps_tool_active_and_allows_retry
    builds = 0
    tool, model, view = completion_fixture do |*|
      builds += 1
      raise "Test failure" if builds == 1
      { warnings: [] }
    end
    tool.onReturn(view)
    UI.timers.last.call
    assert_empty model.selected_tools
    assert_includes Sketchup.status_text, "Test failure"
    tool.onReturn(view)
    UI.timers.last.call
    assert_equal 2, builds
    assert_empty model.selected_tools
  end

  def test_backward_delete_edits_measurements_until_length_is_committed
    tool, view = draw_tool, DrawingView.new
    tool.add_point([0,0,0], view)
    tool.instance_variable_set(:@hover, [3000,4000,0])
    refute tool.onKeyDown(53, 1, 0, view)
    refute tool.onKeyDown(8, 1, 0, view)
    assert_equal [[[0,0,0]]], tool.instance_variable_get(:@paths)
    tool.onUserText(length_text(5000), view)
    assert tool.onKeyDown(8, 1, 0, view)
    assert_equal [[[0,0,0]]], tool.instance_variable_get(:@paths)
  end

  def test_backward_delete_removes_step_start_and_restores_previous_level
    tool, view = draw_tool, DrawingView.new
    tool.add_point([0,0,0], view)
    tool.add_point([3000,0,0], view)
    UI.step_value = [200]
    tool.step(view, 1)
    tool.onKeyDown(8, 1, 0, view)
    assert_equal [[[0,0,0],[3000,0,0]]], tool.instance_variable_get(:@paths)
    assert_equal 0, tool.instance_variable_get(:@level)
    refute tool.onKeyDown(46, 1, 0, view), "Windows forward Delete stays native"
  end

  def test_diagonal_typed_length_and_repeat_entry
    tool, view = draw_tool, DrawingView.new
    tool.add_point([10,20,30], view)
    tool.instance_variable_set(:@hover, [310,420,30])
    tool.onUserText(length_text(1000), view)
    assert_equal [[10,20,30],[610,820,30]], tool.instance_variable_get(:@paths).last
    tool.onUserText(length_text(500), view)
    assert_equal [[10,20,30],[310,420,30]], tool.instance_variable_get(:@paths).last
    tool.onUserText(length_text(-10), view)
    assert_equal 2, tool.instance_variable_get(:@paths).last.length
    assert_includes Sketchup.status_text, "positive length"
  end

  def test_arrows_and_shift_lock_without_creating_steps
    tool, view = draw_tool, DrawingView.new
    tool.add_point([0,0,0], view)
    klass = Basegrid::StripFootingTool::DrawTool
    tool.onKeyDown(klass::RIGHT_KEY, 1, 0, view)
    assert_equal [1,0,0], tool.instance_variable_get(:@lock_direction)
    tool.onKeyDown(klass::RIGHT_KEY, 1, 0, view)
    assert_nil tool.instance_variable_get(:@lock_direction)
    tool.instance_variable_set(:@input, Sketchup::InputPoint.new([300,400,0]))
    tool.instance_variable_set(:@hover, [300,400,0])
    tool.onKeyDown(klass::SHIFT_KEY, 1, 0, view)
    assert_equal [300,400,0], tool.instance_variable_get(:@lock_direction)
    tool.onKeyUp(klass::SHIFT_KEY, 1, 0, view)
    assert_nil tool.instance_variable_get(:@lock_direction)
    tool.onKeyDown(klass::UP_KEY, 1, 0, view)
    assert_equal [0,0,1], tool.instance_variable_get(:@lock_direction)
    assert_equal [[[0,0,0]]], tool.instance_variable_get(:@paths)
    tool.deactivate(view)
    assert_empty view.locks.last
  end

  def test_step_keys_are_brackets_on_windows_and_mac_and_leave_letters_available
    tool, view = draw_tool, DrawingView.new
    steps = []
    tool.define_singleton_method(:step) { |_, direction| steps << direction }
    [[false,219,221],[true,91,93]].each do |mac,down,up|
      tool.define_singleton_method(:mac_keyboard?) { mac }
      steps.clear
      tool.onKeyDown(up, 1, 0, view)
      tool.onKeyDown(down, 1, 0, view)
      tool.onKeyDown(up, 2, 0, view)
      assert_equal [1,-1], steps
      tool.instance_variable_set(:@shift_held,true)
      refute tool.onKeyDown(up,1,0,view)
      assert_equal [1,-1],steps
      tool.instance_variable_set(:@shift_held,false)
      %w[U D L R C A M P Q S F T O H Z B E].each do |key|
        refute tool.onKeyDown(key.ord, 1, 0, view)
      end
    end
  end

  def test_material_dimensions_and_fixed_cover
    bindings = {
      "mesh" => { "dimensions_mm" => { "bars" => 4, "width" => 300, "diameter" => 11, "cross_diameter_mm" => 6, "cross_spacing_mm" => 250 } },
      "chairs" => { "dimensions_mm" => { "width" => 20 } },
      "spacers" => { "dimensions_mm" => { "diameter" => 5 } }
    }
    settings = @tool.resolved_settings({ "cover_mm" => 15 }, bindings)
    assert_equal [4,100,11,6,250,20,6,50], settings.values_at("bar_count","bar_spacing_mm","bar_diameter_mm","cross_diameter_mm","cross_spacing_mm","support_width_mm","spacer_diameter_mm","cover_mm")
  end

  def test_custom_shortcuts_dispatch_and_update_prompts
    preferences = Basegrid::KeyboardShortcuts
    previous = preferences.saved
    preferences.save('step_up'=>'U','step_down'=>'J','step_height'=>'N')
    tool,view = draw_tool,DrawingView.new
    calls = []
    tool.define_singleton_method(:step) { |_,direction| calls << direction }
    tool.define_singleton_method(:change_step_height) { |_| calls << :height }
    [85,74,78].each { |key| assert tool.onKeyDown(key,1,0,view) }
    assert_equal [1,-1,:height],calls
    assert_includes Sketchup.status_text,'J down / U up'
    refute tool.onKeyDown(219,1,0,view)
  ensure
    preferences.save(previous) if previous
  end

  def test_selected_350_bogar_uses_nominal_height_in_a_450_footing
    bindings = {
      "mesh" => { "dimensions_mm" => { "bars" => 3, "width" => 200, "diameter" => 11 } },
      "spacers" => { "dimensions_mm" => { "height" => 350, "diameter" => 11 } }
    }
    settings = @tool.resolved_settings({ "depth_mm" => 450 }, bindings)
    assert_equal 350, settings["spacer_height_mm"]
    assert_equal 6, settings["spacer_diameter_mm"], "mesh compatibility gauge is not spacer thickness"
    plan = Basegrid::StripFootingGeometry.plan([[[0,0,0],[3000,0,0]]], settings)
    assert plan[:spacers].all? { |spacer| spacer[:height_mm] == 350 }
    assert_equal(-400, plan[:spacers].first[:origin][2])
    assert_equal(-50, plan[:spacers].first[:bars].first[:b][2])
    assert_raises(RuntimeError) { Basegrid::StripFootingGeometry.plan([[[0,0,0],[3000,0,0]]], settings.merge("spacer_height_mm" => 400)) }
  end

  def test_steps_raise_and_lower_without_changing_xy
    tool, view = draw_tool, DrawingView.new
    tool.add_point([0,0,0], view)
    tool.add_point([3000,4000,0], view)
    UI.step_value = [200]
    tool.step(view, 1)
    assert_equal [3000,4000,200], tool.instance_variable_get(:@paths).last.last
    tool.add_point([6000,8000,200], view)
    tool.step(view, -1)
    assert_equal [6000,8000,0], tool.instance_variable_get(:@paths).last.last
    tool.add_point([9000,12000,0], view)
    UI.step_value = [450]
    tool.change_step_height(view)
    assert_equal 3, tool.instance_variable_get(:@paths).length
    assert_includes UI.last_message, "less than footing depth"
    UI.step_value = nil
    tool.change_step_height(view)
    assert_equal 3, tool.instance_variable_get(:@paths).length
  end

  def test_step_height_can_be_set_before_drawing_and_changed_for_pending_or_future_steps
    settings = @tool.resolved_settings({ "step_height_mm" => 150 }, {})
    tool = Basegrid::StripFootingTool::DrawTool.new(@tool, settings, {})
    view = DrawingView.new
    tool.add_point([0,0,0], view)
    tool.add_point([3000,0,0], view)
    UI.stub(:inputbox, ->(*) { flunk "Brackets must not open a dialog" }) do
      tool.onKeyDown(221, 1, 0, view)
    end
    assert_equal [3000,0,150], tool.instance_variable_get(:@paths).last.first
    assert tool.pending_step?
    UI.step_value = [250]
    tool.change_step_height(view)
    assert_equal [3000,0,250], tool.instance_variable_get(:@paths).last.first
    assert_equal 250, tool.instance_variable_get(:@level)
    tool.add_point([6000,0,250], view)
    refute tool.pending_step?
    UI.step_value = [100]
    tool.change_step_height(view)
    assert_equal [3000,0,250], tool.instance_variable_get(:@paths).last.first
    tool.onKeyDown(219, 1, 0, view)
    assert_equal [6000,0,150], tool.instance_variable_get(:@paths).last.first
    assert_includes Sketchup.status_text, "100.0 mm"
  end

  def test_invalid_initial_step_height_is_rejected
    [0, -20, 450, Float::INFINITY].each do |height|
      assert_raises(RuntimeError) do
        Basegrid::StripFootingTool::DrawTool.new(@tool, @tool.resolved_settings({}, {}).merge("step_height_mm" => height), {})
      end
    end
  end

  def test_dialog_only_exposes_dimensions_layers_and_materials
    html = @tool.send(:settings_html, { "settings" => { "alignment" => "right_edge", "cover_mm" => 15 } })
    payload = JSON.parse(html.match(/const data=(.*?); const fields/)[1])
    assert_equal Basegrid::StripFootingTool::INPUT_KEYS, payload["defaults"].keys
    assert_equal %w[concrete mesh chairs spacers z_bars pier_bar pier_concrete], payload["materials"].keys
    assert_equal "Supports", payload["material_labels"]["chairs"]
    assert_equal "Bogar spacers", payload["material_labels"]["spacers"]
    assert_equal false, payload["defaults"]["include_step_z_bars"]
    assert_equal 200, payload["defaults"]["step_z_threshold_mm"]
    assert_includes html, "input.type='checkbox'"
    assert_includes html, "input.checked"
    refute payload["choices"].key?("alignment")
    tool = Basegrid::StripFootingTool::DrawTool.new(@tool, @tool.resolved_settings({ "alignment" => "right_edge", "vertical_reference" => "bottom" }, {}), {})
    assert_equal "left edge top", tool.anchor_label
  end

  def test_z_bar_material_diameter_and_preferences
    material = {"dimensions_mm"=>{"diameter"=>16}}
    settings = @tool.resolved_settings({"include_step_z_bars"=>true,"step_z_threshold_mm"=>250}, {"z_bars"=>material})
    assert_equal 16,settings["step_z_diameter_mm"]
    @tool.remember_settings(settings,{"z_bars"=>"n16"})
    saved = @tool.saved_settings
    assert_equal true,saved["settings"]["include_step_z_bars"]
    assert_equal 250,saved["settings"]["step_z_threshold_mm"]
    assert_equal "n16",saved["materials"]["z_bars"]
    assert_raises(RuntimeError) { @tool.resolved_settings({}, {"z_bars"=>{"dimensions_mm"=>{}}}) }
  end

  def test_footing_pier_inputs_use_half_depth_and_footing_material
    settings = @tool.resolved_settings({"include_piers"=>true,"pier_add_bar"=>true,"depth_mm"=>600,"width_mm"=>500,"pier_depth_mm"=>1200},{})
    input = @tool.pier_input(settings,{"concrete"=>"c25","pier_bar"=>"n16"})
    assert_equal [1100,300,200],input.values_at("bar_below_mm","bar_above_mm","top_crank_mm")
    assert_equal "c25",input["concrete_material"]
    assert_equal "c32",@tool.pier_input(settings,{"concrete"=>"c25","pier_concrete"=>"c32"})["concrete_material"]
    assert_equal "",@tool.pier_input(settings,{"concrete"=>"c25","pier_concrete"=>""})["concrete_material"]
    assert_equal "n16",input["bar_material"]
    assert_equal true,input["add_bar"]
    @tool.remember_settings(settings,{"pier_bar"=>"n16"})
    saved = @tool.saved_settings
    assert_equal true,saved["settings"]["include_piers"]
    assert_equal "n16",saved["materials"]["pier_bar"]
  end

  def test_down_arrow_chooses_parallel_or_perpendicular_to_reference
    tool = draw_tool
    tool.instance_variable_set(:@reference_direction, [0.6,0.8])
    tool.instance_variable_set(:@hover, [300,400,0])
    assert_equal [0.6,0.8,0], tool.inferred_direction([0,0,0])
    tool.instance_variable_set(:@hover, [-400,300,0])
    assert_equal [-0.8,0.6,0], tool.inferred_direction([0,0,0])
  end

  def test_mouse_direction_is_free_until_an_axis_is_locked
    tool, view = draw_tool, DrawingView.new
    coordinate = Struct.new(:to_mm)
    position = Struct.new(:x,:y,:z).new(*[300,400,80].map { |v| coordinate.new(v) })
    tool.instance_variable_set(:@input, Sketchup::InputPoint.new(position))
    tool.add_point([0,0,0], view)
    tool.onMouseMove(0, 10, 10, view)
    assert_equal [300,400,0], tool.instance_variable_get(:@hover)
    tool.onKeyDown(Basegrid::StripFootingTool::DrawTool::RIGHT_KEY, 1, 0, view)
    tool.onMouseMove(0, 10, 10, view)
    assert_equal [300,0,0], tool.instance_variable_get(:@hover)
    tool.onKeyDown(Basegrid::StripFootingTool::DrawTool::RIGHT_KEY, 1, 0, view)
    tool.onMouseMove(0, 10, 10, view)
    assert_equal [300,400,0], tool.instance_variable_get(:@hover)
  end
  def setup
    Sketchup.defaults = {}
    @library = OpenStruct.new(
      concrete_materials: [{ "id" => "concrete" }],
      material_types: [{ "id" => "mesh_type", "name" => "Reo Trench Mesh" },
                       { "id" => "wrong", "name" => "Timber" }],
      materials: [{ "id" => "mesh", "name" => "Mesh", "material_type_id" => "mesh_type" },
                  { "id" => "retired", "name" => "Old", "status" => "retired", "material_type_id" => "mesh_type" },
                  { "id" => "wood", "name" => "Wood", "material_type_id" => "wrong" }])
    @tool = Basegrid::StripFootingTool.new(library: @library)
  end

  def test_material_types_filter_active_products_and_allow_unassigned
    assert_equal ["mesh"], @tool.materials_for("mesh").map { |m| m["id"] }
    assert_nil @tool.validate_materials({})["mesh"]
    assert_equal "mesh", @tool.validate_materials("mesh" => "mesh")["mesh"]["id"]
    assert_raises(RuntimeError) { @tool.validate_materials("mesh" => "wood") }
    assert_raises(RuntimeError) { @tool.validate_materials("mesh" => "retired") }
    assert_raises(RuntimeError) { @tool.validate_materials("other" => "mesh") }
  end

  def test_saved_inputs_restore_in_a_new_tool_without_persisting_anchor_or_product_dimensions
    settings = @tool.resolved_settings({ "width_mm" => 600, "depth_mm" => 500, "reinforcement" => "bottom", "step_height_mm" => 150, "alignment" => "right_edge" }, {})
    bindings = { "concrete" => "concrete", "mesh" => "mesh", "chairs" => "support", "spacers" => "" }
    @tool.remember_settings(settings, bindings)
    reopened = Basegrid::StripFootingTool.new(library: @library)
    saved = reopened.saved_settings
    assert_equal settings.slice(*Basegrid::StripFootingTool::INPUT_KEYS), saved["settings"]
    assert_equal bindings, saved["materials"]
    refute saved["settings"].key?("alignment")
    refute saved["settings"].key?("spacer_height_mm")
  end

  def test_step_height_changes_are_saved_for_the_next_session
    tool, view = draw_tool, DrawingView.new
    UI.step_value = [175]
    tool.change_step_height(view)
    assert_equal 175, Basegrid::StripFootingTool.new(library: @library).saved_settings["settings"]["step_height_mm"]
    UI.step_value = [450]
    tool.change_step_height(view)
    assert_equal 175, @tool.saved_settings["settings"]["step_height_mm"]
  end

  def test_invalid_saved_preferences_fall_back_to_defaults
    ["invalid json", "[]", "null"].each do |encoded|
      Sketchup.write_default("Basegrid", "strip_footing_settings", encoded)
      assert_equal({}, @tool.saved_settings)
    end
    Sketchup.write_default("Basegrid", "strip_footing_settings", '{"settings":null,"materials":[]}')
    assert_equal({ "settings" => {}, "materials" => {} }, @tool.saved_settings)
  end

  def test_web_support_and_bogar_types_accept_each_without_including_bar_chairs
    @library.material_types.concat([
      { "id" => "supports", "name" => "Trench Mesh Supports", "uom" => "each" },
      { "id" => "bogar", "name" => "Bogar Spacer", "uom" => "each" },
      { "id" => "plural", "name" => "Bogar Spacers", "uom" => "ea" },
      { "id" => "bar_chairs", "name" => "Bar Chairs", "uom" => "each" },
      { "id" => "wrong_unit", "name" => "Bogar Spacer", "uom" => "m" }
    ])
    %w[supports bogar plural bar_chairs wrong_unit].each do |id|
      @library.materials << { "id" => id, "name" => id, "material_type_id" => id }
    end
    assert_equal ["supports"], @tool.materials_for("chairs").map { |m| m["id"] }
    assert_equal %w[bogar plural], @tool.materials_for("spacers").map { |m| m["id"] }
    assert_raises(RuntimeError) { @tool.validate_materials("chairs" => "bar_chairs") }
    assert_raises(RuntimeError) { @tool.validate_materials("spacers" => "wrong_unit") }
  end

  def test_tab_cycles_the_setout_anchor_around_the_cross_section
    settings = @tool.resolved_settings({}, {})
    tool = Basegrid::StripFootingTool::DrawTool.new(@tool, settings, {})
    view = OpenStruct.new(invalidated: 0)
    def view.invalidate = self.invalidated += 1

    assert_equal "left edge top", tool.anchor_label
    walked = 6.times.map do
      assert tool.onKeyDown(Basegrid::StripFootingTool::DrawTool::TAB_KEY, 1, 0, view)
      tool.anchor_label
    end

    assert_equal 6, walked.uniq.length, "each press must reach a different anchor point"
    assert_equal "left edge top", walked.last, "the cycle must return to where it started"
    assert_equal 6, view.invalidated
    assert_includes Sketchup.status_text, "anchor left edge top (Tab cycles)"
    refute tool.onKeyDown(0, 1, 0, view), "other keys stay available to SketchUp"
    assert_equal 6, view.invalidated
  end

  def test_settings_html_escapes_material_content
    @library.materials.first["name"] = "</script><script>alert(1)</script>"
    html = @tool.send(:settings_html, {})
    refute_includes html, "</script><script>alert(1)"
    assert_includes html, "textContent"
  end

  def test_product_dimensions_override_manual_mesh_dimensions
    material = { "dimensions_mm" => { "width" => 300, "bars" => 4, "diameter" => 11 } }
    settings = @tool.resolved_settings({ "bar_diameter_mm" => 12 }, "mesh" => material)
    assert_equal 4, settings["bar_count"]
    assert_equal 11, settings["bar_diameter_mm"]
    assert_equal 100, settings["bar_spacing_mm"]
    assert_equal 8, settings["cross_diameter_mm"]
  end

  def test_failed_creation_aborts_its_operation
    entities = Object.new
    def entities.add_group = raise("simulated entity creation failure")
    model = Object.new
    operations = []
    model.define_singleton_method(:active_path) { nil }
    model.define_singleton_method(:active_entities) { entities }
    model.define_singleton_method(:start_operation) { |*_| operations << :start }
    model.define_singleton_method(:abort_operation) { operations << :abort }
    Sketchup.active_model = model
    error = assert_raises(RuntimeError) { @tool.build(model, [[[0,0,0],[6000,0,0]]]) }
    assert_match(/simulated entity/, error.message)
    assert_equal [:start, :abort], operations
    operations.clear
    assert_raises(RuntimeError) { @tool.build(model, [[[0,0,0],[0,0,0]]]) }
    assert_empty operations
  end

  def test_takeoff_supports_mixed_units_and_preserves_unassigned_roles
    entity = Object.new
    def entity.set_attribute(*); end
    record = Basegrid::Takeoff.write_quantity(entity, material: { "id" => "", "name" => "Unassigned mesh" },
      role_id: "concrete.strip_footing.mesh", material_role: "mesh", quantity: 5.9, unit: "m", basis: "modelled")
    assert_equal "m", record["unit"]
    assert_equal "mesh", record["material_role"]
    assert_in_delta 5.9, record["quantity"], 1e-9
    assert_equal "", record["material_id"]
  end

  def test_shared_support_definition_counts_each_placed_instance_once
    definition = Struct.new(:entities).new([])
    instance_class = Struct.new(:definition, :record) do
      def get_attribute(_dictionary, key) = key == "takeoff_json" ? JSON.generate(record) : nil
    end
    record = { "material_id" => "support", "material_name" => "Support", "unit" => "ea", "quantity" => 1 }
    instances = [instance_class.new(definition, record), instance_class.new(definition, record)]
    records = Basegrid::Takeoff.records(Struct.new(:entities).new(instances))
    assert_equal 2, records.length
    assert_equal 2, Basegrid::Takeoff.summary_rows(records).first["quantity"]
  end

  def test_each_placed_bar_gets_its_own_geometry_not_a_shared_definition
    groups = []
    group_class = Struct.new(:name, :entities, :layer)
    entities = Object.new
    entities.define_singleton_method(:add_group) do
      group_class.new(nil, [], nil).tap { |group| groups << group }
    end
    shared = false
    model = Object.new
    model.define_singleton_method(:layers) { [:layer0] }
    model.define_singleton_method(:definitions) { shared = true; [] }
    built = []
    @tool.define_singleton_method(:add_bar) { |target, bar| built << [target, bar] }

    bar = { a: [0, 0, 0], b: [0, 0, 1000], diameter: 11 }
    first = @tool.send(:place_bar, model, entities, bar, "Longitudinal Bar 01")
    second = @tool.send(:place_bar, model, entities, bar, "Longitudinal Bar 02")

    refute shared, "identical bars must not be placed through a shared component definition"
    refute_same first, second
    assert_equal ["Longitudinal Bar 01", "Longitudinal Bar 02"], groups.map(&:name)
    assert_equal 2, built.length
    refute_same built[0][0], built[1][0], "each bar must own the entities its geometry is built in"
  end

  def test_repeated_dimensions_reuse_definition_but_different_sizes_do_not
    definition_class = Struct.new(:name, :entities, :attributes) do
      def valid? = true
      def set_attribute(dictionary, key, value) = attributes[[dictionary,key]] = value
      def get_attribute(dictionary, key) = attributes[[dictionary,key]]
    end
    definitions = []
    definitions.define_singleton_method(:add) do |name|
      definition_class.new(name, [], {}).tap { |item| self << item }
    end
    model = Struct.new(:definitions).new(definitions)
    builds = 0
    first = @tool.send(:part_definition, model, ["support",10,200,50], "Mesh Support") { builds += 1 }
    second = @tool.send(:part_definition, model, ["support",10,200,50], "Mesh Support") { builds += 1 }
    third = @tool.send(:part_definition, model, ["support",10,300,50], "Mesh Support") { builds += 1 }
    assert_same first, second
    refute_same first, third
    assert_equal 2, builds
    assert_equal 2, definitions.length
    other_tool = Basegrid::StripFootingTool.new(library: @library)
    reused = other_tool.send(:part_definition, model, ["support",10,200,50], "Mesh Support") { flunk "Should reuse model definition" }
    assert_same first, reused
  end
end
