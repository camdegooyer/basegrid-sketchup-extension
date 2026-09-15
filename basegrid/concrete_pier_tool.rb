# frozen_string_literal: true

require_relative "starter_bar_tool"

module Basegrid
  class ConcretePierTool
    TOOL_ID = "concrete.pier"
    PIER_SEGMENTS = 24
    DEFAULTS = { "pier_diameter_mm" => 450, "pier_depth_mm" => 600, "concrete_material" => "",
                 "add_bar" => false, "bar_material" => "", "bar_diameter_mm" => 16,
                 "bar_above_mm" => 300, "bar_below_mm" => 500, "top_crank_mm" => 0,
                 "bottom_crank_mm" => 0, "top_crank_dir" => "in", "bottom_crank_dir" => "in" }.freeze

    def initialize(library: MaterialLibrary.new)
      @library = library
      @bars = StarterBarTool.new(library: library)
    end

    def resolve(input)
      raise "Pier settings must be an object." unless input.is_a?(Hash)
      settings = DEFAULTS.merge(input.select { |key, _| DEFAULTS.key?(key) })
      DEFAULTS.each do |key, default|
        next unless default.is_a?(Numeric)
        settings[key] = Float(settings[key])
        raise "#{key.delete_suffix('_mm')} must be a finite non-negative number." unless settings[key].finite? && settings[key] >= 0
      end
      raise "Pier diameter and depth must be positive." unless settings["pier_diameter_mm"] >= 1 && settings["pier_depth_mm"] >= 1
      raise "Invalid starter bar option." unless [true, false].include?(settings["add_bar"])
      %w[top_crank_dir bottom_crank_dir].each { |key| raise "Invalid crank direction." unless %w[in out].include?(settings[key]) }
      concrete_id = settings["concrete_material"].to_s
      concrete = @library.concrete_materials.find { |m| m["id"].to_s == concrete_id } unless concrete_id.empty?
      raise "Selected concrete material is unavailable." if !concrete_id.empty? && !concrete
      bar = nil
      if settings["add_bar"]
        id = settings["bar_material"].to_s
        bar = @bars.materials_for("bar").find { |m| m["id"].to_s == id } unless id.empty?
        raise "Selected starter bar material is unavailable." if !id.empty? && !bar
        diameter = bar&.dig("dimensions_mm", "diameter") || bar&.dig("dimensions_mm", "diameter_mm")
        raise "Selected bar material has no diameter metadata. Update the material and sync again." if bar && diameter.nil?
        settings["bar_diameter_mm"] = Float(diameter) if diameter
        raise "Bar diameter must be positive and finite." unless settings["bar_diameter_mm"].finite? && settings["bar_diameter_mm"] >= 1
        raise "Starter bar height must be positive." unless settings["bar_above_mm"] + settings["bar_below_mm"] >= 1
      end
      [settings, { "concrete" => concrete, "bar" => bar }]
    end

    def saved_settings
      result = JSON.parse(Sketchup.read_default("Basegrid", "pier_settings", "{}"))
      result.is_a?(Hash) ? result : {}
    rescue JSON::ParserError, TypeError
      {}
    end

    def run
      @library.load
      model = Sketchup.active_model
      selection = model.selection.to_a
      existing = selection.length == 1 && selection[0].is_a?(Sketchup::Group) && selection[0].get_attribute("Basegrid", "tool_id") == TOOL_ID ? selection[0] : nil
      raise "The pier is locked." if existing&.locked?
      defaults = existing ? JSON.parse(existing.get_attribute("Basegrid", "parameters_json")) : saved_settings
      context = model.active_path&.dup
      @dialog&.close
      dialog = UI::HtmlDialog.new(dialog_title: "Concrete Piers", preferences_key: "basegrid_concrete_piers",
                                  scrollable: true, resizable: true, width: 460, height: 640,
                                  style: UI::HtmlDialog::STYLE_DIALOG)
      @dialog = dialog
      submitting = false
      dialog.add_action_callback("create") do |_, payload|
        next if submitting
        begin
          submitting = true
          raise "The active model or editing context changed." unless Sketchup.active_model == model && context == model.active_path
          settings, = resolve(JSON.parse(payload))
          raise "The editing context is locked." if Array(model.active_path).any?(&:locked?)
          if existing
            build(model, settings, transform: existing.transformation, replace: existing)
          else
            model.select_tool(PlacementTool.new(self, model, settings))
          end
          Sketchup.write_default("Basegrid", "pier_settings", JSON.generate(settings))
          dialog.close
        rescue StandardError => e
          submitting = false
          dialog.execute_script("document.getElementById('error').textContent=#{JSON.generate(e.message)}")
        end
      end
      dialog.set_html(settings_html(defaults, editing: !!existing))
      dialog.show
    rescue StandardError => e
      UI.messagebox("Concrete pier: #{e.message}")
    end

    def bar_points(settings)
      below, above = settings.values_at("bar_below_mm", "bar_above_mm")
      bottom = settings["bottom_crank_mm"] * (settings["bottom_crank_dir"] == "in" ? 1 : -1)
      top = settings["top_crank_mm"] * (settings["top_crank_dir"] == "in" ? 1 : -1)
      [[bottom, 0, -below], [0, 0, -below], [0, 0, above], [top, 0, above]].chunk_while { |a,b| a == b }.map(&:first)
    end

    def build(model, input, transform:, replace: nil)
      raise "The active model changed." unless Sketchup.active_model == model
      raise "The editing context is locked." if Array(model.active_path).any?(&:locked?)
      raise "The original pier is unavailable or locked." if replace && (!replace.valid? || replace.locked? || !model.active_entities.include?(replace))
      settings, materials = resolve(input)
      model.start_operation(replace ? "Edit Concrete Pier" : "Create Concrete Pier", true)
      started = true
      root = build_in(model, model.active_entities, settings, materials, transform: transform, world: model.edit_transform * transform)
      root.name = replace.name if replace
      root.layer = replace.layer if replace
      replace.erase! if replace
      model.commit_operation
      started = false
      root
    rescue StandardError
      model.abort_operation if started
      raise
    end

    # The assembly owner supplies the transaction and enclosing world transform.
    def build_in(model, entities, settings, materials, transform:, world:)
      root = entities.add_group
      root.name = "Concrete Pier"
      root.layer = model.layers[0]
      root.transformation = transform
      root.set_attribute("Basegrid", "tool_id", TOOL_ID)
      root.set_attribute("Basegrid", "parameters_json", JSON.generate(settings))
      concrete = root.entities.add_group
      concrete.name = "Concrete"
      concrete.set_attribute("Basegrid", "cylindrical_texture_radius", settings["pier_diameter_mm"]/50.8)
      edges = concrete.entities.add_circle(@bars.point([0,0,0]), Geom::Vector3d.new(0,0,1), settings["pier_diameter_mm"]/50.8, PIER_SEGMENTS)
      face = concrete.entities.add_face(edges)
      raise "Could not create the pier profile." unless face
      face.reverse! if face.normal.z < 0
      face.pushpull(-settings["pier_depth_mm"]/25.4)
      # Report the generated polygonal volume, including any enclosing scale.
      scale = world.xaxis.dot(world.yaxis.cross(world.zaxis)).abs
      volume = PIER_SEGMENTS * Math.sin(2*Math::PI/PIER_SEGMENTS)/2 * (settings["pier_diameter_mm"]/2)**2 * settings["pier_depth_mm"]/1e9 * scale
      decorate(model, concrete, "concrete", materials["concrete"], volume, "m3")
      if settings["add_bar"]
        bar = root.entities.add_group
        bar.name = "Starter Bar"
        points = bar_points(settings)
        @bars.add_bar(bar.entities, points, settings["bar_diameter_mm"])
        length = points.map { |p| @bars.point(p).transform(world) }.each_cons(2).sum { |a,b| a.distance(b) } * 0.0254
        type = materials["bar"] && @library.material_types.find { |t| t["id"] == materials["bar"]["material_type_id"] }
        unit = type && %w[ea each].include?(type["uom"]) ? "ea" : "m"
        decorate(model, bar, "bar", materials["bar"], unit == "m" ? length : 1, unit)
      end
      root
    end

    def decorate(model, entity, role, material, quantity, unit)
      role_id = "#{TOOL_ID}.#{role}"
      name = role == "concrete" ? "Pier | Concrete" : "Pier | Starter Bar"
      tag = model.layers[name] || model.layers.add(name)
      owner = tag.get_attribute("Basegrid", "generated_role_id").to_s
      raise "The tag #{name} belongs to another role." unless owner.empty? || owner == role_id
      tag.set_attribute("Basegrid", "generated_role_id", role_id)
      entity.layer = tag
      entity.entities.each { |child| child.layer = model.layers[0] }
      entity.set_attribute("Basegrid", "generated_role_id", role_id)
      entity.set_attribute("Basegrid", "material_role", role)
      if material
        entity.set_attribute("Basegrid", "material_id", material.fetch("id"))
        entity.set_attribute("Basegrid", "material_type_id", material.fetch("material_type_id"))
        MaterialAppearance.new(library: @library).apply(entity, material, mode: MaterialAppearance.mode(model), model: model)
      else
        entity.material = role == "concrete" ? "Silver" : "DimGray"
      end
      Takeoff.write_quantity(entity, material: material || { "id" => "", "name" => "Unassigned #{role}" },
                            role_id: role_id, material_role: role, quantity: quantity, unit: unit,
                            basis: role == "concrete" ? "Generated 24-sided pier volume" : "Starter bar centreline length or placed count")
    end

    def settings_html(saved, editing: false)
      fields = { "pier_diameter_mm" => "Pier diameter (mm)", "pier_depth_mm" => "Pier depth (mm)",
                 "bar_above_mm" => "Above pier top (mm)",
                 "bar_below_mm" => "Below pier top (mm)", "top_crank_mm" => "Top crank (mm)", "bottom_crank_mm" => "Bottom crank (mm)" }
      number = ->(key) { "<label for='#{key}'>#{fields[key]}</label><input id='#{key}' type='number' min='0' step='any' required>" }
      directions = %w[top bottom].map { |end_name| "<label for='#{end_name}_crank_dir'>#{end_name.capitalize} direction</label><select id='#{end_name}_crank_dir'><option value='in'>In</option><option value='out'>Out</option></select>" }
      data = JSON.generate(defaults: DEFAULTS.merge(saved.select { |key,_| DEFAULTS.key?(key) }), concrete: @library.concrete_materials, bar: @bars.materials_for("bar")).gsub("<", "\\u003c")
      <<~HTML
        <!doctype html><html><head><meta charset="utf-8"><style>
        *{box-sizing:border-box}body{font:13px -apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;margin:20px;background:white;color:#25282b}h1{font-size:20px;margin:0 0 16px}label{display:block;margin:10px 0 5px}input,select{width:100%;padding:7px;font:inherit;border:1px solid #bcc2c7;border-radius:3px}.row{display:grid;grid-template-columns:1fr 1fr;gap:14px}.check{display:flex;align-items:center;gap:8px}.check input{width:auto}button{margin-top:16px;padding:9px 16px;background:#246c52;color:white;border:0;border-radius:3px}#error{color:#b42318}[hidden]{display:none!important}
        </style></head><body><h1>Concrete piers</h1><form id="form">
        <div class="row"><div>#{number.call("pier_diameter_mm")}</div><div>#{number.call("pier_depth_mm")}</div></div>
        <label for="concrete_material">Concrete material</label><select id="concrete_material"></select>
        <label class="check"><input id="add_bar" type="checkbox">Starter bar</label><section id="bar_fields">
        <label for="bar_material">Bar material</label><select id="bar_material"></select>
        <div class="row"><div>#{number.call("bar_above_mm")}</div><div>#{number.call("bar_below_mm")}</div></div>
        <div class="row"><div>#{number.call("top_crank_mm")}#{directions[0]}</div><div>#{number.call("bottom_crank_mm")}#{directions[1]}</div></div>
        </section><div id="error" role="alert"></div><button type="submit">#{editing ? 'Update pier' : 'Place piers'}</button></form><script>
        const data=#{data},el=id=>document.getElementById(id);
        for(const role of ['concrete','bar']){const select=el(role+'_material');select.add(new Option('Unassigned',''));data[role].forEach(row=>select.add(new Option(row.name,row.id)));}
        for(const [key,value] of Object.entries(data.defaults)){const input=el(key);if(!input)continue;if(input.type==='checkbox')input.checked=value;else input.value=value;}
        function refresh(){el('bar_fields').hidden=!el('add_bar').checked;el('bar_fields').querySelectorAll('input,select').forEach(input=>input.disabled=!el('add_bar').checked);}
        el('add_bar').addEventListener('change',refresh);el('bar_material').addEventListener('change',refresh);refresh();
        el('form').addEventListener('submit',event=>{event.preventDefault();const values={};for(const key of Object.keys(data.defaults)){const input=el(key);if(!input)continue;values[key]=input.type==='checkbox'?input.checked:input.type==='number'?Number(input.value):input.value;}el('error').textContent='';sketchup.create(JSON.stringify(values));});
        </script></body></html>
      HTML
    end

    class PlacementTool
      def initialize(owner, model, settings)
        @owner, @model, @settings = owner, model, settings
        @context = model.active_path&.dup
        @input = Sketchup::InputPoint.new
      end

      def activate
        @active = true
        prompt
      end

      def prompt
        Sketchup.set_status_text(@center ? "Pick starter-bar crank direction. Esc cancels this pier." : "Pick pier top centre. Esc finishes.")
      end

      def deactivate(view)
        @active = false
        @deactivated = true
        view.lock_inference
        view.invalidate
      end

      def onCancel(_reason, view)
        return unless @active
        if @center && !@busy
          @center = nil
          view.lock_inference
          prompt
          view.invalidate
        else
          @active = false
          UI.start_timer(0, false) { @model.select_tool(nil) if @model == Sketchup.active_model && !@deactivated }
        end
      end

      def onMouseMove(_flags, x, y, view)
        return unless @active && !@busy
        if @center
          @input.pick(view, x, y, Sketchup::InputPoint.new(@center))
        else
          @input.pick(view, x, y)
        end
        @hover = @input.valid? ? @input.position : nil
        view.tooltip = @input.tooltip
        view.invalidate
      end

      def onLButtonDown(flags, x, y, view)
        return unless @active && !@busy
        onMouseMove(flags, x, y, view)
        return unless @hover
        if @settings["add_bar"] && !@center
          @center = @hover.clone
          view.lock_inference
          prompt
          return
        end
        center = @center || @hover
        delta = @center ? @hover - @center : Geom::Vector3d.new(1,0,0)
        direction = Geom::Vector3d.new(delta.x, delta.y, 0)
        if direction.length < 1.0/25.4
          Sketchup.set_status_text("Pick a direction away from the pier centre in plan.")
          return
        end
        direction.normalize!
        transform = @model.edit_transform.inverse * Geom::Transformation.axes(center, direction, Geom::Vector3d.new(-direction.y,direction.x,0), Geom::Vector3d.new(0,0,1))
        place(transform, view)
      end

      def place(transform, view)
        return unless @active && !@busy
        @busy = true
        UI.start_timer(0, false) do
          begin
            next unless @active && @model == Sketchup.active_model && @context == @model.active_path
            @owner.build(@model, @settings, transform: transform)
            @center = @hover = nil
            @axis_key = nil
            view.lock_inference
            prompt
          rescue StandardError => e
            Sketchup.set_status_text("Concrete pier: #{e.message}")
          ensure
            @busy = false
            view.invalidate if @active
          end
        end
      end

      def onKeyDown(key, repeat, _flags, view)
        return unless @active && !@busy
        return unless [16,37,38,39,40].include?(key) && @input.valid?
        return true if repeat > 1
        if key == 16 || key == 40
          view.lock_inference(@input)
          @axis_key = nil
        elsif @axis_key == key
          view.lock_inference
          @axis_key = nil
        else
          axis = { 37 => [0,1,0], 38 => [0,0,1], 39 => [1,0,0] }.fetch(key)
          origin = @center || @hover
          return unless origin
          view.lock_inference(Sketchup::InputPoint.new(origin), Sketchup::InputPoint.new(origin.offset(Geom::Vector3d.new(axis))))
          @axis_key = key
        end
        true
      end

      def onKeyUp(key, _repeat, _flags, view)
        return unless @active && !@busy && key == 16
        view.lock_inference
        true
      end

      def preview
        center = @center || @hover
        return [] unless center
        c = center.to_a.map { |v| v*25.4 }
        rings = [0, -@settings["pier_depth_mm"]].map do |z|
          (0..PIER_SEGMENTS).map { |i| angle = i*2*Math::PI/PIER_SEGMENTS; [c[0]+@settings["pier_diameter_mm"]/2*Math.cos(angle), c[1]+@settings["pier_diameter_mm"]/2*Math.sin(angle), c[2]+z] }
        end
        lines = rings + [0,6,12,18].map { |i| [rings[0][i], rings[1][i]] }
        if @settings["add_bar"]
          dx, dy = @center && @hover ? [@hover.x-@center.x, @hover.y-@center.y] : [1,0]
          length = Math.hypot(dx,dy)
          dx,dy = length > 1e-9 ? [dx/length,dy/length] : [1,0]
          lines << @owner.bar_points(@settings).map { |x,y,z| [c[0]+dx*x, c[1]+dy*x,c[2]+z] }
        end
        lines
      end

      def draw(view)
        return unless @active && !@busy
        @input.draw(view) if @input.valid?
        view.drawing_color = "SeaGreen"
        view.line_width = 2
        preview.each { |line| view.draw(GL_LINE_STRIP, line.map { |p| Geom::Point3d.new(p.map { |v| v/25.4 }) }) }
      end

      def getExtents
        bounds = Geom::BoundingBox.new
        preview.flatten(1).each { |p| bounds.add(Geom::Point3d.new(p.map { |v| v/25.4 })) } if @active && !@busy
        bounds
      end
    end
  end
end
