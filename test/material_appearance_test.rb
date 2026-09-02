# frozen_string_literal: true

require "minitest/autorun"

module Buildgrid
  class MaterialLibrary
  end
end

module Sketchup
  Color = Struct.new(:red, :green, :blue) unless const_defined?(:Color)
end

require_relative "../buildgrid/material_appearance"

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

  class RecordingAppearance < Buildgrid::MaterialAppearance
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

  def test_defaults_to_model_texture
    model = FakeModel.new({})

    assert_equal "texture", Buildgrid::MaterialAppearance.mode(model)
    assert_equal "display_texture", Buildgrid::MaterialAppearance.next_mode(model)
  end

  def test_switches_back_from_display_texture
    model = FakeModel.new({ ["Buildgrid", "material_appearance_mode"] => "display_texture" })

    assert_equal "texture", Buildgrid::MaterialAppearance.next_mode(model)
  end

  def test_invalid_stored_mode_falls_back_to_model_texture
    model = FakeModel.new({ ["Buildgrid", "material_appearance_mode"] => "unknown" })

    assert_equal "texture", Buildgrid::MaterialAppearance.mode(model)
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
    appearance = Buildgrid::MaterialAppearance.new(library: Object.new)
    native = FakeNativeMaterial.new(Object.new, nil)

    appearance.send(:apply_appearance, native, { "color" => "#7f8081" })

    assert_nil native.texture
    assert_equal [127, 128, 129], [native.color.red, native.color.green, native.color.blue]
  end
end
