# frozen_string_literal: true

require "minitest/autorun"

module Basegrid
  class MaterialLibrary
  end
end

module Sketchup
  Color = Struct.new(:red, :green, :blue) unless const_defined?(:Color)
  class Face; end unless const_defined?(:Face)
end

module Geom
  Point3d = Struct.new(:x, :y, :z) unless const_defined?(:Point3d)
end

require_relative "../basegrid/material_appearance"

class MaterialAppearanceTest < Minitest::Test
  FakeModel = Struct.new(:attributes) do
    def get_attribute(dictionary, key, default = nil)
      attributes.fetch([dictionary, key], default)
    end
  end

  class ToggleModel
    attr_reader :attributes, :entities, :operations

    def initialize(entities)
      @attributes = {}
      @entities = entities
      @operations = []
    end

    def get_attribute(dictionary, key, default = nil)
      attributes.fetch([dictionary, key], default)
    end

    def set_attribute(dictionary, key, value)
      attributes[[dictionary, key]] = value
    end

    def start_operation(name, _disable_ui)
      operations << name
    end

    def commit_operation; end

    def abort_operation; end
  end

  FakeEntity = Struct.new(:material_id) do
    def get_attribute(_dictionary, key)
      key == "material_id" ? material_id : nil
    end
  end

  class RecordingAppearance < Basegrid::MaterialAppearance
    attr_reader :applied_modes

    def initialize(library:)
      super
      @applied_modes = []
    end

    def apply(_entity, _material, mode:, model:)
      @applied_modes << [mode, model]
    end
  end

  FakeNativeMaterial = Struct.new(:texture, :color)

  class CylinderFace < Sketchup::Face
    attr_reader :normal, :vertices, :mappings
    def initialize(points, z_normal = 0)
      @normal = Geom::Point3d.new(1,0,z_normal)
      @vertices = points.map { |point| Struct.new(:position).new(point) }
      @mappings = []
    end
    def position_material(material, mapping, front)
      @mappings << [material,mapping,front]
    end
  end

  def test_cylinder_texture_maps_both_sides_with_physical_scale_and_unwrapped_seam
    radius = 9.0
    points = [[170,0],[-175,0],[-175,-40],[170,-40]].map do |degrees,z|
      angle = degrees*Math::PI/180
      Geom::Point3d.new(radius*Math.cos(angle),radius*Math.sin(angle),z)
    end
    side = CylinderFace.new(points)
    cap = CylinderFace.new(points,1)
    texture = Struct.new(:width,:height).new(10,20)
    material = FakeNativeMaterial.new(texture,nil)
    appearance = Basegrid::MaterialAppearance.new(library:Object.new)
    appearance.send(:map_cylinder,[side,cap],material,radius)
    assert_equal [true,false],side.mappings.map(&:last)
    assert_empty cap.mappings
    uv = side.mappings.first[1].each_slice(2).map(&:last)
    assert_in_delta 15*Math::PI/180*radius/10,uv[1].x-uv[0].x,1e-8
    assert_in_delta(-2,uv[2].y-uv[1].y,1e-8)
    material.texture = nil
    appearance.send(:map_cylinder,[side],material,radius)
    assert_equal 2,side.mappings.length
  end

  def test_defaults_to_model_texture
    model = FakeModel.new({})

    assert_equal "texture", Basegrid::MaterialAppearance.mode(model)
    assert_equal "display_texture", Basegrid::MaterialAppearance.next_mode(model)
  end

  def test_switches_back_from_display_texture
    model = FakeModel.new({ ["Basegrid", "material_appearance_mode"] => "display_texture" })

    assert_equal "texture", Basegrid::MaterialAppearance.next_mode(model)
  end

  def test_invalid_stored_mode_falls_back_to_model_texture
    model = FakeModel.new({ ["Basegrid", "material_appearance_mode"] => "unknown" })

    assert_equal "texture", Basegrid::MaterialAppearance.mode(model)
  end

  def test_toggle_switches_to_display_and_back_to_model_texture
    entity = FakeEntity.new("concrete-1")
    model = ToggleModel.new([entity])
    library = Object.new
    library.define_singleton_method(:find) { |id| { "id" => id } }
    appearance = RecordingAppearance.new(library: library)

    first = appearance.toggle(model)
    second = appearance.toggle(model)

    assert_equal "display_texture", first[:mode]
    assert_equal "texture", second[:mode]
    assert_equal [["display_texture", model], ["texture", model]], appearance.applied_modes
    assert_equal ["Switch Material Appearance", "Switch Material Appearance"], model.operations
  end

  def test_applies_a_solid_display_color_and_removes_the_fallback_texture
    appearance = Basegrid::MaterialAppearance.new(library: Object.new)
    native = FakeNativeMaterial.new(Object.new, nil)

    appearance.send(:apply_appearance, native, { "color" => "#7f8081" })

    assert_nil native.texture
    assert_equal [127, 128, 129], [native.color.red, native.color.green, native.color.blue]
  end
end
