# frozen_string_literal: true
require_relative "api_test"
require "minitest/mock"

module Sketchup
  class Group; end unless const_defined?(:Group)
  def self.read_default(_section,_key,fallback) = fallback unless respond_to?(:read_default)
  def self.write_default(*_args) = true unless respond_to?(:write_default)
end

class BasegridAPITest
  NEW_COMMANDS = {
    "basegrid_create_starter_bars" => {"points_mm"=>[[0,0,0],[1000,0,0]]},
    "basegrid_create_step_z_bars" => {"pairs"=>[{"upper"=>{"ends"=>[[0,0,200],[1000,0,200]]},"lower"=>{"ends"=>[[0,0,0],[1000,0,0]]}}]},
    "basegrid_create_concrete_pier" => {"top_center_mm"=>[0,0,0]},
    "basegrid_create_flashing" => {"points_mm"=>[[0,0,0],[1000,0,0]]},
    "basegrid_create_structural_steel" => {"start_mm"=>[0,0,0],"end_mm"=>[0,0,3000],"settings"=>{"material_id"=>"steel"}}
  }.freeze

  def test_flashing_profile_api_and_flat_create_settings
    data={}
    read=->(section,key,fallback) { data.fetch([section,key],fallback) }
    write=->(section,key,value) { data[[section,key]]=value }
    Sketchup.stub(:read_default,read) do
      Sketchup.stub(:write_default,write) do
        args={"name"=>"Flat","settings"=>{"lengths_mm"=>[100],"angles_deg"=>[],"material_id"=>"stock","anchor_index"=>1}}
        assert invoke("basegrid_save_flashing_profile",args)["ok"]
        listed=invoke("basegrid_list_flashing_profiles",{},mode:"inspect")
        assert_equal "Flat",listed.dig("result","profiles",0,"name")
        assert_equal [],listed.dig("result","profiles",0,"settings","angles_deg")
        builder=Basegrid::FlashingTool.new
        calls=[]
        builder.define_singleton_method(:build) { |*pos,**kw| calls << [pos,kw]; GeneratedGroup.new(Basegrid::FlashingTool::TOOL_ID) }
        Basegrid::FlashingTool.stub(:new,builder) do
          result=invoke("basegrid_create_flashing",{"model_guid"=>@model.guid,"points_mm"=>[[0,0,0],[1000,0,0]],"profile_name"=>"Flat","settings"=>{"mirror"=>true}})
          assert result["ok"],result.inspect
          assert_equal [100.0],calls.first.first[2]["lengths_mm"]
          assert_equal "stock",calls.first.first[2]["material_id"]
          assert_equal true,calls.first.first[2]["mirror"]
        end
        assert invoke("basegrid_save_flashing_profile",args.merge("previous_name"=>"Flat","name"=>"Flat renamed"))["ok"]
        assert invoke("basegrid_delete_flashing_profile",{"name"=>"Flat renamed"})["ok"]
        assert_equal [],invoke("basegrid_list_flashing_profiles").dig("result","profiles")
      end
    end
  end

  def test_new_endpoints_require_model_guard_and_recursively_validate
    NEW_COMMANDS.each do |name,args|
      assert_error "INVALID_ARGUMENTS",invoke(name,args)
      assert_error "MODEL_CHANGED",invoke(name,args.merge("model_guid"=>"other"))
      args = args.merge("model_guid"=>@model.guid)
      assert_error "INVALID_ARGUMENTS",invoke(name,args.merge("settings"=>{"invented"=>123}))
    end
    args = {"model_guid"=>@model.guid,"points_mm"=>[[0,0,0],[1,2,"bad"]]}
    assert_error "INVALID_ARGUMENTS",invoke("basegrid_create_starter_bars",args)
    assert_error "INVALID_ARGUMENTS",invoke("basegrid_create_flashing",args.merge("points_mm"=>[[0,0,0],[1,2,Float::NAN]]))
    assert_error "INVALID_ARGUMENTS",invoke("basegrid_create_step_z_bars",{"model_guid"=>@model.guid,"pairs"=>[{"upper"=>{"ends"=>[[0,0,0]]},"lower"=>{}}]})
    assert_empty @model.operations
  end

  def test_new_catalogue_entries_expose_actual_schemas
    NEW_COMMANDS.each_key do |name|
      id = Basegrid::API::DRAWING_TOOLS.find { |_,_,n| n == name }.first
      result = invoke("basegrid_tool_catalog",{"tool_id"=>id}).fetch("result")
      assert_equal name,result["mcp_tool"]
      assert_equal Basegrid::API::TOOLS.find { |t| t["name"] == name }["inputSchema"],result["inputSchema"]
    end
  end

  class GeneratedGroup < Sketchup::Group
    attr_accessor :tool_id, :locked, :valid
    def initialize(tool_id)
      @tool_id,@locked,@valid = tool_id,false,true
    end
    def valid? = @valid
    def locked? = @locked
    def persistent_id = 777
    def entities = []
    def get_attribute(_dict,key,*_default)
      key == "tool_id" ? tool_id : '{"settings":{"bar_material":"N12"}}'
    end
  end

  class DrawingFrame
    def inverse = self
    def *(_other) = self
    def self.axes(*_args) = new
  end
  class DrawingVector
    def initialize(*_args); end
  end
  class DrawingPoint
    def initialize(values) = @values = values
    def values = @values
    def distance(other) = Math.sqrt(values.zip(other.values).sum { |a,b| (b-a)**2 })/25.4
  end

  def with_drawing_geometry
    Object.const_set(:Geom,Module.new) unless defined?(Geom)
    originals = %i[Vector3d Transformation].to_h { |key| [key,Geom.const_defined?(key,false) ? Geom.const_get(key) : nil] }
    originals.each_key { |key| Geom.send(:remove_const,key) if Geom.const_defined?(key,false) }
    Geom.const_set(:Vector3d,DrawingVector)
    Geom.const_set(:Transformation,DrawingFrame)
    @model.define_singleton_method(:edit_transform) { DrawingFrame.new }
    @api.stub(:api_point,->(values) { DrawingPoint.new(values) }) { yield }
  ensure
    originals&.each do |key,value|
      Geom.send(:remove_const,key)
      Geom.const_set(key,value) if value
    end
  end

  def test_all_new_endpoints_dispatch_to_existing_builders_and_return_takeoff
    classes = [Basegrid::StarterBarTool,Basegrid::StarterBarTool,Basegrid::ConcretePierTool,Basegrid::FlashingTool,Basegrid::StructuralSteelTool]
    with_drawing_geometry do
      NEW_COMMANDS.zip(classes).each do |(name,args),klass|
        calls = []
        id = Basegrid::API::DRAWING_TOOLS.find { |_,_,n| n == name }.first
        group = GeneratedGroup.new(id)
        builder = Object.new
        method = name.include?("step_z") ? :build_step_z : :build
        builder.define_singleton_method(method) { |*pos,**kw| calls << [pos,kw]; group }
        builder.define_singleton_method(:frame) { |*_points| DrawingFrame.new }
        klass.stub(:new,builder) do
          result = invoke(name,args.merge("model_guid"=>@model.guid))
          assert result["ok"],result.inspect
          assert_equal 777,result.dig("result","entity","persistent_id")
          assert_equal "N12",result.dig("result","parameters","settings","bar_material")
          assert_equal [],result.dig("result","takeoff")
          assert_equal 1,calls.length
          assert_same @model,calls.first.first.first
          assert_nil calls.first.last[:replace]
          if name == "basegrid_create_structural_steel"
            assert_in_delta 3000,calls.first.first[1]["length_mm"]
            assert_equal "steel",calls.first.first[1]["material_id"]
          end
        end
      end
    end
  end

  def test_replacement_rejects_wrong_type_locked_or_outside_context
    group = GeneratedGroup.new(Basegrid::StarterBarTool::TOOL_ID)
    @model.active_entities = [group]
    ref = @registry.register(group)
    args = {"model_guid"=>@model.guid,"replace_ref"=>ref,"points_mm"=>[[0,0,0],[1000,0,0]]}
    group.locked = true
    assert_error "INVALID_REPLACEMENT",invoke("basegrid_create_starter_bars",args)
    group.locked = false
    group.tool_id = "other"
    assert_error "INVALID_REPLACEMENT",invoke("basegrid_create_starter_bars",args)
    group.tool_id = Basegrid::StarterBarTool::TOOL_ID
    @model.active_entities = []
    assert_error "INVALID_REPLACEMENT",invoke("basegrid_create_starter_bars",args)
    @model.active_entities = [group]
    builder = Object.new
    builder.define_singleton_method(:build) do |*_pos,**kw|
      raise "Replacement not forwarded" unless kw[:replace] == group
      group
    end
    Basegrid::StarterBarTool.stub(:new,builder) { assert invoke("basegrid_create_starter_bars",args)["ok"] }
  end

  def test_slab_and_footing_replacement_dispatch_and_guards
    [
      ["basegrid_create_slab", Basegrid::ConcreteSlabTool, @arguments],
      ["basegrid_create_strip_footing", Basegrid::StripFootingTool,
       {"model_guid"=>@model.guid,"paths_mm"=>[[[0,0,0],[3000,0,0]]]}]
    ].each do |name,klass,args|
      group = GeneratedGroup.new(klass::TOOL_ID)
      @model.active_entities = [group]
      args = args.merge("replace_ref"=>@registry.register(group))
      builder = Object.new
      calls = []
      builder.define_singleton_method(:build) do |*pos,**kw|
        calls << [pos,kw]
        name.end_with?("strip_footing") ? {entity: group,volume_m3: 0.6,warnings: []} : group
      end
      klass.stub(:new,builder) do
        assert invoke(name,args)["ok"]
        assert_same group,calls.last.last[:replace]
        group.locked = true
        assert_error "INVALID_REPLACEMENT",invoke(name,args)
        group.locked = false
        group.valid = false
        assert_error "INVALID_REPLACEMENT",invoke(name,args)
        group.valid = true
        group.tool_id = "other"
        assert_error "INVALID_REPLACEMENT",invoke(name,args)
        group.tool_id = klass::TOOL_ID
        @model.active_entities = []
        assert_error "INVALID_REPLACEMENT",invoke(name,args)
        @model.active_entities = [group]
        @model.active_path = [OpenStruct.new(locked?: true)]
        assert_error "LOCKED_CONTEXT",invoke(name,args)
        @model.active_path = nil
        assert_error "INVALID_ARGUMENTS",invoke(name,args.merge("replace_ref"=>""))
        assert_error "MODEL_CHANGED",invoke(name,args.merge("model_guid"=>"other"))
        assert_equal 1,calls.length
      end
    end
  end

  def test_footing_api_forwards_z_bar_controls_and_material
    group = GeneratedGroup.new(Basegrid::StripFootingTool::TOOL_ID)
    args = {"model_guid"=>@model.guid,"paths_mm"=>[[[0,0,0],[3000,0,0]]],
            "settings"=>{"include_step_z_bars"=>true,"step_z_threshold_mm"=>200},"materials"=>{"z_bars"=>"n12"}}
    builder = Object.new
    builder.define_singleton_method(:build) do |_model,_paths,settings,materials,**_kw|
      raise "Missing Z bar controls" unless settings["include_step_z_bars"] && settings["step_z_threshold_mm"] == 200 && materials["z_bars"] == "n12"
      {entity: group,volume_m3: 0.6,warnings: []}
    end
    Basegrid::StripFootingTool.stub(:new,builder) { assert invoke("basegrid_create_strip_footing",args)["ok"] }
    assert_error "INVALID_ARGUMENTS",invoke("basegrid_create_strip_footing",args.merge("settings"=>{"include_step_z_bars"=>"true"}))
    assert_error "INVALID_ARGUMENTS",invoke("basegrid_create_strip_footing",args.merge("settings"=>{"step_z_threshold_mm"=>-1}))
  end
end
