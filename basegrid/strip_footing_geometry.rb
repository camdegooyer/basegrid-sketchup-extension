# frozen_string_literal: true

module Basegrid
  # Pure millimetre geometry. A cell decomposition computes the union, so steps
  # and junctions never add intersecting concrete volumes to the takeoff.
  module StripFootingGeometry
    TOLERANCE = 0.01
    MAX_CELLS = 150_000
    DEFAULTS = {
      "width_mm" => 450.0, "depth_mm" => 450.0, "alignment" => "center",
      "vertical_reference" => "top", "step_overlap_mm" => 450.0,
      "reinforcement" => "top_bottom", "bar_count" => 3, "bar_spacing_mm" => 100.0,
      "bar_diameter_mm" => 12.0, "cross_diameter_mm" => 8.0,
      "cross_spacing_mm" => 300.0, "cover_mm" => 50.0,
      "support_spacing_mm" => 900.0, "support_width_mm" => 10.0,
      "support_first_offset_mm" => 200.0, "spacer_diameter_mm" => 6.0,
      "spacer_pair_offset_mm" => 7.0
    }.freeze
    module_function

    def settings(raw)
      raise "Settings must be an object." unless raw.is_a?(Hash)
      # 0.3.0 saddle member thickness has no meaning for rectangular supports.
      raw = raw.reject { |key, _| key == "support_thickness_mm" }
      unknown = raw.keys - DEFAULTS.keys
      raise "Unknown footing settings: #{unknown.join(', ')}" unless unknown.empty?
      values = DEFAULTS.merge(raw)
      DEFAULTS.each do |key, default|
        next unless default.is_a?(Numeric)
        values[key] = Float(values[key])
        raise "#{key} must be finite and greater than zero." unless values[key].finite? && values[key].positive?
      end
      raise "Bar count must be 3 or 4." unless [3, 4].include?(values["bar_count"])
      { "alignment" => %w[center left_edge right_edge],
        "vertical_reference" => %w[top bottom], "reinforcement" => %w[none bottom top_bottom] }.each do |key, choices|
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
      step_boxes = []
      paths.each do |path|
        raise "Each path needs 2–100 points." unless path.is_a?(Array) && (2..100).cover?(path.length)
        points = path.map { |point| normalize_point(point) }
        runs = points.each_cons(2).map do |a, b|
          dx, dy = b[0] - a[0], b[1] - a[1]
          raise "Use horizontal X/Y runs; add steps through the base offset control." if (b[2] - a[2]).abs > TOLERANCE
          raise "First version supports X/Y-aligned paths only." unless dx.abs <= TOLERANCE || dy.abs <= TOLERANCE
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
        if !perpendicular?(a, b)
          axis = a[:direction][0].abs > 0.5 ? 0 : 1
          if (a[:a][1-axis] - b[:a][1-axis]).abs <= TOLERANCE
            a_range = [a[:a][axis], a[:b][axis]].sort
            b_range = [b[:a][axis], b[:b][axis]].sort
            overlap = [a_range[1], b_range[1]].min - [a_range[0], b_range[0]].max
            raise "Paths retrace the same run; remove the overlapping segment." if overlap > TOLERANCE
          end
        end
        joint = endpoint_joint(a, b)
        next unless joint
        height = (a[:bottom] - b[:bottom]).abs
        if height > TOLERANCE
          raise "Step height must be less than footing depth." if height >= s["depth_mm"] - TOLERANCE
          raise "Put the step on a straight run, away from the corner." if perpendicular?(a, b)
          high = a[:bottom] > b[:bottom] ? a : b
          low = high.equal?(a) ? b : a
          host = s["vertical_reference"] == "top" ? high : low
          overlap = s["step_overlap_mm"]
          raise "Step overlap exceeds its adjoining run; lengthen the run or reduce overlap." if overlap > host[:length] + TOLERANCE
          at_start = same_xy?(joint, host[:a])
          from, to = at_start ? [0, overlap] : [host[:length] - overlap, host[:length]]
          z0, z1 = s["vertical_reference"] == "top" ? [low[:bottom], high[:bottom]] : [low[:top], high[:top]]
          lap_box = run_box(host, from, to, center - width / 2, center + width / 2, z0, z1)
          boxes << lap_box
          step_boxes << lap_box
        elsif perpendicular?(a, b)
          # Intersection of the two infinite strips gives a complete corner for
          # centre and edge alignments, regardless of path direction.
          aa = run_box(a, -width, a[:length] + width, center - width / 2, center + width / 2, a[:bottom], a[:top])
          bb = run_box(b, -width, b[:length] + width, center - width / 2, center + width / 2, b[:bottom], b[:top])
          boxes << [3.times.map { |i| [aa[0][i], bb[0][i]].max }, 3.times.map { |i| [aa[1][i], bb[1][i]].min }]
        end
      end
      surface = union(boxes)
      parts = concrete_parts(segments, step_boxes, s, surface)
      reinforcement = steel(segments, s)
      warnings = []
      if s["reinforcement"] != "none"
        warnings << "Supports and spacer pairs are dimensioned representations, not manufacturer product replicas."
        warnings << "Mesh runs continue through corners and junctions and stack one mesh depth apart; bends, hooks and lapped splices are not modelled." if segments.length > 1
      end
      surface.merge(settings: s, segments: segments, concrete_parts: parts, mesh_layers: reinforcement[:layers], bars: reinforcement[:bars],
                    chairs: reinforcement[:chairs], spacers: reinforcement[:spacers],
                    mesh_length_m: reinforcement[:mesh_length_m], warnings: warnings)
    end

    def concrete_parts(segments, step_boxes, s, surface)
      parts = segments.map.with_index do |run, index|
        offsets = [run[:center] - s["width_mm"] / 2, run[:center] + s["width_mm"] / 2]
        corners = [[:a, offsets[0]], [:b, offsets[0]], [:b, offsets[1]], [:a, offsets[1]]].map do |endpoint, offset|
          vertex = run[endpoint]
          base = point(run, endpoint == :a ? 0 : run[:length], offset, run[:bottom])
          adjacent = segments.reject { |other| other.equal?(run) }.select do |other|
            (other[:bottom] - run[:bottom]).abs <= TOLERANCE &&
              (same_xy?(other[:a], vertex) || same_xy?(other[:b], vertex))
          end
          next base if adjacent.length != 1 || !perpendicular?(run, adjacent.first)
          other = adjacent.first
          forward = endpoint == :a ? same_xy?(other[:b], vertex) : same_xy?(other[:a], vertex)
          # Edge alignment only has a common offset when the path directions
          # agree; retain the union fallback for differently oriented branches.
          next base unless forward || s["alignment"] == "center"
          direction = other[:direction].map { |v| forward ? v : -v }
          q = [vertex[0] - direction[1] * offset, vertex[1] + direction[0] * offset]
          d = run[:direction]
          determinant = d[0] * direction[1] - d[1] * direction[0]
          distance = ((q[0]-base[0])*direction[1] - (q[1]-base[1])*direction[0]) / determinant
          [base[0] + distance*d[0], base[1] + distance*d[1], run[:bottom]]
        end
        prism(corners, run[:top], format("Footing Segment %02d", index+1))
      end
      step_boxes.each_with_index do |box, index|
        parts << union([box]).merge(name: format("Step Overlap %02d", index+1))
      end
      # Mitered segments partition ordinary runs/loops exactly. Branches and
      # overlapping step regions keep their net union to avoid duplicate solids.
      expected = surface[:volume_m3]
      if parts.any? { |part| part[:volume_m3] <= 0 } || (parts.sum { |part| part[:volume_m3] } - expected).abs > [1e-9, expected*1e-8].max
        return [surface.merge(name: "Joined Concrete")]
      end
      parts
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

    def point(run, station, offset, z)
      [run[:a][0] + run[:direction][0] * station + run[:side][0] * offset,
       run[:a][1] + run[:direction][1] * station + run[:side][1] * offset, z]
    end

    def run_box(run, from, to, left, right, bottom, top)
      p = point(run, from, left, bottom)
      q = point(run, to, right, top)
      [3.times.map { |i| [p[i], q[i]].min }, 3.times.map { |i| [p[i], q[i]].max }]
    end

    def union(boxes)
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

    def steel(segments, s)
      result = { bars: [], layers: [], chairs: [], spacers: [], mesh_length_m: 0.0 }
      return result if s["reinforcement"] == "none"
      radius = s["bar_diameter_mm"] / 2
      cross_radius = s["cross_diameter_mm"] / 2
      cover = s["cover_mm"]
      half_mesh = (s["bar_count"] - 1) * s["bar_spacing_mm"] / 2
      extent = [radius, cross_radius, s["spacer_diameter_mm"] / 2].max
      raise "Mesh does not fit the footing width and clear cover." if half_mesh + extent + cover > s["width_mm"] / 2
      layer_depth = 2 * radius + 2 * cross_radius
      # Runs on one axis keep nominal cover; runs on the other stack one mesh
      # depth above them, so meshes carried through a junction sit on each
      # other instead of intersecting.
      axes = segments.map { |run| run[:direction][0].abs > 0.5 ? 0 : 1 }
      lifts = axes.map { |axis| axis == axes.first ? 0.0 : layer_depth }
      layers_per_run = s["reinforcement"] == "top_bottom" ? 2 : 1
      required = (2 * cover + layer_depth * layers_per_run) + lifts.max * layers_per_run
      raise "Mesh layers do not fit the depth and clear cover." if required >= s["depth_mm"]
      lap = half_mesh + radius
      raise "Spacer pair bars must not overlap." if s["spacer_pair_offset_mm"] * 2 < s["spacer_diameter_mm"]
      estimated_bars = segments.sum { |run| (run[:length] / s["cross_spacing_mm"]).ceil + s["bar_count"] }
      estimated_bars *= 2 if s["reinforcement"] == "top_bottom"
      estimated_supports = segments.sum { |run| (run[:length] / s["support_spacing_mm"]).ceil + 1 }
      raise "Too much reinforcement; increase spacing or shorten the assembly." if estimated_bars > 20_000 || estimated_supports > 2_000
      segments.each_with_index do |run, index|
        lift = lifts[index]
        from = junction_reach(run, segments, index, :start, lap) || cover
        to = junction_reach(run, segments, index, :end, lap) || run[:length] - cover
        raise "Run #{index + 1} is too short for the specified end cover." if to <= from
        heights = [["Bottom", run[:bottom] + cover + radius + lift, 1]]
        heights << ["Top", run[:top] - cover - radius - lift, -1] if s["reinforcement"] == "top_bottom"
        heights.each do |name, z, direction|
          longitudinal = s["bar_count"].to_i.times.map do |i|
            offset = run[:center] - half_mesh + i * s["bar_spacing_mm"]
            bar(point(run, from, offset, z), point(run, to, offset, z), radius * 2)
          end
          cross_bars = []
          station = from + s["cross_spacing_mm"]
          while station <= to - cross_radius
            z_cross = z + direction * (radius + cross_radius)
            cross_bars << bar(point(run, station, run[:center] - half_mesh, z_cross), point(run, station, run[:center] + half_mesh, z_cross), cross_radius * 2)
            station += s["cross_spacing_mm"]
          end
          result[:layers] << { segment_index: index, name: format("%s Mesh %02d", name, index+1),
                              longitudinal: longitudinal, cross_bars: cross_bars,
                              primary_index: s["bar_count"].to_i / 2, length_m: (to-from)/1000.0 }
          result[:bars].concat(longitudinal + cross_bars)
          result[:mesh_length_m] += (to - from) / 1000.0
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
          result[:chairs] << { segment_index: index,
            origin: point(run, station, run[:center], run[:bottom]), direction: run[:direction],
            width_mm: 2*w, length_mm: 2*half_mesh, height_mm: cover + lift }
          next unless heights.length == 2
          lower = heights[0][1] + radius
          upper = heights[1][1] - radius
          [-half_mesh, half_mesh].each do |offset|
            pair_offset = s["spacer_pair_offset_mm"]
            pair_radius = s["spacer_diameter_mm"] / 2
            next if station-pair_offset-pair_radius < from || station+pair_offset+pair_radius > to
            bars = [-pair_offset, pair_offset].map do |delta|
              bar(point(run, station+delta, run[:center]+offset, lower),
                  point(run, station+delta, run[:center]+offset, upper), pair_radius*2)
            end
            result[:spacers] << { segment_index: index, origin: point(run, station, run[:center]+offset, lower),
              direction: run[:direction], diameter_mm: pair_radius*2, pair_offset_mm: pair_offset,
              height_mm: upper-lower, bars: bars }
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
