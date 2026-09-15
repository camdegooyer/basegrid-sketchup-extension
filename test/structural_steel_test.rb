# frozen_string_literal: true
require "minitest/autorun"
require "minitest/mock"
require "ostruct"
require_relative "../basegrid/structural_steel_tool"

module Sketchup
  InputPoint = Struct.new(:position) do
    def valid? = !position.nil?
  end unless const_defined?(:InputPoint)
  class << self
    attr_accessor :active_model, :defaults, :status_text
    def read_default(section,key,fallback) = (defaults || {}).fetch([section,key],fallback)
    def write_default(section,key,value) = (self.defaults ||= {})[[section,key]] = value
    def set_status_text(text,*slot)
      self.status_text = text if slot.empty?
    end
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
SB_VCB_LABEL = 1 unless defined?(SB_VCB_LABEL)

class StructuralSteelTest < Minitest::Test
  G = Basegrid::StructuralSteelGeometry
  def setup
    types = G::TYPES.map { |t| {"id"=>t,"name"=>"Structural Steel - #{t}","uom"=>"m","profile"=>"i_section"} }
    @library = OpenStruct.new(material_types: types,materials: G::TYPES.map { |t| material(t) })
    @owner = Basegrid::StructuralSteelTool.new(library: @library)
    Sketchup.defaults = {}
    UI.timers = []
  end
  def material(type)
    dims = case type
           when "CHS" then {"diameter"=>100,"wall_thickness"=>5}
           when "SHS" then {"width"=>100,"depth"=>nil,"wall_thickness"=>5}
           when "RHS" then {"width"=>100,"depth"=>150,"wall_thickness"=>5}
           else {"depth"=>200,"flange_width"=>100,"flange_thickness"=>10,"web_thickness"=>6}
           end
    {"id"=>type,"name"=>"Test #{type}","material_type_id"=>type,"dimensions_mm"=>dims}
  end
  def test_web_type_filter_ignores_shared_pfc_profile_label
    assert_equal G::TYPES.sort,@owner.materials.map { |m| m["steel_type"] }.sort
    assert_equal "PFC",@owner.resolve("material_id"=>"PFC")[:section][:type]
    @library.material_types.first["uom"] = "ea"
    assert_raises(RuntimeError) { @owner.resolve("material_id"=>"PFC") }
    @library.materials.last["status"] = "archived"
    assert_raises(RuntimeError) { @owner.resolve("material_id"=>"CHS") }
  end
  def test_section_areas_winding_and_voids
    {"PFC"=>3080,"UB"=>3080,"UC"=>3080,"SHS"=>1900,"RHS"=>2400}.each do |type,area|
      loops = G.profile(G.section(material(type),type))
      assert_in_delta area,loops.sum { |l| G.area(l) },0.0001
      assert_operator G.area(loops.first),:>,0
      assert_operator G.area(loops.last),:<,0 if loops.length == 2
      loops.each { |l| assert_equal l.uniq.length,l.length }
    end
    loops = G.profile(G.section(material("CHS"),"CHS"))
    assert_equal [48,48],loops.map(&:length)
    assert_in_delta 48*Math.sin(2*Math::PI/48)*(50**2-45**2)/2,loops.sum { |l| G.area(l) }
  end
  def test_channel_web_is_on_one_side
    loop = G.profile(G.section(material("PFC"),"PFC")).first
    assert_includes loop,[-44.0,-90.0]
    refute_includes loop,[3.0,-90.0]
  end
  def test_material_dimensions_are_required_and_must_be_valid
    %w[depth web_thickness flange_thickness flange_width].each do |key|
      m = material("UB")
      m["dimensions_mm"][key] = nil
      assert_raises(RuntimeError) { G.section(m,"UB") }
    end
    m = material("SHS")
    m["dimensions_mm"]["wall_thickness"] = 50
    assert_raises(RuntimeError) { G.section(m,"SHS") }
    m = material("UB")
    m["dimensions_mm"]["flange_thickness"] = 100
    assert_raises(RuntimeError) { G.section(m,"UB") }
    assert_raises(RuntimeError) { G.settings("rotation_deg"=>Float::INFINITY) }
    assert_raises(RuntimeError) { G.settings("length_mm"=>0.2) }
    assert_raises(RuntimeError) { G.settings("anchor"=>"bogus") }
  end
  def test_radii_only_when_present_in_material
    m = material("UB")
    plain = G.profile(G.section(m,"UB"))
    m["dimensions_mm"]["root_radius"] = 8
    rounded = G.profile(G.section(m,"UB"))
    assert_operator rounded.first.length,:>,plain.first.length
    assert_operator G.area(rounded.first),:>,G.area(plain.first)
    m = material("SHS")
    m["dimensions_mm"]["outer_radius"] = 40
    assert_raises(RuntimeError) { G.profile(G.section(m,"SHS")) }
  end
  def test_anchor_rotation_and_offsets
    item = G.section(material("SHS"),"SHS")
    loop = G.placed_profile(item,{}).first
    assert_in_delta 0,loop.map(&:first).min
    assert_in_delta 0,loop.map(&:last).max
    assert_in_delta(-100,loop.map(&:last).min)
    shifted = G.placed_profile(item,{"anchor"=>"center","rotation_deg"=>90,"lateral_offset_mm"=>17,"vertical_offset_mm"=>-8}).first
    assert_in_delta(-33,shifted.map(&:first).min)
    assert_in_delta 42,shifted.map(&:last).max
  end
  def test_settings_persist_and_corrupt_preferences_fall_back
    @owner.remember(G.settings("material_id"=>"RHS","rotation_deg"=>90))
    assert_equal "RHS",@owner.saved_settings["material_id"]
    assert_equal 90,@owner.saved_settings["rotation_deg"]
    %w[null [] bad].each do |raw|
      Sketchup.write_default("Basegrid","steel_member_settings",raw)
      assert_equal({},@owner.saved_settings)
    end
  end
  def test_dimension_summary_is_plain_text_and_section_specific
    assert_equal "Diameter: 100 mm; Wall: 5 mm",@owner.dimension_summary(G.section(material("CHS"),"CHS"))
    assert_equal "Depth: 100 mm; Width: 100 mm; Wall: 5 mm",@owner.dimension_summary(G.section(material("SHS"),"SHS"))
    assert_equal "Depth: 200 mm; Width: 100 mm; Flange: 10 mm; Web: 6 mm",@owner.dimension_summary(G.section(material("UB"),"UB"))
    html = @owner.settings_html(G::DEFAULTS)
    assert_includes html,'<p id="dimensions"'
    assert_includes html,"el('dimensions').textContent=m?.dimension_summary||''"
    refute_match(/<input[^>]+id="(?:depth|width|diameter|wall|flange|web)"/,html)
  end
  def test_ui_has_geometry_preview_and_escapes_material_names
    @library.materials.first["name"] = "</script><script>bad</script>"
    html = @owner.settings_html(G::DEFAULTS)
    assert_includes html,"<canvas"
    refute_includes html,"</script><script>bad"
    refute_includes html,'id="anchor"'
    assert_includes html,"Column height"
  end
  class View
    def lock_inference(*); end
    def invalidate; end
  end
  class Transform
    def inverse = self
    def *(_other) = self
  end
  def drawing
    owner = Object.new
    def owner.build(*) = (@builds ||= []) << true
    def owner.builds = @builds || []
    def owner.remember(*); end
    model = OpenStruct.new(active_path: nil,edit_transform: Transform.new)
    Sketchup.active_model = model
    tool = Basegrid::StructuralSteelTool::DrawTool.new(owner,model,@owner.resolve("material_id"=>"SHS"))
    tool.activate
    def tool.span = [@settings,StructuralSteelTest::Transform.new]
    [tool,model,owner,View.new]
  end
  def test_deferred_completion_is_single_and_cancellable
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
    tool,model,owner,view = drawing
    tool.finish(view)
    tool.deactivate(view)
    UI.timers.shift.call
    assert_empty owner.builds
  end
  def test_tab_and_delete_do_not_steal_native_or_measurement_keys
    tool,_model,_owner,view = drawing
    tool.onKeyDown(9,1,0,view)
    assert_equal "top_center",tool.instance_variable_get(:@settings)["anchor"]
    tool.onKeyDown(9,2,0,view)
    assert_equal "top_center",tool.instance_variable_get(:@settings)["anchor"]
    tool.instance_variable_set(:@start,:picked)
    tool.onKeyDown(49,1,0,view)
    tool.onKeyDown(8,1,0,view)
    assert_equal :picked,tool.instance_variable_get(:@start)
    assert_nil tool.onKeyDown(32,1,0,view)
    tool.instance_variable_set(:@typing,false)
    tool.onKeyDown(8,1,0,view)
    assert_nil tool.instance_variable_get(:@start)
    Sketchup.stub(:platform,:platform_osx) do
      tool.instance_variable_set(:@start,:picked)
      tool.onKeyDown(127,1,0,view)
      assert_nil tool.instance_variable_get(:@start)
    end
  end
  class Point
    attr_reader :coords
    def initialize(*coords) = @coords = coords
    def distance(other) = Math.sqrt(coords.zip(other.coords).sum { |a,b| (b-a)**2 })
    def vector_to(other) = coords.zip(other.coords).map { |a,b| b-a }
    def offset(vector,length)
      mag = Math.sqrt(vector.sum { |v| v*v })
      Point.new(*coords.zip(vector).map { |a,v| a+v/mag*length })
    end
  end
  def test_typed_beam_length_preserves_arbitrary_3d_direction
    tool,_model,_owner,view = drawing
    tool.instance_variable_set(:@start,Point.new(0,0,0))
    tool.instance_variable_set(:@hover,Point.new(2,3,6))
    text = Object.new
    def text.to_l = 700.0/25.4
    tool.onUserText(text,view)
    endpoint = tool.instance_variable_get(:@hover).coords
    [200,300,600].zip(endpoint).each { |expected,value| assert_in_delta expected,value*25.4 }
    assert_equal 1,UI.timers.length
  end
  def test_typed_column_height_updates_preview_without_placing
    tool,_model,_owner,view = drawing
    tool.instance_variable_get(:@settings)["usage"] = "column"
    tool.instance_variable_set(:@start,:picked)
    text = Object.new
    def text.to_l = 4500.0/25.4
    tool.onUserText(text,view)
    assert_in_delta 4500,tool.instance_variable_get(:@settings)["length_mm"]
    assert_empty UI.timers
  end
end
