# frozen_string_literal: true

require "json"
require_relative "starter_bar_geometry"
require_relative "material_library"
require_relative "material_appearance"
require_relative "takeoff"
require_relative "starter_step_z_tool"

module Basegrid
  class StarterBarTool
    TOOL_ID = "reinforcement.starter_bars"
    MATERIAL_TYPES = { "bar" => "Reo Bar Processed", "chair" => "Bar Chairs", "cap" => "Reo Bar Safety Caps" }.freeze

    def initialize(library: MaterialLibrary.new)
      @library = library
    end

    def materials_for(role)
      types = @library.material_types.select do |type|
        type.fetch("status", "active") == "active" && type["name"].to_s.casecmp?(MATERIAL_TYPES.fetch(role)) &&
          (role == "bar" ? %w[m ea each] : %w[ea each]).include?(type["uom"])
      end.map { |type| type.fetch("id") }
      @library.materials.select { |material| material.fetch("status", "active") == "active" && types.include?(material["material_type_id"]) }
        .sort_by { |material| material.fetch("name").downcase }
    end

    def saved_settings
      value = JSON.parse(Sketchup.read_default("Basegrid", "starter_bar_settings", "{}"))
      value.is_a?(Hash) ? value : {}
    rescue JSON::ParserError, TypeError
      {}
    end

    def ordered_points(edges, transform)
      raise "Select a connected chain or loop of edges first." if edges.empty?
      graph = Hash.new { |hash, key| hash[key] = [] }
      edges.each { |edge| graph[edge.start] << edge; graph[edge.end] << edge }
      raise "The selected path branches. Select one chain or loop." if graph.any? { |_, linked| linked.length > 2 }
      ends = graph.keys.select { |vertex| graph[vertex].length == 1 }
      raise "Select one connected chain or loop." unless [0, 2].include?(ends.length)
      vertex = (ends.empty? ? graph.keys : ends).min_by { |v| v.position.to_a }
      points = [vertex.position.transform(transform).to_a.map { |n| n*25.4 }]
      visited = {}
      loop do
        edge = graph[vertex].reject { |item| visited[item] }.min_by { |item| item.other_vertex(vertex).position.to_a }
        break unless edge
        visited[edge] = true
        vertex = edge.other_vertex(vertex)
        points << vertex.position.transform(transform).to_a.map { |n| n*25.4 }
      end
      raise "Selected edges are disconnected." unless visited.length == edges.length
      StarterBarGeometry.path(points)
      points
    end

    def run
      @library.load
      model = Sketchup.active_model
      selected = model.selection.to_a
      step_existing = selected.length == 1 && step_z_existing?(selected.first) ? selected.first : nil
      existing = selected.length == 1 && selected.first.is_a?(Sketchup::Group) &&
        selected.first.get_attribute("Basegrid", "tool_id") == TOOL_ID &&
        !selected.first.get_attribute("Basegrid", "parameters_json").to_s.empty? ? selected.first : nil
      if existing
        raise "The starter bar group is locked." if existing.locked?
        metadata = JSON.parse(existing.get_attribute("Basegrid", "parameters_json"))
        # Stored path points are local to the assembly, so edits follow a moved group.
        transform = model.edit_transform * existing.transformation
        points = metadata.fetch("points").map { |point| Geom::Point3d.new(point.map { |n| n/25.4 }).transform(transform).to_a.map { |n| n*25.4 } }
        defaults = metadata.fetch("settings")
      elsif step_existing
        defaults = JSON.parse(step_existing.get_attribute("Basegrid", "parameters_json")).fetch("settings")
      else
        defaults = saved_settings
      end
      context = model.active_path&.dup
      @dialog&.close
      @dialog = UI::HtmlDialog.new(dialog_title: "Starter Bars", preferences_key: "basegrid_starter_bars",
                                   scrollable: true, resizable: true, width: 490, height: 690,
                                   style: UI::HtmlDialog::STYLE_DIALOG)
      @dialog.add_action_callback("create") do |_, encoded|
        begin
          raise "The model or editing context has changed." unless model == Sketchup.active_model && context == model.active_path
          input = JSON.parse(encoded)
          raise "Select a path to create a different assembly type." if (existing && input["mode"] == "step_z") || (step_existing && input["mode"] != "step_z")
          if input["mode"] == "step_z"
            start_step_z(input, model, replace: step_existing)
            @dialog.close
            next
          end
          points ||= ordered_points(model.selection.to_a.grep(Sketchup::Edge), model.edit_transform)
          settings, = resolve(input)
          StarterBarGeometry.plan(points, settings)
          Sketchup.write_default("Basegrid", "starter_bar_settings", JSON.generate(settings))
          if existing
            build(model, points, settings, anchor: metadata.fetch("anchor", 0), reverse: metadata.fetch("reverse", false), replace: existing)
          else
            model.select_tool(PlacementTool.new(self, model, points, settings))
          end
          @dialog.close
        rescue StandardError => e
          @dialog.execute_script("document.getElementById('error').textContent=#{JSON.generate(e.message)}")
        end
      end
      @dialog.set_html(settings_html(defaults, editing_step: !!step_existing, editing_path: !!existing))
      @dialog.show
    rescue StandardError => e
      UI.messagebox(e.message)
    end

    def resolve(input)
      settings = StarterBarGeometry.settings(input)
      bindings = MATERIAL_TYPES.to_h do |role, _|
        id = settings.fetch("#{role}_material").to_s
        material = id.empty? ? nil : materials_for(role).find { |item| item.fetch("id").to_s == id }
        raise "Selected #{role} material is unavailable or incompatible." if !id.empty? && !material
        [role, material]
      end
      diameter = bindings["bar"]&.dig("dimensions_mm", "diameter") || bindings["bar"]&.dig("dimensions_mm", "diameter_mm")
      raise "Selected bar material has no diameter metadata. Update the material and sync again." if bindings["bar"] && diameter.nil?
      settings = StarterBarGeometry.settings(settings.merge("diameter_mm" => diameter)) if diameter
      [settings, bindings]
    end

    def build(model, points, input, anchor: 0, reverse: false, replace: nil)
      raise "The active model has changed." unless model == Sketchup.active_model
      raise "The editing context is locked." if Array(model.active_path).any?(&:locked?)
      raise "The original group is unavailable or locked." if replace && (!replace.valid? || replace.locked?)
      settings, bindings = resolve(input)
      plan = StarterBarGeometry.plan(points, settings, anchor: anchor, reverse: reverse)
      model.start_operation("Create Starter Bars", true)
      started = true
      root = model.active_entities.add_group
      root.name = "Starter Bars"
      root.layer = model.layers[0]
      root.transformation = model.edit_transform.inverse
      root.set_attribute("Basegrid", "tool_id", TOOL_ID)
      root.set_attribute("Basegrid", "parameters_json", JSON.generate(points: points, settings: settings, anchor: anchor, reverse: reverse))
      definitions = {}
      plan[:bars].each_with_index do |bar, index|
        frame = Geom::Transformation.axes(point(bar[:center]), Geom::Vector3d.new(bar[:tangent]),
                                          Geom::Vector3d.new(bar[:inward]), Geom::Vector3d.new(0, 0, 1))
        signature = JSON.generate(bar[:points])
        definition = definitions[signature] ||= begin
          item = model.definitions.add("Starter Bar")
          add_bar(item.entities, bar[:points], settings["diameter_mm"])
          item
        end
        instance = root.entities.add_instance(definition, frame)
        instance.name = format("Starter Bar %03d", index+1)
        decorate(model, instance, "bar", bindings["bar"], bar[:length_m])
        bar[:chairs].each do |position|
          chair_definition = definitions[:chair] ||= accessory_definition(model, "Bar Chair", 20, 35, 50)
          chair = root.entities.add_instance(chair_definition, frame * Geom::Transformation.translation(point(position)))
          decorate(model, chair, "chair", bindings["chair"], 1)
        end
        if bar[:cap]
          cap_definition = definitions[:cap] ||= accessory_definition(model, "Safety Cap", 25, 25, 25)
          cap_axis = point(bar[:points][-2]).vector_to(point(bar[:points][-1]))
          cap = root.entities.add_instance(cap_definition, frame * Geom::Transformation.new(point(bar[:cap]), cap_axis))
          decorate(model, cap, "cap", bindings["cap"], 1)
        end
      end
      replace.erase! if replace
      model.commit_operation
      started = false
      model.selection.clear
      model.selection.add(root)
      root
    rescue StandardError
      model.abort_operation if started
      raise
    end

    def point(values) = Geom::Point3d.new(values.map { |value| value/25.4 })

    def add_bar(entities, points, diameter)
      path = entities.add_curve(points.map { |values| point(values) })
      origin = point(points.first)
      direction = origin.vector_to(point(points[1]))
      circle = entities.add_circle(origin, direction, diameter/50.8, 8)
      face = entities.add_face(circle)
      raise "Could not create starter bar profile." unless face
      face.reverse! if face.normal.dot(direction) > 0
      raise "Could not sweep starter bar." unless face.followme(path)
      entities.erase_entities(path.select(&:valid?))
    end

    def accessory_definition(model, name, top_radius, base_radius, height)
      definition = model.definitions.add(name)
      top = 12.times.map { |i| angle = i*Math::PI/6; point([top_radius*Math.cos(angle), top_radius*Math.sin(angle), 0]) }
      bottom = 12.times.map { |i| angle = i*Math::PI/6; point([base_radius*Math.cos(angle), base_radius*Math.sin(angle), -height]) }
      definition.entities.add_face(top)
      definition.entities.add_face(bottom.reverse)
      12.times { |i| j = (i+1)%12; definition.entities.add_face(top[i], bottom[i], bottom[j], top[j]) }
      definition
    end

    def decorate(model, entity, role, material, length)
      role_id = "#{TOOL_ID}.#{role}"
      tag_name = "Starter Bars | #{MATERIAL_TYPES.fetch(role)}"
      tag = model.layers[tag_name] || model.layers.add(tag_name)
      owner = tag.get_attribute("Basegrid", "generated_role_id").to_s
      raise "The tag #{tag_name} belongs to another generated role." unless owner.empty? || owner == role_id
      tag.set_attribute("Basegrid", "generated_role_id", role_id)
      entity.layer = tag
      entity.set_attribute("Basegrid", "tool_id", TOOL_ID)
      entity.set_attribute("Basegrid", "material_role", role)
      entity.set_attribute("Basegrid", "generated_role_id", role_id)
      if material
        entity.set_attribute("Basegrid", "material_id", material.fetch("id"))
        entity.set_attribute("Basegrid", "material_type_id", material.fetch("material_type_id"))
        MaterialAppearance.new(library: @library).apply(entity, material, mode: MaterialAppearance.mode(model), model: model)
      else
        entity.material = role == "cap" ? "Yellow" : "DimGray"
      end
      type = material && @library.material_types.find { |item| item["id"] == material["material_type_id"] }
      unit = role == "bar" && (!type || type["uom"] == "m") ? "m" : "ea"
      Takeoff.write_quantity(entity, material: material || { "id" => "", "name" => "Unassigned #{MATERIAL_TYPES.fetch(role)}" },
                            role_id: role_id, material_role: role, quantity: unit == "m" ? length : 1,
                            unit: unit, basis: unit == "m" ? "Starter bar centreline length" : "Placed component count")
    end

    def settings_html(saved, editing_step: false, editing_path: false)
      payload = JSON.generate(defaults: StarterBarGeometry::DEFAULTS.merge(step_z_defaults).merge(saved),
                              editingStep: editing_step, editingPath: editing_path,
                              materials: MATERIAL_TYPES.keys.to_h { |role| [role, materials_for(role)] }).gsub("<", "\\u003c")
      <<~HTML
        <!doctype html><html><head><meta charset="utf-8"><style>
        *{box-sizing:border-box}body{font:13px -apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;color:#25282b;background:#fff;margin:20px}
        h1{font-size:20px;margin:0 0 18px}label{display:block;margin:10px 0 5px}input,select{width:100%;padding:7px;border:1px solid #bcc2c7;border-radius:3px;background:#fff;color:#25282b;font:inherit}
        .row{display:grid;grid-template-columns:1fr 1fr;gap:14px}.check{display:flex;align-items:center;gap:7px}.check input{width:auto}button{margin-top:16px;padding:9px 16px;background:#246c52;color:#fff;border:0;border-radius:3px;cursor:pointer}#error{color:#b42318;margin-top:12px}[hidden]{display:none!important}
        </style></head><body><h1>Starter bars</h1><form id="form">
        <label for="mode">Bar layout</label><select id="mode"><option value="straight">Straight starters</option><option value="tapered">Tapered starters</option><option value="pins">Horizontal pins</option><option value="step_z">Step Z-bars</option></select>
        <label for="bar_material">Reinforcement material</label><select id="bar_material"></select>
        <div data-modes="straight tapered pins"><label for="spacing_mm">Spacing (mm)</label><input id="spacing_mm" type="number" min="1" step="any" required></div>
        <div data-modes="straight tapered pins"><label for="first_offset_mm">First offset (mm)</label><input id="first_offset_mm" type="number" min="0" step="any" required></div>
        #{step_z_fields_html}
        <div data-modes="straight tapered"><div class="row"><div><label for="above_mm">Above baseline (mm)</label><input id="above_mm" type="number" min="0" step="any" required></div><div><label for="below_mm">Below baseline (mm)</label><input id="below_mm" type="number" min="0" step="any" required></div></div>
        <div class="row"><div><label for="top_start_mm">Top crank (mm)</label><input id="top_start_mm" type="number" min="0" step="any" required></div><div data-modes="tapered"><label for="top_end_mm">Top crank at end (mm)</label><input id="top_end_mm" type="number" min="0" step="any" required></div></div>
        <label for="top_direction">Top direction</label><select id="top_direction"><option value="in">In</option><option value="out">Out</option></select>
        <div class="row"><div><label for="bottom_start_mm">Bottom crank (mm)</label><input id="bottom_start_mm" type="number" min="0" step="any" required></div><div data-modes="tapered"><label for="bottom_end_mm">Bottom crank at end (mm)</label><input id="bottom_end_mm" type="number" min="0" step="any" required></div></div>
        <label for="bottom_direction">Bottom direction</label><select id="bottom_direction"><option value="in">In</option><option value="out">Out</option></select>
        <label class="check"><input id="chairs" type="checkbox">Bar chairs</label><div id="chair_options"><label for="chair_material">Chair material</label><select id="chair_material"></select></div></div>
        <div data-modes="pins" class="row"><div><label for="in_mm">Distance in (mm)</label><input id="in_mm" type="number" min="0" step="any" required></div><div><label for="out_mm">Distance out (mm)</label><input id="out_mm" type="number" min="0" step="any" required></div></div>
        <div data-modes="straight tapered pins"><label class="check"><input id="caps" type="checkbox">Safety caps</label><div id="cap_options"><label for="cap_material">Cap material</label><select id="cap_material"></select></div></div>
        <div id="error" role="alert"></div><button type="submit">Create / update</button></form>
        <script>
        const data=#{payload};const el=id=>document.getElementById(id);
        for(const option of el('mode').options){option.disabled=(data.editingStep&&option.value!=='step_z')||(data.editingPath&&option.value==='step_z');}
        for(const [role,rows] of Object.entries(data.materials)){const select=el(role+'_material');select.add(new Option('Unassigned',''));rows.forEach(row=>select.add(new Option(row.name,row.id)));}
        for(const [key,value] of Object.entries(data.defaults)){const input=el(key);if(!input)continue;if(input.type==='checkbox')input.checked=value;else input.value=value;}
        function refresh(){document.querySelectorAll('[data-modes]').forEach(node=>node.hidden=!node.dataset.modes.split(' ').includes(el('mode').value));el('chair_options').hidden=!el('chairs').checked;el('cap_options').hidden=!el('caps').checked;document.querySelectorAll('input,select').forEach(input=>input.disabled=!!input.closest('[hidden]'));}
        ['mode','chairs','caps','bar_material'].forEach(id=>el(id).addEventListener('change',refresh));refresh();
        el('form').addEventListener('submit',event=>{event.preventDefault();const values={};for(const key of Object.keys(data.defaults)){const input=el(key);if(input)values[key]=input.type==='checkbox'?input.checked:input.type==='number'?Number(input.value):input.value;}el('error').textContent='';sketchup.create(JSON.stringify(values));});
        </script></body></html>
      HTML
    end

    class PlacementTool
      def initialize(owner, model, points, settings)
        @owner, @model, @points, @settings = owner, model, points, settings
        @context = model.active_path&.dup
        @path = StarterBarGeometry.path(points)
        @anchor = 0.0
        @reverse = false
        @input = Sketchup::InputPoint.new
      end

      def activate
        Sketchup.set_status_text("Pick first bar position on selected path. Tab: cycle endpoints. Right-click: reverse direction.")
        update_preview
      end

      def onMouseMove(_flags, x, y, view)
        return if @finished
        @input.pick(view, x, y)
        if @input.valid?
          @anchor = StarterBarGeometry.nearest_chainage(@path, @input.position.to_a.map { |n| n*25.4 })
          update_preview
        end
        view.tooltip = @input.tooltip
        view.invalidate
      end

      def onKeyDown(key, repeat, _flags, view)
        return if @finished || @deactivated
        return unless key == 9
        return true if repeat > 1
        @anchor = @anchor < @path[:total]/2 ? @path[:total] : 0
        update_preview
        view.invalidate
        true
      end

      def getMenu(menu)
        return if @finished || @deactivated
        menu.add_item("Reverse layout direction") { @reverse = !@reverse; update_preview; @model.active_view.invalidate }
        menu.add_item("Place starter bars") { finish }
      end

      def update_preview
        @preview = StarterBarGeometry.plan(@points, @settings, anchor: @anchor, reverse: @reverse)
      rescue StandardError => e
        @preview = nil
        Sketchup.set_status_text("Starter bars: #{e.message}")
      end

      def draw(view)
        return if !@preview || @finished || @deactivated
        view.drawing_color = "SeaGreen"
        view.line_width = 2
        @preview[:bars].each do |bar|
          points = bar[:points].map do |local|
            @owner.point(3.times.map { |axis| bar[:center][axis] + bar[:tangent][axis]*local[0] + bar[:inward][axis]*local[1] + (axis == 2 ? local[2] : 0) })
          end
          view.draw(GL_LINE_STRIP, points)
        end
        @input.draw(view) if @input.valid?
      end

      def getExtents
        box = Geom::BoundingBox.new
        return box unless @preview
        @preview[:bars].each do |bar|
          bar[:points].each do |local|
            box.add(@owner.point(3.times.map { |axis| bar[:center][axis]+bar[:inward][axis]*local[1]+(axis == 2 ? local[2] : 0) }))
          end
        end
        box
      end

      def onLButtonDown(_flags, _x, _y, _view) = finish

      def finish
        return if @finished || !@preview
        @finished = true
        UI.start_timer(0, false) do
          next if @cancelled || @model != Sketchup.active_model || @model.active_path != @context
          begin
            @owner.build(@model, @points, @settings, anchor: @anchor, reverse: @reverse)
            @preview = nil
            @finished = false
            @model.active_view.invalidate if @model.respond_to?(:active_view) && @model.active_view
            Sketchup.set_status_text("Starter bars placed. Pick another position on the path; Space selects.")
          rescue StandardError => e
            @finished = false
            Sketchup.set_status_text("Starter bars: #{e.message}")
          end
        end
      end

      def onCancel(_reason, _view)
        @cancelled = true
        UI.start_timer(0, false) { @model.select_tool(nil) unless @deactivated || @model != Sketchup.active_model }
      end

      def deactivate(view)
        @deactivated = true
        @cancelled = true
        view.invalidate
      end
    end
  end
end
