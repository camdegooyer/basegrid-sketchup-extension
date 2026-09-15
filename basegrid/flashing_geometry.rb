# frozen_string_literal: true

module Basegrid
  module FlashingGeometry
    DEFAULTS = { "finish" => "colourbond", "lengths_mm" => [25,40,25], "angles_deg" => [90,-90],
                 "start_angle_deg" => 0, "anchor_index" => 0, "mirror" => false,
                 "path_side" => "left", "material_side" => "right", "material_id" => "" }.freeze
    EPS = 1e-7
    module_function

    def settings(input)
      raise "Flashing settings must be an object." unless input.is_a?(Hash)
      s = DEFAULTS.merge(input.select { |key,_| DEFAULTS.key?(key) })
      raise "Choose a flashing finish." unless %w[colourbond zincalume perforated].include?(s["finish"])
      raise "Specify 1 to 7 profile legs." unless s["lengths_mm"].is_a?(Array) && (1..7).cover?(s["lengths_mm"].length)
      raise "Invalid material override." unless s["material_id"].is_a?(String)
      raise "Specify one bend angle between each leg." unless s["angles_deg"].is_a?(Array) && s["angles_deg"].length == s["lengths_mm"].length-1
      s["lengths_mm"] = s["lengths_mm"].map { |v| finite(v).tap { |n| raise "Leg lengths must be at least 1 mm." if n < 1 } }
      s["angles_deg"] = s["angles_deg"].map { |v| finite(v).tap { |n| raise "Bend angles must be between -175 and 175 degrees, excluding zero." if n.abs > 175 || n.abs < EPS } }
      s["start_angle_deg"] = finite(s["start_angle_deg"])
      anchor = finite(s["anchor_index"])
      raise "Invalid profile anchor." unless anchor == anchor.to_i && (0..s["lengths_mm"].length).cover?(anchor)
      s["anchor_index"] = anchor.to_i
      raise "Invalid mirror setting." unless [true,false].include?(s["mirror"])
      %w[path_side material_side].each { |key| raise "Invalid profile side." unless %w[left right].include?(s[key]) }
      s
    end

    def finite(value)
      Float(value).tap { |n| raise "Dimensions must be finite." unless n.finite? }
    end

    def profile(s)
      angle = s["start_angle_deg"]*Math::PI/180
      points = [[0.0,0.0]]
      s["lengths_mm"].each_with_index do |length,i|
        points << [points.last[0]+length*Math.cos(angle), points.last[1]+length*Math.sin(angle)]
        angle += s["angles_deg"][i]*Math::PI/180 if i < s["angles_deg"].length
      end
      s["mirror"] ? points.map { |x,y| [x,-y] } : points
    end

    def add(a,b) = a.zip(b).map { |x,y| x+y }
    def sub(a,b) = a.zip(b).map { |x,y| x-y }
    def mul(a,n) = a.map { |x| x*n }
    def dot(a,b) = a.zip(b).sum { |x,y| x*y }
    def length(a) = Math.sqrt(dot(a,a))
    def unit(a)
      n = length(a)
      raise "Zero-length direction." if n < EPS
      mul(a,1.0/n)
    end
    def cross(a,b) = [a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0]]

    def polygon(s, thickness)
      raise "Material thickness must be positive." unless finite(thickness) > 0
      points = profile(s)
      offset = thickness * (s["material_side"] == "left" ? 1 : -1)
      normals = points.each_cons(2).map { |a,b| d = unit(sub(b,a)); [-d[1],d[0]] }
      other = points.each_with_index.map do |p,i|
        n = i == 0 ? normals.first : i == points.length-1 ? normals.last : unit(add(normals[i-1],normals[i]))
        scale = i == 0 || i == points.length-1 ? 1 : dot(n,normals[i])
        add(p,mul(n,offset/scale))
      end
      poly = points+other.reverse
      poly.each_index do |i|
        ((i+1)...poly.length).each do |j|
          next if j == i+1 || (i == 0 && j == poly.length-1)
          raise "Profile overlaps itself. Adjust leg lengths or bend angles." if intersects?(poly[i],poly[(i+1)%poly.length],poly[j],poly[(j+1)%poly.length])
        end
      end
      poly
    end

    def intersects?(a,b,c,d)
      orient = ->(p,q,r) { (q[0]-p[0])*(r[1]-p[1])-(q[1]-p[1])*(r[0]-p[0]) }
      o = [orient.call(a,b,c),orient.call(a,b,d),orient.call(c,d,a),orient.call(c,d,b)]
      return true if o[0]*o[1] < -EPS && o[2]*o[3] < -EPS
      [[a,b,c,o[0]],[a,b,d,o[1]],[c,d,a,o[2]],[c,d,b,o[3]]].any? do |p,q,r,v|
        v.abs < EPS && 2.times.all? { |i| r[i] >= [p[i],q[i]].min-EPS && r[i] <= [p[i],q[i]].max+EPS }
      end
    end

    def plan(path, input, thickness:, normal: nil)
      s = settings(input)
      raise "Draw at least one flashing run." unless path.is_a?(Array) && (2..1000).cover?(path.length)
      points = path.map { |p| raise "Invalid path point." unless p.is_a?(Array) && p.length == 3; p.map { |v| finite(v) } }
      runs = points.each_cons(2).map { |a,b| unit(sub(b,a)) }
      distances = points.each_cons(2).map { |a,b| length(sub(b,a)) }
      raise "Path segments must be at least 1 mm." if distances.any? { |n| n < 1 }
      candidate = runs.each_cons(2).map { |a,b| cross(a,b) }.find { |v| length(v) > EPS }
      candidate ||= normal || (runs.first[2].abs < 0.9 ? [0,0,1] : [0,1,0])
      candidate = runs.first[2].abs < 0.9 ? [0,0,1] : [0,1,0] if length(cross(candidate,runs.first)) < EPS
      up = unit(sub(candidate,mul(runs.first,dot(candidate,runs.first))))
      up = mul(up,-1) if normal && dot(up,normal) < 0
      raise "Flashing path must lie in one plane." if runs.any? { |run| dot(run,up).abs > 1e-6 }
      horizontal = runs.first
      vertical = cross(up,horizontal)
      flat = points.map { |p| d = sub(p,points.first); [dot(d,horizontal),dot(d,vertical)] }
      flat.each_cons(2).with_index do |(a,b),i|
        ((i+2)...flat.length-1).each do |j|
          raise "Closed or self-crossing flashing paths are not supported." if intersects?(a,b,flat[j],flat[j+1])
        end
      end
      sides = runs.map { |run| mul(cross(up,run),s["path_side"] == "left" ? 1 : -1) }
      poly = polygon(s,thickness)
      area = poly.each_index.sum { |i| a,b = poly[i],poly[(i+1)%poly.length]; a[0]*b[1]-b[0]*a[1] }
      poly.reverse! if area * (s["path_side"] == "left" ? 1 : -1) < 0
      anchor = profile(s)[s["anchor_index"]]
      rings = points.each_with_index.map do |p,i|
        side = i == 0 ? sides.first : i == points.length-1 ? sides.last : unit(add(sides[i-1],sides[i]))
        factor = i == 0 || i == points.length-1 ? 1 : dot(side,sides[i])
        raise "The path corner is too sharp." if factor < 0.1
        poly.map { |x,y| add(add(p,mul(side,(x-anchor[0])/factor)),mul(up,y-anchor[1])) }
      end
      rings.each_cons(2).with_index do |(a,b),i|
        raise "Profile is too wide for the path corner or segment." if a.zip(b).any? { |p,q| dot(sub(q,p),runs[i]) <= EPS }
      end
      { settings: s, points: points, normal: up, rings: rings,
        girth_mm: s["lengths_mm"].sum, folds: s["angles_deg"].length, length_m: distances.sum/1000 }
    end
  end
end
