# frozen_string_literal: true
require "minitest/autorun"
require_relative "../basegrid/strip_footing_geometry"

class FootingPierLayoutTest < Minitest::Test
  G = Basegrid::StripFootingGeometry
  def layout(paths, settings = {})
    G.plan(paths,{"reinforcement"=>"none","include_piers"=>true,"pier_spacing_mm"=>2000}.merge(settings))[:piers]
  end

  def test_straight_even_and_fixed_spacing
    paths = [[[0,0,0],[5500,0,0]]]
    expected = (0..3).map { |i| 225+5050.0*i/3 }
    expected.zip(layout(paths)).each { |x,p| assert_in_delta x,p[:top][0],0.001 }
    assert_equal [225,2225,4225,5275],layout(paths,"piers_even_spacing"=>false).map { |p| p[:top][0] }
    assert layout(paths).all? { |p| p[:top][2] == -450 }
    assert_empty layout(paths,"include_piers"=>false)
  end

  def test_flush_ends_follow_direction_and_reject_piers_that_cannot_fit
    paths = [[[100,200,0],[1900,2600,0]]]
    points = layout(paths).map { |p| p[:top] }
    assert_in_delta 235,points.first[0],0.001
    assert_in_delta 380,points.first[1],0.001
    assert_in_delta 1765,points.last[0],0.001
    assert_in_delta 2420,points.last[1],0.001
    assert_equal 1,layout([[[0,0,0],[450,0,0]]]).length
    assert_raises(RuntimeError) { layout([[[0,0,0],[449,0,0]]]) }
  end

  def test_corner_piers_are_optional_and_edge_anchors_use_physical_centreline
    paths = [[[0,0,0],[3000,0,0],[3000,3000,0]]]
    points = layout(paths).map { |p| p[:top].first(2) }
    assert_includes points,[3000,0]
    refute_includes layout(paths,"piers_at_corners"=>false).map { |p| p[:top].first(2) },[3000,0]
    assert_includes layout(paths,"alignment"=>"left_edge").map { |p| p[:top].first(2) },[3225,-225]
  end

  def test_t_and_cross_intersections_are_deduplicated_and_optional
    [
      [[[0,0,0],[6000,0,0]],[[3000,0,0],[3000,3000,0]]],
      [[[0,0,0],[6000,0,0]],[[3000,-3000,0],[3000,3000,0]]]
    ].each do |paths|
      at_joint = ->(piers) { piers.count { |p| Math.hypot(p[:top][0]-3000,p[:top][1])<0.01 } }
      assert_equal 1,at_joint.call(layout(paths))
      assert_equal 0,at_joint.call(layout(paths,"piers_at_intersections"=>false))
    end
  end

  def test_closed_loop_and_rotated_layout
    paths = [[[0,0,0],[4000,0,0],[4000,4000,0],[0,4000,0],[0,0,0]]]
    piers = layout(paths)
    assert_equal 8,piers.length
    assert_equal piers.length,piers.map { |p| p[:top] }.uniq.length
    rotated = paths.map { |path| path.map { |x,y,z| [x*0.6-y*0.8,x*0.8+y*0.6,z] } }
    assert_equal piers.length,layout(rotated).length
    assert_equal 8,layout(paths,"piers_at_corners"=>false).length
  end

  def test_step_piers_stop_at_lowest_overlapping_concrete_underside
    piers = layout([[[0,0,0],[3000,0,0]],[[3000,0,200],[6000,0,200]]])
    joint = piers.select { |p| (p[:top][0]-3000).abs<0.01 }
    assert_equal 1,joint.length
    assert_equal(-450,joint.first[:top][2])
    assert_equal(-250,piers.max_by { |p| p[:top][0] }[:top][2])
  end

  def test_bar_defaults_and_editable_overrides
    s = G.settings("depth_mm"=>600,"width_mm"=>500,"pier_depth_mm"=>1200)
    assert_equal [1100,300,200],s.values_at("pier_bar_below_mm","pier_bar_above_mm","pier_bar_cog_mm")
    s = G.settings("pier_bar_below_mm"=>700,"pier_bar_above_mm"=>150,"pier_bar_cog_mm"=>100)
    assert_equal [700,150,100],s.values_at("pier_bar_below_mm","pier_bar_above_mm","pier_bar_cog_mm")
    assert_raises(RuntimeError) { G.settings("include_piers"=>"true") }
    assert_raises(RuntimeError) { G.settings("pier_spacing_mm"=>0) }
    assert_raises(RuntimeError) { layout([[[0,0,0],[6000,0,0]]],"pier_spacing_mm"=>1) }
  end
end
