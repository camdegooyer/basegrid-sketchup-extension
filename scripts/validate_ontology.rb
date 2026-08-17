# frozen_string_literal: true

require "json"

ROOT = File.expand_path("..", __dir__)
ERRORS = []

def read_json(relative_path)
  JSON.parse(File.read(File.join(ROOT, relative_path), encoding: "UTF-8"))
rescue JSON::ParserError => error
  ERRORS << "#{relative_path}: invalid JSON (#{error.message})"
  {}
rescue Errno::ENOENT
  ERRORS << "#{relative_path}: file is missing"
  {}
end

def require_keys(record, keys, label)
  missing = keys.reject { |key| record.key?(key) }
  ERRORS << "#{label}: missing keys #{missing.join(", ")}" unless missing.empty?
end

def duplicate_values(values)
  values.compact.group_by(&:itself).select { |_value, matches| matches.length > 1 }.keys
end

def check_enum(value, allowed, label)
  ERRORS << "#{label}: invalid value #{value.inspect}" unless allowed.include?(value)
end

def check_confidence(value, label)
  valid = value.is_a?(Numeric) && value.between?(0, 1)
  ERRORS << "#{label}: confidence must be between 0 and 1" unless valid
end

def graph_has_cycle?(edges)
  adjacency = Hash.new { |hash, key| hash[key] = [] }
  edges.each { |from, to| adjacency[from] << to }
  state = {}
  visit = lambda do |node|
    return true if state[node] == :visiting
    return false if state[node] == :visited

    state[node] = :visiting
    return true if adjacency[node].any? { |target| visit.call(target) }

    state[node] = :visited
    false
  end
  adjacency.keys.any? { |node| visit.call(node) }
end

source_schema = read_json("schemas/source.schema.json")
standard_schema = read_json("schemas/standard.schema.json")
object_schema = read_json("schemas/physical_object.schema.json")
relationship_schema = read_json("schemas/relationship.schema.json")
source_registry = read_json("data/sources/source_registry.json")
standard_registry = read_json("data/standards/standards_registry.json")
review_registry = read_json("data/review/unresolved_terms.json")
ontology = read_json("exports/ontology.json")
relationships_export = read_json("exports/relationships.json")
coverage_metrics = read_json("exports/coverage_metrics.json")

sources = source_registry.fetch("sources", [])
standards = standard_registry.fetch("standards", [])
objects = ontology.fetch("objects", [])
relationships = relationships_export.fetch("relationships", [])
source_ids = sources.map { |source| source["id"] }
standard_ids = standards.map { |standard| standard["id"] }
object_ids = objects.map { |object| object["id"] }

{
  "source" => source_ids,
  "standard" => standard_ids,
  "object" => object_ids,
  "relationship" => relationships.map { |relationship| relationship["id"] },
  "claim" => objects.flat_map { |object| object.fetch("claims", []).map { |claim| claim["id"] } },
  "review item" => review_registry.fetch("items", []).map { |item| item["id"] }
}.each do |label, ids|
  duplicates = duplicate_values(ids)
  ERRORS << "duplicate #{label} IDs: #{duplicates.join(", ")}" unless duplicates.empty?
end

duplicate_names = objects.group_by { |object| [object["discipline"], object["canonical_name"].to_s.downcase.strip] }.select { |_key, matches| matches.length > 1 }.keys
ERRORS << "duplicate canonical name and discipline pairs: #{duplicate_names.map { |item| item.join("/") }.join(", ")}" unless duplicate_names.empty?

expected_direct_standards = 64
direct_standards = standards.count { |standard| standard["directly_referenced_by_housing_provisions"] }
ERRORS << "expected #{expected_direct_standards} directly referenced Housing Provisions standards, found #{direct_standards}" unless direct_standards == expected_direct_standards

source_required = source_schema.fetch("required", [])
source_allowed = source_schema.fetch("properties", {}).keys
sources.each do |source|
  label = "source #{source["id"] || "<unknown>"}"
  require_keys(source, source_required, label)
  extras = source.keys - source_allowed
  ERRORS << "#{label}: unexpected keys #{extras.join(", ")}" unless extras.empty?
  ERRORS << "#{label}: ID format is invalid" unless source.fetch("id", "").match?(/\ASRC-[A-Z0-9-]+\z/)
  ERRORS << "#{label}: source tier must be 1 to 5" unless source.fetch("source_tier", 0).between?(1, 5)
end

standard_required = standard_schema.fetch("required", [])
standard_allowed = standard_schema.fetch("properties", {}).keys
standards.each do |standard|
  label = "standard #{standard["id"] || "<unknown>"}"
  require_keys(standard, standard_required, label)
  extras = standard.keys - standard_allowed
  ERRORS << "#{label}: unexpected keys #{extras.join(", ")}" unless extras.empty?
  unknown_sources = standard.fetch("source_ids", []) - source_ids
  ERRORS << "#{label}: unknown sources #{unknown_sources.join(", ")}" unless unknown_sources.empty?
end

object_required = object_schema.fetch("required", [])
object_allowed = object_schema.fetch("properties", {}).keys
object_types = object_schema.dig("properties", "object_type", "enum")
geometry_classes = object_schema.dig("properties", "geometry_class", "enum")
review_statuses = object_schema.dig("properties", "review_status", "enum")
alias_types = object_schema.dig("$defs", "alias", "properties", "type", "enum")
claim_types = object_schema.dig("properties", "claims", "items", "properties", "claim_type", "enum")
forbidden_definition_phrases = ["according to as ", "the standard defines"]

objects.each do |object|
  label = "object #{object["id"] || "<unknown>"}"
  require_keys(object, object_required, label)
  extras = object.keys - object_allowed
  ERRORS << "#{label}: unexpected keys #{extras.join(", ")}" unless extras.empty?
  ERRORS << "#{label}: ID format is invalid" unless object.fetch("id", "").match?(/\AAU-[A-Z0-9-]+\z/)
  ERRORS << "#{label}: definition is too short" unless object.fetch("definition_plain", "").length >= 20
  lowered_definition = object.fetch("definition_plain", "").downcase
  forbidden_definition_phrases.each do |phrase|
    ERRORS << "#{label}: definition contains discouraged source-dependent wording #{phrase.inspect}" if lowered_definition.include?(phrase)
  end
  check_enum(object["object_type"], object_types, "#{label} object_type")
  check_enum(object["geometry_class"], geometry_classes, "#{label} geometry_class")
  check_enum(object["review_status"], review_statuses, "#{label} review_status")

  claims = object.fetch("claims", [])
  ERRORS << "#{label}: has no provenance claims" if claims.empty?
  claims.each do |claim|
    claim_label = "#{label} claim #{claim["id"] || "<unknown>"}"
    require_keys(claim, %w[id claim_type text source_ids confidence], claim_label)
    check_enum(claim["claim_type"], claim_types, "#{claim_label} claim_type")
    check_confidence(claim["confidence"], claim_label)
    ERRORS << "#{claim_label}: has no source" if claim.fetch("source_ids", []).empty?
    unknown = claim.fetch("source_ids", []) - source_ids
    ERRORS << "#{claim_label}: unknown sources #{unknown.join(", ")}" unless unknown.empty?
  end

  %w[aliases possible_aliases_requiring_review].each do |field|
    object.fetch(field, []).each do |item|
      alias_label = "#{label} #{field} #{item["term"] || "<unknown>"}"
      require_keys(item, %w[term type region confidence], alias_label)
      check_enum(item["type"], alias_types, "#{alias_label} type")
      check_confidence(item["confidence"], alias_label)
    end
  end

  object.fetch("confidence", {}).each { |field, value| check_confidence(value, "#{label} confidence.#{field}") }
  unknown_standards = object.fetch("standard_references", []).map { |reference| reference["standard_id"] } - standard_ids
  ERRORS << "#{label}: unknown standards #{unknown_standards.join(", ")}" unless unknown_standards.empty?
  unknown_assemblies = object.fetch("part_of_assemblies", []) - object_ids
  ERRORS << "#{label}: unknown assembly IDs #{unknown_assemblies.join(", ")}" unless unknown_assemblies.empty?
  non_assembly_targets = object.fetch("part_of_assemblies", []).select do |assembly_id|
    target = objects.find { |candidate| candidate["id"] == assembly_id }
    target && target["object_type"] != "assembly"
  end
  ERRORS << "#{label}: part_of_assemblies includes non-assemblies #{non_assembly_targets.join(", ")}" unless non_assembly_targets.empty?
  child_ids = object.fetch("child_ids", [])
  parent_ids = [object["parent_id"]].compact
  unknown_hierarchy_ids = (child_ids + parent_ids) - object_ids
  ERRORS << "#{label}: unknown hierarchy IDs #{unknown_hierarchy_ids.join(", ")}" unless unknown_hierarchy_ids.empty?
  ERRORS << "#{label}: is its own parent" if object["parent_id"] == object["id"]
  aliases = object.fetch("aliases", []).map { |item| item["term"].to_s.downcase }
  forbidden = object.fetch("not_synonyms", []).map(&:downcase)
  overlap = aliases & forbidden
  ERRORS << "#{label}: terms appear as both accepted aliases and non-synonyms: #{overlap.join(", ")}" unless overlap.empty?
end

relationship_required = relationship_schema.fetch("required", [])
relationship_allowed = relationship_schema.fetch("properties", {}).keys
relationship_types = relationship_schema.dig("properties", "relationship", "enum")
edge_triples = relationships.map { |relationship| [relationship["from_id"], relationship["relationship"], relationship["to_id"]] }
duplicate_edges = duplicate_values(edge_triples)
ERRORS << "duplicate relationship triples: #{duplicate_edges.map { |edge| edge.join(" ") }.join(", ")}" unless duplicate_edges.empty?
edge_set = edge_triples.to_h { |edge| [edge, true] }
inverse_types = {
  "part_of" => "has_part",
  "has_part" => "part_of",
  "supports" => "supported_by",
  "supported_by" => "supports",
  "connects_to" => "connects_to",
  "adjacent_to" => "adjacent_to",
  "alternative_to" => "alternative_to",
  "commonly_used_with" => "commonly_used_with"
}.freeze

relationships.each do |relationship|
  label = "relationship #{relationship["id"] || "<unknown>"}"
  require_keys(relationship, relationship_required, label)
  extras = relationship.keys - relationship_allowed
  ERRORS << "#{label}: unexpected keys #{extras.join(", ")}" unless extras.empty?
  check_enum(relationship["relationship"], relationship_types, "#{label} type")
  check_enum(relationship["review_status"], review_statuses, "#{label} review_status")
  check_confidence(relationship["confidence"], label)
  unknown_objects = [relationship["from_id"], relationship["to_id"]].compact - object_ids
  ERRORS << "#{label}: unknown objects #{unknown_objects.join(", ")}" unless unknown_objects.empty?
  ERRORS << "#{label}: self relationship is not allowed" if relationship["from_id"] == relationship["to_id"]
  unknown_sources = relationship.fetch("source_ids", []) - source_ids
  ERRORS << "#{label}: unknown sources #{unknown_sources.join(", ")}" unless unknown_sources.empty?
  inverse = inverse_types[relationship["relationship"]]
  expected = [relationship["to_id"], inverse, relationship["from_id"]]
  ERRORS << "#{label}: missing inverse #{expected.join(" ")}" if inverse && !edge_set[expected]
end

is_a_edges = relationships.select { |relationship| relationship["relationship"] == "is_a" }.map { |relationship| [relationship["from_id"], relationship["to_id"]] }
ERRORS << "is_a hierarchy contains a cycle" if graph_has_cycle?(is_a_edges)

review_registry.fetch("items", []).each do |item|
  unknown_objects = item.fetch("affected_object_ids", []) - object_ids
  unknown_sources = item.fetch("source_ids", []) - source_ids
  ERRORS << "review #{item["id"]}: unknown objects #{unknown_objects.join(", ")}" unless unknown_objects.empty?
  ERRORS << "review #{item["id"]}: unknown sources #{unknown_sources.join(", ")}" unless unknown_sources.empty?
end

jsonl_objects = File.readlines(File.join(ROOT, "exports", "ontology.jsonl"), chomp: true).reject(&:empty?).map.with_index do |line, index|
  JSON.parse(line)
rescue JSON::ParserError => error
  ERRORS << "exports/ontology.jsonl line #{index + 1}: invalid JSON (#{error.message})"
  nil
end.compact
ERRORS << "ontology JSONL does not match canonical object export" unless jsonl_objects == objects

objects.group_by { |object| object.fetch("discipline") }.each do |discipline, discipline_objects|
  directory = File.join("exports", "disciplines", discipline)
  discipline_export = read_json(File.join(directory, "ontology.json"))
  discipline_relationships = read_json(File.join(directory, "relationships.json"))
  expected_ids = discipline_objects.map { |object| object.fetch("id") }.sort
  actual_ids = discipline_export.fetch("objects", []).map { |object| object.fetch("id") }.sort
  ERRORS << "#{discipline} discipline export object IDs do not match canonical export" unless actual_ids == expected_ids
  internal = discipline_relationships.fetch("relationships", [])
  external = discipline_relationships.fetch("external_relationships", [])
  ERRORS << "#{discipline} internal relationship references an external object" unless internal.all? { |edge| expected_ids.include?(edge["from_id"]) && expected_ids.include?(edge["to_id"]) }
  ERRORS << "#{discipline} external relationship has invalid boundary" unless external.all? { |edge| expected_ids.include?(edge["from_id"]) && !expected_ids.include?(edge["to_id"]) }
  %w[glossary.md report.md ontology.jsonl].each do |filename|
    ERRORS << "#{directory}/#{filename}: file is missing" unless File.file?(File.join(ROOT, directory, filename))
  end
end

ERRORS << "ontology object_count does not match objects array" unless ontology["object_count"] == objects.length
ERRORS << "ontology relationship_count does not match relationships export" unless ontology["relationship_count"] == relationships.length
ERRORS << "coverage metrics object_count does not match ontology" unless coverage_metrics["object_count"] == objects.length
ERRORS << "coverage metrics relationship_count does not match relationships" unless coverage_metrics["relationship_count"] == relationships.length
ERRORS << "coverage metrics discipline_count does not match ontology" unless coverage_metrics["discipline_count"] == objects.map { |object| object["discipline"] }.uniq.length

if ERRORS.empty?
  puts "Validation passed: #{objects.length} objects, #{relationships.length} relationships, #{standards.length} standards, #{sources.length} sources, #{coverage_metrics["discipline_count"]} disciplines."
  exit 0
end

warn "Validation failed with #{ERRORS.length} error(s):"
ERRORS.each { |error| warn "- #{error}" }
exit 1
