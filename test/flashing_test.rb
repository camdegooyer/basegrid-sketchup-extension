# frozen_string_literal: true
require "minitest/autorun"
require "ostruct"
require_relative "../basegrid/flashing_tool"

module Sketchup
  InputPoint = Struct.new(:position) do
    def valid? = !position.nil?
  end unless const_defined?(:InputPoint)
  class << self
    attr_accessor :active_model, :defaults, :status_text
    def read_default(section,key,fallback) = (defaults || {}).fetch([section,key],fallback)
    def write_default(section,key,value) = (self.defaults ||= {})[[section,key]] = value
    def set_status_text(text) = self.status_text = text
    def platform = :platform_win
  end
end
module UI
  class << self
    attr_accessor :timers
    def start_timer(_delay,_repeat,&block)
      (self.timers ||= []) << block
      timers.length
    end
  end
end

class FlashingTest < Minitest::Test
  G = Basegrid::FlashingGeometry
  def setup
    types = ["Flashings Colorbond","Flashings Zincalume","Flashings Perforated"].each_with_index.map { |name,i| { "id" => i.to_s,"name" => name,"profile" => "flashing","uom" => "m" } }
    @library = OpenStruct.new(material_types: types,materials: [material("a",150,2),material("b",200,2),material("c",150,3)])
    @tool = Basegrid::FlashingTool.new(library: @library)
    UI.timers = []
    Sketchup.defaults = {}
  end
  def material(id,girth,folds,type: "0")
    { "id" => id,"name" => id,"material_type_id" => type,"dimensions_mm" => { "girth_mm" => girth,"folds" => folds,"thickness_mm" => 0.55 } }
  end
  def test_material_rounding_and_exact_boundary
    assert_equal "a", @tool.match_material({})[:material]["id"]
    assert_equal "a", @tool.match_material("lengths_mm" => [50,50,50])[:material]["id"]
    assert_equal "b", @tool.match_material("lengths_mm" => [50,50,50.01])[:material]["id"]
    assert_equal "a", @tool.match_material("lengths_mm" => [50,50],"angles_deg" => [90])[:material]["id"]
  end

  def test_flat_profile_matching_and_closed_positive_volume
    input = { "lengths_mm" => [100], "angles_deg" => [] }
    assert_equal 2, @tool.match_material(input)[:stock_folds]
    @library.materials << material("flat",100,0)
    assert_equal "flat", @tool.match_material(input)[:material]["id"]
    [0,1].product([true,false],%w[left right]).each do |anchor,mirror,side|
      plan = G.plan([[0,0,0],[1000,0,0]],input.merge("anchor_index"=>anchor,"mirror"=>mirror,"material_side"=>side),thickness:0.55)
      assert_equal 0,plan[:folds]
      a,b=plan[:rings]
      assert_equal 4,a.length
      faces=[a.reverse,b]
      a.each_index { |i| j=(i+1)%a.length; faces << [a[i],a[j],b[j],b[i]] }
      volume=faces.sum { |face| (1...face.length-1).sum { |i| G.dot(face[0],G.cross(face[i],face[i+1]))/6 } }
      assert_in_delta 55_000,volume,0.001
    end
  end

  def test_explicit_override_uses_metadata_and_warns_without_changing_profile
    @library.materials << material("zinc",50,0,type:"1")
    match=@tool.match_material("material_id"=>"zinc")
    assert_equal "zinc",match[:material]["id"]
    assert_equal 0.55,match[:thickness_mm]
    assert_equal [25,40,25],match[:settings]["lengths_mm"]
    assert_equal 1,match[:warnings].length
    assert_raises(RuntimeError) { @tool.match_material("material_id"=>"missing") }
    @library.materials.last["status"]="retired"
    assert_raises(RuntimeError) { @tool.match_material("material_id"=>"zinc") }
    @library.materials.first["dimensions_mm"]["thickness_mm"]=0
    assert_raises(RuntimeError) { @tool.match_material("material_id"=>"a") }
  end

  def test_named_profiles_persist_update_rename_and_delete_without_geometry
    input={"lengths_mm"=>[125],"angles_deg"=>[],"material_id"=>"a","anchor_index"=>1}
    @tool.save_profile("Flat",input)
    other=Basegrid::FlashingTool.new(library:@library)
    assert_equal "Flat",other.profiles.first["name"]
    assert_equal "a",other.profile_settings("Flat")["material_id"]
    assert_equal 60,other.profile_settings("Flat",{"start_angle_deg"=>60})["start_angle_deg"]
    assert_raises(RuntimeError) { other.save_profile("flat",input) }
    other.save_profile("Flat 125",input.merge("mirror"=>true),previous_name:"Flat")
    assert_equal true,other.profile_settings("Flat 125")["mirror"]
    assert_raises(RuntimeError) { other.profile_settings("Flat") }
    assert_raises(RuntimeError) { other.save_profile("",input) }
    other.delete_profile("Flat 125")
    assert_empty @tool.profiles
    assert_raises(RuntimeError) { other.delete_profile("Flat 125") }
    Sketchup.write_default("Basegrid","flashing_profiles","bad")
    assert_raises(JSON::ParserError) { other.save_profile("New",input) }
  end

  def test_production_dialog_has_native_bridge_and_no_mock_storage
    html=@tool.settings_html({"lengths_mm"=>[100],"angles_deg"=>[]})
    assert_includes html,"sketchup.create"
    assert_includes html,"sketchup.profiles"
    assert_includes html,'<option>0</option>'
    refute_includes html,"localStorage"
    refute_includes html,"Mock only"
    refute_includes html,"__BASEGRID_FLASHING_DATA__"
  end
  def test_exact_folds_preferred_before_rounding_up
    @library.materials = [material("exact",200,2),material("more_folds",150,3)]
    assert_equal "exact", @tool.match_material({})[:material]["id"]
    @library.materials.shift
    assert_equal 3, @tool.match_material({})[:stock_folds]
  end
  def test_live_cache_dimension_names
    @library.materials = [{ "id"=>"live","material_type_id"=>"0","dimensions_mm"=>{"girth"=>150,"folds"=>2,"thickness"=>0.55} }]
    match = @tool.match_material({})
    assert_equal "live",match[:material]["id"]
    assert_equal 0.55,match[:thickness_mm]
  end
  def test_type_filter_and_unavailable_materials
    @library.materials << material("zinc",150,2,type: "1") << material("perf",150,2,type: "2")
    assert_equal "zinc", @tool.match_material("finish" => "zincalume")[:material]["id"]
    assert_equal "perf", @tool.match_material("finish" => "perforated")[:material]["id"]
    assert_raises(RuntimeError) { @tool.match_material("lengths_mm" => [100,100,100]) }
    @library.materials.each { |m| m["status"] = "retired" }
    assert_raises(RuntimeError) { @tool.match_material({}) }
  end
  def test_missing_metadata_and_ambiguous_matches_are_not_silently_used
    @library.materials << material("duplicate",150,2)
    assert_raises(RuntimeError) { @tool.match_material({}) }
    @library.materials = [{ "id" => "bad","material_type_id" => "0","dimensions_mm" => {} }]
    assert_raises(RuntimeError) { @tool.match_material({}) }
  end
  def test_profile_girth_and_path_length_are_independent
    plan = G.plan([[0,0,0],[2000,0,0],[2000,2000,0]],{},thickness: 0.55)
    assert_equal 90, plan[:girth_mm]
    assert_equal 2, plan[:folds]
    assert_equal 4, plan[:length_m]
    assert_equal 3, plan[:rings].length
  end
  def test_mirrored_profiles_and_sides_have_consistent_shell_winding
    [true,false].product(%w[left right]).each do |mirror,side|
      rings = G.plan([[0,0,0],[2000,0,0]],{"mirror"=>mirror,"path_side"=>side},thickness: 0.55)[:rings]
      faces = [rings.first.reverse,rings.last]
      a,b = rings
      a.each_index { |i| j=(i+1)%a.length; faces << [a[i],a[j],b[j]] << [a[i],b[j],b[i]] }
      volume = faces.sum { |face| (1...face.length-1).sum { |i| G.dot(face[0],G.cross(face[i],face[i+1]))/6 } }
      assert_operator volume, :>, 0
    end
  end
  def test_arbitrary_plane_and_vertical_run
    plan = G.plan([[0,0,0],[0,0,2000],[2000,0,2000]],{},thickness: 0.55)
    assert_equal 4, plan[:length_m]
    assert_in_delta 1, plan[:normal][1].abs
    plan = G.plan([[0,0,0],[0,0,2000]],{},thickness: 0.55,normal: [0,0,1])
    assert_equal 2, plan[:length_m]
  end
  def test_invalid_profiles_and_paths
    [ {"lengths_mm"=>[0,40,25]}, {"angles_deg"=>[0,90]}, {"angles_deg"=>[180,90]}, {"anchor_index"=>9} ].each { |input| assert_raises(RuntimeError) { G.settings(input) } }
    assert_raises(RuntimeError) { G.plan([[0,0,0],[10,0,0],[0,0,0]],{},thickness:0.55) }
    assert_raises(RuntimeError) { G.plan([[0,0,0],[1000,0,0],[1000,1000,0],[1000,1000,1000]],{},thickness:0.55) }
    assert_raises(RuntimeError) { G.plan([[0,0,0],[1000,1000,0],[0,1000,0],[1000,0,0]],{},thickness:0.55) }
    assert_raises(RuntimeError) { G.polygon(G.settings("lengths_mm"=>[100,100,100,100],"angles_deg"=>[90,90,90]),0.55) }
  end
  def test_anchor_moves_profile_not_girth
    a = G.plan([[0,0,0],[1000,0,0]],{},thickness:0.55)
    b = G.plan([[0,0,0],[1000,0,0]],{"anchor_index"=>2},thickness:0.55)
    refute_equal a[:rings],b[:rings]
    assert_equal a[:girth_mm],b[:girth_mm]
  end
  def test_html_and_corrupt_preferences
    html = @tool.settings_html({"finish"=>"</script><script>bad</script>"})
    refute_includes html,"</script><script>bad"
    assert_includes html,'<canvas'
    assert_includes html,'Colourbond'
    %w[null [] bad].each do |raw|
      Sketchup.write_default("Basegrid","flashing_settings",raw)
      assert_equal({},@tool.saved_settings)
    end
  end
  class View
    def lock_inference(*); end
    def invalidate; end
  end
  def drawing
    owner = Object.new
    def owner.build(*) = (@builds ||= []) << true
    def owner.builds = @builds || []
    model = OpenStruct.new(active_path:nil)
    Sketchup.active_model = model
    tool = Basegrid::FlashingTool::DrawTool.new(owner,model,@tool.match_material({}))
    tool.activate
    tool.instance_variable_set(:@points,[[0,0,0],[1000,0,0]])
    [tool,model,owner,View.new]
  end
  def test_deferred_finish_duplicate_guard_and_context_change
    tool,model,owner,view = drawing
    tool.finish(view)
    tool.finish(view)
    assert_equal 1,UI.timers.length
    assert_empty owner.builds
    UI.timers.shift.call
    assert_equal 1,owner.builds.length
    tool,model,owner,view = drawing
    tool.finish(view)
    model.active_path = [:changed]
    UI.timers.shift.call
    assert_empty owner.builds
  end
  def test_deactivation_prevents_pending_build
    tool,_model,owner,view = drawing
    tool.finish(view)
    tool.deactivate(view)
    UI.timers.shift.call
    assert_empty owner.builds
  end
  def test_tab_cycles_anchor_and_deletion_preserves_measurement_editing
    tool,_model,_owner,view = drawing
    tool.onKeyDown(9,1,0,view)
    assert_equal 1,tool.instance_variable_get(:@settings)["anchor_index"]
    tool.onKeyDown(9,2,0,view)
    assert_equal 1,tool.instance_variable_get(:@settings)["anchor_index"]
    tool.onKeyDown(49,1,0,view)
    tool.onKeyDown(8,1,0,view)
    assert_equal 2,tool.instance_variable_get(:@points).length
    tool.instance_variable_set(:@typing,false)
    tool.onKeyDown(8,1,0,view)
    assert_equal 1,tool.instance_variable_get(:@points).length
  end

  def test_measurement_sets_exact_length_along_hover_direction
    tool,_model,_owner,view = drawing
    tool.instance_variable_set(:@points,[[0,0,0]])
    tool.instance_variable_set(:@hover,[3,4,0])
    text = Object.new
    def text.to_l = 1000.0/25.4
    tool.onUserText(text,view)
    endpoint = tool.instance_variable_get(:@points).last
    assert_in_delta 600,endpoint[0]
    assert_in_delta 800,endpoint[1]
  end

  def test_mac_backward_delete_removes_one_point
    tool,_model,_owner,view = drawing
    Sketchup.stub(:platform,:platform_osx) { tool.onKeyDown(127,1,0,view) }
    assert_equal 1,tool.instance_variable_get(:@points).length
  end
end
