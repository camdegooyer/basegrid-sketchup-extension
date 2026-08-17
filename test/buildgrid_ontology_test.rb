# frozen_string_literal: true

require "minitest/autorun"
require_relative "../src/buildgrid_ontology"

class BuildgridOntologyTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def setup
    @ontology = Buildgrid::Ontology.load(root: ROOT)
  end

  def test_loads_tool_manifest_and_generated_ontology
    assert_operator @ontology.objects.length, :>=, 3_500
    assert_operator @ontology.relationships.length, :>=, 8_700
    assert_operator @ontology.tool_ids.length, :>=, 10
    assert_includes @ontology.tool_ids, "skp_tool_timber_wall_frame"
  end

  def test_wall_frame_tool_resolves_required_and_optional_objects
    bundle = @ontology.tool_bundle("skp_tool_timber_wall_frame")
    required_ids = bundle.fetch("required_objects").map { |object| object.fetch("id") }
    optional_ids = bundle.fetch("optional_objects").map { |object| object.fetch("id") }

    assert_equal "AU-TF-WALL-FRAME", bundle.fetch("root_object").fetch("id")
    assert_includes required_ids, "AU-TF-TOP-PLATE"
    assert_includes required_ids, "AU-TF-BOTTOM-PLATE"
    assert_includes required_ids, "AU-TF-COMMON-STUD"
    assert_includes optional_ids, "AU-TF-NOGGING"
    assert_includes optional_ids, "AU-TF-LINTEL"
  end

  def test_can_return_only_required_tool_objects
    objects = @ontology.tool_objects("skp_tool_external_cladding", include_optional: false)
    ids = objects.map { |object| object.fetch("id") }

    assert_includes ids, "AU-CL-EXTERNAL-WALL-CLADDING-SYSTEM"
    assert_includes ids, "AU-CL-WALL-WEATHER-BARRIER"
    refute_includes ids, "AU-CL-VENTILATED-RAINSCREEN-FACADE"
  end

  def test_relationship_lookup_supports_future_generators
    edges = @ontology.related_from("AU-TF-WALL-FRAME", relationship: "has_part")
    target_ids = edges.map { |edge| edge.fetch("to_id") }

    assert_includes target_ids, "AU-TF-COMMON-STUD"
    assert_includes target_ids, "AU-TF-TOP-PLATE"
    assert_includes target_ids, "AU-TF-BOTTOM-PLATE"
  end
end
