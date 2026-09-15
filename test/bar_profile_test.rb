# frozen_string_literal: true

require "minitest/autorun"
require_relative "../basegrid/starter_bar_tool"
require_relative "../basegrid/strip_footing_tool"

class BarProfileTest < Minitest::Test
  class ProfileCaptured < StandardError; end

  class Entities
    attr_reader :segments
    def add_curve(*) = []
    def add_circle(_origin, _direction, _radius, segments)
      @segments = segments
      raise ProfileCaptured
    end
  end

  class Point
    def vector_to(*) = :direction
    def -(*) = :direction
  end

  def test_starter_and_step_z_shared_bar_builder_uses_eight_segments
    tool = Basegrid::StarterBarTool.new
    def tool.point(*) = Point.new
    entities = Entities.new
    assert_raises(ProfileCaptured) { tool.add_bar(entities, [[0,0,0], [0,0,100]], 12) }
    assert_equal 8, entities.segments
  end

  def test_trench_mesh_bar_builder_uses_eight_segments
    tool = Basegrid::StripFootingTool.new
    def tool.point3d(*) = Point.new
    entities = Entities.new
    diameter = Struct.new(:mm).new(11)
    assert_raises(ProfileCaptured) { tool.send(:add_bar, entities, { a: [0,0,0], b: [0,100,0], diameter: diameter }) }
    assert_equal 8, entities.segments
  end
end
