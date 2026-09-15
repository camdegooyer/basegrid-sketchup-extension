# frozen_string_literal: true

module Basegrid
  # Plan pier stations on the footing centreline network, in world millimetres.
  module FootingPierLayout
    TOLERANCE = 0.01
    MAX_PIERS = 2000
    module_function

    def cross(a, b) = a[0]*b[1] - a[1]*b[0]
    def delta(a, b) = [a[0]-b[0], a[1]-b[1]]
    def at(line, distance) = [line[:a][0]+line[:d][0]*distance, line[:a][1]+line[:d][1]*distance]

    def plan(runs, settings)
      return [] unless settings["include_piers"]
      lines = runs.map do |run|
        { a: at({a: run[:a],d: run[:side]},run[:center]), d: run[:direction],
          from: 0.0,to: run[:length],cuts: [],run: run }
      end
      lines.combination(2) do |a,b|
        determinant = cross(a[:d],b[:d])
        next if determinant.abs < 1e-8
        raw = delta(b[:run][:a],a[:run][:a])
        ta,tb = cross(raw,b[:d])/determinant,cross(raw,a[:d])/determinant
        next unless ta.between?(-TOLERANCE,a[:run][:length]+TOLERANCE) && tb.between?(-TOLERANCE,b[:run][:length]+TOLERANCE)
        next if (a[:run][:bottom]-b[:run][:bottom]).abs > TOLERANCE
        shifted = delta(b[:a],a[:a])
        sa,sb = cross(shifted,b[:d])/determinant,cross(shifted,a[:d])/determinant
        [[a,ta,sa],[b,tb,sb]].each do |line,raw_station,station|
          if raw_station.abs < TOLERANCE
            line[:from] = station
          elsif (raw_station-line[:run][:length]).abs < TOLERANCE
            line[:to] = station
          end
          line[:cuts] << station
        end
      end
      nodes,edges = [],[]
      node_for = lambda do |p|
        nodes.index { |node| Math.hypot(node[:p][0]-p[0],node[:p][1]-p[1]) < TOLERANCE } ||
          (nodes << {p: p,edges: []}; nodes.length-1)
      end
      lines.each do |line|
        raise "Pier centreline is too short at a corner." unless line[:to]-line[:from] > TOLERANCE
        # Collinear joins and steps also split the centreline network.
        lines.each do |other|
          next if other.equal?(line)
          [other[:from],other[:to]].each do |station|
            p = at(other,station)
            v = delta(p,line[:a])
            t = v[0]*line[:d][0]+v[1]*line[:d][1]
            line[:cuts] << t if cross(v,line[:d]).abs < TOLERANCE && t > line[:from]+TOLERANCE && t < line[:to]-TOLERANCE
          end
        end
        cuts = ([line[:from],line[:to]]+line[:cuts].select { |t| t.between?(line[:from],line[:to]) }).sort
        cuts = cuts.chunk_while { |a,b| (a-b).abs < TOLERANCE }.map(&:first)
        cuts.each_cons(2) do |a,b|
          from,to = node_for.call(at(line,a)),node_for.call(at(line,b))
          index = edges.length
          edges << {from: from,to: to,length: b-a,run: line[:run]}
          nodes[from][:edges] << index;nodes[to][:edges] << index
        end
      end
      nodes.each_with_index do |node,index|
        degree = node[:edges].length
        corner = degree == 2 && cross(*node[:edges].map do |e|
          edge = edges[e];delta(nodes[edge[:from] == index ? edge[:to] : edge[:from]][:p],node[:p])
        end).abs > TOLERANCE
        levels = node[:edges].map { |e| edges[e][:run][:bottom] }.uniq
        node[:required] = degree == 1 || (corner && settings["piers_at_corners"]) ||
          (degree > 2 && settings["piers_at_intersections"]) || levels.length > 1
        node[:break] = degree != 2 || node[:required]
      end
      visited,result = {},[]
      starts = nodes.each_index.sort_by { |i| nodes[i][:break] ? 0 : 1 }
      starts.each do |start|
        nodes[start][:edges].each do |first|
          next if visited[first]
          chain,current,e = [],start,first
          loop do
            visited[e] = true
            edge = edges[e];following = edge[:from] == current ? edge[:to] : edge[:from]
            chain << [current,following,edge]
            current = following
            break if current == start || nodes[current][:break]
            e = nodes[current][:edges].find { |candidate| !visited[candidate] }
            break unless e
          end
          length = chain.sum { |_,_,edge| edge[:length] }
          radius = settings["pier_diameter_mm"] / 2
          start_inset = nodes[start][:edges].length == 1 ? radius : 0.0
          end_inset = nodes[current][:edges].length == 1 ? radius : 0.0
          usable_length = length - start_inset - end_inset
          raise "Footing run is too short to fit end piers flush with the ends." if usable_length < -TOLERANCE
          stations([usable_length,0.0].max,settings["pier_spacing_mm"],settings["piers_even_spacing"],nodes[start][:required],nodes[current][:required]).each do |station|
            distance = station + start_inset
            piece = chain.find do |_,_,edge|
              if distance <= edge[:length]+TOLERANCE then true else distance -= edge[:length];false end
            end || chain.last
            a,b,edge = piece
            ratio = [[distance/edge[:length],0].max,1].min
            p = nodes[a][:p].zip(nodes[b][:p]).map { |x,y| x+(y-x)*ratio }
            existing = result.find { |item| Math.hypot(item[:top][0]-p[0],item[:top][1]-p[1]) < TOLERANCE }
            z = edge[:run][:bottom]
            if existing
              existing[:top][2] = [existing[:top][2],z].min
            else
              result << {top: p+[z],direction: edge[:run][:side]}
              raise "Too many piers; increase the nominated centres." if result.length > MAX_PIERS
            end
          end
        end
      end
      result
    end

    def stations(length, spacing, even, start_required, end_required)
      raise "Too many piers; increase the nominated centres." if length/spacing > MAX_PIERS
      return stations(length,spacing,even,true,false).map { |t| length-t }.sort if !start_required && end_required
      if even
        if start_required && end_required
          count = [(length/spacing).ceil,1].max
          return (0..count).map { |i| length*i/count }
        elsif start_required
          count = [(length/spacing-0.5).ceil,0].max
          return (0..count).map { |i| length*i/(count+0.5) }
        end
        count = [(length/spacing).ceil,1].max
        return count.times.map { |i| length*(i+0.5)/count }
      end
      result = [];station = start_required ? 0.0 : [spacing/2,length/2].min
      while station < length-TOLERANCE
        result << station;station += spacing
      end
      result << length if end_required
      result
    end
  end
end
