# frozen_string_literal: true

require "json"

module Basegrid
  class ConcreteSlabTool
    TOOL_ID = "concrete.slab_from_face"
    GENERATED_ROLE_ID = "concrete.slab_from_face.slab_body"
    OBJECT_ROLE = "slab_body"
    MATERIAL_ROLE = "concrete"
    DEFAULT_THICKNESS_MM = 100.0
    DEFAULT_TAG_NAME = "Slab | Concrete"
    DEFAULT_FOLDER_PATH = "Structure"
    HORIZONTAL_TOLERANCE = 0.001
    INCH_TO_METRE = 0.0254

    def initialize(library: MaterialLibrary.new)
      @library = library
    end

    def run
      model = Sketchup.active_model
      @library.load
      face = selected_face(model)
      return unless face

      materials = @library.concrete_materials
      if materials.empty?
        UI.messagebox("No active materials were found under the Concrete material type (Bulk, m3). Sync materials first.")
        return
      end

      groups = @library.takeoff_groups_for_role(GENERATED_ROLE_ID)
      show_settings_dialog(model, face, materials, groups)
    rescue StandardError => e
      UI.messagebox("Concrete slab could not be created.\n\n#{e.message}")
    end

    def build(model, source_face, thickness_mm, material, takeoff_groups = [])
      validate_face!(model, source_face)
      thickness_mm = Float(thickness_mm)
      raise "Slab thickness must be a finite number greater than zero." unless thickness_mm.finite? && thickness_mm.positive?

      group = nil
      model.start_operation("Create Concrete Slab", true)
      operation_started = true
      group = model.active_entities.add_group
      group.name = "Concrete Slab"
      group.layer = model.layers[0]
      top_face = copy_face(group.entities, source_face)
      transformation = model.respond_to?(:edit_transform) ? model.edit_transform : Geom::Transformation.new
      world_normal = top_face.normal.transform(transformation)
      top_face.reverse! if world_normal.z.negative?
      normal_scale = top_face.normal.transform(transformation).length
      raise "The current editing context has an invalid scale." unless normal_scale.positive?

      top_face.pushpull(-thickness_mm.to_f.mm / normal_scale)
      untag_inner_geometry(model, group.entities)

      MaterialAppearance.new(library: @library).apply(
        group,
        material,
        mode: MaterialAppearance.mode(model)
      )
      assign_role_tag(model, group)
      write_metadata(group, thickness_mm, material)
      quantity = concrete_volume_m3(model, source_face, thickness_mm)
      Takeoff.write(
        group,
        material: material,
        role_id: GENERATED_ROLE_ID,
        quantity_m3: quantity,
        basis: "selected face net area multiplied by generated slab thickness",
        takeoff_groups: takeoff_groups
      )
      model.commit_operation
      operation_started = false
      model.selection.clear
      model.selection.add(group)
      group
    rescue StandardError
      model.abort_operation if operation_started
      raise
    end

    def validate_face!(model, face)
      raise "The active SketchUp model has changed." unless model == Sketchup.active_model
      raise "Provide one valid SketchUp face." unless face.is_a?(Sketchup::Face) && face.valid?
      unless face.model == model && face.parent == model.active_entities.parent
        raise "The face must belong to the current editing context."
      end
      if Array(model.active_path).any?(&:locked?)
        raise "The current editing context contains a locked group or component."
      end

      transformation = model.edit_transform
      # Transform the plane's tangent vectors: normals cannot be transformed
      # directly when an editing context has non-uniform scale or shear.
      x_axis, y_axis, = face.normal.axes
      world_normal = x_axis.transform(transformation).cross(y_axis.transform(transformation))
      raise "The current editing context has an invalid scale." unless world_normal.length.positive?

      world_normal.normalize!
      if world_normal.z.abs < 1.0 - HORIZONTAL_TOLERANCE
        raise "The face must be horizontal."
      end
      extrusion = face.normal.transform(transformation)
      extrusion.normalize! if extrusion.length.positive?
      if extrusion.z.abs < 1.0 - HORIZONTAL_TOLERANCE
        raise "The editing context skews the extrusion. Create the slab in an unskewed context."
      end
      face
    end

    private

    def selected_face(model)
      faces = model.selection.grep(Sketchup::Face)
      unless faces.length == 1 && model.selection.length == 1
        UI.messagebox("Select exactly one horizontal face before creating a slab.")
        return nil
      end
      face = faces.first
      transformation = model.respond_to?(:edit_transform) ? model.edit_transform : Geom::Transformation.new
      world_normal = face.normal.transform(transformation)
      world_normal.normalize!
      if world_normal.z.abs < 1.0 - HORIZONTAL_TOLERANCE
        UI.messagebox("The selected face must be horizontal.")
        return nil
      end
      face
    end

    def show_settings_dialog(model, face, materials, groups)
      @pending_settings = {
        model: model,
        face: face,
        materials: materials,
        groups: groups
      }
      @settings_dialog&.close
      @settings_dialog = UI::HtmlDialog.new(
        dialog_title: "Concrete Slab",
        preferences_key: "basegrid_concrete_slab",
        scrollable: true,
        resizable: true,
        width: 520,
        height: 610,
        style: UI::HtmlDialog::STYLE_DIALOG
      )
      @settings_dialog.add_action_callback("createSlab") do |_context, encoded|
        submit_settings(encoded)
      end
      @settings_dialog.add_action_callback("cancel") { |_context| @settings_dialog.close }
      @settings_dialog.set_html(settings_html(materials, groups))
      @settings_dialog.show
    end

    def settings_html(materials, groups)
      labels = material_labels(materials)
      material_options = materials.each_with_index.map do |material, index|
        { "id" => material.fetch("id").to_s, "label" => labels[index] }
      end
      payload = JSON.generate(
        "thickness_mm" => Sketchup.read_default("Basegrid", "slab_thickness_mm", DEFAULT_THICKNESS_MM).to_f,
        "material_id" => Sketchup.read_default("Basegrid", "slab_concrete_material_id", "").to_s,
        "selected_group_id" => remembered_group_ids.first.to_s,
        "materials" => material_options,
        "groups" => groups.map { |group| { "id" => group.fetch("id").to_s, "name" => group.fetch("name").to_s } }
      ).gsub("<", "\\u003c")
      <<~HTML
        <!doctype html>
        <html>
        <head>
          <meta charset="utf-8">
          <style>
            :root { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; }
            * { box-sizing: border-box; }
            body { margin: 0; color: #202124; background: #f4f5f6; }
            header { padding: 22px 24px 18px; color: white; background: #263238; }
            h1 { margin: 0 0 5px; font-size: 21px; }
            header p { margin: 0; color: #cfd8dc; font-size: 13px; }
            main { padding: 20px 24px 24px; }
            label.title { display: block; margin: 0 0 7px; color: #596168; font-size: 12px; font-weight: 650; }
            input[type=number], select { width: 100%; height: 38px; padding: 7px 9px; border: 1px solid #bdc3c7; border-radius: 5px; background: white; color: #202124; }
            .field { margin-bottom: 17px; }
            .hint { margin: 7px 0 0; color: #747c82; font-size: 11px; }
            .error { min-height: 18px; margin-top: 10px; color: #b3261e; font-size: 12px; }
            footer { display: flex; justify-content: flex-end; gap: 8px; margin-top: 10px; }
            button { padding: 8px 15px; border: 1px solid #aeb4b8; border-radius: 4px; background: white; color: #202124; cursor: pointer; }
            button.primary { border-color: #1769aa; color: white; background: #1769aa; }
          </style>
        </head>
        <body>
          <header><h1>Concrete slab</h1><p>Create from the selected horizontal face.</p></header>
          <main>
            <div class="field"><label class="title" for="thickness">Thickness (mm)</label><input id="thickness" type="number" min="0.1" step="1"></div>
            <div class="field">
              <label class="title" for="takeoff-group">Takeoff group</label>
              <select id="takeoff-group"></select>
              <p class="hint">Available groups are controlled by this generated role in the web app.</p>
            </div>
            <div class="field"><label class="title" for="material">Concrete material</label><select id="material"></select></div>
            <div id="error" class="error"></div>
            <footer><button onclick="sketchup.cancel()">Cancel</button><button class="primary" onclick="createSlab()">Create slab</button></footer>
          </main>
          <script>
            const data = #{payload};
            const material = document.getElementById("material");
            data.materials.forEach(item => {
              const option = document.createElement("option");
              option.value = item.id; option.textContent = item.label;
              material.appendChild(option);
            });
            material.value = data.materials.some(item => item.id === data.material_id) ? data.material_id : data.materials[0].id;
            document.getElementById("thickness").value = data.thickness_mm;
            const takeoffGroup = document.getElementById("takeoff-group");
            const unassigned = document.createElement("option");
            unassigned.value = ""; unassigned.textContent = "No takeoff group";
            takeoffGroup.appendChild(unassigned);
            data.groups.forEach(group => {
              const option = document.createElement("option");
              option.value = group.id; option.textContent = group.name;
              takeoffGroup.appendChild(option);
            });
            takeoffGroup.value = data.groups.some(group => group.id === data.selected_group_id) ? data.selected_group_id : "";
            function createSlab() {
              const thickness = Number(document.getElementById("thickness").value);
              if (!Number.isFinite(thickness) || thickness <= 0) {
                document.getElementById("error").textContent = "Enter a thickness greater than zero.";
                return;
              }
              sketchup.createSlab(JSON.stringify({
                thickness_mm: thickness,
                material_id: material.value,
                takeoff_group_id: takeoffGroup.value
              }));
            }
          </script>
        </body>
        </html>
      HTML
    end

    def submit_settings(encoded)
      values = JSON.parse(encoded.to_s)
      pending = @pending_settings
      raise "The slab settings have expired. Select the face and run the tool again." unless pending
      face = pending.fetch(:face)
      raise "The selected face is no longer available." if face.respond_to?(:valid?) && !face.valid?

      thickness = Float(values.fetch("thickness_mm"))
      raise "Slab thickness must be greater than zero." unless thickness.positive?
      material = pending.fetch(:materials).find do |candidate|
        candidate.fetch("id").to_s == values.fetch("material_id").to_s
      end
      raise "Select an available concrete material." unless material

      selected_id = values["takeoff_group_id"].to_s
      takeoff_groups = pending.fetch(:groups).select { |group| group.fetch("id").to_s == selected_id }.first(1)
      Sketchup.write_default("Basegrid", "slab_thickness_mm", thickness)
      Sketchup.write_default("Basegrid", "slab_concrete_material_id", material.fetch("id").to_s)
      Sketchup.write_default("Basegrid", "slab_takeoff_group_ids", JSON.generate(takeoff_groups.map { |group| group.fetch("id").to_s }))
      @settings_dialog.close
      @pending_settings = nil
      build(pending.fetch(:model), face, thickness, material, takeoff_groups)
    rescue StandardError => e
      UI.messagebox("Concrete slab could not be created.\n\n#{e.message}")
    end

    def remembered_group_ids
      JSON.parse(Sketchup.read_default("Basegrid", "slab_takeoff_group_ids", "[]").to_s)
    rescue JSON::ParserError
      []
    end

    def material_labels(materials)
      counts = materials.each_with_object(Hash.new(0)) { |material, memo| memo[material.fetch("name").to_s] += 1 }
      materials.map do |material|
        name = material.fetch("name").to_s.tr("|", "-")
        counts[material.fetch("name").to_s] > 1 ? "#{name} (#{material.fetch('id').to_s[0, 8]})" : name
      end
    end

    def copy_face(target_entities, source_face)
      outer_points = source_face.outer_loop.vertices.map(&:position)
      face = target_entities.add_face(outer_points)
      raise "The selected face boundary could not be copied." unless face

      source_face.loops.reject(&:outer?).each do |loop|
        opening = target_entities.add_face(loop.vertices.map(&:position))
        opening.erase! if opening&.valid?
      end
      face = target_entities.grep(Sketchup::Face).max_by(&:area)
      raise "The selected face openings could not be copied." unless face

      face
    end

    def concrete_volume_m3(model, face, thickness_mm)
      transformation = model.respond_to?(:edit_transform) ? model.edit_transform : nil
      area_sq_in = transformation ? face.area(transformation) : face.area
      thickness_in = thickness_mm.to_f / 25.4
      area_sq_in * thickness_in * (INCH_TO_METRE**3)
    end

    def assign_role_tag(model, group)
      layers = model.layers
      tag = layers[DEFAULT_TAG_NAME]
      existing_role = tag&.get_attribute("Basegrid", "generated_role_id").to_s
      if tag && !existing_role.empty? && existing_role != GENERATED_ROLE_ID
        raise "The tag #{DEFAULT_TAG_NAME.inspect} is already assigned to another generated role."
      end
      unless tag
        tag = layers.add(DEFAULT_TAG_NAME)
        folder_path = Sketchup.read_default("Basegrid", "slab_concrete_folder", DEFAULT_FOLDER_PATH).to_s
        folder = ensure_folder_path(layers, folder_path)
        tag.folder = folder if folder
      end
      tag.set_attribute("Basegrid", "generated_role_id", GENERATED_ROLE_ID)
      group.layer = tag
    end

    def untag_inner_geometry(model, entities)
      untagged = model.layers[0]
      entities.each { |entity| entity.layer = untagged if entity.respond_to?(:layer=) }
    end

    def ensure_folder_path(layers, path)
      names = path.split("/").map(&:strip).reject(&:empty?)
      parent = layers
      folder = nil
      names.each do |name|
        folder = parent.folders.find { |candidate| candidate.name == name } || parent.add_folder(name)
        parent = folder
      end
      folder
    end

    def write_metadata(group, thickness_mm, material)
      group.set_attribute("Basegrid", "schema_version", 1)
      group.set_attribute("Basegrid", "tool_id", TOOL_ID)
      group.set_attribute("Basegrid", "generated_role_id", GENERATED_ROLE_ID)
      group.set_attribute("Basegrid", "object_role", OBJECT_ROLE)
      group.set_attribute("Basegrid", "material_role", MATERIAL_ROLE)
      group.set_attribute("Basegrid", "material_id", material.fetch("id").to_s)
      group.set_attribute("Basegrid", "material_type_id", material.fetch("material_type_id").to_s)
      group.set_attribute("Basegrid", "parameters_json", JSON.generate("thickness_mm" => thickness_mm.to_f))
    end
  end
end
