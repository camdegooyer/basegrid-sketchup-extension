# frozen_string_literal: true

require "securerandom"
require "base64"
require "tempfile"

module Basegrid
  class ObjectReferences
    def initialize
      @prefix = "bg_#{SecureRandom.hex(6)}"
      @entries = {}
      @reverse = {}
    end

    def register(object)
      key = [Sketchup.active_model.object_id, object.object_id]
      return @reverse[key] if @reverse.key?(key)
      raise "Too many API references. Restart the Basegrid API." if @entries.length >= 10_000

      ref = "#{@prefix}_#{@entries.length + 1}"
      @entries[ref] = [object, Sketchup.active_model]
      @reverse[key] = ref
    end

    def resolve(ref)
      object, model = @entries.fetch(ref) { raise "Unknown Basegrid reference: #{ref}" }
      raise "This reference belongs to another model." unless model == Sketchup.active_model
      raise "This reference was deleted or undone." if object.respond_to?(:valid?) && !object.valid?

      object
    end
  end

  # Explicit, discoverable Ruby API surface. This is Basegrid-owned code and
  # does not load another extension or accept executable Ruby text.
  class NativeAPI
    METHODS = {
      "Sketchup::Model" => {
        read: %w[title guid entities active_entities selection layers materials definitions pages active_view bounds active_path edit_transform find_entity_by_persistent_id raytest get_attribute],
        edit: %w[set_attribute]
      },
      "Sketchup::Entities" => {
        read: %w[to_a count length parent []],
        edit: %w[add_face add_line add_edges add_curve add_circle add_arc add_ngon add_group add_instance add_cpoint add_cline add_text add_dimension_linear add_dimension_radial transform_entities transform_by_vectors],
        full: %w[erase_entities clear!]
      },
      "Sketchup::Entity" => {
        read: %w[valid? deleted? typename persistent_id entityID model parent get_attribute],
        edit: %w[set_attribute]
      },
      "Sketchup::Drawingelement" => {
        read: %w[bounds layer material hidden? visible? casts_shadows? receives_shadows?],
        edit: %w[layer= material= hidden= casts_shadows= receives_shadows=], full: %w[erase!]
      },
      "Sketchup::Face" => {
        read: %w[area normal vertices edges loops outer_loop plane bounds back_material classify_point],
        edit: %w[pushpull reverse! back_material= position_material]
      },
      "Sketchup::Edge" => {
        read: %w[start end vertices length faces curve line soft? smooth?], edit: %w[soft= smooth=]
      },
      "Sketchup::Vertex" => { read: %w[position edges faces] },
      "Sketchup::Loop" => { read: %w[vertices edges outer?] },
      "Sketchup::Curve" => { read: %w[vertices edges length], edit: %w[move_vertices] },
      "Sketchup::ArcCurve" => { read: %w[center normal radius start_angle end_angle] },
      "Sketchup::Group" => {
        read: %w[name entities definition transformation volume manifold? locked?],
        edit: %w[name= transformation= transform! move! copy make_unique locked= to_component], full: %w[explode]
      },
      "Sketchup::ComponentInstance" => {
        read: %w[name definition transformation volume manifold? locked?],
        edit: %w[name= transformation= transform! move! make_unique locked=], full: %w[explode]
      },
      "Sketchup::ComponentDefinition" => { read: %w[name description entities instances bounds guid group?], edit: %w[name= description=] },
      "Sketchup::DefinitionList" => { read: %w[to_a count []], edit: %w[add], full: %w[remove purge_unused] },
      "Sketchup::Selection" => { read: %w[to_a count length [] empty? include?], edit: %w[add remove clear toggle] },
      "Sketchup::Layers" => { read: %w[to_a count [] folders], edit: %w[add add_folder], full: %w[remove purge_unused] },
      "Sketchup::Layer" => { read: %w[name visible? folder color], edit: %w[name= visible= folder= color=] },
      "Sketchup::LayerFolder" => { read: %w[name visible? layers folders], edit: %w[name= visible= add_folder] },
      "Sketchup::Materials" => { read: %w[to_a count [] current], edit: %w[add current=], full: %w[remove purge_unused] },
      "Sketchup::Material" => { read: %w[name display_name color alpha texture materialType], edit: %w[name= color= alpha=] },
      "Sketchup::Pages" => { read: %w[to_a count [] selected_page], edit: %w[add selected_page=], full: %w[erase] },
      "Sketchup::Page" => { read: %w[name description camera], edit: %w[name= description= update] },
      "Sketchup::View" => { read: %w[camera vpwidth vpheight], edit: %w[zoom zoom_extents camera= invalidate refresh] },
      "Sketchup::Camera" => { read: %w[eye target up perspective? fov height], edit: %w[set perspective= fov= height=] },
      "Sketchup::ConstructionPoint" => { read: %w[position], edit: %w[position=] },
      "Sketchup::Text" => { read: %w[text point vector], edit: %w[text= point= vector=] },
      "Sketchup::Dimension" => { read: %w[text], edit: %w[text=] }
    }.freeze
    UNITS = { "mm" => 1.0 / 25.4, "cm" => 1.0 / 2.54, "m" => 1000.0 / 25.4, "inch" => 1.0, "feet" => 12.0 }.freeze
    MANAGED_METHODS = %w[start_operation commit_operation abort_operation].freeze

    def initialize(registry:, model:)
      @registry = registry
      @model = model
    end

    def call(name, args, mode)
      case name
      when "basegrid_native_api"
        { "methods" => discovered_methods, "roots" => ["active_model"], "units" => UNITS.keys,
          "value_types" => %w[Point3d Vector3d Length Color Transformation],
          "point_example" => { "$type" => "Point3d", "x" => 6000, "y" => 0, "z" => 0, "unit" => "mm" },
          "numeric_returns" => "Plain numeric API results use SketchUp internal inches, square inches or cubic inches. Typed points and lengths return millimetres.",
          "scope" => "The installed SketchUp native instance methods are discovered at runtime. Methods beyond the common drawing set require full permission. Ruby execution, callback blocks and transaction control are not exposed." }
      when "basegrid_model" then summary
      when "basegrid_capture_view" then capture(args)
      when "basegrid_invoke"
        run_calls([args.slice("target", "method", "arguments").merge("id" => "call")], mode, "Basegrid: #{args['method']}").first.fetch("result")
      when "basegrid_batch" then run_calls(args.fetch("calls"), mode, args.fetch("operation_name", "Basegrid Drawing"))
      else raise "Unknown native Basegrid command."
      end
    end

    def run_calls(calls, mode, operation_name)
      raise "Open a SketchUp model first." unless @model
      raise "calls must contain between 1 and 100 calls." unless calls.is_a?(Array) && (1..100).cover?(calls.length)
      ids = calls.map do |entry|
        unless entry.is_a?(Hash) && (entry.keys - %w[id target method arguments]).empty? && entry["id"].is_a?(String) && !entry["id"].empty?
          raise "Each call needs a unique string id, target, method and optional arguments."
        end
        entry["id"]
      end
      raise "Call IDs must be unique." unless ids.uniq.length == ids.length
      results = {}
      operation_open = false
      output = calls.map do |entry|
        target = decode_target(entry["target"], results)
        method = entry["method"]
        classification = authorize(target, method, mode)
        arguments = entry.fetch("arguments", [])
        raise "arguments must be an array of at most 32 values." unless arguments.is_a?(Array) && arguments.length <= 32
        values = arguments.map { |value| decode(value, results) }
        if classification != :read
          raise "Unlock the target before editing it." if target.respond_to?(:locked?) && target.locked? && method != "locked="
          raise "The editing context is locked." if Array(@model.active_path).any?(&:locked?)
          unless operation_open
            @model.start_operation(operation_name, true)
            operation_open = true
          end
        end
        value = target.public_send(method, *values)
        results[entry.fetch("id")] = value
        { "id" => entry.fetch("id"), "result" => encode(value) }
      end
      @model.commit_operation if operation_open
      operation_open = false
      output
    rescue StandardError
      @model.abort_operation if operation_open
      raise
    end

    private

    def authorize(target, name, mode)
      raise "method must be a string." unless name.is_a?(String)
      classification = nil
      target.class.ancestors.each do |klass|
        METHODS.fetch(klass.name, {}).each { |level, names| classification ||= level if names.include?(name) }
      end
      classification ||= :full if native_method?(target.public_method(name)) rescue nil
      classification = nil if MANAGED_METHODS.include?(name)
      raise "#{target.class.name}##{name} is not exposed by Basegrid. Call basegrid_native_api for supported methods." unless classification
      allowed = { "inspect" => [:read], "edit" => %i[read edit], "full" => %i[read edit full] }.fetch(mode, [])
      raise "#{name} requires #{classification} permission in Basegrid's MCP API menu." unless allowed.include?(classification)
      raise "#{name} is not available in this SketchUp version." unless target.respond_to?(name)

      classification
    end

    def decode_target(value, results)
      raise "target must contain exactly one root or reference." unless value.is_a?(Hash) && value.length == 1
      return @model if value == { "$root" => "active_model" }
      return @registry.resolve(value["$ref"]) if value.key?("$ref")
      return results.fetch(value["$result"]) { raise "Unknown earlier call result." } if value.key?("$result")

      raise "Unknown native API target."
    end

    def number(value)
      raise "Geometry coordinates must be finite numbers." unless value.is_a?(Numeric) && value.finite?

      value.to_f
    end

    def scale(value)
      UNITS.fetch(value.fetch("unit")) { raise "Use explicit units: #{UNITS.keys.join(', ')}." }
    end

    def decode(value, results, depth = 0)
      raise "Argument nesting exceeds 12 levels." if depth > 12
      case value
      when Array
        raise "Argument arrays are limited to 4096 entries." if value.length > 4096
        value.map { |item| decode(item, results, depth + 1) }
      when Hash
        return decode_target(value, results) if value.keys.any? { |key| %w[$ref $result $root].include?(key) }
        type = value["$type"].to_s.delete_prefix("Geom::").delete_prefix("Sketchup::")
        case type
        when "Point3d" then Geom::Point3d.new(*%w[x y z].map { |key| number(value.fetch(key)) * scale(value) })
        when "Vector3d" then Geom::Vector3d.new(*%w[x y z].map { |key| number(value.fetch(key)) })
        when "Length" then number(value.fetch("value")) * scale(value)
        when "Color" then Sketchup::Color.new(*%w[r g b].map { |key| number(value.fetch(key)).clamp(0, 255).to_i })
        when "Transformation"
          case value.fetch("kind")
          when "translation"
            Geom::Transformation.translation(%w[x y z].map { |key| number(value.fetch(key)) * scale(value) })
          when "scaling" then Geom::Transformation.scaling(number(value.fetch("scale")))
          when "rotation"
            Geom::Transformation.rotation(decode(value.fetch("point"), results, depth + 1), decode(value.fetch("axis"), results, depth + 1), number(value.fetch("degrees")) * Math::PI / 180.0)
          else raise "Unknown transformation kind."
          end
        when ""
          value.transform_values { |item| decode(item, results, depth + 1) }
        else raise "Unknown typed argument: #{type}"
        end
      when String
        raise "Argument strings are limited to 16384 bytes." if value.bytesize > 16_384
        value
      when Numeric
        number(value)
        value
      when nil, true, false then value
      else raise "Unsupported argument type."
      end
    end

    def encode(value, depth = 0)
      raise "Result nesting exceeds 12 levels." if depth > 12
      return { "$type" => "Length", "value" => value.to_f * 25.4, "unit" => "mm" } if defined?(::Length) && value.is_a?(::Length)
      case value
      when nil, true, false, Integer, String then value
      when Float then value.finite? ? value : value.to_s
      when Array
        items = value.first(200).map { |item| encode(item, depth + 1) }
        value.length > 200 ? { "items" => items, "total" => value.length, "truncated" => true } : items
      when Hash then value.transform_values { |item| encode(item, depth + 1) }
      else
        case value.class.name
        when "Geom::Point3d"
          { "$type" => "Point3d", "x" => value.x.to_f * 25.4, "y" => value.y.to_f * 25.4, "z" => value.z.to_f * 25.4, "unit" => "mm" }
        when "Geom::Vector3d" then { "$type" => "Vector3d", "x" => value.x, "y" => value.y, "z" => value.z }
        when "Geom::BoundingBox" then { "min" => encode(value.min), "max" => encode(value.max) }
        when "Geom::Transformation" then { "$type" => "Transformation", "matrix" => value.to_a }
        when "Sketchup::Color" then { "$type" => "Color", "r" => value.red, "g" => value.green, "b" => value.blue }
        else
          raise "This return type is not exposed by Basegrid." unless value.class.ancestors.any? { |klass| METHODS.key?(klass.name) || native_class?(klass) }
          result = { "$ref" => @registry.register(value), "ruby_class" => value.class.name }
          result["persistent_id"] = value.persistent_id if value.respond_to?(:persistent_id)
          result
        end
      end
    end

    def summary
      raise "Open a SketchUp model first." unless @model

      { "model_guid" => @model.guid, "title" => @model.title,
        "selection" => encode(@model.selection.to_a), "entity_count" => @model.entities.length,
        "tags" => @model.layers.map(&:name), "materials" => @model.materials.map(&:name), "bounds" => encode(@model.bounds) }
    end

    def native_class?(klass)
      klass.name.to_s.start_with?("Sketchup::", "Geom::")
    end

    def native_method?(method)
      native_class?(method.owner) && method.source_location.nil? && !MANAGED_METHODS.include?(method.name.to_s)
    end

    def discovered_methods
      output = METHODS.transform_values { |levels| levels.transform_values(&:dup) }
      [Sketchup, (Geom if defined?(Geom))].compact.each do |namespace|
        namespace.constants(false).each do |name|
          next if namespace.autoload?(name)
          klass = namespace.const_get(name, false)
          next unless klass.is_a?(Class) && native_class?(klass)
          known = METHODS.select { |class_name, _| klass.ancestors.any? { |ancestor| ancestor.name == class_name } }.values.flat_map { |levels| levels.values.flatten }
          extra = klass.public_instance_methods.select { |method| native_method?(klass.instance_method(method)) }.map(&:to_s) - known
          next if extra.empty?
          output[klass.name] ||= {}
          output[klass.name][:full] = (Array(output[klass.name][:full]) + extra).uniq.sort
        end
      end
      output
    end

    def capture(args)
      raise "Open a SketchUp model first." unless @model

      temporary = Tempfile.new(["basegrid-view-", ".png"])
      path = temporary.path
      temporary.close
      width, height = args.fetch("width", 1200), args.fetch("height", 800)
      @model.active_view.refresh
      success = @model.active_view.write_image(filename: path, width: width, height: height, antialias: true)
      raise "SketchUp could not capture the viewport." unless success
      { "width" => width, "height" => height, "image" => { "data" => Base64.strict_encode64(File.binread(path)), "mimeType" => "image/png" } }
    ensure
      temporary&.unlink
    end
  end
end
