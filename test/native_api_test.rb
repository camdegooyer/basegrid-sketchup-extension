# frozen_string_literal: true

require "minitest/autorun"
require "ostruct"
require_relative "../basegrid/api"

module Geom
  Point3d = Struct.new(:x, :y, :z) unless const_defined?(:Point3d)
end

module Sketchup
  class << self
    attr_accessor :active_model unless method_defined?(:active_model)
  end

  class Model
    attr_reader :operations, :entities
    def initialize
      @operations = []
      @entities = Entities.new(self)
    end
    def guid = "native-model"
    def active_entities = entities
    def active_path = nil
    def start_operation(name, _disable_ui) = @operations << [:start, name]
    def commit_operation = @operations << [:commit]
    def abort_operation = @operations << [:abort]
    def title = "Native API test"
  end

  class Entities
    attr_reader :parent, :created
    def initialize(parent)
      @parent = parent
      @created = []
    end
    def add_face(points)
      face = Face.new(points)
      @created << face
      face
    end
  end

  class Face
    attr_reader :points, :distance
    attr_accessor :valid
    def initialize(points)
      @points = points
      @valid = true
    end
    def pushpull(distance) = @distance = distance
    def valid? = @valid
    def persistent_id = object_id
  end
end

class NativeAPITest < Minitest::Test
  def setup
    @model = Sketchup::Model.new
    Sketchup.active_model = @model
    @references = Basegrid::ObjectReferences.new
    @native = Basegrid::NativeAPI.new(registry: @references, model: @model)
  end

  def footprint_calls
    points = [[0, 0, 0], [6000, 0, 0], [6000, 4000, 0], [0, 4000, 0]].map do |x, y, z|
      { "$type" => "Point3d", "x" => x, "y" => y, "z" => z, "unit" => "mm" }
    end
    [
      { "id" => "entities", "target" => { "$root" => "active_model" }, "method" => "active_entities" },
      { "id" => "face", "target" => { "$result" => "entities" }, "method" => "add_face", "arguments" => [points] }
    ]
  end

  def test_native_footprint_returns_a_face_reference_and_converts_millimetres
    result = @native.run_calls(footprint_calls, "edit", "Footprint")
    face = @references.resolve(result.last.dig("result", "$ref"))
    assert_instance_of Sketchup::Face, face
    assert_in_delta 6000 / 25.4, face.points[1].x, 1e-9
    assert_in_delta 4000 / 25.4, face.points[2].y, 1e-9
    assert_equal [[:start, "Footprint"], [:commit]], @model.operations
  end

  def test_face_can_feed_the_basegrid_slab_tool_in_the_next_request
    face_ref = @native.run_calls(footprint_calls, "edit", "Footprint").last.dig("result", "$ref")
    material = { "id" => "n25", "name" => "N25" }
    library = Object.new
    library.define_singleton_method(:load) {}
    library.define_singleton_method(:concrete_materials) { [material] }
    library.define_singleton_method(:takeoff_groups_for_role) { |_role| [] }
    slab = OpenStruct.new(persistent_id: 123)
    slab.define_singleton_method(:get_attribute) { |*_args| '{"quantity":3.6,"unit":"m3","material_id":"n25"}' }
    received_face = nil
    builder = Object.new
    builder.define_singleton_method(:build) do |_model, face, *_args|
      received_face = face
      slab
    end
    api = Basegrid::API.new(registry: @references, model: @model, library: library, main: Object.new)
    Basegrid::ConcreteSlabTool.stub(:new, builder) do
      result = api.call("basegrid_create_slab", { "model_guid" => @model.guid, "face_ref" => face_ref, "thickness_mm" => 150, "material_id" => "n25" }, permission_mode: "edit")
      assert result["ok"], result.inspect
      assert_equal 3.6, result.dig("result", "takeoff", "quantity")
    end
    assert_same @model.entities.created.first, received_face
  end

  def test_failed_batch_aborts_the_geometry_operation
    calls = footprint_calls + [{ "id" => "fail", "target" => { "$result" => "face" }, "method" => "eval", "arguments" => ["bad"] }]
    assert_raises(RuntimeError) { @native.run_calls(calls, "full", "Footprint") }
    assert_equal [[:start, "Footprint"], [:abort]], @model.operations
  end

  def test_inspect_allows_reads_but_not_geometry_writes
    @native.run_calls(footprint_calls.first(1), "inspect", "Read")
    assert_empty @model.operations
    assert_raises(RuntimeError) { @native.run_calls(footprint_calls, "inspect", "Denied") }
    assert_empty @model.entities.created
    assert_empty @model.operations
  end

  def test_private_ruby_and_transaction_controls_are_not_remotely_callable
    %w[instance_eval send public_send start_operation commit_operation abort_operation].each do |method|
      assert_raises(RuntimeError) do
        @native.run_calls([{ "id" => "blocked", "target" => { "$root" => "active_model" }, "method" => method }], "full", "Denied")
      end
    end
    assert_empty @model.operations
  end

  def test_deleted_faces_and_another_model_cannot_reuse_references
    ref = @native.run_calls(footprint_calls, "edit", "Footprint").last.dig("result", "$ref")
    @references.resolve(ref).valid = false
    assert_raises(RuntimeError) { @references.resolve(ref) }
    Sketchup.active_model = Sketchup::Model.new
    assert_raises(RuntimeError) { @references.resolve(ref) }
  end

  def test_invalid_units_duplicate_ids_and_future_results_are_rejected
    calls = footprint_calls
    calls.last["arguments"][0][0]["unit"] = "guess"
    assert_raises(RuntimeError) { @native.run_calls(calls, "edit", "Denied") }
    assert_empty @model.operations
    assert_raises(RuntimeError) { @native.run_calls(footprint_calls.first(1) * 2, "edit", "Denied") }
    assert_raises(RuntimeError) { @native.run_calls([footprint_calls.last], "edit", "Denied") }
  end
end
