# Native SketchUp smoke test. Launch with the isolated template fixture documented in docs/STRIP_FOOTING.md.
footing_test_root = File.expand_path("..", __dir__)
require 'sketchup.rb'
require 'json'
UI.start_timer(3.0, false) do
  output = { pid: Process.pid, version: Sketchup.version }
  begin
    require File.join(footing_test_root, 'basegrid/strip_footing_tool')
    model = Sketchup.active_model
    raise 'Expected the isolated test fixture' unless model.path.tr('\\', '/').end_with?('/tmp/footing-inspection/test-template-final.skp')
    library = Basegrid::MaterialLibrary.new
    library.load
    builder = Basegrid::StripFootingTool.new(library: library)
    result = builder.build(model, [[[10000,0,0],[10000,3929,0],[14121,3929,0],[14121,0,0]]], { 'reinforcement' => 'top_bottom' })
    output[:volume_m3] = result[:volume_m3]
    output[:root] = result[:entity].name
    root = result[:entity]
    concrete = root.entities.grep(Sketchup::Group).find { |group| group.name == 'Concrete' }
    reinforcement = root.entities.grep(Sketchup::Group).find { |group| group.name == 'Reinforcement' }
    segments = concrete.entities.grep(Sketchup::Group)
    raise 'Expected one joined concrete solid' unless segments.length == 1 && segments.all?(&:manifold?)
    output[:concrete_segments] = segments.map { |group| { name: group.name, solid: group.manifold? } }
    supports = reinforcement.entities.grep(Sketchup::Group).select { |group| group.name.start_with?('Mesh Supports') }.flat_map { |group| group.entities.to_a }
    pairs = reinforcement.entities.grep(Sketchup::Group).select { |group| group.name.start_with?('Mesh Spacers') }.flat_map { |group| group.entities.to_a }
    raise 'Expected reusable support instances' unless supports.all? { |item| item.is_a?(Sketchup::ComponentInstance) && item.manifold? } && supports.map(&:definition).uniq.length < supports.length
    raise 'Expected paired bar instances' unless pairs.all? { |item| item.is_a?(Sketchup::ComponentInstance) && item.manifold? } && pairs.map(&:definition).uniq.length < pairs.length
    records = Basegrid::Takeoff.records(model)
    support_quantity = records.select { |r| r['role_id'] == 'concrete.strip_footing.chairs' }.sum { |r| r['quantity'] }
    pair_quantity = records.select { |r| r['role_id'] == 'concrete.strip_footing.spacers' }.sum { |r| r['quantity'] }
    raise 'Instance quantities do not match placements' unless support_quantity == supports.length && pair_quantity == pairs.length
    output[:support_instances] = supports.length
    output[:support_definitions] = supports.map(&:definition).uniq.length
    output[:spacer_instances] = pairs.length
    output[:spacer_definitions] = pairs.map(&:definition).uniq.length
    output[:instance_takeoff_verified] = true
    layers = reinforcement.entities.grep(Sketchup::Group).select { |group| group.name.include?('Mesh') && !group.name.start_with?('Mesh ') }
    raise 'Expected six mesh layer groups' unless layers.length == 6
    raise 'Expected Primary Bar and Mesh Frame' unless layers.all? { |group| group.entities.to_a.map(&:name).sort == ['Mesh Frame', 'Primary Bar'] }
    output[:mesh_layers] = layers.map(&:name)
    output[:ok] = true
    model.selection.clear
    model.active_view.camera = Sketchup::Camera.new([21000,-14000,13000].map(&:mm), [12000,2000,-200].map(&:mm), [0,0,1])
    model.active_view.zoom(result[:entity])
    model.active_view.write_image(filename: File.join(footing_test_root, 'tmp/footing-inspection/live-test.png'), width: 1400, height: 900)
    concrete.hidden = true
    model.active_view.write_image(filename: File.join(footing_test_root, 'tmp/footing-inspection/live-reinforcement.png'), width: 1400, height: 900)
    concrete.hidden = false
    model.save(File.join(footing_test_root, 'tmp/footing-inspection/updated-footing.skp'))
    output[:other_cases] = []
    cases = {
      'step' => [[[0,0,0],[3000,0,0]],[[3000,0,200],[6000,0,200]]],
      'junction' => [[[0,0,0],[6000,0,0]],[[3000,0,0],[3000,3000,0]]],
      'loop' => [[[0,0,0],[3000,0,0],[3000,3000,0],[0,3000,0],[0,0,0]]],
      'diagonal' => [[[0,0,0],[3000,4000,0]]],
      'oblique_corner' => [[[0,0,0],[3000,0,0],[5000,2000,0]]],
      'diagonal_crossing' => [[[0,0,0],[6000,0,0]],[[1500,-1500,0],[4500,1500,0]]],
      'rotated_step' => [[[0,0,0],[2400,1800,0]],[[2400,1800,200],[4800,3600,200]]]
    }
    cases.each do |name, paths|
      item = builder.build(model, paths, { 'reinforcement' => 'none' })
      output[:other_cases] << { name: name, volume_m3: item[:volume_m3] }
      model.start_operation('Remove test fixture', true)
      item[:entity].erase!
      model.commit_operation
    end
    root_count = model.entities.length
    definitions_count = model.definitions.length
    failing = Basegrid::StripFootingTool.new(library: library)
    def failing.decorate(*) = raise('test rollback after geometry creation')
    begin
      failing.build(model, [[[0,0,0],[6000,0,0]]], { 'reinforcement' => 'none' })
      raise 'Failure was not raised'
    rescue RuntimeError => error
      raise unless error.message == 'test rollback after geometry creation'
    end
    raise 'Rollback left geometry behind' unless model.entities.length == root_count && model.definitions.length == definitions_count
    output[:rollback_verified] = true
    tool = Basegrid::StripFootingTool::DrawTool.new(builder, builder.resolved_settings({}, {}), {})
    model.select_tool(tool)
    view = model.active_view
    raise 'Expected top-left default' unless tool.anchor_label == 'left edge top'
    tool.add_point([0,0,0], view)
    tool.instance_variable_set(:@hover, [3000,4000,0])
    tool.onUserText('5000mm', view)
    raise 'Diagonal length entry failed' unless tool.instance_variable_get(:@paths).last.last.zip([3000,4000,0]).all? { |a,b| (a-b).abs < 0.001 }
    tool.onKeyDown(Basegrid::StripFootingTool::DrawTool::RIGHT_KEY, 1, 0, view)
    raise 'Arrow did not lock inference' unless view.inference_locked?
    tool.onKeyDown(Basegrid::StripFootingTool::DrawTool::RIGHT_KEY, 1, 0, view)
    raise 'Arrow did not unlock inference' if view.inference_locked?
    model.select_tool(nil)
    output[:drawing_callbacks_verified] = true
  rescue Exception => e
    output[:ok] = false
    output[:error] = e.message
    output[:backtrace] = e.backtrace.first(10)
  ensure
    File.write(File.join(footing_test_root, 'tmp/footing-inspection/live-test.json'), JSON.pretty_generate(output))
  end
end
