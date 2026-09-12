# frozen_string_literal: true
require "minitest/autorun"
require_relative "../basegrid/strip_footing_geometry"

class StripFootingGeometryTest < Minitest::Test
  G = Basegrid::StripFootingGeometry

  def concrete(paths, settings = {})
    G.plan(paths, { "reinforcement" => "none" }.merge(settings))
  end

  def test_straight_volume_and_outward_watertight_surface
    plan = concrete([[[0,0,0], [6000,0,0]]])
    assert_in_delta 1.215, plan[:volume_m3], 1e-9
    assert_surface(plan)
    assert_equal(-450.0, plan[:faces].flatten(1).map(&:last).min)
  end

  def test_loop_has_open_middle_and_no_internal_faces
    plan = concrete([[[0,0,0], [3000,0,0], [3000,3000,0], [0,3000,0], [0,0,0]]])
    assert_in_delta((3450.0**2 - 2550.0**2) * 450 / 1e9, plan[:volume_m3], 1e-9)
    assert_surface(plan)
  end

  def test_t_and_cross_junction_subtract_overlap_once
    t = concrete([[[0,0,0], [6000,0,0]], [[3000,0,0], [3000,3000,0]]])
    assert_in_delta((6000*450 + 3000*450 - 225*450) * 450 / 1e9, t[:volume_m3], 1e-9)
    assert_surface(t)
    cross = concrete([[[0,0,0], [6000,0,0]], [[3000,-3000,0], [3000,3000,0]]])
    assert_in_delta((2*6000*450 - 450*450) * 450 / 1e9, cross[:volume_m3], 1e-9)
    assert_surface(cross)
  end

  def test_step_both_vertical_references_and_directions
    %w[top bottom].each do |reference|
      [-200, 200].each do |height|
        plan = concrete([[[0,0,0], [3000,0,0]], [[3000,0,height], [6000,0,height]]], "vertical_reference" => reference)
        assert_in_delta((6000*450*450 + 450*450*200) / 1e9, plan[:volume_m3], 1e-9)
        assert_surface(plan)
      end
    end
  end

  def test_step_cannot_extend_beyond_short_run
    error = assert_raises(RuntimeError) { concrete([[[0,0,0], [1000,0,0]], [[1000,0,200], [1100,0,200]]]) }
    assert_match(/overlap exceeds/, error.message)
  end

  def test_invalid_paths_do_not_silently_change_geometry
    [ [[[0,0,0], [1000,500,0]]], [[[0,0,0], [1000,0,50]]],
      [[[0,0,0], [0,0,0]]], [[[0,0,0], [1000,0,0]], [[2000,0,0], [3000,0,0]]] ].each do |paths|
      assert_raises(RuntimeError) { concrete(paths) }
    end
    assert_raises(RuntimeError) { concrete([[[0,0,0], [1000,0,0]]], "width_mm" => Float::NAN) }
  end

  def test_step_at_corner_is_explicitly_rejected
    error = assert_raises(RuntimeError) { concrete([[[0,0,0], [3000,0,0]], [[3000,0,200], [3000,3000,200]]]) }
    assert_match(/straight run/, error.message)
  end

  def test_retraced_paths_do_not_duplicate_mesh_quantities
    assert_raises(RuntimeError) { G.plan([[[0,0,0], [3000,0,0], [1000,0,0]]]) }
  end

  def test_clear_cover_bar_separation_and_chair_contact
    plan = G.plan([[[0,0,0], [6000,0,0]]], "reinforcement" => "bottom")
    longitudinal, cross = plan[:bars][0], plan[:bars][3]
    assert_equal(-394.0, longitudinal[:a][2])
    assert_in_delta 50, longitudinal[:a][2] - longitudinal[:diameter]/2 + 450, 1e-9
    assert_in_delta((longitudinal[:diameter] + cross[:diameter])/2, cross[:a][2] - longitudinal[:a][2], 1e-9)
    support = plan[:chairs][0]
    assert_in_delta longitudinal[:a][2] - longitudinal[:diameter]/2, support[:origin][2]+support[:height_mm], 1e-9
    assert_equal [200, 10, 50], support.values_at(:length_mm, :width_mm, :height_mm)
    assert_equal [250, 0, -450], support[:origin]
    assert_in_delta 5.9, plan[:mesh_length_m], 1e-9
    assert_empty plan[:spacers]
  end

  def test_top_bottom_cover_and_spacers
    plan = G.plan([[[0,0,0], [6000,0,0]]], "reinforcement" => "top_bottom")
    assert_in_delta 11.8, plan[:mesh_length_m], 1e-9
    assert_in_delta(-50, plan[:bars].map { |bar| bar[:a][2] + bar[:diameter]/2 }.max, 1e-9)
    refute_empty plan[:spacers]
    pair = plan[:spacers].first
    assert_equal 2, pair[:bars].length
    assert_equal [6, 6], pair[:bars].map { |bar| bar[:diameter] }
    assert_in_delta 14, pair[:bars][1][:a][0] - pair[:bars][0][:a][0], 1e-9
    assert_in_delta 326, pair[:height_mm], 1e-9
    assert_equal plan[:chairs].length*2, plan[:spacers].length
    assert_equal ["Bottom Mesh 01", "Top Mesh 01"], plan[:mesh_layers].map { |layer| layer[:name] }
  end

  def test_reference_u_has_three_mitered_solid_segments
    plan = concrete([[[0,0,0],[0,3929,0],[4121,3929,0],[4121,0,0]]])
    assert_equal ["Footing Segment 01", "Footing Segment 02", "Footing Segment 03"], plan[:concrete_parts].map { |part| part[:name] }
    plan[:concrete_parts].each do |part|
      assert_equal 6, part[:faces].length
      assert_surface(part)
    end
    assert_in_delta plan[:volume_m3], plan[:concrete_parts].sum { |part| part[:volume_m3] }, 1e-9
    assert_equal 2, (plan[:concrete_parts][0][:faces][1] & plan[:concrete_parts][1][:faces][1]).length
  end

  def test_branch_grouping_keeps_net_union_without_duplicate_concrete
    plan = concrete([[[0,0,0],[6000,0,0]], [[3000,0,0],[3000,3000,0]]])
    assert_equal ["Joined Concrete"], plan[:concrete_parts].map { |part| part[:name] }
    assert_surface(plan[:concrete_parts].first)
  end

  def test_previous_saddle_settings_remain_loadable
    values = G.settings("support_thickness_mm" => 6)
    refute values.key?("support_thickness_mm")
    assert_equal 6, values["spacer_diameter_mm"]
  end

  def test_impossible_mesh_is_rejected_without_reducing_cover
    assert_raises(RuntimeError) { G.plan([[[0,0,0], [6000,0,0]]], "width_mm" => 200) }
    assert_raises(RuntimeError) { G.plan([[[0,0,0], [80,0,0]]]) }
    assert_raises(RuntimeError) { G.plan([[[0,0,0], [6000,0,0]]], "depth_mm" => 110) }
    assert_raises(RuntimeError) { G.plan([[[0,0,0], [6000,0,0]]], "cross_spacing_mm" => 0.0001) }
  end

  def test_edge_alignment_and_reversed_direction
    %w[left_edge right_edge].each do |alignment|
      plan = concrete([[[0,0,0], [3000,0,0], [3000,3000,0]]], "alignment" => alignment)
      assert_surface(plan)
    end
    plan = concrete([[[6000,0,0], [0,0,0]]])
    assert_in_delta 1.215, plan[:volume_m3], 1e-9
    assert_surface(plan)
  end

  def assert_surface(plan)
    edges = Hash.new(0)
    signed_volume = 0.0
    plan[:faces].each do |face|
      face.each_with_index { |p, i| edges[[p, face[(i+1)%face.length]].sort] += 1 }
      a, b, c, d = face
      [[a,b,c], [a,c,d]].each do |p,q,r|
        cross = [q[1]*r[2]-q[2]*r[1], q[2]*r[0]-q[0]*r[2], q[0]*r[1]-q[1]*r[0]]
        signed_volume += p.zip(cross).sum { |x,y| x*y } / 6.0
      end
    end
    assert edges.values.all? { |count| count == 2 }, "Every surface edge must have exactly two incident faces"
    assert_in_delta plan[:volume_m3], signed_volume / 1e9, 1e-8
  end
end
