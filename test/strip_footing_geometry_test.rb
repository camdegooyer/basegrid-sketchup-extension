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
        assert_in_delta((6000*450*450 + 675*450*200) / 1e9, plan[:volume_m3], 1e-9)
        assert_surface(plan)
      end
    end
  end

  def test_step_cannot_extend_beyond_short_run
    error = assert_raises(RuntimeError) { concrete([[[0,0,0], [1000,0,0]], [[1000,0,200], [1100,0,200]]]) }
    assert_match(/overlap exceeds/, error.message)
  end

  def test_invalid_paths_do_not_silently_change_geometry
    [ [[[0,0,0], [1000,0,50]]],
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

  def test_mesh_continues_through_a_corner_and_stacks_clear_of_the_other_run
    plan = G.plan([[[0,0,0], [0,5480,0]], [[0,5480,0], [3905,5480,0]]],
                  "bar_diameter_mm" => 11.0, "bar_spacing_mm" => 100.0)
    along, across = plan[:mesh_layers].values_at(0, 2)
    assert_equal ["Bottom Mesh 01", "Bottom Mesh 02"], [along, across].map { |layer| layer[:name] }

    # Each run reaches the far face of the other run's outermost longitudinal
    # bar: 100 mm half mesh width plus the 5.5 mm bar radius past the vertex.
    assert_in_delta 5585.5, along[:longitudinal].map { |bar| bar[:b][1] }.max, 1e-9
    assert_in_delta(-105.5, across[:longitudinal].map { |bar| bar[:a][0] }.min, 1e-9)
    # Free ends keep end cover.
    assert_in_delta 50.0, along[:longitudinal].map { |bar| bar[:a][1] }.min, 1e-9
    assert_in_delta 3855.0, across[:longitudinal].map { |bar| bar[:b][0] }.max, 1e-9

    # Cross wires are carried through at their normal spacing rather than
    # stopping at the old bar end, so no stretch of bar is left bare.
    assert_operator along[:cross_bars].map { |bar| bar[:a][1] }.max, :>, 5400
    [[along, 1], [across, 0]].each do |layer, axis|
      ends = layer[:longitudinal].flat_map { |bar| [bar[:a][axis], bar[:b][axis]] }
      stations = layer[:cross_bars].map { |bar| bar[:a][axis] }
      assert_operator stations.min - ends.min, :<=, 300.0
      assert_operator ends.max - stations.max, :<=, 300.0
    end

    # The crossing run stacks exactly one mesh depth above, so the two meshes
    # touch instead of intersecting. Manufactured supports remain 50 mm high.
    depth = 11.0 + 8.0 # one bar diameter plus one cross wire diameter
    assert_in_delta depth, across[:longitudinal][0][:a][2] - along[:longitudinal][0][:a][2], 1e-9
    assert_in_delta 50.0, plan[:chairs].find { |chair| chair[:segment_index] == 1 }[:height_mm], 1e-9
    assert_in_delta 50.0, plan[:chairs].find { |chair| chair[:segment_index] == 0 }[:height_mm], 1e-9
    refute_includes plan[:warnings].join, "terminate independently"
  end

  def test_step_mesh_extends_into_overlap_without_changing_layer_heights
    plan = G.plan([[[0,0,0], [4000,0,0]], [[4000,0,200], [8000,0,200]]], "reinforcement" => "bottom")
    lower, upper = plan[:mesh_layers]
    assert_in_delta 4625.0, lower[:longitudinal].map { |bar| bar[:b][0] }.max, 1e-9
    assert_in_delta 4050.0, upper[:longitudinal].map { |bar| bar[:a][0] }.min, 1e-9
    assert_in_delta 200.0, upper[:longitudinal][0][:a][2] - lower[:longitudinal][0][:a][2], 1e-9
  end

  def z_plan(height, settings = {})
    G.plan([[[0,0,0],[3000,0,0]], [[3000,0,height],[6000,0,height]]],
      {"include_step_z_bars"=>true,"bar_count"=>4,"bar_diameter_mm"=>11}.merge(settings))
  end

  def test_z_bars_are_optional_and_threshold_is_strict
    assert_empty z_plan(200)[:z_bars]
    assert_equal 8, z_plan(300)[:z_bars].length
    assert_empty z_plan(300,"include_step_z_bars"=>false)[:z_bars]
    assert_empty z_plan(300,"step_z_threshold_mm"=>300)[:z_bars]
    assert_equal 8, z_plan(200,"step_z_threshold_mm"=>199)[:z_bars].length
    assert_equal 4, z_plan(300,"reinforcement"=>"bottom")[:z_bars].length
    assert_empty z_plan(300,"reinforcement"=>"none")[:z_bars]
    assert_equal 8, z_plan(1,"step_z_threshold_mm"=>0)[:z_bars].length
    assert_raises(RuntimeError) { z_plan(300,"include_step_z_bars"=>"true") }
    assert_raises(RuntimeError) { z_plan(300,"step_z_threshold_mm"=>-1) }
  end

  def test_z_bars_use_diameter_laps_and_staggered_cover_adjusted_bends
    [12,16,20].each do |diameter|
      plan = z_plan(300,"step_z_diameter_mm"=>diameter,"width_mm"=>500)
      plan[:z_bars].each do |bar|
        a,b,c,d = bar[:points]
        assert_in_delta diameter*50,b[0]-a[0],1e-9
        assert_in_delta diameter*50,d[0]-c[0],1e-9
        assert_in_delta 300,c[2]-b[2],1e-9
        assert_in_delta (diameter*100+300)/1000.0,bar[:length_m],1e-9
        expected = bar[:name].include?("Top") ? 3050+diameter/2.0 : 3625-diameter/2.0
        assert_in_delta expected,b[0],1e-9
      end
    end
  end

  def test_step_extensions_continue_cross_wires_and_accessories
    plan = z_plan(300)
    lower = plan[:mesh_layers].first
    assert_in_delta 3625,lower[:longitudinal].first[:b][0],1e-9
    assert lower[:cross_bars].any? { |bar| bar[:a][0]>3000 }
    longer = z_plan(300,"depth_mm"=>650)
    assert longer[:chairs].any? { |item| item[:segment_index]==0 && item[:origin][0]>3000 }
    assert longer[:spacers].any? { |item| item[:segment_index]==0 && item[:origin][0]>3000 }
  end

  def test_z_bars_support_reversed_rotated_steps_and_bottom_reference
    paths = [[[0,0,0],[3000,0,0]], [[3000,0,300],[6000,0,300]]]
    [paths,paths.reverse.map(&:reverse),paths.map { |path| path.map { |x,y,z| [x*0.6-y*0.8,x*0.8+y*0.6,z] } }].each do |runs|
      %w[top bottom].each do |reference|
        plan = G.plan(runs,"include_step_z_bars"=>true,"vertical_reference"=>reference)
        assert_equal 6,plan[:z_bars].length
        assert plan[:z_bars].all? { |bar| (bar[:length_m]-1.5).abs<1e-9 }
      end
    end
  end

  def test_z_bars_reject_laps_that_cannot_fit
    error = assert_raises(RuntimeError) do
      G.plan([[[0,0,0],[3000,0,0]], [[3000,0,300],[3700,0,300]]],"include_step_z_bars"=>true)
    end
    assert_match(/too short.*lap/,error.message)
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

  def test_reference_u_has_one_joined_solid
    plan = concrete([[[0,0,0],[0,3929,0],[4121,3929,0],[4121,0,0]]])
    assert_equal ["Joined Concrete"], plan[:concrete_parts].map { |part| part[:name] }
    plan[:concrete_parts].each do |part|
      assert_surface(part)
    end
    assert_in_delta plan[:volume_m3], plan[:concrete_parts].sum { |part| part[:volume_m3] }, 1e-9
  end

  def test_stepped_reference_is_one_union_without_internal_partition_faces
    plan = concrete([[[0,0,0],[3000,0,0]], [[3000,0,200],[6000,0,200]],
                     [[6000,0,400],[9000,0,400]]], "alignment" => "left_edge", "step_overlap_mm" => 450)
    assert_equal 1, plan[:concrete_parts].length
    solid = plan[:concrete_parts].first
    assert_equal plan[:faces], solid[:faces]
    assert_in_delta 1.9035, solid[:volume_m3], 1e-9
    assert_surface(solid)
  end

  def test_branch_grouping_keeps_net_union_without_duplicate_concrete
    plan = concrete([[[0,0,0],[6000,0,0]], [[3000,0,0],[3000,3000,0]]])
    assert_equal ["Joined Concrete"], plan[:concrete_parts].map { |part| part[:name] }
    assert_surface(plan[:concrete_parts].first)
  end

  def test_default_step_overlap_tracks_depth_and_explicit_values_are_preserved
    {300 => 450, 450 => 675, 600 => 900}.each do |depth, overlap|
      settings = G.settings("depth_mm" => depth)
      assert_equal overlap, settings["step_overlap_mm"]
      assert_equal overlap, G.settings(settings)["step_overlap_mm"]
      plan = concrete([[[0,0,0],[3000,0,0]], [[3000,0,100],[6000,0,100]]], "depth_mm" => depth)
      assert_in_delta (6000*450*depth + overlap*450*100)/1e9, plan[:volume_m3], 1e-9
      assert_surface(plan)
    end
    assert_equal 450, G.settings("depth_mm" => 600, "step_overlap_mm" => 450)["step_overlap_mm"]
    [-1, 0, Float::INFINITY, "bad"].each do |value|
      assert_raises(RuntimeError) { G.settings("step_overlap_mm" => value) }
    end
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
      (1...face.length-1).map { |i| [face[0],face[i],face[i+1]] }.each do |p,q,r|
        cross = [q[1]*r[2]-q[2]*r[1], q[2]*r[0]-q[0]*r[2], q[0]*r[1]-q[1]*r[0]]
        signed_volume += p.zip(cross).sum { |x,y| x*y } / 6.0
      end
    end
    assert edges.values.all? { |count| count == 2 }, "Every surface edge must have exactly two incident faces"
    assert_in_delta plan[:volume_m3], signed_volume / 1e9, 1e-8
  end

  def test_diagonal_run_has_actual_width_and_length
    plan = concrete([[[0,0,0], [3000,4000,0]]])
    assert_in_delta 5000*450*450/1e9, plan[:volume_m3], 1e-8
    assert_surface(plan)
    plan[:concrete_parts].each { |part| assert_surface(part) }
  end

  def test_rotated_loop_branch_and_steps_preserve_volume_and_closed_surfaces
    paths_list = [
      [[[0,0,0],[3000,0,0],[3000,3000,0],[0,3000,0],[0,0,0]]],
      [[[0,0,0],[6000,0,0]],[[3000,0,0],[3000,3000,0]]],
      [[[0,0,0],[3000,0,0]],[[3000,0,200],[6000,0,200]]]
    ]
    paths_list.each do |paths|
      rotated = paths.map { |path| path.map { |x,y,z| [0.8*x-0.6*y,0.6*x+0.8*y,z] } }
      plan = concrete(rotated)
      assert_in_delta concrete(paths)[:volume_m3], plan[:volume_m3], 1e-7
      assert_surface(plan)
      plan[:concrete_parts].each { |part| assert_surface(part) }
    end
  end

  def test_oblique_corner_and_crossing_are_watertight
    [ [[[0,0,0],[3000,0,0],[5000,2000,0]]],
      [[[0,0,0],[6000,0,0]],[[1500,-1500,0],[4500,1500,0]]] ].each do |paths|
      plan = concrete(paths)
      assert_surface(plan)
      plan[:concrete_parts].each { |part| assert_surface(part) }
    end
  end

  def test_oblique_paths_with_edge_anchors
    %w[left_edge right_edge].each do |alignment|
      plan = concrete([[[0,0,0],[3000,4000,0],[7000,5000,0]]], "alignment" => alignment)
      assert_surface(plan)
      plan[:concrete_parts].each { |part| assert_surface(part) }
    end
  end

  def test_fixed_cover_overrides_legacy_settings
    assert_equal 50, G.settings("cover_mm" => 20)["cover_mm"]
  end
end
