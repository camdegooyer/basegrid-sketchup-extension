# frozen_string_literal: true

module Basegrid
  module StarterBarGeometry
    DEFAULTS = {
      "mode" => "straight", "spacing_mm" => 400, "first_offset_mm" => 0,
      "diameter_mm" => 12, "above_mm" => 600, "below_mm" => 400,
      "top_start_mm" => 0, "top_end_mm" => 0, "bottom_start_mm" => 300,
      "bottom_end_mm" => 300, "top_direction" => "in", "bottom_direction" => "out",
      "in_mm" => 400, "out_mm" => 400, "chairs" => false, "caps" => false,
      "bar_material" => "", "chair_material" => "", "cap_material" => ""
    }.freeze
    EPS = 1e-6
    module_function

    def settings(input)
      raise "Settings must be an object." unless input.is_a?(Hash)
      result = DEFAULTS.merge(input.select { |key, _| DEFAULTS.key?(key) })
      DEFAULTS.each do |key, default|
        next unless default.is_a?(Numeric)
        value = Float(result[key])
        raise "#{key.delete_suffix('_mm')} must be a finite non-negative number." unless value.finite? && value >= 0
        result[key] = value
      end
      raise "Select a starter bar mode." unless %w[straight tapered pins].include?(result["mode"])
      raise "Spacing and diameter must be positive." unless result["spacing_mm"] > EPS && result["diameter_mm"] >= 1
      %w[top_direction bottom_direction].each { |key| raise "Invalid crank direction." unless %w[in out].include?(result[key]) }
      %w[chairs caps].each { |key| raise "Invalid #{key} option." unless [true, false].include?(result[key]) }
      if result["mode"] == "pins"
        raise "Pin length must be positive." unless result["in_mm"] + result["out_mm"] > EPS
      else
        raise "Bar height must be positive." unless result["above_mm"] + result["below_mm"] > EPS
      end
      result
    end

    def path(points)
      raise "Select a connected chain or loop of edges." unless points.is_a?(Array) && points.length >= 2
      points = points.map do |point|
        raise "Invalid path point." unless point.is_a?(Array) && point.length == 3
        point.map { |n| Float(n).tap { |v| raise "Invalid path coordinate." unless v.finite? } }
      end
      total = 0.0
      segments = points.each_cons(2).filter_map do |a, b|
        length = Math.hypot(b[0] - a[0], b[1] - a[1])
        next if length <= EPS # Vertical edges represent steps, not spacing distance.
        segment = { a: a, b: b, start: total, length: length,
                    tangent: [(b[0]-a[0])/length, (b[1]-a[1])/length, 0] }
        total += length
        segment
      end
      raise "The path needs a horizontal run." if total <= EPS
      closed = points.first.zip(points.last).all? { |a, b| (a-b).abs < EPS }
      area = points.each_cons(2).sum { |a, b| a[0]*b[1] - b[0]*a[1] }
      { points: points, segments: segments, total: total, closed: closed, ccw: area >= 0 }
    end

    def sample(path, distance)
      s = [[distance, 0].max, path[:total]].min
      segment = path[:segments].reverse.find { |part| s >= part[:start] - EPS } || path[:segments].first
      ratio = [[(s-segment[:start])/segment[:length], 0].max, 1].min
      point = segment[:a].zip(segment[:b]).map { |a, b| a+(b-a)*ratio }
      [point, segment[:tangent]]
    end

    def nearest_chainage(path, point)
      path[:segments].map do |segment|
        a, b = segment.values_at(:a, :b)
        delta = a.zip(b).map { |x, y| y-x }
        t = point.zip(a, delta).sum { |p, x, d| (p-x)*d } / delta.sum { |d| d*d }
        t = [[t, 0].max, 1].min
        distance = point.zip(a, delta).sum { |p, x, d| (p-x-d*t)**2 }
        [distance, segment[:start]+segment[:length]*t]
      end.min_by(&:first).last
    end

    def stations(path, settings, anchor, reverse)
      spacing, offset = settings.values_at("spacing_mm", "first_offset_mm")
      raise "The first offset exceeds the path length." if offset > path[:total]
      raise "Layout exceeds 5,000 bars. Increase spacing or shorten the path." if path[:total]/spacing > 5000
      if path[:closed]
        count = ((path[:total]-offset-EPS)/spacing).floor + 1
        Array.new(count) { |i| (anchor + (reverse ? -1 : 1)*(offset+i*spacing)) % path[:total] }.sort
      else
        count = ((path[:total]-offset+EPS)/spacing).floor + 1
        Array.new(count) { |i| offset+i*spacing }.flat_map do |delta|
          reverse ? [anchor-delta, anchor+delta] : [anchor+delta, anchor-delta]
        end.select { |station| station >= -EPS && station <= path[:total]+EPS }
          .map { |station| [[station, 0].max, path[:total]].min }.uniq
      end
    end

    def plan(points, input = {}, anchor: 0, reverse: false)
      s = settings(input)
      route = path(points)
      anchor = Float(anchor)
      raise "Invalid layout anchor." unless anchor.finite? && anchor >= 0 && anchor <= route[:total]+EPS
      bars = stations(route, s, anchor, reverse).map do |station|
        center, tangent = sample(route, station)
        sign = route[:closed] ? (route[:ccw] ? -1 : 1) : (reverse ? -1 : 1)
        inward = [tangent[1]*sign, -tangent[0]*sign, 0]
        ratio = if route[:closed]
                  ((reverse ? anchor-station : station-anchor) % route[:total])/route[:total]
                else
                  station/route[:total]
                end
        top = crank(s, "top", ratio)
        bottom = crank(s, "bottom", ratio)
        top_sign = s["top_direction"] == "in" ? 1 : -1
        bottom_sign = s["bottom_direction"] == "in" ? 1 : -1
        local = if s["mode"] == "pins"
                  [[0, -s["out_mm"], 0], [0, s["in_mm"], 0]]
                else
                  [[0, bottom*bottom_sign, -s["below_mm"]], [0, 0, -s["below_mm"]],
                   [0, 0, s["above_mm"]], [0, top*top_sign, s["above_mm"]]].chunk_while { |a, b| a == b }.map(&:first)
                end
        chairs = []
        if s["chairs"] && s["mode"] != "pins" && bottom > 0
          offset = [100.0, bottom/2].min
          while offset < bottom
            chairs << [0, (bottom-offset)*bottom_sign, -s["below_mm"]-s["diameter_mm"]/2]
            offset += 800
          end
        end
        { center: center, tangent: tangent, inward: inward, points: local, chairs: chairs,
          cap: s["caps"] ? local.last : nil,
          length_m: local.each_cons(2).sum { |a, b| Math.sqrt(a.zip(b).sum { |x, y| (x-y)**2 }) }/1000 }
      end
      raise "No bars fit this layout." if bars.empty?
      { settings: s, path: route, bars: bars }
    end

    def crank(settings, end_name, ratio)
      start = settings.fetch("#{end_name}_start_mm")
      return start unless settings["mode"] == "tapered"
      start + (settings.fetch("#{end_name}_end_mm")-start)*ratio
    end
  end
end
