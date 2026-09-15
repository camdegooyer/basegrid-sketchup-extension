# frozen_string_literal: true

require "json"
require "csv"

module Basegrid
  module Takeoff
    DICTIONARY = "Basegrid"
    KEY = "takeoff_json"
    SCHEMA_VERSION = 2

    module_function

    def write(entity, material:, role_id:, quantity_m3:, basis:, takeoff_groups: [])
      write_quantity(entity, material: material, role_id: role_id, material_role: "concrete",
                     quantity: quantity_m3, unit: "m3", basis: basis, takeoff_groups: takeoff_groups)
    end

    def write_quantity(entity, material:, role_id:, material_role:, quantity:, unit:, basis:, takeoff_groups: [])
      quantity = Float(quantity)
      raise "Quantity must be finite and non-negative." unless quantity.finite? && quantity >= 0
      raise "Unsupported takeoff unit." unless %w[m3 m ea].include?(unit)
      record = {
        "schema_version" => SCHEMA_VERSION,
        "role_id" => role_id,
        "material_role" => material_role,
        "material_id" => material.fetch("id").to_s,
        "material_name" => material.fetch("name").to_s,
        "unit" => unit,
        "quantity" => quantity,
        "basis" => basis,
        "takeoff_groups" => normalize_groups(takeoff_groups)
      }
      entity.set_attribute(DICTIONARY, KEY, JSON.generate(record))
      record
    end

    def records(model)
      output = []
      collect(model.entities, output)
      output
    end

    def summary(records)
      records.each_with_object({}) do |record, output|
        key = [record["material_id"], record["material_name"], record["unit"]]
        output[key] ||= 0.0
        output[key] += record["quantity"].to_f
      end
    end

    def summary_rows(records)
      summary(records).map do |(material_id, material_name, unit), quantity|
        {
          "material_id" => material_id,
          "material_name" => material_name,
          "unit" => unit,
          "quantity" => quantity
        }
      end.sort_by { |row| [row["material_name"].downcase, row["material_id"]] }
    end

    def to_csv(rows)
      CSV.generate do |csv|
        csv << ["Material", "Material ID", "Quantity", "Unit"]
        rows.each do |row|
          csv << [
            row.fetch("material_name"),
            row.fetch("material_id"),
            format("%.3f", row.fetch("quantity")),
            row.fetch("unit")
          ]
        end
      end
    end

    def grouped_rows(records)
      totals = {}
      records.each do |record|
        groups = normalize_groups(record["takeoff_groups"])
        groups = [{ "id" => "", "name" => "Unassigned" }] if groups.empty?
        groups.each do |group|
          key = [
            group["id"], group["name"],
            record["material_id"], record["material_name"], record["unit"]
          ]
          totals[key] ||= 0.0
          totals[key] += record["quantity"].to_f
        end
      end
      totals.map do |(group_id, group_name, material_id, material_name, unit), quantity|
        {
          "group_id" => group_id,
          "group_name" => group_name,
          "material_id" => material_id,
          "material_name" => material_name,
          "unit" => unit,
          "quantity" => quantity
        }
      end.sort_by { |row| [row["group_name"].downcase, row["material_name"].downcase, row["material_id"]] }
    end

    def grouped_csv(records)
      CSV.generate do |csv|
        csv << ["Takeoff Group", "Group ID", "Material", "Material ID", "Quantity", "Unit"]
        grouped_rows(records).each do |row|
          csv << [
            row.fetch("group_name"),
            row.fetch("group_id"),
            row.fetch("material_name"),
            row.fetch("material_id"),
            format("%.3f", row.fetch("quantity")),
            row.fetch("unit")
          ]
        end
      end
    end

    def normalize_groups(groups)
      Array(groups).filter_map do |group|
        next unless group.is_a?(Hash)

        id = group["id"].to_s
        name = group["name"].to_s
        next if id.empty? || name.empty?

        { "id" => id, "name" => name }
      end.uniq { |group| group["id"] }
    end


    def collect(entities, output)
      entities.each do |entity|
        encoded = entity.get_attribute(DICTIONARY, KEY) if entity.respond_to?(:get_attribute)
        output << JSON.parse(encoded) unless encoded.to_s.empty?
        if entity.respond_to?(:entities)
          collect(entity.entities, output)
        elsif entity.respond_to?(:definition) && entity.definition.respond_to?(:entities)
          collect(entity.definition.entities, output)
        end
      rescue JSON::ParserError
        next
      end
    end
    private_class_method :collect
    private_class_method :normalize_groups
  end
end
