# frozen_string_literal: true

require "json"

module Basegrid
  class Ontology
    attr_reader :objects, :relationships, :materials, :tool_manifest

    def self.load(root: File.expand_path("..", __dir__))
      new(
        objects_path: File.join(root, "exports", "ontology.json"),
        relationships_path: File.join(root, "exports", "relationships.json"),
        materials_path: File.join(root, "exports", "materials.json"),
        tool_manifest_path: File.join(root, "config", "sketchup_tool_definitions.json")
      )
    end

    def initialize(objects_path:, relationships_path:, materials_path:, tool_manifest_path:)
      @objects = read_json(objects_path).fetch("objects")
      @relationships = read_json(relationships_path).fetch("relationships")
      @materials = read_json(materials_path).fetch("materials")
      @tool_manifest = read_json(tool_manifest_path)
      @objects_by_id = @objects.to_h { |object| [object.fetch("id"), object] }
      @relationships_by_from_id = @relationships.group_by { |relationship| relationship.fetch("from_id") }
      @materials_by_id = @materials.to_h { |material| [material.fetch("id"), material] }
      @tools_by_id = @tool_manifest.fetch("tools").to_h { |tool| [tool.fetch("id"), tool] }

      validate_tool_references!
    end

    def tool_ids
      @tools_by_id.keys
    end

    def tool(tool_id)
      @tools_by_id.fetch(tool_id)
    end

    def object(object_id)
      @objects_by_id.fetch(object_id)
    end

    def material(material_id)
      @materials_by_id.fetch(material_id)
    end

    def related_from(object_id, relationship: nil)
      edges = @relationships_by_from_id.fetch(object_id, [])
      edges = edges.select { |edge| edge.fetch("relationship") == relationship } if relationship
      edges
    end

    def tool_objects(tool_id, include_optional: true)
      definition = tool(tool_id)
      ids = [definition.fetch("root_object_id")] + definition.fetch("required_object_ids")
      ids += definition.fetch("optional_object_ids") if include_optional
      ids.uniq.map { |object_id| object(object_id) }
    end

    def tool_bundle(tool_id, include_optional: true)
      definition = tool(tool_id)
      {
        "tool" => definition,
        "root_object" => object(definition.fetch("root_object_id")),
        "required_objects" => definition.fetch("required_object_ids").uniq.map { |object_id| object(object_id) },
        "optional_objects" => include_optional ? definition.fetch("optional_object_ids").uniq.map { |object_id| object(object_id) } : [],
        "detail_levels" => @tool_manifest.fetch("detail_levels")
      }
    end

    private

    def read_json(path)
      JSON.parse(File.read(path, encoding: "UTF-8"))
    end

    def validate_tool_references!
      @tool_manifest.fetch("tools").each do |tool|
        referenced_ids = [tool.fetch("root_object_id")] + tool.fetch("required_object_ids") + tool.fetch("optional_object_ids")
        missing = referenced_ids.uniq.reject { |object_id| @objects_by_id.key?(object_id) }
        next if missing.empty?

        raise KeyError, "#{tool.fetch("id")} references missing ontology object IDs: #{missing.join(", ")}"
      end
    end
  end
end
