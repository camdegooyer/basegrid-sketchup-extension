# frozen_string_literal: true

require_relative "footing_pier_layout"

module Basegrid
  # Pure millimetre geometry. A cell decomposition computes the union, so steps
  # and junctions never add intersecting concrete volumes to the takeoff.
  module StripFootingGeometry
    TOLERANCE = 0.01
    MAX_CELLS = 150_000
    DEFAULTS = {
      "width_mm" => 450.0, "depth_mm" => 450.0, "alignment" => "center",
      "vertical_reference" => "top", "step_overlap_mm" => nil, "step_height_mm" => 200.0,
      "reinforcement" => "top_bottom", "bar_count" => 3, "bar_spacing_mm" => 100.0,
      "double_mesh" => "none",
      "bar_diameter_mm" => 12.0, "cross_diameter_mm" => 8.0,
      "cross_spacing_mm" => 300.0, "cover_mm" => 50.0,
      "support_spacing_mm" => 900.0, "support_width_mm" => 10.0,
      "support_first_offset_mm" => 200.0, "spacer_diameter_mm" => 6.0,
      "include_step_z_bars" => false, "step_z_threshold_mm" => 200.0, "step_z_diameter_mm" => 12.0,
      "include_piers" => false, "pier_spacing_mm" => 1800.0, "piers_at_corners" => true,
      "piers_at_intersections" => true, "piers_even_spacing" => true,
      "pier_diameter_mm" => 450.0, "pier_depth_mm" => 600.0, "pier_add_bar" => false,
      "pier_bar_below_mm" => nil, "pier_bar_above_mm" => nil, "pier_bar_cog_mm" => nil,
      "spacer_pair_offset_mm" => 7.0, "spacer_height_mm" => nil
    }.freeze
    module_function

    def settings(raw)
      raise "Settings must be an object." unless raw.is_a?(Hash)
      # 0.3.0 saddle member thickness has no meaning for rectangular supports.
      raw = raw.reject { |key, _| key == "support_thickness_mm" }
      unknown = raw.keys - DEFAULTS.keys
      raise "Unknown footing settings: #{unknown.join(', ')}" unless unknown.empty?
      values = DEFAULTS.merge(raw).merge("cover_mm" => 50.0)
      values["step_overlap_mm"] = Float(values["depth_mm"]) * 1.5 if values["step_overlap_mm"].nil?
      values["pier_bar_below_mm"] = [Float(values["pier_depth_mm"]) - 100,0].max if values["pier_bar_below_mm"].nil?
      values["pier_bar_above_mm"] = Float(values["depth_mm"]) / 2 if values["pier_bar_above_mm"].nil?
      values["pier_bar_cog_mm"] = [Float(values["width_mm"]) / 2 - 50,0].max if values["pier_bar_cog_mm"].nil?
      %w[include_step_z_bars include_piers piers_at_corners piers_at_intersections piers_even_spacing pier_add_bar].each do |key|
        raise "#{key} must be true or false." unless [true, false].include?(values[key])
      end
      DEFAULTS.each do |key, default|
        next unless default.is_a?(Numeric) || key == "step_overlap_mm" || key.start_with?("pier_bar_") || (key == "spacer_height_mm" && !values[key].nil?)
        values[key] = Float(values[key])
        valid = %w[step_z_threshold_mm pier_bar_cog_mm pier_bar_below_mm].include?(key) ? values[key] >= 0 : values[key].positive?
        raise "#{key} must be finite and #{key == 'step_z_threshold_mm' ? 'non-negative' : 'greater than zero'}." unless values[key].finite? && valid
      end
      raise "Bar count must be 3 or 4." unless [3, 4].include?(values["bar_count"])
      { "alignment" => %w[center left_edge right_edge],
        "vertical_reference" => %w[top bottom], "reinforcement" => %w[none bottom top_bottom],
        "double_mesh" => %w[none top bottom top_bottom] }.each do |key, choices|
        raise "Invalid #{key}." unless choices.include?(values[key])
      end
      values
    rescue ArgumentError, TypeError
      raise "Footing dimensions must be numbers."
    end

    def plan(paths, raw_settings = {})
      s = settings(raw_settings)
      raise "Provide one or more paths." unless paths.is_a?(Array) && paths.any? && paths.length <= 50
      segments = []
      boxes = []
      steps = []
      paths.each do |path|
        raise "Each path needs 2–100 points." unless path.is_a?(Array) && (2..100).cover?(path.length)
        points = path.map { |point| normalize_point(point) }
        runs = points.each_cons(2).map do |a, b|
          dx, dy = b[0] - a[0], b[1] - a[1]
          raise "Use horizontal runs; add height changes with Step from Last Point." if (b[2] - a[2]).abs > TOLERANCE
          length = Math.hypot(dx, dy)
          raise "Each run must be longer than 1 mm." unless length > 1.0
          direction = [dx / length, dy / length]
          bottom = s["vertical_reference"] == "top" ? a[2] - s["depth_mm"] : a[2]
          { a: a, b: b, direction: direction, side: [-direction[1], direction[0]], length: length,
            bottom: bottom, top: bottom + s["depth_mm"] }
        end
        segments.concat(runs)
      end
      raise "Use at most 100 runs per assembly." if segments.length > 100
      width = s["width_mm"]
      center = { "center" => 0.0, "left_edge" => -width / 2, "right_edge" => width / 2 }.fetch(s["alignment"])
      segments.each do |run|
        run[:center] = center
        boxes << run_box(run, 0, run[:length], center - width / 2, center + width / 2, run[:bottom], run[:top])
      end
      # Complete the outer quarter of a same-level right-angle corner. Endpoints
      # can belong to different paths, as with a branch added during drawing.
      segments.combination(2) do |a, b|
        if parallel?(a, b)
          if ((b[:a][0]-a[:a][0])*a[:side][0] + (b[:a][1]-a[:a][1])*a[:side][1]).abs <= TOLERANCE
            a_range = [0, a[:length]]
            b_range = [b[:a], b[:b]].map { |p| (p[0]-a[:a][0])*a[:direction][0] + (p[1]-a[:a][1])*a[:direction][1] }.sort
            overlap = [a_range[1], b_range[1]].min - [a_range[0], b_range[0]].max
            raise "Paths retrace the same run; remove the overlapping segment." if overlap > TOLERANCE
          end
        end
        joint = endpoint_joint(a, b)
        next unless joint
        height = (a[:bottom] - b[:bottom]).abs
        if height > TOLERANCE
          raise "Step height must be less than footing depth." if height >= s["depth_mm"] - TOLERANCE
          raise "Put the step on a straight run, away from the corner." unless parallel?(a, b)
          high = a[:bottom] > b[:bottom] ? a : b
          low = high.equal?(a) ? b : a
          steps << { high: high, low: low, joint: joint, height: height }
          host = s["vertical_reference"] == "top" ? high : low
          overlap = s["step_overlap_mm"]
          raise "Step overlap exceeds its adjoining run; lengthen the run or reduce overlap." if overlap > host[:length] + TOLERANCE
          at_start = same_xy?(joint, host[:a])
          from, to = at_start ? [0, overlap] : [host[:length] - overlap, host[:length]]
          z0, z1 = s["vertical_reference"] == "top" ? [low[:bottom], high[:bottom]] : [low[:top], high[:top]]
          lap_box = run_box(host, from, to, center - width / 2, center + width / 2, z0, z1)
          boxes << lap_box
        elsif !parallel?(a, b)
          # Intersection of the two infinite strips gives a complete corner for
          # centre and edge alignments, regardless of path direction.
          aa = run_box(a, -width, a[:length] + width, center - width / 2, center + width / 2, a[:bottom], a[:top])
          bb = run_box(b, -width, b[:length] + width, center - width / 2, center + width / 2, b[:bottom], b[:top])
          if aa.is_a?(Hash) || bb.is_a?(Hash)
            polygon = footprint(aa)[:polygon]
            footprint(bb)[:polygon].each_with_index do |p, i|
              q = footprint(bb)[:polygon][(i+1)%4]
              polygon = clip_polygon(polygon, p, q)
            end
            boxes << { polygon: polygon, bottom: a[:bottom], top: a[:top] } if polygon.length >= 3
          else
            boxes << [3.times.map { |i| [aa[0][i], bb[0][i]].max }, 3.times.map { |i| [aa[1][i], bb[1][i]].min }]
          end
        end
      end
      surface = union(boxes)
      parts = [surface.merge(name: "Joined Concrete")]
      reinforcement = steel(segments, s, steps)
      z_bars = step_z_bars(steps, segments, reinforcement[:layers], s)
      piers = FootingPierLayout.plan(segments,s)
      piers.each do |pier|
        # A pier beside a step stops at the lowest concrete underside touched
        # by its footprint, so pier and footing takeoff never overlap.
        touched = boxes.map { |box| footprint(box) }.select do |solid|
          polygon = solid[:polygon];p = pier[:top]
          inside = polygon.each_with_index.all? { |a,i| b=polygon[(i+1)%polygon.length]; (b[0]-a[0])*(p[1]-a[1])-(b[1]-a[1])*(p[0]-a[0]) >= -TOLERANCE }
          inside || polygon.each_with_index.any? do |a,i|
            b=polygon[(i+1)%polygon.length];dx,dy=b[0]-a[0],b[1]-a[1]
            fraction = [[((p[0]-a[0])*dx+(p[1]-a[1])*dy)/(dx*dx+dy*dy),0].max,1].min
            Math.hypot(p[0]-a[0]-fraction*dx,p[1]-a[1]-fraction*dy) < s["pier_diameter_mm"]/2-TOLERANCE
          end
        end
        pier[:top][2] = touched.map { |solid| solid[:bottom] }.min || pier[:top][2]
      end
      warnings = []
      if s["reinforcement"] != "none"
        warnings << "Supports and spacer pairs are dimensioned representations, not manufacturer product replicas."
        warnings << "Perpendicular mesh junctions use stacked straight runs; other corners and steps retain square ends. Bends, hooks and lapped splices are not modelled." if segments.length > 1
      end
      surface.merge(settings: s, segments: segments, steps: steps, concrete_parts: parts, mesh_layers: reinforcement[:layers], bars: reinforcement[:bars], z_bars: z_bars, piers: piers,
                    chairs: reinforcement[:chairs], spacers: reinforcement[:spacers],
                    mesh_length_m: reinforcement[:mesh_length_m], warnings: warnings)
    end

    def prism(bottom, top_z, name)
      area = bottom.each_with_index.sum { |p, i| q=bottom[(i+1)%bottom.length]; p[0]*q[1]-q[0]*p[1] } / 2.0
      return { name: name, faces: [], volume_m3: -1 } if area <= 0
      top = bottom.map { |p| [p[0], p[1], top_z] }
      faces = [bottom.reverse, top]
      bottom.each_index { |i| j=(i+1)%bottom.length; faces << [bottom[i], bottom[j], top[j], top[i]] }
      { name: name, faces: faces, volume_m3: area * (top_z-bottom[0][2]) / 1e9 }
    end

    def normalize_point(point)
      raise "Each point must contain three coordinates in mm." unless point.is_a?(Array) && point.length == 3
      point.map do |v|
        number = Float(v)
        raise "Coordinates must be finite and within 1 km of the origin." unless number.finite? && number.abs <= 1_000_000
        number.round(4)
      end
    rescue ArgumentError, TypeError
      raise "Coordinates must be numbers."
    end

    # A run terminating at a perpendicular run at the same level carries its
    # mesh through the junction to the far face of that run's outermost
    # longitudinal bar. Returns nil where the end is free and takes end cover.
    def junction_reach(run, segments, index, side, lap)
      vertex = side == :start ? run[:a] : run[:b]
      other = segments.each_with_index.find do |candidate, other_index|
        other_index != index && (candidate[:bottom] - run[:bottom]).abs <= TOLERANCE &&
          perpendicular?(run, candidate) && on_centreline?(candidate, vertex)
      end
      return nil unless other
      centre = other.first
      along = (centre[:a][0] + centre[:side][0] * centre[:center] - run[:a][0]) * run[:direction][0] +
              (centre[:a][1] + centre[:side][1] * centre[:center] - run[:a][1]) * run[:direction][1]
      side == :start ? along - lap : along + lap
    end

    def on_centreline?(run, point)
      along = (point[0] - run[:a][0]) * run[:direction][0] + (point[1] - run[:a][1]) * run[:direction][1]
      lateral = (point[0] - run[:a][0]) * run[:side][0] + (point[1] - run[:a][1]) * run[:side][1]
      lateral.abs <= TOLERANCE && along >= -TOLERANCE && along <= run[:length] + TOLERANCE
    end

    def same_xy?(a, b)
      (a[0] - b[0]).abs <= TOLERANCE && (a[1] - b[1]).abs <= TOLERANCE
    end

    def endpoint_joint(a, b)
      [a[:a], a[:b]].find { |p| [b[:a], b[:b]].any? { |q| same_xy?(p, q) } }
    end

    def perpendicular?(a, b)
      (a[:direction][0] * b[:direction][0] + a[:direction][1] * b[:direction][1]).abs < TOLERANCE
    end

    def parallel?(a, b)
      (a[:direction][0] * b[:direction][1] - a[:direction][1] * b[:direction][0]).abs < 1e-7
    end

    def point(run, station, offset, z)
      [run[:a][0] + run[:direction][0] * station + run[:side][0] * offset,
       run[:a][1] + run[:direction][1] * station + run[:side][1] * offset, z]
    end

    def run_box(run, from, to, left, right, bottom, top)
      if run[:direction].all? { |v| v.abs > 1e-9 }
        polygon = [[from,left], [to,left], [to,right], [from,right]].map { |station, offset| point(run, station, offset, bottom).first(2) }
        return { polygon: polygon, bottom: bottom, top: top }
      end
      p = point(run, from, left, bottom)
      q = point(run, to, right, top)
      [3.times.map { |i| [p[i], q[i]].min }, 3.times.map { |i| [p[i], q[i]].max }]
    end

    def union(boxes)
      return polygon_union(boxes.map { |box| footprint(box) }) if boxes.any? { |box| box.is_a?(Hash) }
      axes = 3.times.map { |i| boxes.flat_map { |box| [box[0][i].round(4), box[1][i].round(4)] }.uniq.sort }
      count = axes.map { |axis| axis.length - 1 }.inject(:*)
      raise "This assembly is too complex; split it into smaller footings." if count > MAX_CELLS
      occupied = {}
      boxes.each do |lo, hi|
        ranges = 3.times.map { |i| axes[i].index(lo[i].round(4))...axes[i].index(hi[i].round(4)) }
        ranges[0].each { |x| ranges[1].each { |y| ranges[2].each { |z| occupied[[x, y, z]] = true } } }
      end
      raise "No concrete volume was generated." if occupied.empty?
      directions = [[-1, 0, 0], [1, 0, 0], [0, -1, 0], [0, 1, 0], [0, 0, -1], [0, 0, 1]]
      pending = [occupied.keys.first]
      seen = { pending.first => true }
      until pending.empty?
        cell = pending.pop
        directions.each do |delta|
          neighbor = 3.times.map { |i| cell[i] + delta[i] }
          next unless occupied[neighbor] && !seen[neighbor]
          seen[neighbor] = true
          pending << neighbor
        end
      end
      raise "Paths must form one connected footing; separate disconnected runs." unless seen.length == occupied.length
      faces = []
      volume = 0.0
      occupied.each_key do |cell|
        lo = 3.times.map { |i| axes[i][cell[i]] }
        hi = 3.times.map { |i| axes[i][cell[i] + 1] }
        volume += 3.times.map { |i| hi[i] - lo[i] }.inject(:*)
        x, y, z = lo
        xx, yy, zz = hi
        sides = [
          [[x,y,z], [x,y,zz], [x,yy,zz], [x,yy,z]],
          [[xx,y,z], [xx,yy,z], [xx,yy,zz], [xx,y,zz]],
          [[x,y,z], [xx,y,z], [xx,y,zz], [x,y,zz]],
          [[x,yy,z], [x,yy,zz], [xx,yy,zz], [xx,yy,z]],
          [[x,y,z], [x,yy,z], [xx,yy,z], [xx,y,z]],
          [[x,y,zz], [xx,y,zz], [xx,yy,zz], [x,yy,zz]]
        ]
        directions.each_with_index do |delta, index|
          neighbor = 3.times.map { |i| cell[i] + delta[i] }
          faces << sides[index] unless occupied[neighbor]
        end
      end
      { faces: faces, volume_m3: volume / 1_000_000_000.0 }
    end

    def footprint(box)
      return box if box.is_a?(Hash)
      lo, hi = box
      { polygon: [[lo[0],lo[1]], [hi[0],lo[1]], [hi[0],hi[1]], [lo[0],hi[1]]], bottom: lo[2], top: hi[2] }
    end

    def clip_polygon(polygon, a, b)
      result = []
      polygon.each_with_index do |p, i|
        q = polygon[(i+1)%polygon.length]
        dp = (b[0]-a[0])*(p[1]-a[1]) - (b[1]-a[1])*(p[0]-a[0])
        dq = (b[0]-a[0])*(q[1]-a[1]) - (b[1]-a[1])*(q[0]-a[0])
        result << p if dp >= -1e-7
        if (dp > 1e-7 && dq < -1e-7) || (dp < -1e-7 && dq > 1e-7)
          t = dp / (dp-dq)
          result << [p[0]+t*(q[0]-p[0]), p[1]+t*(q[1]-p[1])]
        end
      end
      result
    end

    # Partition the XY plane at every footprint boundary, then extrude occupied
    # cells between levels. Shared faces cancel, preserving net volumes at joins.
    def polygon_union(solids)
      points = solids.flat_map { |solid| solid[:polygon] }
      xs, ys = points.transpose
      cells = [[[xs.min,ys.min], [xs.max,ys.min], [xs.max,ys.max], [xs.min,ys.max]]]
      lines = solids.flat_map { |solid| p = solid[:polygon]; p.each_index.map { |i| [p[i], p[(i+1)%p.length]] } }
      lines.each do |a, b|
        cells = cells.flat_map do |cell|
          distances = cell.map { |p| (b[0]-a[0])*(p[1]-a[1]) - (b[1]-a[1])*(p[0]-a[0]) }
          if distances.min < -1e-7 && distances.max > 1e-7
            [clip_polygon(cell,a,b), clip_polygon(cell,b,a)].select { |p| p.length >= 3 }
          else
            [cell]
          end
        end
        raise "This assembly is too complex; split it into smaller footings." if cells.length > 10_000
      end
      levels = solids.flat_map { |solid| [solid[:bottom], solid[:top]] }.uniq.sort
      raise "This assembly is too complex; split it into smaller footings." if cells.length * levels.length > MAX_CELLS
      faces, neighbors = {}, Hash.new { |h,k| h[k] = [] }
      volume, count = 0.0, 0
      cells.each do |cell|
        cell = cell.map { |p| p.map { |v| v.round(6) } }.uniq
        next if cell.length < 3
        center = 2.times.map { |i| cell.sum { |p| p[i] } / cell.length }
        covering = solids.select do |solid|
          p = solid[:polygon]
          p.each_index.all? { |i| a=p[i]; b=p[(i+1)%p.length]; (b[0]-a[0])*(center[1]-a[1]) - (b[1]-a[1])*(center[0]-a[0]) >= -1e-5 }
        end
        levels.each_cons(2) do |bottom, top|
          next unless covering.any? { |solid| solid[:bottom] <= bottom && solid[:top] >= top }
          part = prism(cell.map { |p| [*p,bottom] }, top, "cell")
          next unless part[:volume_m3] > 1e-14
          id = count
          count += 1
          volume += part[:volume_m3]
          part[:faces].each do |face|
            key = face.sort
            if faces.key?(key)
              other = faces.delete(key)[1]
              neighbors[id] << other
              neighbors[other] << id
            else
              faces[key] = [face,id]
            end
          end
        end
      end
      raise "No concrete volume was generated." if count.zero?
      seen, pending = {}, [0]
      until pending.empty?
        id = pending.pop
        next if seen[id]
        seen[id] = true
        pending.concat(neighbors[id])
      end
      raise "Paths must form one connected footing; separate disconnected runs." unless seen.length == count
      { faces: faces.values.map(&:first), volume_m3: volume }
    end

    def mesh_strip_offsets(s, layer)
      doubled = s["double_mesh"] == "top_bottom" || s["double_mesh"] == layer.downcase
      return [0.0] unless doubled
      half_mesh = (s["bar_count"] - 1) * s["bar_spacing_mm"] / 2
      radius = s["bar_diameter_mm"] / 2
      inset = [radius, s["cross_diameter_mm"] / 2, s["spacer_diameter_mm"] / 2].max
      offset = s["width_mm"] / 2 - s["cover_mm"] - inset - half_mesh
      raise "Double mesh does not fit the footing width and 50 mm cover." if offset < -TOLERANCE
      gap = 2 * offset - 2 * half_mesh - 2 * radius
      raise "Double mesh leaves more than 100 mm clear between strips; select wider mesh or revise the footing." if gap > 100 + TOLERANCE
      [-offset, offset]
    end

    def steel(segments, s, steps = [])
      result = { bars: [], layers: [], chairs: [], spacers: [], mesh_length_m: 0.0 }
      return result if s["reinforcement"] == "none"
      radius = s["bar_diameter_mm"] / 2
      cross_radius = s["cross_diameter_mm"] / 2
      cover = s["cover_mm"]
      half_mesh = (s["bar_count"] - 1) * s["bar_spacing_mm"] / 2
      extent = [radius, cross_radius, s["spacer_diameter_mm"] / 2].max
      raise "Mesh does not fit the footing width and clear cover." if half_mesh + extent + cover > s["width_mm"] / 2
      layer_depth = 2 * radius + 2 * cross_radius
      strip_offsets = { "Bottom" => mesh_strip_offsets(s, "Bottom") }
      strip_offsets["Top"] = mesh_strip_offsets(s, "Top") if s["reinforcement"] == "top_bottom"
      lapped = strip_offsets.transform_values { |offsets| offsets.length == 2 && offsets.last - offsets.first <= 2 * half_mesh + 2 * extent }
      mesh_depth = layer_depth * (lapped.values.any? ? 2 : 1)
      # Runs on one axis keep nominal cover; runs on the other stack one mesh
      # depth above them, so meshes carried through a junction sit on each
      # other instead of intersecting.
      directions = []
      lifts = segments.map do |run|
        index = directions.index { |other| parallel?(run, other) }
        unless index
          index = directions.length
          directions << run
        end
        index * mesh_depth
      end
      layers_per_run = s["reinforcement"] == "top_bottom" ? 2 : 1
      required = (2 * cover + mesh_depth * layers_per_run) + lifts.max * layers_per_run
      raise "Mesh layers do not fit the depth and clear cover." if required >= s["depth_mm"]
      lap = half_mesh + radius + strip_offsets.values.flatten.map(&:abs).max
      raise "Spacer pair bars must not overlap." if s["spacer_pair_offset_mm"] * 2 < s["spacer_diameter_mm"]
      estimated_bars = segments.sum { |run| (run[:length] / s["cross_spacing_mm"]).ceil + s["bar_count"] }
      estimated_bars *= 2 if s["reinforcement"] == "top_bottom"
      estimated_bars *= 2 if strip_offsets.values.any? { |offsets| offsets.length == 2 }
      estimated_supports = segments.sum { |run| (run[:length] / s["support_spacing_mm"]).ceil + 1 }
      estimated_supports *= strip_offsets.values.flatten.uniq.length
      raise "Too much reinforcement; increase spacing or shorten the assembly." if estimated_bars > 20_000 || estimated_supports > 2_000
      segments.each_with_index do |run, index|
        lift = lifts[index]
        from = junction_reach(run, segments, index, :start, lap) || cover
        to = junction_reach(run, segments, index, :end, lap) || run[:length] - cover
        steps.each do |step|
          extended = s["vertical_reference"] == "top" ? step[:low] : step[:high]
          next unless extended.equal?(run)
          if same_xy?(step[:joint], run[:a])
            from = cover - s["step_overlap_mm"]
          else
            to = run[:length] + s["step_overlap_mm"] - cover
          end
        end
        raise "Run #{index + 1} is too short for the specified end cover." if to <= from
        heights = [["Bottom", run[:bottom] + cover + radius + lift, 1]]
        heights << ["Top", run[:top] - cover - radius - lift, -1] if s["reinforcement"] == "top_bottom"
        heights.each do |name, z, direction|
          strip_offsets.fetch(name).each_with_index do |strip_offset, strip_index|
          strip_z = z + (lapped[name] ? direction * strip_index * layer_depth : 0)
          longitudinal = s["bar_count"].to_i.times.map do |i|
            offset = run[:center] + strip_offset - half_mesh + i * s["bar_spacing_mm"]
            bar(point(run, from, offset, strip_z), point(run, to, offset, strip_z), radius * 2)
          end
          cross_bars = []
          station = from + s["cross_spacing_mm"]
          while station <= to - cross_radius
            z_cross = strip_z + direction * (radius + cross_radius)
            cross_bars << bar(point(run, station, run[:center] + strip_offset - half_mesh, z_cross), point(run, station, run[:center] + strip_offset + half_mesh, z_cross), cross_radius * 2)
            station += s["cross_spacing_mm"]
          end
          layer_name = format("%s Mesh %02d", name, index+1)
          layer_name += format(" Strip %02d", strip_index+1) if strip_offsets[name].length == 2
          result[:layers] << { segment_index: index, name: layer_name,
                              longitudinal: longitudinal, cross_bars: cross_bars,
                              primary_index: s["bar_count"].to_i / 2, length_m: (to-from)/1000.0 }
          result[:bars].concat(longitudinal + cross_bars)
          result[:mesh_length_m] += (to - from) / 1000.0
          end
        end
        w = s["support_width_mm"] / 2
        first = from + [s["support_first_offset_mm"], w].max
        last = to - w
        # Short runs get one centred support if it fits; cover is never reduced.
        stations = []
        if first > last
          raise "Run #{index+1} is too short for a mesh support." if to-from < 2*w
          stations << (from+to)/2
        else
          station = first
          while station <= last
            stations << station
            station += s["support_spacing_mm"]
          end
        end
        stations.each do |station|
          strip_offsets.values.flatten.uniq.each do |strip_offset|
          result[:chairs] << { segment_index: index,
            origin: point(run, station, run[:center]+strip_offset, run[:bottom]), direction: run[:direction],
            width_mm: 2*w, length_mm: 2*half_mesh, height_mm: 50.0 }
          next unless heights.length == 2
          lower = heights[0][1] + radius
          upper = heights[1][1] - radius
          if s["spacer_height_mm"]
            raise "Selected Bogar spacer is too tall for the footing and 50 mm cover." if s["spacer_height_mm"] > s["depth_mm"] - 2*cover + TOLERANCE
            lower = run[:bottom] + cover
            upper = lower + s["spacer_height_mm"]
          end
          [-half_mesh, half_mesh].each do |offset|
            pair_offset = s["spacer_pair_offset_mm"]
            pair_radius = s["spacer_diameter_mm"] / 2
            next if station-pair_offset-pair_radius < from || station+pair_offset+pair_radius > to
            bars = [-pair_offset, pair_offset].map do |delta|
              bar(point(run, station+delta, run[:center]+strip_offset+offset, lower),
                  point(run, station+delta, run[:center]+strip_offset+offset, upper), pair_radius*2)
            end
            result[:spacers] << { segment_index: index, origin: point(run, station, run[:center]+strip_offset+offset, lower),
              direction: run[:direction], diameter_mm: pair_radius*2, pair_offset_mm: pair_offset,
              height_mm: upper-lower, bars: bars }
          end
          end
        end
      end
      result
    end

    def step_z_bars(steps, segments, layers, s)
      return [] unless s["include_step_z_bars"] && s["reinforcement"] != "none"
      diameter = s["step_z_diameter_mm"]
      radius, cover, lap = diameter / 2, s["cover_mm"], diameter * 50
      result = []
      steps.each_with_index do |step, step_index|
        next unless step[:height] > s["step_z_threshold_mm"]
        high, low, joint = step.values_at(:high, :low, :joint)
        sign = same_xy?(joint, high[:a]) ? 1 : -1
        direction = high[:direction].map { |v| v * sign }
        side = [-direction[1], direction[0]]
        origin = s["vertical_reference"] == "top" ? 0 : -s["step_overlap_mm"]
        layers.select { |layer| layer[:segment_index] == segments.index(low) }.each do |lower_layer|
          top_layer = lower_layer[:name].start_with?("Top")
          transverse_center = ->(layer) { layer[:longitudinal].sum { |bar| bar[:a][0]*side[0] + bar[:a][1]*side[1] } / layer[:longitudinal].length }
          upper_layer = layers.select { |layer| layer[:segment_index] == segments.index(high) && layer[:name].start_with?(top_layer ? "Top" : "Bottom") }
            .min_by { |layer| [(transverse_center.call(layer)-transverse_center.call(lower_layer)).abs,
                              ((layer[:longitudinal][0][:a][2]-high[:bottom])-(lower_layer[:longitudinal][0][:a][2]-low[:bottom])).abs] }
          next unless upper_layer
          station = origin + (top_layer ? cover + radius : s["step_overlap_mm"] - cover - radius)
          sorted = [lower_layer, upper_layer].map do |layer|
            layer[:longitudinal].sort_by { |bar| bar[:a][0]*side[0] + bar[:a][1]*side[1] }
          end
          sorted[0].zip(sorted[1]).each do |lower_bar, upper_bar|
            transverse = (lower_bar[:a][0]-joint[0])*side[0] + (lower_bar[:a][1]-joint[1])*side[1]
            upper_transverse = (upper_bar[:a][0]-joint[0])*side[0] + (upper_bar[:a][1]-joint[1])*side[1]
            raise "Step Z bars require aligned adjoining mesh runs." if (transverse-upper_transverse).abs > TOLERANCE
            offset = s["bar_diameter_mm"]/2 + radius + 0.5
            centre = low[:center] * (low[:side][0]*side[0] + low[:side][1]*side[1])
            offset = -offset if (transverse+offset-centre).abs + radius + cover > s["width_mm"]/2 + TOLERANCE
            transverse += offset
            raise "Step Z bars do not fit the footing width and cover." if (transverse-centre).abs + radius + cover > s["width_mm"]/2 + TOLERANCE
            z0 = [[lower_bar[:a][2], low[:bottom]+cover+radius].max, low[:top]-cover-radius].min
            z1 = [[upper_bar[:a][2], high[:bottom]+cover+radius].max, high[:top]-cover-radius].min
            endpoints = [[station-lap,z0],[station,z0],[station,z1],[station+lap,z1]]
            [lower_bar,upper_bar].each_with_index do |bar,index|
              range = [bar[:a],bar[:b]].map { |p| (p[0]-joint[0])*direction[0]+(p[1]-joint[1])*direction[1] }.minmax
              leg = index.zero? ? [station-lap,station] : [station,station+lap]
              raise "Adjoining mesh is too short for the 50-diameter Z-bar lap." if leg[0] < range[0]-TOLERANCE || leg[1] > range[1]+TOLERANCE
            end
            points = endpoints.map { |distance,z| [joint[0]+direction[0]*distance+side[0]*transverse, joint[1]+direction[1]*distance+side[1]*transverse,z] }
            result << { name: format("Step %02d %s Z Bar %02d",step_index+1,top_layer ? "Top" : "Bottom",result.length+1), points: points,
                        diameter: diameter, length_m: (2*lap + z1-z0)/1000.0 }
          end
        end
      end
      result
    end

    def bar(a, b, diameter)
      { a: a, b: b, diameter: diameter }
    end
  end
end
