# frozen_string_literal: true

require "minitest/autorun"
require_relative "../basegrid/starter_bar_tool"

class StarterStepZTest < Minitest::Test
  def setup
    @tool = Basegrid::StarterBarTool.new
    @settings = @tool.step_z_defaults.merge("diameter_mm" => 12)
    @pair = { "upper" => { "ends" => [[0, 0, 300], [1000, 0, 300]] },
              "lower" => { "ends" => [[-1000, 0, 0], [0, 0, 0]] } }
  end

  def test_z_shape_offsets_beside_existing_bars
    points = Basegrid::StepZGeometry.plan(@pair, @settings)
    assert_equal [[-600, 12, 0], [0, 12, 0], [0, 12, 300], [600, 12, 300]], points
  end

  def test_vertical_offset_and_reversed_pick_order
    settings = @settings.merge("step_offset_axis" => "vertical", "step_offset_mm" => -20)
    pair = { "upper" => @pair["lower"], "lower" => @pair["upper"] }
    assert_equal [[-600, 0, -20], [0, 0, -20], [0, 0, 280], [600, 0, 280]], Basegrid::StepZGeometry.plan(pair, settings)
  end

  def test_rotated_bars_are_not_axis_locked
    pair = @pair.transform_values do |candidate|
      { "ends" => candidate["ends"].map { |x, y, z| [x/Math.sqrt(2), x/Math.sqrt(2), z] } }
    end
    points = Basegrid::StepZGeometry.plan(pair, @settings)
    assert_in_delta 300, points[2][2]-points[1][2]
    assert_in_delta 600, Math.hypot(points[3][0]-points[2][0], points[3][1]-points[2][1])
    assert_in_delta Math.sqrt(72), points[2][1]
    assert_in_delta -Math.sqrt(72), points[2][0]
  end

  def test_zero_cranks_leave_two_distinct_points
    assert_equal 2, Basegrid::StepZGeometry.plan(@pair, @settings.merge("step_upper_mm" => 0, "step_lower_mm" => 0)).length
  end

  def test_rejects_no_drop_and_invalid_geometry
    assert_raises(RuntimeError) { Basegrid::StepZGeometry.plan(@pair.merge("lower" => @pair["upper"]), @settings) }
    assert_raises(RuntimeError) { Basegrid::StepZGeometry.plan(@pair.merge("upper" => { "ends" => [[0,0,Float::NAN], [1,0,1]] }), @settings) }
  end

  def test_candidate_estimates_bar_axis_from_world_geometry
    points = [0, 1000].product([-6, 6], [294, 306])
    assert_equal [[0.0, 0.0, 300.0], [1000.0, 0.0, 300.0]], Basegrid::StepZGeometry.candidate(points)["ends"]
    assert_nil Basegrid::StepZGeometry.candidate([])
  end

  def test_step_settings_validate_and_keep_material_diameter
    library = Object.new
    def library.material_types = [{ "id" => "processed", "name" => "Reo Bar Processed", "uom" => "m" }]
    def library.materials = [{ "id" => "n16", "name" => "N16", "material_type_id" => "processed", "dimensions_mm" => { "diameter_mm" => 16 } }]
    tool = Basegrid::StarterBarTool.new(library: library)
    settings, bindings = tool.resolve_step_z("mode" => "step_z", "bar_material" => "n16", "step_lower_mm" => 450)
    assert_equal 16, settings["diameter_mm"]
    assert_equal "step_z", settings["mode"]
    assert_equal 450, settings["step_lower_mm"]
    assert_equal "n16", bindings["bar"]["id"]
    settings, = tool.resolve_step_z("above_mm" => 0, "below_mm" => 0, "chair_material" => "removed", "chairs" => true)
    refute settings["chairs"], "Hidden settings from another mode must not prevent step placement."
    assert_raises(RuntimeError) { tool.resolve_step_z("step_upper_mm" => -1) }
    assert_raises(RuntimeError) { tool.resolve_step_z("step_offset_mm" => Float::INFINITY) }
  end
end
