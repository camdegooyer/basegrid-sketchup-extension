# frozen_string_literal: true
require "json"
require_relative "structural_steel_geometry"
require_relative "material_library"
require_relative "material_appearance"
require_relative "takeoff"

module Basegrid
  class StructuralSteelTool
    TOOL_ID = "structure.steel_member"
    G = StructuralSteelGeometry
    def initialize(library: MaterialLibrary.new) = @library = library

    def materials
      types = @library.material_types.filter_map do |t|
        next unless t.fetch("status","active") == "active" && t["uom"] == "m"
        subtype = t["name"].to_s.match(/\AStructural Steel\s*[^a-zA-Z]+\s*(PFC|UB|UC|SHS|RHS|CHS)\z/i)&.[](1)&.upcase
        [t["id"],subtype] if subtype
      end.to_h
      @library.materials.filter_map do |m|
        subtype = types[m["material_type_id"]]
        next unless subtype && m.fetch("status","active") == "active"
        m.merge("steel_type" => subtype)
      end.sort_by { |m| [m["steel_type"],m["name"].to_s] }
    end

    def resolve(input)
      s = G.settings(input)
      material = materials.find { |m| m["id"] == s["material_id"] }
      raise "Choose an active structural steel material from the synced library." unless material
      section = G.section(material,material["steel_type"])
      G.profile(section)
      { settings: s, material: material, section: section }
    end

    def saved_settings
      data = JSON.parse(Sketchup.read_default("Basegrid","steel_member_settings","{}"))
      data.is_a?(Hash) ? data : {}
    rescue JSON::ParserError,TypeError
      {}
    end

    def remember(settings)
      Sketchup.write_default("Basegrid","steel_member_settings",JSON.generate(settings))
    end

    def run(similar: false)
      @library.load
      model = Sketchup.active_model
      selection = model.selection.to_a
      original = selection.length == 1 && selection.first.is_a?(Sketchup::Group) && selection.first.get_attribute("Basegrid","tool_id") == TOOL_ID ? selection.first : nil
      saved = original ? JSON.parse(original.get_attribute("Basegrid","parameters_json")) : saved_settings
      original = nil if similar
      saved = G::DEFAULTS.merge(saved)
      saved["anchor"] = "top_left" unless original
      context = model.active_path&.dup
      @dialog&.close
      dialog = UI::HtmlDialog.new(dialog_title: "Structural Steel",preferences_key: "basegrid_structural_steel",width: 510,height: 680,
                                  scrollable: true,resizable: true,style: UI::HtmlDialog::STYLE_DIALOG)
      @dialog = dialog
      busy = false
      dialog.add_action_callback("create") do |_,json|
        next if busy
        begin
          busy = true
          raise "The active model or editing context changed." unless Sketchup.active_model == model && model.active_path == context
          match = resolve(JSON.parse(json))
          if original
            build(model,match[:settings],transform: original.transformation,replace: original)
          else
            model.select_tool(DrawTool.new(self,model,match))
          end
          remember(match[:settings])
          dialog.close
        rescue StandardError => e
          busy = false
          dialog.execute_script("document.getElementById('error').textContent=#{JSON.generate(e.message).gsub('<','\\u003c')}")
        end
      end
      dialog.set_html(settings_html(saved,editing: !!original))
      dialog.show
    rescue StandardError => e
      UI.messagebox("Structural steel: #{e.message}")
    end

    def point(values) = Geom::Point3d.new(values.map { |v| v/25.4 })

    def frame(start_point,end_point)
      run = start_point.vector_to(end_point)
      raise "Member length must be at least 1 mm." if run.length*25.4 < 1
      run.normalize!
      reference = run.z.abs > 0.999 ? Geom::Vector3d.new(0,1,0) : Geom::Vector3d.new(0,0,1)
      side = reference.cross(run).normalize
      up = run.cross(side).normalize
      Geom::Transformation.axes(start_point,side,up,run)
    end

    def build(model,input,transform:,replace: nil)
      raise "The active model changed." unless Sketchup.active_model == model
      raise "The editing context is locked." if Array(model.active_path).any?(&:locked?)
      raise "The original member is unavailable or locked." if replace && (!replace.valid? || replace.locked? || !model.active_entities.include?(replace))
      match = resolve(input)
      s,material = match.values_at(:settings,:material)
      loops = G.placed_profile(match[:section],s)
      model.start_operation(replace ? "Edit Structural Steel" : "Create Structural Steel",true)
      started = true
      root = model.active_entities.add_group
      root.name = replace ? replace.name : [s["member_mark"],material["name"],s["usage"]].reject(&:empty?).join(" | ")
      root.layer = replace ? replace.layer : model.layers[0]
      root.transformation = transform
      steel = root.entities.add_group
      steel.name = "Steel member"
      face = steel.entities.add_face(loops.first.map { |x,y| point([x,y,0]) })
      raise "Could not create steel profile." unless face
      loops.drop(1).each do |loop|
        hole = steel.entities.add_face(loop.map { |x,y| point([x,y,0]) })
        raise "Could not create steel void." unless hole
        hole.erase!
      end
      face.reverse! if face.normal.z < 0
      face.pushpull(s["length_mm"]/25.4)
      raise "The steel member could not be made into a closed solid." unless steel.manifold?
      steel.entities.each { |entity| entity.layer = model.layers[0] }
      role_id = "#{TOOL_ID}.steel"
      tag_name = "Structural Steel | #{match[:section][:type]}"
      tag = model.layers[tag_name] || model.layers.add(tag_name)
      owner = tag.get_attribute("Basegrid","generated_role_id").to_s
      raise "The steel tag belongs to another role." unless owner.empty? || owner == role_id
      tag.set_attribute("Basegrid","generated_role_id",role_id)
      steel.layer = tag
      { "material_id" => material.fetch("id"),"material_type_id" => material.fetch("material_type_id"),
        "generated_role_id" => role_id,"material_role" => "steel" }.each { |key,value| steel.set_attribute("Basegrid",key,value) }
      MaterialAppearance.new(library: @library).apply(steel,material,mode: MaterialAppearance.mode(model),model: model)
      world = model.edit_transform * transform
      length_m = point([0,0,0]).transform(world).distance(point([0,0,s["length_mm"]]).transform(world))*0.0254
      Takeoff.write_quantity(steel,material: material,role_id: role_id,material_role: "steel",quantity: length_m,unit: "m",basis: "Installed member reference length; square ends")
      root.set_attribute("Basegrid","tool_id",TOOL_ID)
      root.set_attribute("Basegrid","parameters_json",JSON.generate(s))
      replace.erase! if replace
      model.commit_operation
      started = false
      root
    rescue StandardError
      model.abort_operation if started
      raise
    end

    def dimension_summary(section)
      fields = section[:type] == "CHS" ? { width: "Diameter", wall: "Wall" } :
        { depth: "Depth", width: "Width", wall: "Wall", flange: "Flange", web: "Web",
          root_radius: "Root radius", outer_radius: "Outer radius", inner_radius: "Inner radius" }
      fields.filter_map do |key,label|
        value = section[key]
        "#{label}: #{format('%g',value)} mm" if value && value > 0
      end.join("; ")
    end

    def settings_html(saved,editing: false)
      previews = materials.map do |m|
        begin
          section = G.section(m,m["steel_type"])
          m.merge("loops" => G.profile(section), "dimension_summary" => dimension_summary(section))
        rescue StandardError => e
          m.merge("error" => e.message)
        end
      end
      data = JSON.generate(settings: saved,materials: previews).gsub("<","\\u003c")
      <<~HTML
        <!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><style>
        *{box-sizing:border-box}body{font:13px -apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;margin:20px;background:white;color:#25282b;letter-spacing:0}h1{font-size:20px;margin:0 0 14px}label{display:block;margin:10px 0 5px}input,select{width:100%;min-width:0;padding:7px;font:inherit;border:1px solid #bcc2c7;border-radius:3px}.row{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px}canvas{display:block;width:100%;height:145px;background:#f4f6f5;margin:12px 0}button{padding:9px 16px;background:#246c52;color:white;border:0;border-radius:3px;margin-top:16px}#error{color:#b42318;overflow-wrap:anywhere}[hidden]{display:none!important}@media(max-width:340px){.row{grid-template-columns:1fr}}
        </style></head><body><h1>Structural steel</h1><form id="form">
        <div class="row"><div><label for="usage">Member</label><select id="usage"><option value="beam">Beam</option><option value="column">Column / post</option></select></div><div><label for="type">Section type</label><select id="type">#{G::TYPES.map { |t| "<option>#{t}</option>" }.join}</select></div></div>
        <label for="material_id">Material</label><select id="material_id" required></select><p id="dimensions" aria-live="polite" style="line-height:1.6;overflow-wrap:anywhere"></p><canvas id="preview" width="800" height="290"></canvas>
        <div class="row"><div id="length_field"><label for="length_mm">#{editing ? 'Member length' : 'Column height'} (mm)</label><input id="length_mm" type="number" min="1" step="any" required></div><div><label for="rotation_deg">Profile rotation (degrees)</label><input id="rotation_deg" type="number" step="any" required></div></div>
        <div class="row"><div><label for="lateral_offset_mm">Lateral offset (mm)</label><input id="lateral_offset_mm" type="number" step="any" required></div><div><label for="vertical_offset_mm">Profile vertical offset (mm)</label><input id="vertical_offset_mm" type="number" step="any" required></div></div>
        <label for="member_mark">Member mark</label><input id="member_mark" maxlength="100"><div id="error" role="alert"></div><button id="submit" type="submit">#{editing ? 'Update member' : 'Draw members'}</button></form><script>
        const data=#{data},el=id=>document.getElementById(id),s=data.settings;
        for(const [k,v] of Object.entries(s)){if(el(k))el(k).value=v;}
        const selected=data.materials.find(m=>m.id===s.material_id);if(selected)el('type').value=selected.steel_type;
        function fill(){const rows=data.materials.filter(m=>m.steel_type===el('type').value);el('material_id').replaceChildren(new Option('Select material',''));rows.forEach(m=>el('material_id').add(new Option(m.name,m.id)));el('material_id').value=rows.some(m=>m.id===s.material_id)?s.material_id:'';paint();}
        function paint(){const m=data.materials.find(m=>m.id===el('material_id').value),ctx=el('preview').getContext('2d');ctx.clearRect(0,0,800,290);el('dimensions').textContent=m?.dimension_summary||'';el('error').textContent=m?.error||'';el('submit').disabled=!m||!!m.error;if(!m?.loops)return;const a=Number(el('rotation_deg').value)*Math.PI/180,loops=m.loops.map(l=>l.map(([x,y])=>[x*Math.cos(a)-y*Math.sin(a),x*Math.sin(a)+y*Math.cos(a)])),points=loops.flat(),xs=points.map(p=>p[0]),ys=points.map(p=>p[1]),minX=Math.min(...xs),minY=Math.min(...ys),w=Math.max(...xs)-minX,h=Math.max(...ys)-minY,scale=Math.min(720/Math.max(w,1),230/Math.max(h,1));ctx.fillStyle='#69777b';ctx.strokeStyle='#263c35';ctx.lineWidth=2;ctx.beginPath();loops.forEach(l=>{l.forEach(([x,y],i)=>{x=400+(x-minX-w/2)*scale;y=145-(y-minY-h/2)*scale;i?ctx.lineTo(x,y):ctx.moveTo(x,y);});ctx.closePath();});ctx.fill('evenodd');ctx.stroke();}
        function mode(){el('length_field').hidden=!#{editing}&&el('usage').value==='beam';}mode();fill();el('usage').addEventListener('change',mode);el('type').addEventListener('change',fill);el('material_id').addEventListener('change',paint);el('rotation_deg').addEventListener('input',paint);
        el('form').addEventListener('submit',event=>{event.preventDefault();const values={...s};for(const k of Object.keys(s)){const input=el(k);if(input)values[k]=input.type==='number'?Number(input.value):input.value;}sketchup.create(JSON.stringify(values));});
        </script></body></html>
      HTML
    end

    class DrawTool
      AXES = {37 => [0,1,0],38 => [0,0,1],39 => [1,0,0]}.freeze
      def initialize(owner,model,match)
        @owner,@model,@match = owner,model,match
        @settings = match[:settings].dup
        @context = model.active_path&.dup
        @input = Sketchup::InputPoint.new
      end
      def activate
        @active = true
        prompt
      end
      def prompt
        action = @start ? (@settings["usage"] == "column" ? "Pick column orientation." : "Pick member end or type length.") : "Pick member start."
        Sketchup.set_status_text("#{action} Tab: anchor (#{@settings['anchor'].tr('_',' ')}). Esc: cancel.")
        Sketchup.set_status_text(@settings["usage"] == "column" ? "Height" : "Length",SB_VCB_LABEL)
      end
      def deactivate(view)
        @active = false
        @deactivated = true
        view.lock_inference
        view.invalidate
      end
      def onMouseMove(_flags,x,y,view)
        return unless @active && !@busy
        @start ? @input.pick(view,x,y,Sketchup::InputPoint.new(@start)) : @input.pick(view,x,y)
        @hover = @input.valid? ? @input.position : nil
        @typing = false
        view.tooltip = @input.tooltip
        if @start && @hover
          value = @settings["usage"] == "column" ? @settings["length_mm"]/25.4 : @start.distance(@hover)
          Sketchup.set_status_text(value.to_l.to_s,SB_VCB_VALUE)
        end
        view.invalidate
      end
      def onLButtonDown(flags,x,y,view)
        return unless @active && !@busy
        onMouseMove(flags,x,y,view)
        return unless @hover
        if @start
          finish(view)
        else
          @start = @hover.clone
          @axis_key = nil
          view.lock_inference
          prompt
        end
      end
      def span
        return unless @start && @hover
        s = @settings.dup
        if s["usage"] == "column"
          dx,dy = @hover.x-@start.x,@hover.y-@start.y
          return if Math.hypot(dx,dy)*25.4 < 1
          rotation = Math.atan2(dy,dx)
          side = Geom::Vector3d.new(Math.cos(rotation),Math.sin(rotation),0)
          up = Geom::Vector3d.new(-Math.sin(rotation),Math.cos(rotation),0)
          transform = Geom::Transformation.axes(@start,side,up,Geom::Vector3d.new(0,0,1))
        else
          return if @start.distance(@hover)*25.4 < 1
          s["length_mm"] = @start.distance(@hover)*25.4
          transform = @owner.frame(@start,@hover)
        end
        [s,transform]
      end
      def enableVCB? = true
      def onUserText(text,view)
        return unless @active && !@busy && @start
        mm = text.to_l.to_f*25.4
        raise "Length must be at least 1 mm." unless mm.finite? && mm >= 1
        if @settings["usage"] == "column"
          @settings["length_mm"] = mm
          view.invalidate
        else
          raise "Move the cursor to set the member direction." unless @hover && @start.distance(@hover)*25.4 >= 1
          @hover = @start.offset(@start.vector_to(@hover),mm/25.4)
          finish(view)
        end
      rescue StandardError => e
        Sketchup.set_status_text("Structural steel: #{e.message}")
      ensure
        @typing = false
      end
      def finish(view)
        return unless @active && !@busy
        result = span
        return unless result
        settings,world = result
        @busy = true
        UI.start_timer(0,false) do
          begin
            next unless @active && Sketchup.active_model == @model && @context == @model.active_path
            @owner.build(@model,settings,transform: @model.edit_transform.inverse*world)
            @owner.remember(settings)
            @start = @hover = @axis_key = @direction_locked = nil
            view.lock_inference
            prompt
          rescue StandardError => e
            Sketchup.set_status_text("Structural steel: #{e.message}")
          ensure
            @busy = false
            view.invalidate if @active
          end
        end
      end
      def onCancel(_reason,view)
        if @start && !@busy
          @start = @hover = @axis_key = @direction_locked = nil
          @typing = false
          view.lock_inference
          prompt
          view.invalidate
        else
          @active = false
          UI.start_timer(0,false) { @model.select_tool(nil) if !@deactivated && Sketchup.active_model == @model }
        end
      end
      def apply_axis(view)
        return view.lock_inference unless @axis_key && @start
        endpoint = @start.offset(Geom::Vector3d.new(AXES.fetch(@axis_key)))
        view.lock_inference(Sketchup::InputPoint.new(@start),Sketchup::InputPoint.new(endpoint))
      end
      def onKeyDown(key,repeat,_flags,view)
        return unless @active && !@busy
        key = normalized_key(key)
        @typing = true if (48..57).cover?(key) || [110,190,188].include?(key)
        return true if repeat > 1 && [9,16,37,38,39,40].include?(key)
        if key == 9
          @settings["anchor"] = G::ANCHORS[(G::ANCHORS.index(@settings["anchor"])+1)%G::ANCHORS.length]
          prompt
        elsif key == (Sketchup.platform == :platform_osx ? 127 : 8)
          return if @typing
          @start = @hover = @axis_key = @direction_locked = nil
          view.lock_inference
          prompt
        elsif AXES.key?(key) && @start
          @direction_locked = false
          @axis_key = @axis_key == key ? nil : key
          apply_axis(view)
        elsif [16,40].include?(key) && @input.valid?
          if key == 40 && @direction_locked
            @direction_locked = false
            apply_axis(view)
          else
            view.lock_inference(@input)
            @direction_locked = true if key == 40
          end
        else
          return
        end
        view.invalidate
        true
      end
      def onKeyUp(key,_repeat,_flags,view)
        key = normalized_key(key)
        return unless @active && !@busy && key == 16
        apply_axis(view) unless @direction_locked
        true
      end
      def normalized_key(key)
        {"VK_SHIFT"=>16,"VK_LEFT"=>37,"VK_UP"=>38,"VK_RIGHT"=>39,"VK_DOWN"=>40}.each do |name,canonical|
          return canonical if Object.const_defined?(name) && Object.const_get(name) == key
        end
        key
      end
      def getMenu(menu)
        return unless @active && !@busy
        menu.add_item("Rotate profile 90 degrees") { @settings["rotation_deg"] += 90; @model.active_view.invalidate }
        menu.add_item("Rotate profile -90 degrees") { @settings["rotation_deg"] -= 90; @model.active_view.invalidate }
        if @settings["usage"] == "column"
          menu.add_item("Set column height") do
            values = UI.inputbox(["Height (mm)"],[@settings["length_mm"]],"Column height")
            if values
              begin
                @settings = G.settings(@settings.merge("length_mm" => values.first))
                @model.active_view.invalidate
              rescue StandardError => e
                Sketchup.set_status_text(e.message)
              end
            end
          end
        end
      end
      def preview
        result = span
        return [] unless result
        s,transform = result
        G.placed_profile(@match[:section],s).map do |loop|
          [0,s["length_mm"]].map { |z| loop.map { |x,y| @owner.point([x,y,z]).transform(transform) } }
        end
      end
      def draw(view)
        return unless @active && !@busy
        @input.draw(view) if @input.valid?
        view.drawing_color = "SeaGreen"
        view.line_width = 2
        preview.each do |a,b|
          [a,b].each { |ring| view.draw(GL_LINE_STRIP,ring+[ring.first]) }
          a.zip(b).each { |p,q| view.draw(GL_LINES,[p,q]) }
        end
      end
      def getExtents
        box = Geom::BoundingBox.new
        preview.flatten(2).each { |p| box.add(p) } if @active && !@busy
        box
      end
    end
  end
end
