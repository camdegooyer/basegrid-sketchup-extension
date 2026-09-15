# frozen_string_literal: true

require "json"
require_relative "strip_footing_geometry"
require_relative "material_library"
require_relative "material_appearance"
require_relative "takeoff"
require_relative "starter_bar_tool"
require_relative "concrete_pier_tool"
require_relative "keyboard_shortcuts"

module Basegrid
  class StripFootingTool
    TOOL_ID = "concrete.strip_footing"
    ROLES = {
      "concrete" => ["Concrete", "m3"], "mesh" => ["Reo Trench Mesh", "m"],
      "chairs" => ["Trench Mesh Supports", "ea"], "spacers" => ["Bogar Spacers", "ea"],
      "z_bars" => ["Reo Bar Processed", "m"], "pier_bar" => ["Reo Bar Processed", "m"],
      "pier_concrete" => ["Concrete", "m3"]
    }.freeze
    MATERIAL_LABELS = {
      "concrete" => "Concrete material", "mesh" => "Mesh material",
      "chairs" => "Supports", "spacers" => "Bogar spacers", "z_bars" => "Step Z-bar material",
      "pier_bar" => "Pier starter material", "pier_concrete" => "Pier concrete material"
    }.freeze
    INPUT_KEYS = %w[width_mm depth_mm reinforcement double_mesh step_height_mm include_step_z_bars step_z_threshold_mm
      include_piers pier_spacing_mm piers_at_corners piers_at_intersections piers_even_spacing pier_diameter_mm
      pier_depth_mm pier_add_bar pier_bar_below_mm pier_bar_above_mm pier_bar_cog_mm].freeze

    def initialize(library: MaterialLibrary.new)
      @library = library
    end

    def materials_for(role)
      return @library.concrete_materials if %w[concrete pier_concrete].include?(role)
      type_name, unit = ROLES.fetch(role)
      names = role == "spacers" ? [type_name, "Bogar Spacer"] : [type_name]
      units = unit == "ea" ? %w[ea each] : [unit]
      types = @library.material_types.select do |type|
        type.fetch("status", "active") == "active" && names.any? { |name| type.fetch("name").casecmp?(name) } &&
          units.include?(type.fetch("uom", unit))
      end.map { |type| type.fetch("id") }
      @library.materials.select { |m| m.fetch("status", "active") == "active" && types.include?(m["material_type_id"]) }
        .sort_by { |m| m.fetch("name").downcase }
    end

    def run
      @library.load
      saved = saved_settings
      @dialog&.close
      @dialog = UI::HtmlDialog.new(dialog_title: "Strip Footing", preferences_key: "basegrid_strip_footing",
                                    scrollable: true, resizable: true, width: 820, height: 760,
                                    style: UI::HtmlDialog::STYLE_DIALOG)
      @dialog.add_action_callback("drawFooting") do |_context, encoded|
        begin
          input = JSON.parse(encoded)
          bindings = validate_materials(input.fetch("materials"))
          settings = resolved_settings(input.fetch("settings"), bindings)
          drawing_tool = DrawTool.new(self, settings, input.fetch("materials"))
          remember_settings(settings, input.fetch("materials"))
          Sketchup.active_model.select_tool(drawing_tool)
          @dialog.close
        rescue StandardError => e
          @dialog.execute_script("document.getElementById('error').textContent=#{JSON.generate(e.message)}; document.querySelector('[type=submit]').disabled=false")
        end
      end
      @dialog.set_html(settings_html(saved))
      @dialog.show
    end

    def saved_settings
      saved = JSON.parse(Sketchup.read_default("Basegrid", "strip_footing_settings", "{}"))
      return {} unless saved.is_a?(Hash)
      %w[settings materials].to_h { |key| [key, saved[key].is_a?(Hash) ? saved[key] : {}] }
    rescue JSON::ParserError, TypeError
      {}
    end

    def remember_settings(settings, materials)
      input = { settings: settings.slice(*INPUT_KEYS), materials: materials.slice(*ROLES.keys) }
      Sketchup.write_default("Basegrid", "strip_footing_settings", JSON.generate(input))
    end

    def build(model, paths, settings = {}, materials = {}, replace: nil)
      raise "The active model has changed." unless model == Sketchup.active_model
      raise "The editing context is locked." if Array(model.active_path).any?(&:locked?)
      if replace && (!replace.is_a?(Sketchup::Group) || !replace.valid? || replace.locked? ||
                     !model.active_entities.include?(replace) || replace.get_attribute("Basegrid", "tool_id") != TOOL_ID)
        raise "The original footing is unavailable, locked or belongs to another tool."
      end
      bindings = validate_materials(materials)
      plan = StripFootingGeometry.plan(paths, resolved_settings(settings, bindings))
      raise "Select a step Z-bar material." if plan[:z_bars].any? && !bindings["z_bars"]
      pier_builder = ConcretePierTool.new(library: @library)
      pier_settings, pier_materials = pier_builder.resolve(pier_input(plan[:settings],materials)) if plan[:piers].any?
      model.start_operation(replace ? "Edit Strip Footing" : "Create Strip Footing", true)
      started = true
      root = model.active_entities.add_group
      root.name = replace ? replace.name : "Strip Footing"
      # Points are world coordinates. Preserve actual dimensions inside rotated,
      # scaled or mirrored edit contexts by cancelling the context transform.
      root.transformation = model.edit_transform.inverse
      root.layer = replace ? replace.layer : model.layers[0]
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
                [-pair[:pair_offset_mm], pair[:pair_offset_mm]].each do |offset|
                  add_bar(entities, { a: [offset,0,0], b: [offset,0,pair[:height_mm]], diameter: pair[:diameter_mm] })
                end
              end
              instance = collection.entities.add_instance(definition, placement(pair))
              instance.name = format("Spacer Pair %02d", number+1)
              decorate(model, instance, "spacers", bindings["spacers"], 1)
            end
          end
        end
      end
      unless plan[:z_bars].empty?
        collection = plain_group(model, reinforcement.entities, "Step Z Bars")
        bar_builder = StarterBarTool.new(library: @library)
        plan[:z_bars].each do |item|
          group = plain_group(model, collection.entities, item[:name])
          bar_builder.add_bar(group.entities, item[:points], item[:diameter])
          raise "A step Z bar did not form a closed solid." unless group.manifold?
          decorate(model, group, "z_bars", bindings["z_bars"], item[:length_m])
        end
      end
      unless plan[:piers].empty?
        piers = plain_group(model,root.entities,"Piers")
        plan[:piers].each_with_index do |item,index|
          direction = item[:direction]
          transform = Geom::Transformation.axes(point3d(item[:top]), Geom::Vector3d.new(*direction,0),
            Geom::Vector3d.new(-direction[1],direction[0],0), Geom::Vector3d.new(0,0,1))
          pier = pier_builder.build_in(model,piers.entities,pier_settings,pier_materials,transform: transform,world: transform)
          pier.name = format("Pier %02d",index+1)
        end
      end
      replace.erase! if replace
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

    def pier_input(settings,materials)
      { "pier_diameter_mm"=>settings["pier_diameter_mm"], "pier_depth_mm"=>settings["pier_depth_mm"],
        "concrete_material"=>materials.fetch("pier_concrete",materials.fetch("concrete","")),"add_bar"=>settings["pier_add_bar"],
        "bar_material"=>materials.fetch("pier_bar",""),"bar_above_mm"=>settings["pier_bar_above_mm"],
        "bar_below_mm"=>settings["pier_bar_below_mm"],"top_crank_mm"=>settings["pier_bar_cog_mm"],
        "top_crank_dir"=>"in","bottom_crank_mm"=>0 }
    end

    def resolved_settings(settings, bindings)
      derived = ROLES.keys.reduce({}) { |values, role| values.merge(material_dimensions(role, bindings[role])) }
      StripFootingGeometry.settings(settings.merge(derived).merge("cover_mm" => 50.0))
    end

    def material_dimensions(role, material)
      dimensions = material && material["dimensions_mm"]
      if role == "z_bars" && material
        diameter = Float(dimensions&.fetch("diameter", nil)) rescue nil
        raise "Selected step Z-bar material needs a valid diameter." unless diameter && diameter.finite? && diameter.positive?
        return { "step_z_diameter_mm" => diameter }
      end
      return {} unless dimensions.is_a?(Hash)
      keys = case role
             when "mesh" then %w[cross_diameter_mm cross_spacing_mm]
             when "chairs" then %w[support_width_mm support_spacing_mm support_first_offset_mm]
             when "spacers" then %w[spacer_diameter_mm spacer_pair_offset_mm]
             else []
             end
      values = dimensions.select { |key, value| keys.include?(key) && !value.nil? }
      values.merge!(mesh_dimensions(material)) if role == "mesh"
      values["support_width_mm"] = dimensions["width"] if role == "chairs" && dimensions["width"]
      # Bogar's diameter is the compatible mesh gauge, not spacer thickness.
      values["spacer_height_mm"] = dimensions["height"] if role == "spacers" && dimensions["height"]
      values
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

    # Each placed bar carries its own geometry in a group. Bars are cut, trimmed
    # and carried through junctions individually, so sharing one definition per
    # size would make every edit to one bar change every other bar that size.
    # Supports and spacer pairs stay shared components: they are manufactured
    # items that should remain identical.
    def place_bar(model, entities, bar, name)
      group = plain_group(model, entities, name)
      add_bar(group.entities, bar)
      group
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
      edges = entities.add_circle(a, direction, bar[:diameter].mm / 2, 8)
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
        "reinforcement" => "Mesh layers", "double_mesh" => "Double trench mesh", "step_height_mm" => "Step height (mm)",
        "include_step_z_bars" => "Include step Z bars", "step_z_threshold_mm" => "Z bars above step height (mm)",
        "include_piers"=>"Include piers", "pier_spacing_mm"=>"Maximum pier centres (mm)",
        "piers_at_corners"=>"Piers at corners", "piers_at_intersections"=>"Piers at intersections",
        "piers_even_spacing"=>"Even spacing", "pier_diameter_mm"=>"Pier diameter (mm)",
        "pier_depth_mm"=>"Pier depth below footing (mm)", "pier_add_bar"=>"Pier starter bar",
        "pier_bar_below_mm"=>"Bar below pier top (mm)", "pier_bar_above_mm"=>"Bar into footing (mm)",
        "pier_bar_cog_mm"=>"Upper cog (mm)"
      }
      choices = { "reinforcement" => %w[none bottom top_bottom], "double_mesh" => %w[none top bottom top_bottom] }
      payload = JSON.generate(defaults: StripFootingGeometry::DEFAULTS.slice(*INPUT_KEYS), saved: saved, labels: labels, choices: choices,
                              material_labels: MATERIAL_LABELS,
                              mesh_diameter_mm: StripFootingGeometry::DEFAULTS["bar_diameter_mm"],
                              materials: ROLES.to_h { |role, _| [role, materials_for(role).map { |m| m.slice("id", "name", "dimensions_mm") }] }).gsub("<", "\\u003c")
      <<~HTML
        <!doctype html><html><head><meta charset="utf-8"><style>
        #{File.read(File.join(__dir__, 'strip_footing_dialog.css'))}
        </style><meta name="viewport" content="width=device-width,initial-scale=1"></head><body><header><span class="brand">BASEGRID</span><h1>Strip footing</h1></header>
        <form id="form"><div id="fields"></div><p id="error"></p><button type="submit">Start drawing</button></form>
        <script>
        const data=#{payload}; const fields=document.getElementById('fields'); const controls={}, materials={};
        const pierDefaults=()=>({pier_bar_below_mm:Math.max(0,Number(controls.pier_depth_mm?.value??data.saved.settings?.pier_depth_mm??data.defaults.pier_depth_mm)-100),
          pier_bar_above_mm:Number(controls.depth_mm?.value??data.saved.settings?.depth_mm??data.defaults.depth_mm)/2,
          pier_bar_cog_mm:Math.max(0,Number(controls.width_mm?.value??data.saved.settings?.width_mm??data.defaults.width_mm)/2-50)});
        Object.assign(data.defaults,pierDefaults());
        for(const [key,value] of Object.entries(data.defaults)){
          const label=document.createElement('label');label.textContent=data.labels[key];
          const input=document.createElement(data.choices[key]?'select':'input');
          if(data.choices[key])for(const choice of data.choices[key]){const o=document.createElement('option');o.value=choice;o.textContent=String(choice).replaceAll('_',' ');input.append(o);}
          else if(typeof value==='boolean'){input.type='checkbox';input.checked=data.saved.settings?.[key]??value;}
          else{input.type='number';input.min=['step_z_threshold_mm','pier_bar_below_mm','pier_bar_cog_mm'].includes(key)?'0':'0.01';input.step='any';input.required=true;}
          input.value=data.saved.settings?.[key]??value;controls[key]=input;label.append(input);fields.append(label);
        }
        for(const [role,items] of Object.entries(data.materials)){
          const label=document.createElement('label');label.textContent=data.material_labels[role];const select=document.createElement('select');
          const empty=document.createElement('option');empty.value='';empty.textContent='Unassigned';select.append(empty);
          for(const item of items){const o=document.createElement('option');o.value=item.id;o.textContent=item.name;select.append(o);}
          const savedId=String(data.saved.materials?.[role]??'');
          select.value=items.some(item=>String(item.id)===savedId)?savedId:'';materials[role]=select;label.append(select);fields.append(label);
        }
        const defaultSpacer=()=>{
          const mesh=data.materials.mesh.find(item=>String(item.id)===materials.mesh.value);
          const diameter=Number(mesh?.dimensions_mm?.diameter??data.mesh_diameter_mm);
          const height=Number(controls.depth_mm.value)-100;
          const spacer=data.materials.spacers.find(item=>
            Number(item.dimensions_mm?.height)===height && Number(item.dimensions_mm?.diameter)===diameter);
          materials.spacers.value=spacer?String(spacer.id):'';
        };
        controls.depth_mm.addEventListener('input',defaultSpacer);
        materials.mesh.addEventListener('change',defaultSpacer);
        if(!Object.prototype.hasOwnProperty.call(data.saved.materials??{},'spacers'))defaultSpacer();
        if(!Object.prototype.hasOwnProperty.call(data.saved.materials??{},'chairs')){
          materials.chairs.value=data.materials.chairs.length?String(data.materials.chairs[0].id):'';
        }
        if(!Object.prototype.hasOwnProperty.call(data.saved.materials??{},'z_bars')){
          const n12=data.materials.z_bars.find(item=>Number(item.dimensions_mm?.diameter)===12);
          materials.z_bars.value=n12?String(n12.id):'';
        }
        const updateZBars=()=>{
          const enabled=controls.include_step_z_bars.checked;
          controls.step_z_threshold_mm.disabled=!enabled;materials.z_bars.disabled=!enabled;
        };
        controls.include_step_z_bars.addEventListener('change',updateZBars);updateZBars();
        const pierFields=document.createElement('div');pierFields.className='pier-fields';fields.append(pierFields);
        for(const key of Object.keys(controls).filter(key=>key.startsWith('pier_')||key.startsWith('piers_')))pierFields.append(controls[key].parentElement);
        pierFields.append(materials.pier_bar.parentElement);
        pierFields.append(materials.pier_concrete.parentElement);
        let followFootingConcrete=!Object.prototype.hasOwnProperty.call(data.saved.materials??{},'pier_concrete');
        const defaultPierConcrete=()=>{if(followFootingConcrete)materials.pier_concrete.value=materials.concrete.value;};
        materials.concrete.addEventListener('change',defaultPierConcrete);
        materials.pier_concrete.addEventListener('change',()=>{followFootingConcrete=false;});defaultPierConcrete();
        if(!Object.prototype.hasOwnProperty.call(data.saved.materials??{},'pier_bar')){
          const n16=data.materials.pier_bar.find(item=>Number(item.dimensions_mm?.diameter)===16);
          materials.pier_bar.value=n16?String(n16.id):'';
        }
        const autoPier=new Set(Object.keys(pierDefaults()).filter(key=>!Object.prototype.hasOwnProperty.call(data.saved.settings??{},key)||Number(data.saved.settings[key])===data.defaults[key]));
        for(const key of Object.keys(pierDefaults()))controls[key].addEventListener('input',()=>autoPier.delete(key));
        for(const key of ['pier_depth_mm','depth_mm','width_mm'])controls[key].addEventListener('input',()=>{
          for(const [name,value] of Object.entries(pierDefaults()))if(autoPier.has(name))controls[name].value=value;
        });
        const updatePiers=()=>{
          const enabled=controls.include_piers.checked,bar=enabled&&controls.pier_add_bar.checked;
          pierFields.hidden=!enabled;
          materials.pier_concrete.disabled=!enabled;
          for(const key of Object.keys(controls).filter(key=>key.startsWith('pier_')||key.startsWith('piers_'))){
            const starter=key.startsWith('pier_bar_');controls[key].disabled=starter?!bar:!enabled;
            controls[key].parentElement.hidden=starter&&!bar;
          }
          materials.pier_bar.disabled=!bar;materials.pier_bar.parentElement.hidden=!bar;
        };
        controls.include_piers.addEventListener('change',updatePiers);controls.pier_add_bar.addEventListener('change',updatePiers);updatePiers();
        document.getElementById('form').onsubmit=e=>{e.preventDefault();const settings={},bindings={};
          for(const [key,input] of Object.entries(controls))settings[key]=typeof data.defaults[key]==='boolean'?input.checked:typeof data.defaults[key]==='number'?Number(input.value):input.value;
          for(const [role,input] of Object.entries(materials))bindings[role]=input.value;
          sketchup.drawFooting(JSON.stringify({settings,materials:bindings}));};
        </script><script>
        #{File.read(File.join(__dir__, 'strip_footing_dialog.js'))}
        </script></body></html>
      HTML
    end

    class DrawTool
      TAB_KEY = defined?(::VK_TAB) ? ::VK_TAB : 9
      SHIFT_KEY = defined?(::CONSTRAIN_MODIFIER_KEY) ? ::CONSTRAIN_MODIFIER_KEY : 16
      LEFT_KEY = defined?(::VK_LEFT) ? ::VK_LEFT : 37
      RIGHT_KEY = defined?(::VK_RIGHT) ? ::VK_RIGHT : 39
      UP_KEY = defined?(::VK_UP) ? ::VK_UP : 38
      DOWN_KEY = defined?(::VK_DOWN) ? ::VK_DOWN : 40
      # Walks once around the cross section rather than varying one axis at a
      # time, so repeated presses read as rotating through the anchor points.
      ANCHORS = [["top", "left_edge"], ["top", "center"], ["top", "right_edge"],
                 ["bottom", "right_edge"], ["bottom", "center"], ["bottom", "left_edge"]].freeze

      def initialize(builder, settings, materials)
        @builder, @settings, @materials = builder, settings.dup, materials
        @anchor = 0
        @settings["vertical_reference"], @settings["alignment"] = ANCHORS[@anchor]
        validate_step_height(@settings.fetch("step_height_mm", 200.0))
        @paths = [[]]
        @hover = nil
        @error = nil
        @level = nil
      end

      def activate
        @active = true
        @model = Sketchup.active_model
        @context = Array(@model.active_path).dup
        @input = Sketchup::InputPoint.new
        status
      end

      def deactivate(view)
        @active = false
        clear_lock(view)
        view.invalidate
      end

      def enableVCB? = true

      def onKeyDown(key, repeat, flags, view)
        return false if key == 32 # Space remains SketchUp's Select shortcut.
        return true if @finishing || @finished
        if key == undo_key
          return false if @editing_length || shortcut_modifier?(flags)
          undo_point(view) if repeat <= 1
          return true
        elsif key == TAB_KEY
          cycle_anchor
        elsif (action = KeyboardShortcuts.action_for(key, mac: mac_keyboard?))
          return false if @shift_held || shortcut_modifier?(flags)
          if repeat <= 1
            action == "step_height" ? change_step_height(view) : step(view, action == "step_up" ? 1 : -1)
          end
        elsif [LEFT_KEY, RIGHT_KEY, UP_KEY, DOWN_KEY].include?(key)
          return true if repeat > 1
          anchor = @paths.last.last
          return true unless anchor
          if @lock_key == key
            clear_lock(view)
          else
            direction = case key
                        when RIGHT_KEY then [1,0,0]
                        when LEFT_KEY then [0,1,0]
                        when UP_KEY then [0,0,1]
                        else
                          inferred_direction(anchor)
                        end
            lock_direction(view, anchor, direction, key)
          end
        elsif key == SHIFT_KEY
          return true if @shift_held
          @shift_held = true
          if !@lock_key && @input&.valid?
            anchor = @paths.last.last
            if anchor && @hover
              direction = 3.times.map { |i| @hover[i]-anchor[i] }
              lock_direction(view, anchor, direction, SHIFT_KEY)
            else
              view.lock_inference(@input)
              @lock_key = SHIFT_KEY
            end
          end
        else
          numeric_keys = mac_keyboard? ? [43,44,45,46] : [107,109,110,188,189,190]
          @editing_length = true if !shortcut_modifier?(flags) && ((48..57).cover?(key) || (!mac_keyboard? && (96..105).cover?(key)) || numeric_keys.include?(key))
          return false
        end
        status
        view.invalidate
        true
      end

      def mac_keyboard?
        Sketchup.respond_to?(:platform) && Sketchup.platform == :platform_osx
      end

      def undo_key
        # Backward delete: Windows Backspace and the Mac laptop Delete key.
        # Forward Delete is a different key and remains available to SketchUp.
        mac_keyboard? ? 127 : 8
      end

      def inferred_direction(anchor)
        return unless @hover
        delta = 3.times.map { |i| @hover[i]-anchor[i] }
        return delta unless @reference_direction
        dx, dy = @reference_direction
        candidates = [[dx,dy,0],[-dy,dx,0]]
        candidates.max_by { |d| (d[0]*delta[0] + d[1]*delta[1]).abs }
      end

      def shortcut_modifier?(flags)
        %i[CONSTRAIN_MODIFIER_MASK COPY_MODIFIER_MASK ALT_MODIFIER_MASK COMMAND_MODIFIER_MASK].any? do |name|
          Object.const_defined?(name) && (flags & Object.const_get(name)) != 0
        end
      end

      def onKeyUp(key, _repeat, _flags, view)
        return true if @finishing || @finished
        return false unless key == SHIFT_KEY
        @shift_held = false
        clear_lock(view) if @lock_key == SHIFT_KEY
        view.invalidate
        true
      end

      def lock_direction(view, anchor, direction, key)
        return unless direction && direction.sum { |v| v*v } > 1e-8
        target = 3.times.map { |i| anchor[i]+direction[i] }
        view.lock_inference(Sketchup::InputPoint.new(to_point(anchor)), Sketchup::InputPoint.new(to_point(target)))
        @lock_key = key
        @lock_direction = direction
      end

      def clear_lock(view)
        view.lock_inference
        @lock_key = @lock_direction = nil
        @shift_held = false
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
        return if @finishing || @finished
        anchor = @paths.last.last
        if anchor
          unless @input_anchor == anchor
            @anchor_input = Sketchup::InputPoint.new(to_point(anchor))
            @input_anchor = anchor.dup
          end
          @input.pick(view, x, y, @anchor_input)
        else
          @input.pick(view, x, y)
        end
        unless @input.valid?
          @hover = nil
          return
        end
        p = @input.position
        if @input.respond_to?(:edge) && @input.edge
          edge = @input.edge
          vector = edge.end.position.transform(@input.transformation) - edge.start.position.transform(@input.transformation)
          length = Math.hypot(vector.x, vector.y)
          @reference_direction = [vector.x/length, vector.y/length] if length > 1e-8
        end
        @hover = [p.x.to_mm.to_f, p.y.to_mm.to_f, @level || p.z.to_mm.to_f]
        if anchor
          @hover[2] = anchor[2]
          if @lock_direction
            dx, dy = @lock_direction
            squared = dx*dx + dy*dy
            if squared > 1e-8
              station = ((@hover[0]-anchor[0])*dx + (@hover[1]-anchor[1])*dy) / squared
              @hover[0], @hover[1] = anchor[0]+station*dx, anchor[1]+station*dy
            else
              @hover = anchor.dup
            end
          end
        end
        view.tooltip = @input.tooltip
        if defined?(::SB_VCB_VALUE) && anchor
          Sketchup.set_status_text(Math.hypot(@hover[0]-anchor[0], @hover[1]-anchor[1]).mm.to_s, SB_VCB_VALUE)
        end
        view.invalidate
      end

      def onLButtonDown(flags, x, y, view)
        @editing_length = false
        @mouse_down = [x,y]
        onMouseMove(flags, x, y, view)
        add_point(@hover, view) if @hover
      end

      def onLButtonUp(flags, x, y, view)
        origin = @mouse_down
        @mouse_down = nil
        return unless origin && Math.hypot(x-origin[0], y-origin[1]) > 3
        onMouseMove(flags, x, y, view)
        add_point(@hover, view) if @hover
      end

      def onLButtonDoubleClick(_flags, _x, _y, view)
        onReturn(view)
      end

      def add_point(point, view)
        return if @finishing || @finished
        current = @paths.last
        return if current.last && StripFootingGeometry.same_xy?(current.last, point)
        current << point.dup
        @editing_length = false
        clear_lock(view)
        @hover = nil
        @level ||= point[2]
        @error = nil
        status
        view.invalidate
      end

      def onUserText(text, view)
        return if @finishing || @finished
        current = @paths.last
        editing = @hover.nil? && current.length >= 2
        anchor = editing ? current[-2] : current.last
        endpoint = editing ? current.last : @hover
        raise "Click a start point and move in the run direction first." unless anchor && endpoint
        distance = text.to_l.to_mm.to_f
        raise "Enter a positive length." unless distance.finite? && distance > 1
        delta = [endpoint[0] - anchor[0], endpoint[1] - anchor[1]]
        length = Math.hypot(*delta)
        raise "Move the cursor to set a horizontal direction first." if length < 0.01
        target = anchor.dup
        2.times { |i| target[i] += delta[i] * distance / length }
        if editing
          current[-1] = target
          @error = nil
          status
          view.invalidate
        else
          add_point(target, view)
        end
        @editing_length = false
      rescue StandardError => e
        @error = e.message
        status
      end

      def onReturn(view)
        return if @finishing || @finished
        return unless @paths.any? { |path| path.length >= 2 }
        @finishing = true
        # Leave the native keyboard/menu callback before building or changing
        # tools. Modal dialogs here can dispatch events to the retiring tool.
        UI.start_timer(0, false) do
          begin
            next if @active == false
            raise "The model or editing context changed; restart drawing." unless Sketchup.active_model == @model && Array(@model.active_path) == @context
            raise "Draw the next run after the step before finishing." if pending_step?
            paths = @paths.select { |path| path.length >= 2 }
            result = @builder.build(@model, paths, @settings, @materials)
            @paths = [[]]
            @level = @hover = @mouse_down = @input_anchor = @anchor_input = nil
            @editing_length = false
            @error = nil
            @input = Sketchup::InputPoint.new
            clear_lock(view)
            view.invalidate
            warnings = result[:warnings]
            status
            Sketchup.set_status_text("Strip footing created. #{warnings.join(' ')} Click to start another footing; Space selects.")
          rescue StandardError => e
            @error = e.message
            status
            view.invalidate
          ensure
            @finishing = false
          end
        end
        nil
      end

      def onCancel(_reason, view)
        clear_lock(view)
        @model.select_tool(nil)
        view.invalidate
      end

      def getMenu(menu, *_event)
        return if @finishing || @finished
        menu.add_item("Finish Footing") { onReturn(@model.active_view) }
        menu.add_item("Undo Last Point") do
          undo_point(@model.active_view)
        end
        menu.add_item("Start Branch / New Run") do
          @paths << [] unless @paths.last.empty?
          @hover = nil
          @level = nil
          clear_lock(@model.active_view)
          status
        end
        menu.add_item("Step Up (#{KeyboardShortcuts.label('step_up')})") { step(@model.active_view, 1) }
        menu.add_item("Step Down (#{KeyboardShortcuts.label('step_down')})") { step(@model.active_view, -1) }
        menu.add_item("Change Step Height (#{KeyboardShortcuts.label('step_height')})...") { change_step_height(@model.active_view) }
        menu.add_item("Close Current Loop") do
          current = @paths.last
          add_point(current.first, @model.active_view) if current.length >= 3
        end
      end

      def undo_point(view)
        @paths.last.pop
        @paths.pop if @paths.length > 1 && @paths.last.empty?
        @level = @paths.last.last&.last
        @hover = nil
        @error = nil
        @editing_length = false
        @input_anchor = @anchor_input = nil
        @input = Sketchup::InputPoint.new if @input
        clear_lock(view)
        status
        view.invalidate
      end

      def validate_step_height(value)
        height = Float(value)
        raise "Step height must be greater than zero and less than footing depth." unless height.finite? && height > 0.01 && height < @settings["depth_mm"]
        height
      end

      def pending_step?
        return false unless @paths.length > 1 && @paths.last.length == 1
        a, b = @paths[-2].last, @paths.last.first
        a && StripFootingGeometry.same_xy?(a, b) && (a[2]-b[2]).abs > 0.01
      end

      def change_step_height(view)
        values = UI.inputbox(["Step height (mm)"], [@settings.fetch("step_height_mm", 200.0)], "Change Step Height")
        return unless values
        height = validate_step_height(values.first)
        if pending_step?
          previous = @paths[-2].last
          direction = @paths.last.first[2] > previous[2] ? 1 : -1
          @paths.last.first[2] = previous[2] + direction*height
          @level = @paths.last.first[2]
          @hover = nil
          clear_lock(view)
        end
        @settings["step_height_mm"] = height
        @builder.remember_settings(@settings, @materials)
        @error = nil
        status
        view.invalidate
      rescue StandardError => e
        UI.messagebox(e.message)
      end

      def step(view, direction)
        raise "Draw a run before adding a step." if @paths.last.length < 2
        raise "Choose step up or step down." unless [1, -1].include?(direction)
        delta = validate_step_height(@settings.fetch("step_height_mm", 200.0)) * direction
        start = @paths.last.last.dup
        start[2] += delta
        @paths << [start]
        @level = start[2]
        @hover = nil
        @editing_length = false
        @error = nil
        clear_lock(view)
        status
        view.invalidate
      rescue StandardError => e
        UI.messagebox(e.message)
      end

      def draw(view)
        return if @active == false || @finishing || @finished
        @input.draw(view) if @input&.valid?
        @paths.each_cons(2) do |before, after|
          a, b = before.last, after.first
          next unless a && b && StripFootingGeometry.same_xy?(a, b) && (a[2]-b[2]).abs > 0.01
          view.drawing_color = "#b040b0"
          view.line_width = 3
          view.draw(GL_LINES, [to_point(a), to_point(b)])
          midpoint = 3.times.map { |i| (a[i]+b[i])/2.0 }
          view.draw_text(view.screen_coords(to_point(midpoint)), format("%+g mm", b[2]-a[2]))
        end
        paths = @paths.map { |p| p.map(&:dup) }
        paths.last << @hover if @hover && paths.last.any? && !StripFootingGeometry.same_xy?(paths.last.last, @hover)
        paths.each do |path|
          next if path.length < 2
          view.drawing_color = "#1684be"
          view.line_width = 2
          view.draw(GL_LINE_STRIP, path.map { |p| to_point(p) })
        end
        if @hover && @paths.last.last
          endpoints = [to_point(@paths.last.last), to_point(@hover)]
          view.set_color_from_line(*endpoints)
          view.drawing_color = "#b040b0" if [DOWN_KEY, SHIFT_KEY].include?(@lock_key)
          view.line_width = @lock_key ? 3 : 2
          view.draw(GL_LINES, endpoints)
        end
        valid_paths = paths.select { |p| p.length >= 2 }
        return if valid_paths.empty?
        begin
          plan = StripFootingGeometry.plan(valid_paths, @settings.merge("reinforcement" => "none"))
          view.drawing_color = Sketchup::Color.new(80, 160, 210, 65)
          triangles = plan[:faces].flat_map { |f| (1...f.length-1).flat_map { |i| [f[0], f[i], f[i+1]] } }
          view.draw(GL_TRIANGLES, triangles.map { |p| to_point(p) })
          plan[:piers].each do |pier|
            view.drawing_color = "#247755"
            view.line_width = 2
            circles = [0,-@settings["pier_depth_mm"]].map do |z|
              24.times.map do |i|
                angle = i*2*Math::PI/24
                to_point([pier[:top][0]+Math.cos(angle)*@settings["pier_diameter_mm"]/2,
                          pier[:top][1]+Math.sin(angle)*@settings["pier_diameter_mm"]/2,pier[:top][2]+z])
              end
            end
            circles.each { |points| view.draw(GL_LINE_LOOP,points) }
            view.draw(GL_LINES,[0,6,12,18].flat_map { |i| [circles[0][i],circles[1][i]] })
          end
          steel = StripFootingGeometry.steel(plan[:segments], @settings, plan[:steps])
          z_bars = StripFootingGeometry.step_z_bars(plan[:steps], plan[:segments], steel[:layers], @settings)
          bars = steel[:bars] + steel[:spacers].flat_map { |pair| pair[:bars] }
          unless bars.empty?
            view.drawing_color = "#354a5f"
            view.line_width = 2
            view.draw(GL_LINES, bars.flat_map { |bar| [to_point(bar[:a]), to_point(bar[:b])] })
          end
          z_bars.each do |bar|
            view.drawing_color = "#945b28"
            view.line_width = 3
            view.draw(GL_LINE_STRIP, bar[:points].map { |p| to_point(p) })
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
        undo_label = mac_keyboard? ? "Delete" : "Backspace"
        height = @settings.fetch("step_height_mm", 200.0)
        down, up = KeyboardShortcuts.label('step_down'), KeyboardShortcuts.label('step_up')
        message = "Strip footing anchor #{anchor_label} (Tab cycles): click runs; type length; arrows lock; Shift holds inference; #{undo_label} undoes point; #{down} down / #{up} up #{height} mm; right-click changes step height or finishes; Esc cancels."
        message = "Blue axis locked: footing runs stay level; use #{down} / #{up} for steps." if @lock_key == UP_KEY
        Sketchup.set_status_text(@error || message)
        Sketchup.set_status_text("Length", SB_VCB_LABEL) if defined?(::SB_VCB_LABEL)
      end
    end
  end
end
