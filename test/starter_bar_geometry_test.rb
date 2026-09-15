# frozen_string_literal: true
require "minitest/autorun"
require_relative "../basegrid/starter_bar_geometry"

class StarterBarGeometryTest < Minitest::Test
  G = Basegrid::StarterBarGeometry
  LINE = [[0, 0, 0], [1200, 0, 0]].freeze

  def test_straight_starters_have_uniform_spacing_and_cranks
    bars = G.plan(LINE)[:bars]
    assert_equal [0, 400, 800, 1200], bars.map { |bar| bar[:center][0] }
    assert_equal [[0, -300, -400], [0, 0, -400], [0, 0, 600]], bars.first[:points]
    assert_in_delta 1.3, bars.first[:length_m]
  end

  def test_first_offset_is_a_setback_not_a_spacing_phase
    bars = G.plan(LINE, { "first_offset_mm" => 600 })[:bars]
    assert_equal [600, 1000], bars.map { |bar| bar[:center][0] }
  end

  def test_middle_anchor_places_outward_on_both_sides_with_offset
    bars = G.plan(LINE, { "first_offset_mm" => 150 }, anchor: 600)[:bars]
    assert_equal [50, 450, 750, 1150], bars.map { |bar| bar[:center][0] }.sort
  end

  def test_reverse_flips_open_chain_inward_and_keeps_anchor_offset
    forward = G.plan(LINE, {}, anchor: 1200)[:bars]
    backward = G.plan(LINE, {}, anchor: 1200, reverse: true)[:bars]
    assert_equal forward.map { |bar| bar[:center] }.sort, backward.map { |bar| bar[:center] }.sort
    assert_equal [0, -1, 0], forward.first[:inward]
    assert_equal [0, 1, 0], backward.first[:inward]
  end

  def test_vertical_step_has_no_spacing_length_and_samples_upper_run_at_step
    route = [[0, 0, 0], [400, 0, 0], [400, 0, 250], [1200, 0, 250]]
    bars = G.plan(route)[:bars]
    assert_equal [[0, 0, 0], [400, 0, 250], [800, 0, 250], [1200, 0, 250]], bars.map { |bar| bar[:center] }
  end

  def test_sloping_path_uses_plan_spacing_and_interpolates_elevation
    bars = G.plan([[0, 0, 0], [1200, 0, 600]])[:bars]
    assert_equal [0, 200, 400, 600], bars.map { |bar| bar[:center][2] }
  end

  def test_tapered_cranks_interpolate_along_path
    bars = G.plan(LINE, { "mode" => "tapered", "top_start_mm" => 100, "top_end_mm" => 400 })[:bars]
    assert_equal [100, 200, 300, 400], bars.map { |bar| bar[:points].last[1] }
  end

  def test_loop_omits_duplicate_endpoint_and_inward_faces_inside
    points = [[0,0,0], [400,0,0], [400,400,0], [0,400,0], [0,0,0]]
    bars = G.plan(points)[:bars]
    assert_equal 4, bars.length
    assert_equal 4, bars.map { |bar| bar[:center] }.uniq.length
    assert_equal [0, 1, 0], bars.first[:inward]
    reversed = G.plan(points.reverse)[:bars]
    assert_equal [1, 0, 0], reversed.first[:inward]
  end

  def test_loop_taper_starts_at_picked_anchor
    points = [[0,0,0], [400,0,0], [400,400,0], [0,400,0], [0,0,0]]
    bars = G.plan(points, { "mode" => "tapered", "top_start_mm" => 100, "top_end_mm" => 500 }, anchor: 800)[:bars]
    anchor_bar = bars.find { |bar| bar[:center] == [400,400,0] }
    assert_equal 100, anchor_bar[:points].last[1]
  end

  def test_pins_cross_path_and_ignore_chairs
    bar = G.plan(LINE, { "mode" => "pins", "in_mm" => 300, "out_mm" => 500, "chairs" => true, "caps" => true })[:bars].first
    assert_equal [[0,-500,0], [0,300,0]], bar[:points]
    assert_empty bar[:chairs]
    assert_equal [0,300,0], bar[:cap]
    assert_in_delta 0.8, bar[:length_m]
  end

  def test_chairs_follow_bottom_crank_and_caps_follow_top
    bar = G.plan(LINE, { "bottom_start_mm" => 1800, "chairs" => true, "caps" => true })[:bars].first
    assert_equal 3, bar[:chairs].length
    assert_equal [0,-1700,-406], bar[:chairs].first
    assert_equal [0,0,600], bar[:cap]
  end

  def test_nearest_chainage_on_diagonal
    route = G.path([[0,0,0], [300,400,0]])
    assert_in_delta 250, G.nearest_chainage(route, [150,200,90])
    assert_in_delta 500, G.nearest_chainage(route, [600,800,0])
  end

  def test_invalid_dimensions_and_excessive_layout_are_rejected
    [{ "spacing_mm" => 0 }, { "diameter_mm" => Float::INFINITY }, { "above_mm" => -1 },
     { "mode" => "unknown" }, { "top_direction" => "left" }, { "caps" => "true" },
     { "above_mm" => 0, "below_mm" => 0 }, { "mode" => "pins", "in_mm" => 0, "out_mm" => 0 }].each do |settings|
      assert_raises(RuntimeError) { G.plan(LINE, settings) }
    end
    assert_raises(RuntimeError) { G.plan([[0,0,0], [10_000,0,0]], { "spacing_mm" => 1 }) }
    assert_raises(RuntimeError) { G.plan(LINE, { "first_offset_mm" => 1300 }) }
  end

  def test_bad_paths_and_anchors_are_rejected
    assert_raises(RuntimeError) { G.plan([[0,0,0], [0,0,600]]) }
    assert_raises(RuntimeError) { G.plan([[0,0,0], [Float::NAN,0,0]]) }
    assert_raises(RuntimeError) { G.plan(LINE, {}, anchor: -1) }
    assert_raises(RuntimeError) { G.plan(LINE, {}, anchor: 1300) }
  end
end
