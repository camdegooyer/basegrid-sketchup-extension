# frozen_string_literal: true

require "json"
require_relative "strip_footing_geometry"
require_relative "material_library"
require_relative "material_appearance"
require_relative "takeoff"

module Basegrid
  class StripFootingTool
    TOOL_ID = "concrete.strip_footing"
    ROLES = {
      "concrete" => ["Concrete", "m3"], "mesh" => ["Reo Trench Mesh", "m"],
      "chairs" => ["Trench Mesh Supports", "ea"], "spacers" => ["Bogar Spacers", "ea"]
    }.freeze

    def initialize(library: MaterialLibrary.new)
      @library = library
    end

    def materials_for(role)
      return @library.concrete_materials if role == "concrete"
      type_name, unit = ROLES.fetch(role)
      types = @library.material_types.select do |type|
        type.fetch("status", "active") == "active" && type.fetch("name").casecmp?(type_name) &&
          type.fetch("uom", unit) == unit
      end.map { |type| type.fetch("id") }
      @library.materials.select { |m| m.fetch("status", "active") == "active" && types.include?(m["material_type_id"]) }
        .sort_by { |m| m.fetch("name").downcase }
    end

    def run
      @library.load
      saved = JSON.parse(Sketchup.read_default("Basegrid", "strip_footing_settings", "{}")) rescue {}
      saved = {} unless saved.is_a?(Hash)
      @dialog&.close
      @dialog = UI::HtmlDialog.new(dialog_title: "Strip Footing", preferences_key: "basegrid_strip_footing",
                                    scrollable: true, resizable: true, width: 570, height: 760,
                                    style: UI::HtmlDialog::STYLE_DIALOG)
      @dialog.add_action_callback("drawFooting") do |_context, encoded|
        begin
          input = JSON.parse(encoded)
          bindings = validate_materials(input.fetch("materials"))
          settings = resolved_settings(input.fetch("settings"), bindings)
          Sketchup.write_default("Basegrid", "strip_footing_settings", JSON.generate(input))
          Sketchup.active_model.select_tool(DrawTool.new(self, settings, input.fetch("materials")))
          @dialog.close
        rescue StandardError => e
          @dialog.execute_script("document.getElementById('error').textContent=#{JSON.generate(e.message)}")
        end
      end
      @dialog.set_html(settings_html(saved))
      @dialog.show
    end

    def build(model, paths, settings = {}, materials = {})
      raise "The active model has changed." unless model == Sketchup.active_model
      raise "The editing context is locked." if Array(model.active_path).any?(&:locked?)
      bindings = validate_materials(materials)
      plan = StripFootingGeometry.plan(paths, resolved_settings(settings, bindings))
      model.start_operation("Create Strip Footing", true)
      started = true
      root = model.active_entities.add_group
      root.name = "Strip Footing"
      # Points are world coordinates. Preserve actual dimensions inside rotated,
      # scaled or mirrored edit contexts by cancelling the context transform.
      root.transformation = model.edit_transform.inverse
      root.layer = model.layers[0]
      root.set_attribute("Basegrid", "tool_id", TOOL_ID)
      root.set_attribute("Basegrid", "parameters_json", JSON.generate(paths_mm: paths, settings: plan[:settings], materials: materials))
      root.set_attribute("Basegrid", "warnings_json", JSON.generate(plan[:warnings]))
      concrete = plain_group(model, root.entities, "Concrete")
      actual_volume = 0.0
      plan[:concrete_parts].each do |part|
        segment = plain_group(model, concrete.entities, part[:name])
        add_surface(segment.entities, part[:faces])
        raise "#{part[:name]} did not form a closed solid." unless segment.manifold?
        volume = segment.volume * (0.0254**3)
        actual_volume += volume
        decorate(model, segment, "concrete", bindings["concrete"], volume)
      end
      tolerance = [1e-8, plan[:volume_m3] * 1e-5].max
      raise "Concrete volume does not match the planned net volume." if (actual_volume - plan[:volume_m3]).abs > tolerance
      unless plan[:mesh_layers].empty?
        reinforcement = plain_group(model, root.entities, "Reinforcement")
        plan[:mesh_layers].each do |layer|
          mesh = plain_group(model, reinforcement.entities, layer[:name])
          frame = plain_group(model, mesh.entities, "Mesh Frame")
          layer[:longitudinal].each_with_index do |bar, index|
            primary = index == layer[:primary_index]
            parent = primary ? mesh.entities : frame.entities
            place_bar(model, parent, bar, primary ? "Primary Bar" : format("Longitudinal Bar %02d", index+1))
          end
          layer[:cross_bars].each_with_index { |bar, index| place_bar(model, frame.entities, bar, format("Cross Bar %02d", index+1)) }
          decorate(model, mesh, "mesh", bindings["mesh"], layer[:length_m])
        end
        plan[:segments].each_index do |index|
          supports = plan[:chairs].select { |item| item[:segment_index] == index }
          pairs = plan[:spacers].select { |item| item[:segment_index] == index }
          unless supports.empty?
            collection = plain_group(model, reinforcement.entities, format("Mesh Supports %02d", index+1))
            supports.each_with_index do |support, number|
              signature = ["support", support[:width_mm], support[:length_mm], support[:height_mm]]
              definition = part_definition(model, signature, "Mesh Support") do |entities|
                box = [[-support[:width_mm]/2, -support[:length_mm]/2, 0],
                       [support[:width_mm]/2, support[:length_mm]/2, support[:height_mm]]]
                add_surface(entities, StripFootingGeometry.union([box])[:faces])
              end
              instance = collection.entities.add_instance(definition, placement(support))
              instance.name = format("Support %02d", number+1)
              decorate(model, instance, "chairs", bindings["chairs"], 1)
            end
          end
          unless pairs.empty?
            collection = plain_group(model, reinforcement.entities, format("Mesh Spacers %02d", index+1))
            pairs.each_with_index do |pair, number|
              signature = ["spacer_pair", pair[:diameter_mm], pair[:pair_offset_mm], pair[:height_mm]]
              definition = part_definition(model, signature, "Spacer Pair") do |entities|
                [-pair[:pair_offset_mm], pair[:pair_offset_mm]].each_with_index do |offset, bar_index|
                  bar = { a: [offset,0,0], b: [offset,0,pair[:height_mm]], diameter: pair[:diameter_mm] }
                  place_bar(model, entities, bar, format("Spacer Bar %02d", bar_index+1))
                end
              end
              instance = collection.entities.add_instance(definition, placement(pair))
              instance.name = format("Spacer Pair %02d", number+1)
              decorate(model, instance, "spacers", bindings["spacers"], 1)
            end
          end
        end
      end
      model.commit_operation
      started = false
      model.selection.clear
      model.selection.add(root)
      { entity: root, volume_m3: actual_volume, warnings: plan[:warnings] }
    rescue StandardError
      model.abort_operation if started
      raise
    end

    def validate_materials(materials)
      raise "Materials must be an object keyed by role." unless materials.is_a?(Hash)
      raise "Unknown material role." unless (materials.keys - ROLES.keys).empty?
      ROLES.to_h do |role, _|
        id = materials.fetch(role, "").to_s
        material = id.empty? ? nil : materials_for(role).find { |m| m.fetch("id").to_s == id }
        raise "Selected #{role} material is unavailable or has an incompatible material type." if !id.empty? && !material
        [role, material]
      end
    end

    def resolved_settings(settings, bindings)
      StripFootingGeometry.settings(settings.merge(mesh_dimensions(bindings["mesh"])))
    end

    def mesh_dimensions(material)
      dimensions = material && material["dimensions_mm"]
      return {} unless dimensions.is_a?(Hash)
      result = {}
      result["bar_count"] = dimensions["bars"] if dimensions["bars"]
      result["bar_diameter_mm"] = dimensions["diameter"] if dimensions["diameter"]
      if dimensions["width"] && dimensions["bars"] && Float(dimensions["bars"]) > 1
        result["bar_spacing_mm"] = Float(dimensions["width"]) / (Float(dimensions["bars"]) - 1)
      end
      result
    end

    private

    def plain_group(model, entities, name)
      group = entities.add_group
      group.name = name
      group.layer = model.layers[0]
      group
    end

    def part_definition(model, signature, label)
      key = JSON.generate([1, *signature.map { |value| value.is_a?(Numeric) ? value.round(6) : value }])
      @part_definitions ||= {}
      cached = @part_definitions[[model.object_id, key]]
      return cached if cached && cached.valid?
      definition = model.definitions.find { |item| item.get_attribute("Basegrid", "footing_part_signature") == key }
      unless definition
        dimensions = signature.drop(1).map { |value| format("%.2f", value).sub(/\.?0+\z/, "") }.join(" × ")
        definition = model.definitions.add("#{label} #{dimensions} mm")
        yield definition.entities
        definition.set_attribute("Basegrid", "footing_part_signature", key)
      end
      @part_definitions[[model.object_id, key]] = definition
    end

    def placement(item)
      run = item[:direction]
      Geom::Transformation.axes(point3d(item[:origin]), Geom::Vector3d.new(run[0], run[1], 0),
                               Geom::Vector3d.new(-run[1], run[0], 0), Geom::Vector3d.new(0, 0, 1))
    end

    def place_bar(model, entities, bar, name)
      a, b = point3d(bar[:a]), point3d(bar[:b])
      direction = b-a
      length_mm = direction.length.to_mm
      definition = part_definition(model, ["bar", bar[:diameter], length_mm], "Reinforcing Bar") do |target|
        add_bar(target, { a: [0,0,0], b: [0,0,length_mm], diameter: bar[:diameter] })
      end
      instance = entities.add_instance(definition, Geom::Transformation.axes(a, *direction.axes))
      instance.name = name
      instance.layer = model.layers[0]
      instance
    end

    def add_surface(entities, faces)
      # add_face heals/merges adjacent coplanar grid faces during insertion,
      # which can leave a hole at a junction. Fill an already welded surface
      # as one mesh. Keep subdivision topology at junctions: erasing coplanar
      # grid edges can also erase necessary shared boundary edges in SketchUp.
      mesh = Geom::PolygonMesh.new
      faces.each do |vertices|
        mesh.add_polygon(*vertices.map { |p| point3d(p) })
      end
      raise "A concrete or support surface could not be created." unless entities.fill_from_mesh(mesh, true, 0)
      # Hide only coplanar subdivisions, preserving the welded solid shell.
      entities.grep(Sketchup::Edge).each do |edge|
        next unless edge.valid? && edge.faces.length == 2
        a, b = edge.faces
        if a.normal.samedirection?(b.normal)
          edge.hidden = true
          edge.soft = true
        end
      end
      entities.each { |entity| entity.layer = Sketchup.active_model.layers[0] }
    end

    def add_bar(entities, bar)
      a, b = point3d(bar[:a]), point3d(bar[:b])
      direction = b - a
      edges = entities.add_circle(a, direction, bar[:diameter].mm / 2, 12)
      face = entities.add_face(edges)
      raise "A reinforcement bar could not be created." unless face
      face.reverse! if face.normal.dot(direction).negative?
      face.pushpull(direction.length)
      entities.each { |entity| entity.layer = Sketchup.active_model.layers[0] }
      entities.grep(Sketchup::Edge).each do |edge|
        next unless edge.faces.length == 2
        next if edge.faces.any? { |f| f.normal.parallel?(direction) }
        edge.soft = true
        edge.smooth = true
      end
    end

    def point3d(p)
      Geom::Point3d.new(*p.map { |coordinate| coordinate.mm })
    end

    def decorate(model, group, role, material, quantity)
      role_id = "#{TOOL_ID}.#{role}"
      label, unit = ROLES.fetch(role)
      tag_name = "Strip Footing | #{label}"
      tag = model.layers[tag_name]
      if tag && !["", role_id].include?(tag.get_attribute("Basegrid", "generated_role_id").to_s)
        raise "The tag #{tag_name} belongs to another generated role."
      end
      unless tag
        tag = model.layers.add(tag_name)
        folder_name = Sketchup.read_default("Basegrid", "strip_footing_tag_folder", "Structure").to_s
        unless folder_name.empty?
          folder = model.layers.folders.find { |f| f.name == folder_name } || model.layers.add_folder(folder_name)
          tag.folder = folder
        end
      end
      tag.set_attribute("Basegrid", "generated_role_id", role_id)
      group.layer = tag
      group.set_attribute("Basegrid", "tool_id", TOOL_ID)
      group.set_attribute("Basegrid", "generated_role_id", role_id)
      group.set_attribute("Basegrid", "material_role", role)
      if material
        group.set_attribute("Basegrid", "material_id", material.fetch("id"))
        group.set_attribute("Basegrid", "material_type_id", material.fetch("material_type_id"))
        MaterialAppearance.new(library: @library).apply(group, material, mode: MaterialAppearance.mode(model), model: model)
      else
        group.material = role == "concrete" ? "Silver" : "DimGray"
      end
      placeholder = { "id" => "", "name" => "Unassigned #{label}" }
      Takeoff.write_quantity(group, material: material || placeholder, role_id: role_id, material_role: role,
                             quantity: quantity, unit: unit,
                             basis: role == "concrete" ? "Net generated concrete solid volume" : "Generated geometry; excludes undetailed connections and purchase waste")
    end

    def settings_html(saved)
      labels = {
        "width_mm" => "Footing width (mm)", "depth_mm" => "Footing depth (mm)",
        "alignment" => "Path alignment", "vertical_reference" => "Path height reference",
        "step_overlap_mm" => "Step overlap (mm)", "reinforcement" => "Mesh layers",
        "bar_count" => "Longitudinal bars", "bar_spacing_mm" => "Longitudinal bar spacing (mm)",
        "bar_diameter_mm" => "Longitudinal diameter (mm)", "cross_diameter_mm" => "Cross-bar diameter (mm)",
        "cross_spacing_mm" => "Cross-bar spacing (mm)", "cover_mm" => "Clear cover, all faces (mm)",
        "support_spacing_mm" => "Support spacing (mm)", "support_width_mm" => "Support width along run (mm)",
        "support_first_offset_mm" => "First support after end cover (mm)",
        "spacer_diameter_mm" => "Spacer bar diameter (mm)", "spacer_pair_offset_mm" => "Spacer pair half-spacing (mm)"
      }
      choices = { "alignment" => %w[center left_edge right_edge], "vertical_reference" => %w[top bottom],
                  "reinforcement" => %w[none bottom top_bottom], "bar_count" => [3, 4] }
      payload = JSON.generate(defaults: StripFootingGeometry::DEFAULTS, saved: saved, labels: labels, choices: choices,
                              materials: ROLES.to_h { |role, _| [role, materials_for(role).map { |m| m.slice("id", "name").merge("settings" => role == "mesh" ? mesh_dimensions(m) : {}) }] }).gsub("<", "\\u003c")
      <<~HTML
        <!doctype html><html><head><meta charset="utf-8"><style>
        body{font:14px -apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;margin:24px;color:#263238;background:#f5f6f7}
        h1{font-size:24px;margin-bottom:8px}p{line-height:1.5}#fields{display:grid;grid-template-columns:1fr 1fr;gap:14px}
        label{display:block;font-size:12px}input,select{box-sizing:border-box;width:100%;padding:8px;margin-top:5px;border:1px solid #b8c2ca;border-radius:4px}
        button{padding:12px 20px;background:#1769aa;color:white;border:0;border-radius:4px;margin-top:18px;cursor:pointer}
        #error{color:#a32424}aside{padding:12px;background:#fff2cf;line-height:1.5;margin:16px 0}
        </style></head><body><h1>Strip footing</h1><p>Draw connected X/Y runs, loops and branches. Tab moves the setout anchor around the cross section. Right-click to add a step or start a branch. Enter finishes the assembly.</p>
        <aside>First version: mesh runs have no corner, step or junction connection details. Supports are generic dimensioned shapes. Dimensions are modelling inputs. Selected mesh sets its available bar count, diameter and spacing; remaining dimensions stay editable.</aside>
        <form id="form"><div id="fields"></div><p id="error"></p><button type="submit">Start drawing</button></form>
        <script>
        const data=#{payload}; const fields=document.getElementById('fields'); const controls={}, materials={};
        for(const [key,value] of Object.entries(data.defaults)){
          const label=document.createElement('label');label.textContent=data.labels[key];
          const input=document.createElement(data.choices[key]?'select':'input');
          if(data.choices[key])for(const choice of data.choices[key]){const o=document.createElement('option');o.value=choice;o.textContent=String(choice).replaceAll('_',' ');input.append(o);}
          else{input.type='number';input.min='0.01';input.step='any';input.required=true;}
          input.value=data.saved.settings?.[key]??value;controls[key]=input;label.append(input);fields.append(label);
        }
        for(const [role,items] of Object.entries(data.materials)){
          const label=document.createElement('label');label.textContent=role+' material';const select=document.createElement('select');
          const empty=document.createElement('option');empty.value='';empty.textContent='Unassigned — use entered dimensions';select.append(empty);
          for(const item of items){const o=document.createElement('option');o.value=item.id;o.textContent=item.name;select.append(o);}
          select.value=data.saved.materials?.[role]??'';materials[role]=select;label.append(select);fields.append(label);
          if(role==='mesh'){
            const apply=()=>{for(const key of ['bar_count','bar_diameter_mm','bar_spacing_mm'])controls[key].disabled=false;
              const item=items.find(m=>m.id===select.value);for(const [key,value] of Object.entries(item?.settings??{})){controls[key].value=value;controls[key].disabled=true;}};
            select.onchange=apply;apply();
          }
        }
        document.getElementById('form').onsubmit=e=>{e.preventDefault();const settings={},bindings={};
          for(const [key,input] of Object.entries(controls))settings[key]=typeof data.defaults[key]==='number'?Number(input.value):input.value;
          for(const [role,input] of Object.entries(materials))bindings[role]=input.value;
          sketchup.drawFooting(JSON.stringify({settings,materials:bindings}));};
        </script></body></html>
      HTML
    end

    class DrawTool
      TAB_KEY = defined?(::VK_TAB) ? ::VK_TAB : 9
      # Walks once around the cross section rather than varying one axis at a
      # time, so repeated presses read as rotating through the anchor points.
      ANCHORS = [["top", "left_edge"], ["top", "center"], ["top", "right_edge"],
                 ["bottom", "right_edge"], ["bottom", "center"], ["bottom", "left_edge"]].freeze

      def initialize(builder, settings, materials)
        @builder, @settings, @materials = builder, settings, materials
        @anchor = ANCHORS.index([settings["vertical_reference"], settings["alignment"]]) || 1
        @paths = [[]]
        @hover = nil
        @error = nil
        @level = nil
      end

      def activate
        @model = Sketchup.active_model
        @context = Array(@model.active_path).dup
        @input = Sketchup::InputPoint.new
        status
      end

      def deactivate(view)
        view.invalidate
      end

      def enableVCB? = true

      def onKeyDown(key, _repeat, _flags, view)
        return false unless key == TAB_KEY

        cycle_anchor
        status
        view.invalidate
        true
      end

      # Moves the setout anchor to the next point on the cross section. Already
      # clicked points are setout points, so the whole assembly re-offsets.
      def cycle_anchor
        @anchor = (@anchor + 1) % ANCHORS.length
        @settings["vertical_reference"], @settings["alignment"] = ANCHORS[@anchor]
      end

      def anchor_label
        ANCHORS[@anchor].reverse.join(" ").tr("_", " ")
      end

      def onMouseMove(_flags, x, y, view)
        anchor = @paths.last.last
        if anchor
          @input.pick(view, x, y, Sketchup::InputPoint.new(to_point(anchor)))
        else
          @input.pick(view, x, y)
        end
        unless @input.valid?
          @hover = nil
          return
        end
        p = @input.position
        @hover = [p.x.to_mm.to_f, p.y.to_mm.to_f, @level || p.z.to_mm.to_f]
        if anchor
          @hover[2] = anchor[2]
          axis = (@hover[0] - anchor[0]).abs >= (@hover[1] - anchor[1]).abs ? 0 : 1
          @hover[1 - axis] = anchor[1 - axis]
        end
        view.tooltip = @input.tooltip
        view.invalidate
      end

      def onLButtonDown(flags, x, y, view)
        onMouseMove(flags, x, y, view)
        add_point(@hover, view) if @hover
      end

      def onLButtonDoubleClick(_flags, _x, _y, view)
        onReturn(view)
      end

      def add_point(point, view)
        current = @paths.last
        return if current.last && StripFootingGeometry.same_xy?(current.last, point)
        current << point.dup
        @level ||= point[2]
        @error = nil
        status
        view.invalidate
      end

      def onUserText(text, view)
        anchor = @paths.last.last
        raise "Click a start point and move in the run direction first." unless anchor && @hover
        distance = text.to_l.to_mm.to_f
        raise "Enter a positive length." unless distance.finite? && distance > 1
        delta = [@hover[0] - anchor[0], @hover[1] - anchor[1]]
        axis = delta[0].abs >= delta[1].abs ? 0 : 1
        raise "Move the cursor to set a direction first." if delta[axis].abs < 0.01
        target = anchor.dup
        target[axis] += delta[axis].positive? ? distance : -distance
        add_point(target, view)
      rescue StandardError => e
        @error = e.message
        status
      end

      def onReturn(view)
        return if @finished
        raise "The model or editing context changed; restart drawing." unless Sketchup.active_model == @model && Array(@model.active_path) == @context
        paths = @paths.select { |path| path.length >= 2 }
        result = @builder.build(@model, paths, @settings, @materials)
        @finished = true
        @model.select_tool(nil)
        UI.messagebox(result[:warnings].join("\n\n")) unless result[:warnings].empty?
        view.invalidate
      rescue StandardError => e
        @error = e.message
        status
        UI.messagebox(e.message)
      end

      def onCancel(_reason, view)
        @model.select_tool(nil)
        view.invalidate
      end

      def getMenu(menu, *_event)
        menu.add_item("Finish Footing") { onReturn(@model.active_view) }
        menu.add_item("Undo Last Point") do
          @paths.last.pop
          @paths.pop if @paths.length > 1 && @paths.last.empty?
          @level = @paths.last.last&.last
          @hover = nil
          status
          @model.active_view.invalidate
        end
        menu.add_item("Start Branch / New Run") do
          @paths << [] unless @paths.last.empty?
          @hover = nil
          @level = nil
          status
        end
        menu.add_item("Step from Last Point…") do
          current = @paths.last
          if current.length < 2
            UI.messagebox("Draw a run before adding a step.")
            next
          end
          values = UI.inputbox(["Height change (mm; negative lowers footing)"], [200.0], "Footing Step")
          next unless values
          begin
            delta = Float(values.first)
            raise "Step must be nonzero and less than footing depth." unless delta.finite? && delta.abs > 0.01 && delta.abs < @settings["depth_mm"]
            start = current.last.dup
            start[2] += delta
            @paths << [start]
            @level = start[2]
            @hover = nil
            status
          rescue StandardError => e
            UI.messagebox(e.message)
          end
        end
        menu.add_item("Close Current Loop") do
          current = @paths.last
          add_point(current.first, @model.active_view) if current.length >= 3
        end
      end

      def draw(view)
        @input.draw(view) if @input&.valid?
        paths = @paths.map { |p| p.map(&:dup) }
        paths.last << @hover if @hover && paths.last.any? && !StripFootingGeometry.same_xy?(paths.last.last, @hover)
        paths.each do |path|
          next if path.length < 2
          view.drawing_color = "#1684be"
          view.line_width = 2
          view.draw(GL_LINE_STRIP, path.map { |p| to_point(p) })
        end
        valid_paths = paths.select { |p| p.length >= 2 }
        return if valid_paths.empty?
        begin
          plan = StripFootingGeometry.plan(valid_paths, @settings.merge("reinforcement" => "none"))
          view.drawing_color = Sketchup::Color.new(80, 160, 210, 65)
          triangles = plan[:faces].flat_map { |f| [f[0], f[1], f[2], f[0], f[2], f[3]] }
          view.draw(GL_TRIANGLES, triangles.map { |p| to_point(p) })
          steel = StripFootingGeometry.steel(plan[:segments], @settings)
          bars = steel[:bars] + steel[:spacers].flat_map { |pair| pair[:bars] }
          unless bars.empty?
            view.drawing_color = "#354a5f"
            view.line_width = 2
            view.draw(GL_LINES, bars.flat_map { |bar| [to_point(bar[:a]), to_point(bar[:b])] })
          end
          steel[:chairs].each do |support|
            half = support[:length_mm]/2
            run = support[:direction]
            center = support[:origin]
            points = [-half, half].map { |offset| [center[0]-run[1]*offset, center[1]+run[0]*offset, center[2]+support[:height_mm]] }
            view.drawing_color = "#247755"
            view.line_width = 4
            view.draw(GL_LINES, points.map { |p| to_point(p) })
          end
          @error = nil
        rescue StandardError => e
          @error = e.message
        end
        status
      end

      def getExtents
        bounds = Geom::BoundingBox.new
        @paths.flatten(1).each { |p| bounds.add(to_point(p)) }
        bounds.add(to_point(@hover)) if @hover
        bounds
      end

      def to_point(p)
        Geom::Point3d.new(*p.map(&:mm))
      end

      def status
        Sketchup.set_status_text(@error || "Strip footing anchor #{anchor_label} (Tab cycles): click X/Y runs; type a length; "                                            "right-click for steps/branches; Enter builds; Esc cancels.")
      end
    end
  end
end
