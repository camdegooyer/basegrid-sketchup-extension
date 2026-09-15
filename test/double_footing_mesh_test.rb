require 'minitest/autorun'
require_relative '../basegrid/strip_footing_geometry'

class DoubleFootingMeshTest < Minitest::Test
  G = Basegrid::StripFootingGeometry

  def plan(options = {})
    G.plan([[[0,0,0],[6000,0,0]]], { 'width_mm'=>600, 'double_mesh'=>'top_bottom' }.merge(options))
  end

  def test_independent_layers_and_material_lengths
    assert_equal 2, plan('double_mesh'=>'none')[:mesh_layers].length
    %w[top bottom].each do |mode|
      layers = plan('double_mesh'=>mode)[:mesh_layers]
      assert_equal 3, layers.length
      assert_equal 2, layers.count { |layer| layer[:name].downcase.start_with?(mode) }
    end
    double = plan
    assert_equal 4, double[:mesh_layers].length
    assert_in_delta plan('double_mesh'=>'none')[:mesh_length_m]*2, double[:mesh_length_m], 1e-8
    assert_equal 2, plan('reinforcement'=>'bottom')[:mesh_layers].length
    assert_empty plan('reinforcement'=>'none')[:mesh_layers]
  end

  def test_side_cover_and_maximum_clear_gap
    layers = plan('width_mm'=>624)[:mesh_layers].select { |layer| layer[:name].start_with?('Bottom') }
    left, right = layers.map { |layer| layer[:longitudinal].map { |bar| bar[:a][1] }.minmax }
    assert_in_delta(-312+50, left[0]-6, 1e-8)
    assert_in_delta(312-50, right[1]+6, 1e-8)
    assert_in_delta 100, right[0]-left[1]-12, 1e-8
    error = assert_raises(RuntimeError) { plan('width_mm'=>625) }
    assert_match(/100 mm/, error.message)
  end

  def test_lapped_strips_are_stacked_inside_cover
    layers = plan('width_mm'=>450)[:mesh_layers]
    bottom = layers.select { |layer| layer[:name].start_with?('Bottom') }
    assert_in_delta 20, bottom[1][:longitudinal][0][:a][2]-bottom[0][:longitudinal][0][:a][2], 1e-8
    layers.each do |layer|
      (layer[:longitudinal]+layer[:cross_bars]).each do |bar|
        assert_operator bar[:a][2]-bar[:diameter]/2, :>=, -400
        assert_operator bar[:a][2]+bar[:diameter]/2, :<=, -50
      end
    end
    assert_raises(RuntimeError) { plan('width_mm'=>450,'depth_mm'=>170) }
  end

  def test_steps_connect_both_strips
    result = G.plan([[[0,0,0],[6000,0,0]],[[6000,0,300],[12000,0,300]]],
      'width_mm'=>600,'double_mesh'=>'top_bottom','include_step_z_bars'=>true)
    assert_equal 12, result[:z_bars].length
    result[:z_bars].each { |bar| bar[:points].each { |point| assert_operator point[1].abs+bar[:diameter]/2, :<=, 250 } }
  end
end
