# frozen_string_literal: true
require "minitest/autorun"
require "ostruct"
require_relative "../basegrid/strip_footing_tool"

module Sketchup
  class << self
    attr_accessor :active_model
  end
end

class StripFootingToolTest < Minitest::Test
  def setup
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
