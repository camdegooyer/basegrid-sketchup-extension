# frozen_string_literal: true
require "json"
require_relative "flashing_geometry"
require_relative "material_library"
require_relative "material_appearance"
require_relative "takeoff"

module Basegrid
  class FlashingTool
    TOOL_ID = "sheetmetal.flashing"
    TYPES = { "colourbond" => ["Flashings Colourbond", "Flashings Colorbond"],
              "zincalume" => ["Flashings Zinc", "Flashings Zincalume"],
              "perforated" => ["Flashings Perforated"] }.freeze
    def initialize(library: MaterialLibrary.new) = @library = library

    def candidates(finish)
      ids = @library.material_types.select do |type|
        type.fetch("status","active") == "active" && type["profile"] == "flashing" && type["uom"] == "m" &&
          TYPES.fetch(finish).any? { |name| name.casecmp?(type["name"].to_s) }
      end.map { |type| type["id"] }
      @library.materials.select { |m| m.fetch("status","active") == "active" && ids.include?(m["material_type_id"]) }
    end

    def match_material(input)
      s = FlashingGeometry.settings(input)
      girth, folds = s["lengths_mm"].sum, s["angles_deg"].length
      unless s["material_id"].empty?
        material_finish = TYPES.keys.find { |finish| candidates(finish).any? { |m| m["id"] == s["material_id"] } }
        material = material_finish && candidates(material_finish).find { |m| m["id"] == s["material_id"] }
        raise "The override material is not an active flashing material. Sync or choose another material." unless material
        g,f,t = material_dimensions(material)
        raise "The override material needs valid girth, fold count and thickness metadata." unless g && f && t
        return { settings: s, material: material, girth_mm: girth, folds: folds, stock_girth_mm: g, stock_folds: f,
                 thickness_mm: t, material_finish: material_finish, material_override: true, warnings: (g+1e-6 < girth || f < folds) ? ["Override material is below the drawn girth or fold count."] : [] }
      end
      matches = candidates(s["finish"]).filter_map do |m|
        g,f,t = material_dimensions(m)
        next unless g && f && t
        next unless g+1e-6 >= girth && f >= folds
        [m,g,f,t]
      end.sort_by { |m,g,f,t| [f,g,m["id"].to_s] }
      raise "No #{s['finish']} material covers #{girth.round(2)} mm girth and #{folds} folds. Sync or add a suitable library material." if matches.empty?
      best = matches.first
      raise "Several materials match this girth and fold count. Resolve the duplicate library entries before drawing." if matches.count { |m,g,f,t| g == best[1] && f == best[2] } > 1
      { settings: s, material: best[0], girth_mm: girth, folds: folds, stock_girth_mm: best[1], stock_folds: best[2], thickness_mm: best[3] }
    end

    def material_dimensions(material)
      dims = material.fetch("dimensions_mm", {})
      g,f,t = %w[girth folds thickness].map { |key| Float(dims[key] || dims["#{key}_mm"]) rescue nil }
      return [] unless [g,t].all? { |v| v && v.finite? && v > 0 } && f && f.finite? && f >= 0 && f == f.to_i
      [g,f,t]
    end

    def profiles
      stored = JSON.parse(Sketchup.read_default("Basegrid", "flashing_profiles", "[]"))
      raise "Stored flashing profiles are invalid." unless stored.is_a?(Array)
      stored.map { |p| { "name" => profile_name(p.fetch("name")), "settings" => FlashingGeometry.settings(p.fetch("settings")) } }
    end

    def profile_name(name)
      raise "Enter a profile name of 1 to 80 characters." unless name.is_a?(String) && (1..80).cover?(name.strip.length)
      name.strip
    end

    def save_profile(name, settings, previous_name: nil)
      name = profile_name(name)
      current = profiles
      previous_name = profile_name(previous_name) if previous_name
      raise "The saved profile no longer exists." if previous_name && current.none? { |p| p["name"] == previous_name }
      raise "A profile with this name already exists." if current.any? { |p| p["name"].casecmp?(name) && p["name"] != previous_name }
      entry = { "name" => name, "settings" => FlashingGeometry.settings(settings) }
      current = previous_name ? current.map { |p| p["name"] == previous_name ? entry : p } : current + [entry]
      raise "Could not save flashing profiles." unless Sketchup.write_default("Basegrid", "flashing_profiles", JSON.generate(current))
      entry
    end

    def delete_profile(name)
      name = profile_name(name)
      current = profiles
      raise "The saved profile no longer exists." unless current.any? { |p| p["name"] == name }
      raise "Could not save flashing profiles." unless Sketchup.write_default("Basegrid", "flashing_profiles", JSON.generate(current.reject { |p| p["name"] == name }))
      { "deleted" => name }
    end

    def profile_settings(name, overrides = {})
      entry = profiles.find { |p| p["name"] == profile_name(name) }
      raise "The saved profile does not exist." unless entry
      entry.fetch("settings").merge(overrides)
    end

    def saved_settings
      value = JSON.parse(Sketchup.read_default("Basegrid", "flashing_settings", "{}"))
      value.is_a?(Hash) ? value : {}
    rescue JSON::ParserError, TypeError
      {}
    end

    def run(similar: false)
      @library.load
      model = Sketchup.active_model
      selected = model.selection.to_a
      existing = selected.length == 1 && selected.first.is_a?(Sketchup::Group) && selected.first.get_attribute("Basegrid","tool_id") == TOOL_ID ? selected.first : nil
      metadata = existing && JSON.parse(existing.get_attribute("Basegrid","parameters_json"))
      defaults = metadata ? metadata.fetch("settings") : saved_settings
      existing = nil if similar
      context = model.active_path&.dup
      @dialog&.close
      dialog = UI::HtmlDialog.new(dialog_title: "Flashing", preferences_key: "basegrid_flashing", width: 1020, height: 850,
                                  scrollable: true, resizable: true, style: UI::HtmlDialog::STYLE_DIALOG)
      @dialog = dialog
      busy = false
      dialog.add_action_callback("profiles") do |_,json|
        begin
          request = JSON.parse(json)
          if request.fetch("action") == "save"
            entry = save_profile(request.fetch("name"), request.fetch("settings"), previous_name: request["previous_name"])
            selected = entry.fetch("name")
          elsif request["action"] == "delete"
            delete_profile(request.fetch("name"))
            selected = ""
          else
            raise "Unknown profile action."
          end
          dialog.execute_script("profileResponse(#{JSON.generate({ profiles: profiles, selected: selected }).gsub('<','\\u003c')})")
        rescue StandardError => e
          dialog.execute_script("profileResponse(#{JSON.generate({ error: e.message }).gsub('<','\\u003c')})")
        end
      end
      dialog.add_action_callback("create") do |_,json|
        next if busy
        begin
          busy = true
          raise "The model or editing context changed." unless Sketchup.active_model == model && context == model.active_path
          match = match_material(JSON.parse(json))
          FlashingGeometry.polygon(match[:settings],match[:thickness_mm])
          if existing
            transform = model.edit_transform * existing.transformation
            points = metadata.fetch("points").map { |p| point(p).transform(transform).to_a.map { |v| v*25.4 } }
            normal = Geom::Vector3d.new(metadata.fetch("normal")).transform(transform).to_a
            build(model,points,match[:settings],normal: normal,replace: existing)
          else
            model.select_tool(DrawTool.new(self,model,match))
          end
          Sketchup.write_default("Basegrid","flashing_settings",JSON.generate(match[:settings]))
          dialog.close
        rescue StandardError => e
          busy = false
          dialog.execute_script("document.getElementById('error').textContent=#{JSON.generate(e.message)}")
        end
      end
      dialog.set_html(settings_html(defaults,editing: !!existing))
      dialog.show
    rescue StandardError => e
      UI.messagebox("Flashing: #{e.message}")
    end

    def point(values) = Geom::Point3d.new(values.map { |n| n/25.4 })

    def build(model,points,input,normal: nil,replace: nil)
      raise "The active model changed." unless model == Sketchup.active_model
      raise "The editing context is locked." if Array(model.active_path).any?(&:locked?)
      raise "The original flashing is unavailable or locked." if replace && (!replace.valid? || replace.locked? || !model.active_entities.include?(replace))
      match = match_material(input)
      plan = FlashingGeometry.plan(points,match[:settings],thickness: match[:thickness_mm],normal: normal)
      model.start_operation(replace ? "Edit Flashing" : "Create Flashing",true)
      started = true
      root = model.active_entities.add_group
      root.name = replace ? replace.name : "Custom Flashing"
      root.layer = replace ? replace.layer : model.layers[0]
      root.transformation = model.edit_transform.inverse
      sheet = root.entities.add_group
      sheet.name = "Flashing"
      rings = plan[:rings].map { |ring| ring.map { |p| point(p) } }
      raise "Could not create flashing end cap." unless sheet.entities.add_face(rings.first.reverse) && sheet.entities.add_face(rings.last)
      rings.each_cons(2) do |a,b|
        a.each_index do |i|
          j = (i+1)%a.length
          raise "Could not create flashing surface." unless sheet.entities.add_face(a[i],a[j],b[j]) && sheet.entities.add_face(a[i],b[j],b[i])
        end
      end
      sheet.entities.each { |entity| entity.layer = model.layers[0] }
      raise "Flashing could not be made into a closed solid." unless sheet.manifold?
      material = match[:material]
      role_id = "#{TOOL_ID}.sheet"
      tag_name = "Flashing | #{match.fetch(:material_finish,match[:settings]['finish'])}"
      tag = model.layers[tag_name] || model.layers.add(tag_name)
      owner = tag.get_attribute("Basegrid","generated_role_id").to_s
      raise "The flashing tag belongs to another role." unless owner.empty? || owner == role_id
      tag.set_attribute("Basegrid","generated_role_id",role_id)
      sheet.layer = tag
      sheet.set_attribute("Basegrid","material_id",material.fetch("id"))
      sheet.set_attribute("Basegrid","material_type_id",material.fetch("material_type_id"))
      sheet.set_attribute("Basegrid","generated_role_id",role_id)
      sheet.set_attribute("Basegrid","material_role","flashing")
      MaterialAppearance.new(library: @library).apply(sheet,material,mode: MaterialAppearance.mode(model),model: model)
      Takeoff.write_quantity(sheet,material: material,role_id: role_id,material_role: "flashing",quantity: plan[:length_m],unit: "m",basis: match[:material_override] ? "Drawn path length; explicit flashing material override" : "Drawn path length; material girth and folds rounded up from profile")
      root.set_attribute("Basegrid","tool_id",TOOL_ID)
      root.set_attribute("Basegrid","parameters_json",JSON.generate(settings: plan[:settings],points: plan[:points],normal: plan[:normal],girth_mm: plan[:girth_mm],folds: plan[:folds],stock_girth_mm: match[:stock_girth_mm],stock_folds: match[:stock_folds],material_id: material["id"],material_override: !!match[:material_override],warnings: match.fetch(:warnings,[])))
      replace.erase! if replace
      model.commit_operation
      started = false
      root
    rescue StandardError
      model.abort_operation if started
      raise
    end

    def settings_html(saved,editing: false)
      settings = FlashingGeometry::DEFAULTS.merge(saved.select { |key,_| FlashingGeometry::DEFAULTS.key?(key) })
      data = { settings: settings, editing: editing, profiles: profiles,
               catalogue: TYPES.keys.to_h { |finish| [finish,candidates(finish)] } }
      File.read(File.join(__dir__,"flashing_dialog.html"),encoding: "UTF-8")
        .sub("__BASEGRID_FLASHING_DATA__") { JSON.generate(data).gsub("<","\\u003c") }
    end

    class DrawTool
      def initialize(owner,model,match)
        @owner,@model,@match = owner,model,match
        @settings = match[:settings].dup
        @context = model.active_path&.dup
        @points = []
        @input = Sketchup::InputPoint.new
      end
      def activate
        @active = true
        prompt
      end
      def prompt = Sketchup.set_status_text("Draw flashing path. Tab: profile anchor. Enter or double-click: finish. Esc: cancel.")
      def deactivate(view)
        @active = false
        @deactivated = true
        view.lock_inference
        view.invalidate
      end
      def onMouseMove(_flags,x,y,view)
        return unless @active && !@busy
        @points.empty? ? @input.pick(view,x,y) : @input.pick(view,x,y,Sketchup::InputPoint.new(@owner.point(@points.last)))
        @hover = @input.valid? ? @input.position.to_a.map { |v| v*25.4 } : nil
        @typing = false
        view.tooltip = @input.tooltip
        view.invalidate
      end
      def onLButtonDown(flags,x,y,view)
        return unless @active && !@busy
        onMouseMove(flags,x,y,view)
        return unless @hover
        if @points.empty? && @input.face
          @normal = @input.face.normal.transform(@input.transformation).to_a
        end
        add_point(@hover,view)
      end
      def add_point(p,view)
        return if !@points.empty? && FlashingGeometry.length(FlashingGeometry.sub(p,@points.last)) < 1
        @points << p.dup
        @typing = false
        view.lock_inference
        @axis_key = nil
        view.invalidate
      end
      def onLButtonDoubleClick(flags,x,y,view)
        onLButtonDown(flags,x,y,view)
        finish(view)
      end
      def enableVCB? = true
      def onUserText(text,view)
        return unless @active && !@busy && @points.any? && @hover
        distance = text.to_l.to_f*25.4
        raise "Length must be positive." unless distance.finite? && distance > 0
        direction = FlashingGeometry.unit(FlashingGeometry.sub(@hover,@points.last))
        add_point(FlashingGeometry.add(@points.last,FlashingGeometry.mul(direction,distance)),view)
      rescue StandardError => e
        Sketchup.set_status_text("Flashing: #{e.message}")
      ensure
        @typing = false
      end
      def onReturn(view)
        return if @typing
        finish(view)
      end
      def finish(view)
        return unless @active && !@busy && @points.length >= 2
        FlashingGeometry.plan(@points,@settings,thickness: @match[:thickness_mm],normal: @normal)
        @busy = true
        UI.start_timer(0,false) do
          begin
            next unless @active && Sketchup.active_model == @model && @context == @model.active_path
            @owner.build(@model,@points,@settings,normal: @normal)
            @points = []
            @hover = @normal = nil
            view.lock_inference
            prompt
          rescue StandardError => e
            Sketchup.set_status_text("Flashing: #{e.message}")
          ensure
            @busy = false
            view.invalidate if @active
          end
        end
      rescue StandardError => e
        Sketchup.set_status_text("Flashing: #{e.message}")
      end
      def onCancel(_reason,view)
        if !@busy && @points.any?
          @points = []
          @hover = @normal = nil
          view.lock_inference
          view.invalidate
        else
          @active = false
          UI.start_timer(0,false) { @model.select_tool(nil) if !@deactivated && Sketchup.active_model == @model }
        end
      end
      def onKeyDown(key,repeat,_flags,view)
        return unless @active && !@busy
        @typing = true if (48..57).cover?(key) || [110,190,188].include?(key)
        return true if repeat > 1 && [9,8,127,16,37,38,39,40].include?(key) && !@typing
        if key == 9
          @settings["anchor_index"] = (@settings["anchor_index"]+1)%(@settings["lengths_mm"].length+1)
        elsif key == (Sketchup.platform == :platform_osx ? 127 : 8)
          return if @typing
          @points.pop
          @normal = nil if @points.empty?
          view.lock_inference
        elsif [16,37,38,39,40].include?(key) && @input.valid?
          if key == 16 || key == 40
            view.lock_inference(@input)
          elsif @axis_key == key
            view.lock_inference
            @axis_key = nil
          else
            axis = {37=>[0,1,0],38=>[0,0,1],39=>[1,0,0]}.fetch(key)
            p = @points.empty? ? @input.position : @owner.point(@points.last)
            view.lock_inference(Sketchup::InputPoint.new(p),Sketchup::InputPoint.new(p.offset(Geom::Vector3d.new(axis))))
            @axis_key = key
          end
        else
          return
        end
        view.invalidate
        true
      end
      def onKeyUp(key,_repeat,_flags,view)
        return unless @active && !@busy && key == 16
        view.lock_inference
        true
      end
      def getMenu(menu)
        return unless @active && !@busy
        menu.add_item("Flip profile side") { @settings["path_side"] = @settings["path_side"] == "left" ? "right" : "left"; @model.active_view.invalidate }
        menu.add_item("Finish flashing") { finish(@model.active_view) }
      end
      def preview
        points = @points.dup
        points << @hover if @hover && (points.empty? || FlashingGeometry.length(FlashingGeometry.sub(@hover,points.last)) >= 1)
        return nil if points.length < 2
        FlashingGeometry.plan(points,@settings,thickness: @match[:thickness_mm],normal: @normal)
      rescue StandardError
        nil
      end
      def draw(view)
        return unless @active && !@busy
        @input.draw(view) if @input.valid?
        view.drawing_color = "SeaGreen"
        view.line_width = 2
        plan = preview
        if plan
          plan[:rings].each { |ring| view.draw(GL_LINE_STRIP,(ring+[ring.first]).map { |p| @owner.point(p) }) }
          plan[:rings].each_cons(2) { |a,b| a.zip(b).each { |p,q| view.draw(GL_LINES,[@owner.point(p),@owner.point(q)]) } }
        elsif @points.length >= 2
          view.draw(GL_LINE_STRIP,@points.map { |p| @owner.point(p) })
        end
      end
      def getExtents
        box = Geom::BoundingBox.new
        plan = preview if @active && !@busy
        (plan ? plan[:rings].flatten(1) : @points).each { |p| box.add(@owner.point(p)) }
        box
      end
    end
  end
end
