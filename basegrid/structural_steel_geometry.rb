# frozen_string_literal: true

module Basegrid
  module StructuralSteelGeometry
    TYPES = %w[PFC UB UC SHS RHS CHS].freeze
    ANCHORS = %w[top_left top_center top_right middle_right bottom_right bottom_center bottom_left middle_left center].freeze
    DEFAULTS = { "material_id" => "", "usage" => "beam", "length_mm" => 3000.0,
                 "rotation_deg" => 0.0, "lateral_offset_mm" => 0.0, "vertical_offset_mm" => 0.0,
                 "anchor" => "top_left", "member_mark" => "" }.freeze
    module_function

    def number(value, label, positive: false)
      n = Float(value)
      raise ArgumentError unless n.finite? && (!positive || n > 0)
      n
    rescue ArgumentError, TypeError
      raise "#{label} must be a #{positive ? 'positive ' : ''}finite number."
    end

    def settings(input)
      raise "Invalid steel settings." unless input.is_a?(Hash)
      s = DEFAULTS.merge(input.select { |k,_| DEFAULTS.key?(k) })
      %w[length_mm rotation_deg lateral_offset_mm vertical_offset_mm].each { |k| s[k] = number(s[k],k,positive: k == "length_mm") }
      raise "Member length must be at least 1 mm." if s["length_mm"] < 1
      raise "Choose beam or column." unless %w[beam column].include?(s["usage"])
      raise "Invalid anchor." unless ANCHORS.include?(s["anchor"])
      s["member_mark"] = s["member_mark"].to_s.strip[0,100]
      s
    end

    def section(material, subtype)
      raise "Unsupported steel section." unless TYPES.include?(subtype)
      dims = material.fetch("dimensions_mm", {})
      read = ->(key, fallback = nil) { number(dims[key] || dims["#{key}_mm"] || fallback,key,positive: true) }
      width = subtype == "CHS" ? read.call("diameter") : read.call("flange_width", dims["width"])
      depth = subtype == "CHS" ? width : read.call("depth", subtype == "SHS" ? width : nil)
      item = { type: subtype, width: width, depth: depth }
      if %w[SHS RHS CHS].include?(subtype)
        wall = read.call("wall_thickness")
        raise "Wall thickness leaves no internal void." unless 2*wall < [width,depth].min
        raise "SHS width and depth must match." if subtype == "SHS" && (width-depth).abs > 0.001
        item[:wall] = wall
        %w[outer_radius inner_radius].each do |key|
          radius = number(dims[key] || 0,key)
          limit = key == "outer_radius" ? [width,depth].min/2 : [width,depth].min/2-wall
          raise "Invalid #{key}." unless radius.between?(0,limit)
          item[key.to_sym] = radius
        end
      else
        item[:flange] = read.call("flange_thickness")
        item[:web] = read.call("web_thickness")
        raise "Flange or web thickness exceeds the section." unless item[:flange]*2 < depth && item[:web] < width
        item[:root_radius] = number(dims["root_radius"] || 0,"Root radius")
        limit = [(depth-2*item[:flange])/2,(width-item[:web])/(subtype == "PFC" ? 1 : 2)].min
        raise "Root radius exceeds the section." unless item[:root_radius].between?(0,limit)
      end
      item
    end

    def arc(center,radius,from,to)
      (0..4).map do |i|
        angle = (from+(to-from)*i/4.0)*Math::PI/180
        [center[0]+radius*Math.cos(angle),center[1]+radius*Math.sin(angle)]
      end
    end

    def rectangle(width,depth,radius)
      x,y = width/2,depth/2
      [[[-x+radius,-y+radius],180,270],[[x-radius,-y+radius],270,360],
       [[x-radius,y-radius],0,90],[[-x+radius,y-radius],90,180]].flat_map { |c,a,b| arc(c,radius,a,b) }
    end

    def profile(item)
      w,d = item.values_at(:width,:depth)
      x,y = w/2,d/2
      loops = case item[:type]
              when "CHS"
                [w/2,w/2-item[:wall]].map do |r|
                  48.times.map { |i| angle = 2*Math::PI*i/48; [r*Math.cos(angle),r*Math.sin(angle)] }
                end.tap { |l| l[1].reverse! }
              when "SHS","RHS"
                [rectangle(w,d,item[:outer_radius]),rectangle(w-2*item[:wall],d-2*item[:wall],item[:inner_radius]).reverse]
              else
                f,t,r = item.values_at(:flange,:web,:root_radius)
                inner = item[:type] == "PFC" ? -x+t : t/2
                p = [[-x,-y],[x,-y],[x,-y+f],[inner+r,-y+f]]
                p += arc([inner+r,-y+f+r],r,-90,-180)
                p += arc([inner+r,y-f-r],r,180,90)
                p += [[x,y-f],[x,y],[-x,y]]
                unless item[:type] == "PFC"
                  p += [[-x,y-f],[-t/2-r,y-f]]
                  p += arc([-t/2-r,y-f-r],r,90,0)
                  p += arc([-t/2-r,-y+f+r],r,0,-90)
                  p << [-x,-y+f]
                end
                [p]
              end
      result = loops.map do |loop|
        clean = loop.each_with_object([]) { |p,list| list << p unless list.any? && Math.hypot(p[0]-list.last[0],p[1]-list.last[1]) < 1e-7 }
        clean.pop if Math.hypot(clean.first[0]-clean.last[0],clean.first[1]-clean.last[1]) < 1e-7
        clean
      end
      if result.length == 2
        outer,inner = result
        contained = inner.all? do |p|
          outer.each_index.all? do |i|
            a,b = outer[i],outer[(i+1)%outer.length]
            (b[0]-a[0])*(p[1]-a[1])-(b[1]-a[1])*(p[0]-a[0]) > 1e-7
          end
        end
        raise "Corner radii leave an invalid internal void." unless contained
      end
      result
    end

    def placed_profile(item,input)
      s = settings(input)
      anchor = s["anchor"]
      ax = anchor.include?("left") ? -item[:width]/2 : anchor.include?("right") ? item[:width]/2 : 0
      ay = anchor.include?("top") ? item[:depth]/2 : anchor.include?("bottom") ? -item[:depth]/2 : 0
      a = s["rotation_deg"]*Math::PI/180
      profile(item).map do |loop|
        loop.map do |x,y|
          x,y = x-ax,y-ay
          [x*Math.cos(a)-y*Math.sin(a)+s["lateral_offset_mm"],x*Math.sin(a)+y*Math.cos(a)+s["vertical_offset_mm"]]
        end
      end
    end

    def area(loop)
      loop.each_index.sum { |i| a,b = loop[i],loop[(i+1)%loop.length]; a[0]*b[1]-b[0]*a[1] }/2.0
    end
  end
end
