# frozen_string_literal: true

require "json"
require_relative "material_library"
require_relative "concrete_slab_tool"
require_relative "material_appearance"
require_relative "takeoff"
require_relative "native_api"

module Basegrid
  # Structured entry points shared by the local HTTP bridge and MCP connector.
  # Model work runs on Basegrid's main-thread queue; drawing tools own Undo.
  class API
    RESOURCE_ROOT = File.directory?(File.join(__dir__, "config")) ? __dir__ : File.expand_path("..", __dir__)
    TOOLS = JSON.parse(File.read(File.join(RESOURCE_ROOT, "config", "basegrid_api_tools.json"), encoding: "UTF-8")).freeze

    class Error < StandardError
      attr_reader :code

      def initialize(code, message)
        @code = code
        super(message)
      end
    end

    def initialize(registry:, model: Sketchup.active_model, library: MaterialLibrary.new, main: Main)
      @registry = registry
      @model = model
      @library = library
      @main = main
    end

    def call(name, arguments = {}, permission_mode: "inspect")
      tool = TOOLS.find { |item| item.fetch("name") == name }
      raise Error.new("UNKNOWN_TOOL", "Unknown Basegrid tool: #{name}") unless tool

      validate_arguments!(tool.fetch("inputSchema"), arguments)
      unless %w[inspect edit full].include?(permission_mode)
        raise Error.new("PERMISSION_DENIED", "Unknown bridge permission mode.")
      end
      native_dispatch = %w[basegrid_invoke basegrid_batch].include?(name)
      if !tool.dig("annotations", "readOnlyHint") && permission_mode == "inspect" && !native_dispatch
        raise Error.new("PERMISSION_DENIED", "This command requires Basegrid API edit mode.")
      end
      if arguments.key?("model_guid") && (!@model || @model.guid != arguments["model_guid"])
        raise Error.new("MODEL_CHANGED", "The model has changed. Call basegrid_status before editing.")
      end

      result = case name
               when "basegrid_status" then status(permission_mode)
               when "basegrid_list_materials" then list_materials(arguments)
               when "basegrid_sync_materials" then sync_materials
               when "basegrid_create_slab" then create_slab(arguments)
               when "basegrid_takeoff" then takeoff(arguments)
               when "basegrid_set_appearance" then set_appearance(arguments)
               when "basegrid_set_slab_tag_folder" then set_folder(arguments)
               when "basegrid_tool_catalog" then tool_catalog(arguments)
               when "basegrid_find_objects" then find_objects(arguments)
               else NativeAPI.new(registry: @registry, model: @model).call(name, arguments, permission_mode)
               end
      { "ok" => true, "result" => result }
    rescue Error => e
      { "ok" => false, "error" => { "code" => e.code, "message" => e.message } }
    rescue StandardError => e
      { "ok" => false, "error" => { "code" => "BASEGRID_ERROR", "message" => e.message } }
    end

    private

    def validate_arguments!(schema, arguments)
      raise Error.new("INVALID_ARGUMENTS", "arguments must be an object.") unless arguments.is_a?(Hash)

      properties = schema.fetch("properties")
      unknown = arguments.keys - properties.keys
      missing = schema.fetch("required") - arguments.keys
      raise Error.new("INVALID_ARGUMENTS", "Unknown arguments: #{unknown.join(', ')}") unless unknown.empty?
      raise Error.new("INVALID_ARGUMENTS", "Required arguments: #{missing.join(', ')}") unless missing.empty?

      arguments.each do |key, value|
        rule = properties.fetch(key)
        valid = case rule.fetch("type")
                when "string" then value.is_a?(String)
                when "boolean" then value == true || value == false
                when "integer" then value.is_a?(Integer)
                when "number" then value.is_a?(Numeric) && value.finite?
                when "object" then value.is_a?(Hash)
                when "array" then value.is_a?(Array)
                else false
                end
        valid &&= rule["enum"].include?(value) if rule.key?("enum")
        valid &&= value.length >= rule["minLength"] if rule.key?("minLength")
        valid &&= value.length <= rule["maxLength"] if rule.key?("maxLength")
        valid &&= value >= rule["minimum"] if rule.key?("minimum")
        valid &&= value <= rule["maximum"] if rule.key?("maximum")
        valid &&= value > rule["exclusiveMinimum"] if rule.key?("exclusiveMinimum")
        valid &&= value.length >= rule["minItems"] if rule.key?("minItems")
        valid &&= value.length <= rule["maxItems"] if rule.key?("maxItems")
        raise Error.new("INVALID_ARGUMENTS", "Invalid #{key}: expected #{rule.fetch('type')} within its declared limits.") unless valid
      end
    end

    def require_model!
      raise Error.new("NO_MODEL", "Open a SketchUp model first.") unless @model

      @model
    end

    def entity_reference(entity)
      { "$ref" => @registry.register(entity), "ruby_class" => entity.class.name,
        "persistent_id" => entity.persistent_id }
    end

    def status(permission_mode)
      @library.load
      {
        "version" => Basegrid::EXTENSION_VERSION,
        "permission_mode" => permission_mode,
        "model_guid" => @model&.guid,
        "model_title" => @model&.title,
        "selected_faces" => @model ? @model.selection.grep(Sketchup::Face).map { |face| entity_reference(face) } : [],
        "connected" => @main.oauth_connection.connected? || !@main.legacy_material_sync_token.empty?,
        "cloud_drawing" => @main.respond_to?(:cloud_connection_status) ? @main.cloud_connection_status : nil,
        "cached_material_count" => @library.materials.length,
        "compatible_concrete_count" => @library.concrete_materials.length,
        "appearance" => @model ? MaterialAppearance.mode(@model) : nil,
        "implemented_drawing_tools" => [ConcreteSlabTool::TOOL_ID],
        "takeoff_basis" => "Stored at slab creation; manual geometry edits do not recalculate quantity."
      }
    end

    def list_materials(arguments)
      @library.load
      materials = arguments.fetch("concrete_only", true) ? @library.concrete_materials : @library.materials
      query = arguments.fetch("query", "").downcase
      materials = materials.select { |item| item.fetch("name").downcase.include?(query) }
      offset = arguments.fetch("offset", 0)
      items = materials.drop(offset).first(arguments.fetch("limit", 50)).map do |item|
        # Signed download URLs and local cache paths are not part of the API.
        item.slice("id", "name", "material_type_id", "status")
      end
      {
        "materials" => items, "total" => materials.length, "offset" => offset,
        "takeoff_groups" => @library.takeoff_groups_for_role(ConcreteSlabTool::GENERATED_ROLE_ID).map { |item| item.slice("id", "name") }
      }
    end

    def sync_materials
      token = @main.material_sync_token
      if token.empty?
        raise Error.new("NOT_CONNECTED", "Use Extensions > Basegrid > Materials > Connect in SketchUp, then retry sync.")
      end
      @main.sync_with_token(token)
    end

    def create_slab(arguments)
      model = require_model!
      @library.load
      material = @library.concrete_materials.find { |item| item.fetch("id") == arguments.fetch("material_id") }
      raise Error.new("INVALID_MATERIAL", "Choose a compatible concrete material from basegrid_list_materials.") unless material

      group_id = arguments.fetch("takeoff_group_id", "")
      groups = @library.takeoff_groups_for_role(ConcreteSlabTool::GENERATED_ROLE_ID).select { |item| item.fetch("id") == group_id }
      if !group_id.empty? && groups.empty?
        raise Error.new("INVALID_TAKEOFF_GROUP", "That takeoff group is not permitted for the slab role.")
      end
      face = if arguments.key?("face_ref")
               @registry.resolve(arguments.fetch("face_ref"))
             else
               selection = model.selection.to_a
               unless selection.length == 1 && selection.first.is_a?(Sketchup::Face)
                 raise Error.new("INVALID_FACE", "Supply face_ref or select exactly one horizontal face.")
               end
               selection.first
             end
      slab = ConcreteSlabTool.new(library: @library).build(model, face, arguments.fetch("thickness_mm"), material, groups)
      { "entity" => entity_reference(slab),
        "takeoff" => JSON.parse(slab.get_attribute(Takeoff::DICTIONARY, Takeoff::KEY)) }
    end

    def takeoff(arguments)
      records = Takeoff.records(require_model!)
      return { "csv" => Takeoff.grouped_csv(records) } if arguments.fetch("format", "json") == "csv"

      { "object_count" => records.length, "summary" => Takeoff.summary_rows(records),
        "groups" => Takeoff.grouped_rows(records), "records" => records,
        "quantity_basis" => "Stored at creation; not recalculated from later geometry edits." }
    end

    def set_appearance(arguments)
      model = require_model!
      target = arguments.fetch("mode") == "model" ? MaterialAppearance::MODEL_MODE : MaterialAppearance::DISPLAY_MODE
      return { "mode" => target, "changed" => 0 } if MaterialAppearance.mode(model) == target

      @library.load
      result = MaterialAppearance.new(library: @library).toggle(model)
      model.active_view.invalidate
      result
    end

    def set_folder(arguments)
      folder = arguments.fetch("folder").split("/").map(&:strip).reject(&:empty?).join("/")
      Sketchup.write_default("Basegrid", "slab_concrete_folder", folder)
      { "folder" => folder, "applies_to" => "New slab role tags only." }
    end

    def tool_catalog(arguments)
      implemented = { "id" => ConcreteSlabTool::TOOL_ID, "label" => "Concrete Slab from Face",
                      "status" => "implemented", "mcp_tool" => "basegrid_create_slab" }
      return implemented if arguments["tool_id"] == implemented["id"]

      manifest = JSON.parse(File.read(File.join(RESOURCE_ROOT, "config", "sketchup_tool_definitions.json"), encoding: "UTF-8"))
      if arguments.key?("tool_id")
        definition = manifest.fetch("tools").find { |item| item.fetch("id") == arguments["tool_id"] }
        raise Error.new("UNKNOWN_TOOL", "Unknown drawing tool ID.") unless definition

        return definition.merge("status" => "definition_only")
      end
      { "tools" => [implemented] + manifest.fetch("tools").map do |item|
        item.slice("id", "label", "category", "draw_input").merge("status" => "definition_only")
      end }
    end

    def ontology
      require File.join(RESOURCE_ROOT, "src", "basegrid_ontology")
      @ontology ||= Ontology.load
    end

    def find_objects(arguments)
      if arguments.key?("object_id")
        id = arguments.fetch("object_id")
        return { "object" => ontology.object(id), "relationships" => ontology.related_from(id) }
      end
      query = arguments.fetch("query", "").downcase
      objects = ontology.objects.select do |item|
        [item["id"], item["canonical_name"], item["preferred_australian_name"]].any? { |value| value.to_s.downcase.include?(query) }
      end
      offset = arguments.fetch("offset", 0)
      { "total" => objects.length, "offset" => offset,
        "objects" => objects.drop(offset).first(arguments.fetch("limit", 25)).map do |item|
          item.slice("id", "canonical_name", "discipline", "definition_plain")
        end }
    end
  end
end
