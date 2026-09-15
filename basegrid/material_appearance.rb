# frozen_string_literal: true

module Basegrid
  class MaterialAppearance
    DICTIONARY = "Basegrid"
    MODEL_MODE_KEY = "material_appearance_mode"
    MODEL_MODE = "texture"
    DISPLAY_MODE = "display_texture"
    MODES = [MODEL_MODE, DISPLAY_MODE].freeze

    def initialize(library: MaterialLibrary.new)
      @library = library
    end

    def self.mode(model)
      configured = model.get_attribute(DICTIONARY, MODEL_MODE_KEY, MODEL_MODE).to_s
      MODES.include?(configured) ? configured : MODEL_MODE
    end

    def self.next_mode(model)
      mode(model) == MODEL_MODE ? DISPLAY_MODE : MODEL_MODE
    end

    def toggle(model)
      target_mode = self.class.next_mode(model)
      changed = 0
      missing = []

      model.start_operation("Switch Material Appearance", true)
      each_bound_entity(model.entities) do |entity, material_id|
        material = @library.find(material_id)
        unless material
          missing << material_id
          next
        end

        apply(entity, material, mode: target_mode, model: model)
        changed += 1
      end
      model.set_attribute(DICTIONARY, MODEL_MODE_KEY, target_mode)
      model.commit_operation
      { mode: target_mode, changed: changed, missing_material_ids: missing.uniq }
    rescue StandardError
      model.abort_operation
      raise
    end

    def apply(entity, material, mode:, model: Sketchup.active_model)
      appearance_role = MODES.include?(mode.to_s) ? mode.to_s : MODEL_MODE
      native = native_material(model, material, appearance_role)
      entity.material = native if entity.respond_to?(:material=)
      paint_nested(entity.entities, native) if entity.respond_to?(:entities)
      if entity.respond_to?(:entities) && entity.respond_to?(:get_attribute)
        radius = entity.get_attribute(DICTIONARY, "cylindrical_texture_radius", 0).to_f
        map_cylinder(entity.entities, native, radius) if radius.positive?
      end
      native
    end

    private

    def map_cylinder(entities, native, radius)
      texture = native.texture
      return unless texture && texture.width.to_f.positive? && texture.height.to_f.positive?
      entities.grep(Sketchup::Face).each do |face|
        next unless face.normal.z.abs < 1e-8
        points = face.vertices.map(&:position)
        next unless points.length == 4
        angles = points.map { |p| Math.atan2(p.y, p.x) }
        # Unwrap the seam before mapping each flat side of the round pier.
        angles.map! { |a| a.negative? ? a+2*Math::PI : a } if angles.max-angles.min > Math::PI
        mapping = points.zip(angles).flat_map do |point, angle|
          [point, Geom::Point3d.new(angle*radius/texture.width.to_f, point.z/texture.height.to_f, 0)]
        end
        face.position_material(native, mapping, true)
        face.position_material(native, mapping, false)
      end
    end

    def each_bound_entity(entities, &block)
      entities.each do |entity|
        material_id = entity.get_attribute(DICTIONARY, "material_id").to_s if entity.respond_to?(:get_attribute)
        if material_id && !material_id.empty?
          block.call(entity, material_id)
          next
        end

        each_bound_entity(entity.entities, &block) if entity.respond_to?(:entities)
      end
    end

    def paint_nested(entities, native)
      entities.each do |child|
        if child.is_a?(Sketchup::Face)
          child.material = native
          child.back_material = native
        elsif child.respond_to?(:entities) && material_id_for(child).empty?
          child.material = native if child.respond_to?(:material=)
          paint_nested(child.entities, native)
        end
      end
    end

    def native_material(model, material, requested_role)
      appearance_role, appearance = resolved_appearance(material, requested_role)
      existing = model.materials.find do |candidate|
        candidate.get_attribute(DICTIONARY, "material_id").to_s == material.fetch("id").to_s &&
          candidate.get_attribute(DICTIONARY, "appearance_role").to_s == requested_role
      end
      if existing
        existing.set_attribute(DICTIONARY, "resolved_appearance_role", appearance_role)
        apply_appearance(existing, appearance) if appearance
        return existing
      end

      base_name = material.fetch("name").to_s
      proposed_name = requested_role == DISPLAY_MODE ? "#{base_name} | Display" : base_name
      name = unique_material_name(model, proposed_name, material.fetch("id").to_s, requested_role)
      native = model.materials.add(name)
      native.set_attribute(DICTIONARY, "material_id", material.fetch("id").to_s)
      native.set_attribute(DICTIONARY, "appearance_role", requested_role)
      native.set_attribute(DICTIONARY, "resolved_appearance_role", appearance_role)
      apply_appearance(native, appearance) if appearance
      native
    end

    def resolved_appearance(material, requested_role)
      requested = material[requested_role]
      return [requested_role, requested] if usable_appearance?(requested)

      fallback = material[MODEL_MODE]
      [MODEL_MODE, usable_appearance?(fallback) ? fallback : nil]
    end

    def usable_appearance?(appearance)
      return false unless appearance.is_a?(Hash)

      File.file?(appearance["local_path"].to_s) || valid_color?(appearance["color"])
    end

    def unique_material_name(model, proposed_name, material_id, appearance_role)
      candidate = model.materials[proposed_name]
      return proposed_name unless candidate
      if candidate.get_attribute(DICTIONARY, "material_id").to_s == material_id &&
         candidate.get_attribute(DICTIONARY, "appearance_role").to_s == appearance_role
        return proposed_name
      end

      "#{proposed_name} | #{material_id[0, 8]}"
    end

    def apply_appearance(native, appearance)
      if File.file?(appearance["local_path"].to_s)
        native.color = nil
        native.texture = appearance.fetch("local_path")
        width = appearance["width_mm"].to_f
        height = appearance["height_mm"].to_f
        native.texture.size = [width.mm, height.mm] if native.texture && width.positive? && height.positive?
        return
      end

      color = appearance["color"].to_s
      return unless valid_color?(color)

      channels = color.delete_prefix("#").scan(/../).map { |value| value.to_i(16) }
      native.texture = nil
      native.color = Sketchup::Color.new(*channels)
    end

    def valid_color?(color)
      color.to_s.match?(/\A#[0-9a-fA-F]{6}\z/)
    end

    def material_id_for(entity)
      return "" unless entity.respond_to?(:get_attribute)

      entity.get_attribute(DICTIONARY, "material_id").to_s
    end
  end
end
