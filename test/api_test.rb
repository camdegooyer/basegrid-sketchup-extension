# frozen_string_literal: true

require "minitest/autorun"
require "ostruct"
require_relative "../basegrid/api"

module Basegrid
  EXTENSION_VERSION = "test" unless const_defined?(:EXTENSION_VERSION)
end

module Sketchup
  class Face; end unless const_defined?(:Face)
  class << self
    attr_accessor :active_model unless method_defined?(:active_model)
  end
end

class BasegridAPITest < Minitest::Test
  class Registry
    def initialize
      @objects = {}
    end

    def register(entity)
      key = "su_#{entity.object_id}"
      @objects[key] = entity
      key
    end

    def resolve(key)
      @objects.fetch(key)
    end
  end

  class Face < Sketchup::Face
    attr_accessor :model, :parent, :normal, :is_valid

    def initialize(model)
      @model = model
      @is_valid = true
      @parent = model.active_entities.parent
      @normal = Vector.new
    end

    def valid? = @is_valid
    def persistent_id = object_id
  end

  class Vector
    def axes = [self, self, self]
    def transform(_transformation) = self
    def cross(_other) = self
    def length = 1
    def normalize! = self
    def z = 1
  end

  class Model
    attr_accessor :selection, :active_entities, :active_path
    attr_reader :operations

    def initialize
      @selection = []
      @active_entities = OpenStruct.new(parent: self)
      @active_path = nil
      @operations = []
    end

    def guid = "model-1"
    def title = "Test Model"
    def entities = []
    def edit_transform = nil
    def get_attribute(_dictionary, _key, default = nil) = default
    def abort_operation = @operations << :abort
  end

  class Library
    def load; end
    def concrete_materials = materials.first(1)
    def materials
      [{ "id" => "n25", "name" => "N25", "material_type_id" => "concrete", "texture" => { "image_url" => "secret-signed-url" } },
       { "id" => "retired", "name" => "Old Concrete", "status" => "retired" }]
    end
    def takeoff_groups_for_role(_role) = [{ "id" => "slabs", "name" => "Concrete Slabs" }]
  end

  class Main
    def oauth_connection = OpenStruct.new(connected?: false)
    def legacy_material_sync_token = ""
    def material_sync_token = ""
  end

  def setup
    @model = Model.new
    Sketchup.active_model = @model
    @registry = Registry.new
    @face = Face.new(@model)
    @face_ref = @registry.register(@face)
    @api = Basegrid::API.new(registry: @registry, model: @model, library: Library.new, main: Main.new)
    @arguments = { "model_guid" => "model-1", "face_ref" => @face_ref, "thickness_mm" => 100, "material_id" => "n25" }
  end

  def invoke(name, arguments = {}, mode: "edit")
    @api.call(name, arguments, permission_mode: mode)
  end

  def assert_error(code, result)
    assert_equal false, result["ok"], result.inspect
    assert_equal code, result.dig("error", "code"), result.inspect
  end

  def test_inspect_mode_blocks_every_basegrid_write
    Basegrid::API::TOOLS.reject { |item| item.dig("annotations", "readOnlyHint") || %w[basegrid_invoke basegrid_batch].include?(item["name"]) }.each do |tool|
      args = case tool["name"]
             when "basegrid_create_slab" then @arguments
             when "basegrid_set_appearance" then { "model_guid" => "model-1", "mode" => "model" }
             when "basegrid_set_slab_tag_folder" then { "folder" => "Structure" }
             else {}
             end
      assert_error "PERMISSION_DENIED", invoke(tool["name"], args, mode: "inspect")
    end
  end

  def test_rejects_unknown_tools_and_arguments_and_invalid_dimensions
    assert_error "UNKNOWN_TOOL", invoke("eval", { "source" => "anything" })
    assert_error "INVALID_ARGUMENTS", invoke("basegrid_status", { "token" => "secret" })
    [0, -100, Float::INFINITY, Float::NAN, "100", nil].each do |value|
      assert_error "INVALID_ARGUMENTS", invoke("basegrid_create_slab", @arguments.merge("thickness_mm" => value))
    end
    assert_error "INVALID_ARGUMENTS", invoke("basegrid_create_slab", @arguments.except("model_guid"))
  end

  def test_rejects_wrong_model_material_and_group_before_drawing
    assert_error "MODEL_CHANGED", invoke("basegrid_create_slab", @arguments.merge("model_guid" => "other"))
    assert_error "INVALID_MATERIAL", invoke("basegrid_create_slab", @arguments.merge("material_id" => "retired"))
    assert_error "INVALID_TAKEOFF_GROUP", invoke("basegrid_create_slab", @arguments.merge("takeoff_group_id" => "other"))
  end

  def test_status_returns_face_refs_without_credentials
    @model.selection = [@face]
    result = invoke("basegrid_status", {}, mode: "inspect")
    assert result["ok"], result.inspect
    assert_equal @face_ref, result.dig("result", "selected_faces", 0, "$ref")
    assert_equal "model-1", result.dig("result", "model_guid")
    assert_equal false, result.dig("result", "connected")
    refute_includes JSON.generate(result), "token"
  end

  def test_material_list_uses_eligible_ids_and_excludes_texture_credentials
    result = invoke("basegrid_list_materials")
    assert_equal ["n25"], result.dig("result", "materials").map { |item| item["id"] }
    assert_equal "slabs", result.dig("result", "takeoff_groups", 0, "id")
    refute_includes JSON.generate(result), "secret-signed-url"
    assert_error "INVALID_ARGUMENTS", invoke("basegrid_list_materials", { "limit" => 101 })
  end

  def test_slab_invokes_the_actual_builder_with_material_and_group_records
    slab = OpenStruct.new(persistent_id: 123)
    slab.define_singleton_method(:get_attribute) { |*_args| '{"quantity":2.4,"unit":"m3","material_id":"n25"}' }
    captured = nil
    builder = Object.new
    builder.define_singleton_method(:build) do |*args|
      captured = args
      slab
    end
    Basegrid::ConcreteSlabTool.stub(:new, builder) do
      result = invoke("basegrid_create_slab", @arguments.merge("takeoff_group_id" => "slabs"))
      assert result["ok"], result.inspect
      assert_equal 2.4, result.dig("result", "takeoff", "quantity")
      assert_equal slab, @registry.resolve(result.dig("result", "entity", "$ref"))
    end
    assert_equal [@model, @face, 100], captured.first(3)
    assert_equal "n25", captured[3]["id"]
    assert_equal ["slabs"], captured[4].map { |item| item["id"] }
  end

  def test_selection_requires_exactly_one_face
    args = @arguments.except("face_ref")
    assert_error "INVALID_FACE", invoke("basegrid_create_slab", args)
    @model.selection = [@face, Object.new]
    assert_error "INVALID_FACE", invoke("basegrid_create_slab", args)
  end

  def test_geometry_guard_rejects_stale_wrong_context_and_locked_faces_before_operation
    builder = Basegrid::ConcreteSlabTool.new(library: Library.new)
    assert_equal @face, builder.validate_face!(@model, @face)
    @face.is_valid = false
    assert_raises(RuntimeError) { builder.build(@model, @face, 100, {}) }
    @face.is_valid = true
    @face.parent = Object.new
    assert_raises(RuntimeError) { builder.build(@model, @face, 100, {}) }
    @face.parent = @model
    @model.active_path = [OpenStruct.new(locked?: true)]
    assert_raises(RuntimeError) { builder.build(@model, @face, 100, {}) }
    assert_empty @model.operations
  end

  def test_geometry_guard_rejects_nonfinite_thickness_before_operation
    builder = Basegrid::ConcreteSlabTool.new(library: Library.new)
    assert_raises(RuntimeError) { builder.build(@model, @face, Float::INFINITY, {}) }
    assert_empty @model.operations
  end

  def test_takeoff_csv_and_disconnected_sync
    assert_includes invoke("basegrid_takeoff", { "format" => "csv" }).dig("result", "csv"), "Takeoff Group,Group ID"
    assert_error "NOT_CONNECTED", invoke("basegrid_sync_materials")
  end

  def test_catalogue_does_not_advertise_planned_generators_as_implemented
    tools = invoke("basegrid_tool_catalog").dig("result", "tools")
    assert_equal ["concrete.slab_from_face"], tools.select { |item| item["status"] == "implemented" }.map { |item| item["id"] }
    wall = invoke("basegrid_tool_catalog", { "tool_id" => "skp_tool_timber_wall_frame" })
    assert_equal "definition_only", wall.dig("result", "status")
    assert_error "UNKNOWN_TOOL", invoke("basegrid_tool_catalog", { "tool_id" => "made-up" })
  end
end
