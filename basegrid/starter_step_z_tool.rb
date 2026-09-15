# frozen_string_literal: true

module Basegrid
  class StarterBarTool
    STEP_Z_TOOL_ID = "reinforcement.starter_bars.step_z"

    def step_z_defaults
      { "step_upper_mm" => 600, "step_lower_mm" => 600,
        "step_upper_direction" => "in", "step_lower_direction" => "out",
        "step_offset_axis" => "horizontal", "step_offset_mm" => 0 }
    end

    def step_z_fields_html
      <<~HTML
        <div data-modes="step_z">
        <div class="row"><div><label for="step_upper_mm">Upper crank (mm)</label><input id="step_upper_mm" type="number" min="0" step="any" required></div><div><label for="step_lower_mm">Lower crank (mm)</label><input id="step_lower_mm" type="number" min="0" step="any" required></div></div>
        <div class="row"><div><label for="step_upper_direction">Upper direction</label><select id="step_upper_direction"><option value="in">In</option><option value="out">Out</option></select></div><div><label for="step_lower_direction">Lower direction</label><select id="step_lower_direction"><option value="in">In</option><option value="out">Out</option></select></div></div>
        <div class="row"><div><label for="step_offset_axis">Offset axis</label><select id="step_offset_axis"><option value="horizontal">Horizontal</option><option value="vertical">Vertical</option></select></div><div><label for="step_offset_mm">Offset (mm, 0 = bar diameter)</label><input id="step_offset_mm" type="number" step="any" required></div></div>
        </div>
      HTML
    end

    def step_z_existing?(entity)
      entity.is_a?(Sketchup::Group) && entity.get_attribute("Basegrid", "tool_id") == STEP_Z_TOOL_ID
    end

    def resolve_step_z(input)
      base, bindings = resolve(input.select { |key, _| %w[diameter_mm bar_material].include?(key) }.merge("mode" => "straight"))
      settings = base.merge(step_z_defaults).merge(input.select { |key, _| step_z_defaults.key?(key) })
      %w[step_upper_mm step_lower_mm step_offset_mm].each do |key|
        value = Float(settings[key])
        raise "Invalid step dimension." unless value.finite? && (key == "step_offset_mm" || value >= 0)
        settings[key] = value
      end
      %w[step_upper_direction step_lower_direction].each do |key|
        raise "Invalid step crank direction." unless %w[in out].include?(settings[key])
      end
      raise "Invalid step offset axis." unless %w[horizontal vertical].include?(settings["step_offset_axis"])
      [settings.merge("mode" => "step_z", "chairs" => false, "caps" => false), bindings]
    end

    def start_step_z(input, model, replace: nil)
      settings, = resolve_step_z(input)
      raise "The editing context is locked." if Array(model.active_path).any?(&:locked?)
      if replace
        metadata = JSON.parse(replace.get_attribute("Basegrid", "parameters_json"))
        transform = model.edit_transform * replace.transformation
        pairs = metadata.fetch("pairs").map do |pair|
          pair.transform_values { |candidate| transform_step_candidate(candidate, transform) }
        end
        build_step_z(model, pairs, settings, replace: replace)
      else
        selected = model.selection.to_a.select { |entity| step_container?(entity) }
        candidates = selected.map { |entity| step_candidate(entity, model.edit_transform * entity.transformation) }
        if selected.length == 2 && candidates.all?
          build_step_z(model, [{ "upper" => candidates[0], "lower" => candidates[1] }], settings)
        else
          model.select_tool(StepZPicker.new(self, model, settings))
        end
      end
      Sketchup.write_default("Basegrid", "starter_bar_settings", JSON.generate(settings))
    end

    def step_container?(entity)
      entity.is_a?(Sketchup::Group) || entity.is_a?(Sketchup::ComponentInstance)
    end

    def transform_step_candidate(candidate, transform)
      { "ends" => candidate.fetch("ends").map { |p| point(p).transform(transform).to_a.map { |v| v*25.4 } } }
    end

    # Gather the picked leaf's geometry in world coordinates, including nested transforms.
    def step_candidate(entity, transform)
      points = []
      walk = lambda do |container, frame, depth|
        raise "The picked bar is too deeply nested." if depth > 16
        entities = container.is_a?(Sketchup::Group) ? container.entities : container.definition.entities
        entities.each do |child|
          if child.is_a?(Sketchup::Edge)
            points << child.start.position.transform(frame).to_a.map { |v| v*25.4 }
            points << child.end.position.transform(frame).to_a.map { |v| v*25.4 }
          elsif step_container?(child)
            walk.call(child, frame * child.transformation, depth+1)
          end
          raise "Pick an individual bar, not a whole assembly." if points.length > 20_000
        end
      end
      walk.call(entity, transform, 0)
      StepZGeometry.candidate(points.uniq)
    end

    def build_step_z(model, pairs, input, replace: nil)
      raise "The active model has changed." unless model == Sketchup.active_model
      raise "The editing context is locked." if Array(model.active_path).any?(&:locked?)
      raise "The original group is unavailable or locked." if replace && (!replace.valid? || replace.locked?)
      settings, bindings = resolve_step_z(input)
      plans = pairs.map { |pair| StepZGeometry.plan(pair, settings) }
      model.start_operation("Create Step Z Bars", true)
      started = true
      root = model.active_entities.add_group
      root.name = "Starter Step Z Bars"
      root.layer = model.layers[0]
      root.transformation = model.edit_transform.inverse
      root.set_attribute("Basegrid", "tool_id", STEP_Z_TOOL_ID)
      root.set_attribute("Basegrid", "parameters_json", JSON.generate(settings: settings, pairs: pairs))
      plans.each_with_index do |points, index|
        bar = root.entities.add_group
        bar.name = format("Step Z Bar %03d", index+1)
        add_bar(bar.entities, points, settings["diameter_mm"])
        length = points.each_cons(2).sum { |a, b| Math.sqrt(a.zip(b).sum { |x, y| (x-y)**2 }) }/1000
        decorate(model, bar, "bar", bindings["bar"], length)
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

    class StepZPicker
      def initialize(owner, model, settings)
        @owner, @model, @settings = owner, model, settings
        @context = model.active_path&.dup
      end

      def activate
        @active = true
        prompt
      end

      def deactivate(view)
        @active = false
        @deactivated = true
        view.invalidate
      end

      def onCancel(_reason, view)
        @upper = nil
        @active = false
        view.invalidate
        UI.start_timer(0, false) { @model.select_tool(nil) unless @deactivated || @model != Sketchup.active_model }
      end

      def onMouseMove(_flags, x, y, view)
        return if @busy || !@active
        @hover = picked(x, y, view)
        view.tooltip = @hover ? (@upper ? "Bottom bar" : "Top bar") : "Pick an individual bar"
        view.invalidate
      end

      def draw(view)
        return if @busy || !@active
        [@upper, @hover].compact.each do |item|
          view.drawing_color = item.equal?(@upper) ? "Green" : "Orange"
          view.line_width = 4
          view.draw(GL_LINES, item[:candidate].fetch("ends").map { |p| @owner.point(p) })
        end
      end

      def onLButtonDown(_flags, x, y, view)
        return if @busy || !@active
        item = picked(x, y, view)
        return unless item
        unless @upper
          @upper = item
          prompt
          view.invalidate
          return
        end
        if item[:path] == @upper[:path]
          Sketchup.set_status_text("Pick a different bottom bar.")
          return
        end
        pair = { "upper" => @upper[:candidate], "lower" => item[:candidate] }
        StepZGeometry.plan(pair, @settings)
        @busy = true
        UI.start_timer(0, false) do
          begin
            next unless @active && @model == Sketchup.active_model && @context == @model.active_path
            raise "A picked bar is no longer available." unless [@upper, item].all? { |pick| pick[:path].all?(&:valid?) }
            @owner.build_step_z(@model, [pair], @settings)
            @upper = @hover = nil
            prompt
          rescue StandardError => e
            Sketchup.set_status_text("Step Z bars: #{e.message}")
          ensure
            @busy = false
            view.invalidate if @active
          end
        end
      rescue StandardError => e
        Sketchup.set_status_text("Step Z bars: #{e.message}")
      end

      def prompt
        Sketchup.set_status_text(@upper ? "Step Z bars: pick bottom bar. Esc to finish." : "Step Z bars: pick top bar. Esc to finish.")
      end

      def picked(x, y, view)
        picker = view.pick_helper
        picker.do_pick(x, y)
        picker.count.times do |index|
          path = picker.path_at(index).to_a
          leaf = path.rindex { |entity| @owner.step_container?(entity) }
          next unless leaf
          containers = path[0..leaf].select { |entity| @owner.step_container?(entity) }
          transform = containers.reduce(@model.edit_transform) { |frame, entity| frame * entity.transformation }
          candidate = @owner.step_candidate(containers.last, transform)
          return { path: containers, candidate: candidate } if candidate
        end
        nil
      rescue StandardError
        nil
      end
    end
  end

  module StepZGeometry
    module_function

    def candidate(points)
      return nil if points.length < 2
      center = 3.times.map { |i| points.sum { |p| p[i] }/points.length.to_f }
      xx = points.sum { |p| (p[0]-center[0])**2 }
      yy = points.sum { |p| (p[1]-center[1])**2 }
      xy = points.sum { |p| (p[0]-center[0])*(p[1]-center[1]) }
      angle = Math.atan2(2*xy, xx-yy)/2
      axis = [Math.cos(angle), Math.sin(angle), 0]
      extent = points.map { |p| (p[0]-center[0])*axis[0] + (p[1]-center[1])*axis[1] }.minmax
      return nil if extent[1]-extent[0] < 1
      { "ends" => extent.map { |distance| center.zip(axis).map { |v, d| v+d*distance } } }
    end

    def plan(pair, settings)
      candidates = %w[upper lower].map do |key|
        ends = pair.fetch(key).fetch("ends")
        raise "Invalid picked bar geometry." unless ends.is_a?(Array) && ends.length == 2 && ends.all? { |p| p.is_a?(Array) && p.length == 3 && p.all? { |n| n.is_a?(Numeric) && n.finite? } }
        { ends: ends, center: ends[0].zip(ends[1]).map { |a, b| (a+b)/2 } }
      end
      lower, upper = candidates.sort_by { |item| item[:center][2] }
      rise = upper[:center][2]-lower[:center][2]
      raise "Picked bars need at least 1 mm of vertical separation." if rise < 1
      delta = upper[:ends][1].zip(upper[:ends][0]).map { |a, b| a-b }
      length = Math.hypot(delta[0], delta[1])
      raise "The upper bar needs a horizontal run." if length < 1
      tangent = [delta[0]/length, delta[1]/length, 0]
      perpendicular = [-tangent[1], tangent[0], 0]
      anchor = upper[:ends].min_by { |p| p.zip(lower[:center]).sum { |a, b| (a-b)**2 } }
      offset = settings.fetch("step_offset_mm")
      axis = settings["step_offset_axis"] == "vertical" ? [0, 0, 1] : perpendicular
      if offset.abs < 0.5
        side = upper[:center].zip(lower[:center], perpendicular).sum { |a, b, d| (a-b)*d }
        offset = settings.fetch("diameter_mm") * (settings["step_offset_axis"] == "horizontal" && side < 0 ? -1 : 1)
      end
      top = anchor.zip(axis).map { |p, d| p+d*offset }
      bottom = [top[0], top[1], top[2]-rise]
      upper_sign = settings["step_upper_direction"] == "in" ? 1 : -1
      lower_sign = settings["step_lower_direction"] == "in" ? 1 : -1
      points = [bottom.zip(tangent).map { |p, d| p+d*settings.fetch("step_lower_mm")*lower_sign },
                bottom, top, top.zip(tangent).map { |p, d| p+d*settings.fetch("step_upper_mm")*upper_sign }]
      points.chunk_while { |a, b| a == b }.map(&:first)
    end
  end
end
