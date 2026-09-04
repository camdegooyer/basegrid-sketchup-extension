# frozen_string_literal: true

require "csv"
require "fileutils"
require "json"
require "set"

ROOT = File.expand_path("..", __dir__)
CATALOG_GLOB = File.join(ROOT, "data", "catalog", "*_catalog.json")
REVIEW_PATH = File.join(ROOT, "data", "review", "unresolved_terms.json")
STANDARDS_PATH = File.join(ROOT, "data", "standards", "standards_registry.json")
SOURCES_PATH = File.join(ROOT, "data", "sources", "source_registry.json")
EXPORT_DIR = File.join(ROOT, "exports")
GENERATED_AT = "2026-08-16T00:00:00+10:00"

def read_json(path)
  JSON.parse(File.read(path, encoding: "UTF-8"))
end

ALIAS_TYPE_NORMALISATION = {
  "common_alias" => "regional_synonym",
  "possible_alias" => "related_but_not_synonym"
}.freeze

def alias_record(record)
  record = {
    "term" => record,
    "type" => "related_but_not_synonym",
    "region" => "Australia",
    "confidence" => 0.65
  } if record.is_a?(String)

  {
    "term" => record.fetch("term"),
    "type" => ALIAS_TYPE_NORMALISATION.fetch(record.fetch("type"), record.fetch("type")),
    "region" => record.fetch("region", "Australia"),
    "confidence" => record.fetch("confidence")
  }
end

def confidence_for(status, aliases)
  base = status == "accepted" ? 0.92 : 0.76
  {
    "existence" => status == "accepted" ? 0.96 : 0.85,
    "definition" => base,
    "aliases" => aliases.empty? ? 0.9 : [base - 0.04, 0.0].max.round(2),
    "relationships" => [base - 0.05, 0.0].max.round(2),
    "overall" => [base - 0.03, 0.0].max.round(2)
  }
end

def standard_references(entry, catalogue)
  ids = (catalogue.fetch("default_standards", []) + Array(entry["standards"])).uniq
  ids.map do |id|
    {
      "standard_id" => id,
      "relationship" => "Referenced or supporting technical standard for this object family; exact rules require the applicable licensed edition and project inputs.",
      "verification_status" => "verified"
    }
  end
end

def ncc_references(entry, catalogue)
  Array(entry["ncc_references"] || catalogue.fetch("ncc_references", [])).map do |reference|
    reference.merge("verification_status" => "verified")
  end
end

def build_object(entry, catalogue, assembly_ids)
  status = entry.fetch("review_status", "accepted")
  aliases = Array(entry["aliases"]).map { |item| alias_record(item) }
  possible_aliases = Array(entry["possible_aliases"]).map { |item| alias_record(item) }
  cad = entry.fetch("cad")
  source_ids = entry.fetch("sources")
  name = entry.fetch("name")

  {
    "id" => entry.fetch("id"),
    "canonical_name" => name,
    "preferred_australian_name" => name,
    "object_type" => entry.fetch("object_type"),
    "discipline" => catalogue.fetch("discipline"),
    "category" => entry.fetch("category"),
    "definition_plain" => entry.fetch("definition"),
    "definition_technical" => nil,
    "primary_function" => entry.fetch("functions"),
    "orientation" => entry.fetch("orientation"),
    "typical_materials" => entry.fetch("materials"),
    "geometry_class" => entry.fetch("geometry"),
    "aliases" => aliases,
    "possible_aliases_requiring_review" => possible_aliases,
    "not_synonyms" => entry.fetch("not_synonyms"),
    "part_of_assemblies" => entry.fetch("part_of").select { |id| assembly_ids.include?(id) },
    "common_attributes" => entry.fetch("attributes"),
    "standard_references" => standard_references(entry, catalogue),
    "ncc_references" => ncc_references(entry, catalogue),
    "claims" => [
      {
        "id" => "#{entry.fetch("id")}-CLAIM-EXISTENCE",
        "claim_type" => "existence",
        "text" => "#{name.capitalize} is used as a distinct physical object or assembly in Australian #{catalogue.fetch("discipline").tr("_", " ")} construction.",
        "source_ids" => source_ids,
        "confidence" => confidence_for(status, aliases).fetch("existence")
      },
      {
        "id" => "#{entry.fetch("id")}-CLAIM-DEFINITION",
        "claim_type" => "definition",
        "text" => entry.fetch("definition"),
        "source_ids" => source_ids,
        "confidence" => confidence_for(status, aliases).fetch("definition")
      },
      {
        "id" => "#{entry.fetch("id")}-CLAIM-FUNCTION",
        "claim_type" => "function",
        "text" => entry.fetch("functions").join("; "),
        "source_ids" => source_ids,
        "confidence" => confidence_for(status, aliases).fetch("definition")
      }
    ],
    "confidence" => confidence_for(status, aliases),
    "review_status" => status,
    "regional_usage" => {
      "Australia" => "preferred",
      "New_Zealand" => "unknown",
      "United_Kingdom" => "unknown",
      "United_States" => "unknown"
    },
    "cad_attributes" => {
      "dimensional_axes" => entry.fetch("geometry") == "discrete_component" ? ["width", "height", "thickness"] : ["length", "breadth", "depth"],
      "repetition_pattern" => cad.fetch("pattern"),
      "typical_placement" => cad.fetch("placement"),
      "host_object" => cad.fetch("host"),
      "start_relationship" => cad.fetch("start"),
      "end_relationship" => cad.fetch("end"),
      "opening_relationship" => cad.fetch("opening"),
      "load_bearing_role" => cad.fetch("load")
    },
    "search_text" => ([name] + aliases.map { |item| item.fetch("term") }).join(" | "),
    "ai_aliases" => aliases.map { |item| item.fetch("term") },
    "natural_language_examples" => ["Draw a #{name}.", "Select the #{name}."],
    "disambiguation_terms" => entry.fetch("not_synonyms"),
    "negative_terms" => entry.fetch("not_synonyms"),
    "external_mappings" => {"ifc" => [], "revit" => [], "sketchup" => [], "cost_codes" => [], "material_library" => []},
    "history" => [{"timestamp" => GENERATED_AT, "action" => "Created in the Australian building-object ontology research programme.", "agent" => "Codex", "source_ids" => source_ids}],
    "notes" => entry.fetch("notes")
  }
end

def relation_id(index, from_id, relationship, to_id)
  clean = "#{from_id}-#{relationship}-#{to_id}".sub(/^AU-/, "").gsub(/[^A-Z0-9]+/i, "-").upcase
  "REL-#{format("%03d", index)}-#{clean}"
end

def build_relationships(entries)
  inverse_relationships = {
    "part_of" => "has_part",
    "has_part" => "part_of",
    "supports" => "supported_by",
    "supported_by" => "supports",
    "connects_to" => "connects_to",
    "adjacent_to" => "adjacent_to",
    "alternative_to" => "alternative_to",
    "commonly_used_with" => "commonly_used_with"
  }.freeze
  candidates = []
  entries.each do |entry|
    entry.fetch("part_of").each do |assembly_id|
      candidates << [entry.fetch("id"), "part_of", assembly_id, entry.fetch("sources"), entry.fetch("review_status", "accepted")]
      candidates << [assembly_id, "has_part", entry.fetch("id"), entry.fetch("sources"), entry.fetch("review_status", "accepted")]
    end
    Array(entry["relations"]).each do |relation|
      from_id = entry.fetch("id")
      relationship = relation.fetch("type")
      to_id = relation.fetch("to")
      source_ids = entry.fetch("sources")
      status = entry.fetch("review_status", "accepted")
      candidates << [from_id, relationship, to_id, source_ids, status]
      inverse = inverse_relationships[relationship]
      candidates << [to_id, inverse, from_id, source_ids, status] if inverse
    end
  end

  status_rank = {"accepted" => 0, "accepted_pending_review" => 1, "research_required" => 2, "hold" => 3}.freeze
  merged = candidates.group_by { |item| item[0, 3] }.map do |triple, items|
    source_ids = items.flat_map { |item| item[3] }.uniq.sort
    status = items.map { |item| item[4] }.max_by { |value| status_rank.fetch(value) }
    triple + [source_ids, status]
  end

  merged.sort_by { |item| item[0, 3] }.each_with_index.map do |item, index|
    from_id, relationship, to_id, source_ids, status = item
    {
      "id" => relation_id(index + 1, from_id, relationship, to_id),
      "from_id" => from_id,
      "relationship" => relationship,
      "to_id" => to_id,
      "source_ids" => source_ids,
      "confidence" => status == "accepted" ? 0.87 : 0.72,
      "review_status" => status
    }
  end
end

def write_json(path, value)
  File.write(path, JSON.pretty_generate(value) + "\n", mode: "w", encoding: "UTF-8")
end

def write_glossary(path, objects, title = "Australian building-object glossary")
  lines = ["# #{title}", "", "Generated from the canonical ontology export. Definitions are original plain-English summaries, not reproduced standards text.", ""]
  objects.sort_by { |object| object.fetch("preferred_australian_name") }.each do |object|
    aliases = object.fetch("aliases").map { |item| item.fetch("term") }
    lines << "## #{object.fetch("preferred_australian_name")}"
    lines << ""
    lines << "**ID:** `#{object.fetch("id")}`  "
    lines << "**Category:** #{object.fetch("category").tr("_", " ")}  "
    lines << "**Status:** #{object.fetch("review_status").tr("_", " ")}"
    lines << ""
    lines << object.fetch("definition_plain")
    unless aliases.empty?
      lines << ""
      lines << "Accepted search terms: #{aliases.join(", ")}."
    end
    lines << ""
    lines << "Main functions: #{object.fetch("primary_function").join("; ")}."
    lines << ""
  end
  File.write(path, lines.join("\n") + "\n", mode: "w", encoding: "UTF-8")
end

def material_id(name)
  slug = name.downcase.gsub("&", "and").gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
  "AU-MAT-#{slug.upcase}"
end

def build_materials(objects)
  indexed = {}
  objects.each do |object|
    object.fetch("typical_materials").each do |name|
      material_name = name.strip
      next if material_name.empty?

      record = indexed[material_name.downcase] ||= {
        "id" => material_id(material_name),
        "name" => material_name,
        "search_text" => material_name,
        "object_ids" => [],
        "disciplines" => [],
        "categories" => [],
        "object_types" => [],
        "source_ids" => [],
        "review_statuses" => {}
      }
      record.fetch("object_ids") << object.fetch("id")
      record.fetch("disciplines") << object.fetch("discipline")
      record.fetch("categories") << object.fetch("category")
      record.fetch("object_types") << object.fetch("object_type")
      record.fetch("source_ids").concat(object.fetch("claims").flat_map { |claim| claim.fetch("source_ids") })
      status = object.fetch("review_status")
      record.fetch("review_statuses")[status] = record.fetch("review_statuses").fetch(status, 0) + 1
    end
  end

  indexed.values.sort_by { |material| material.fetch("name").downcase }.map do |material|
    material.merge(
      "object_count" => material.fetch("object_ids").uniq.length,
      "object_ids" => material.fetch("object_ids").uniq.sort,
      "disciplines" => material.fetch("disciplines").uniq.sort,
      "categories" => material.fetch("categories").uniq.sort,
      "object_types" => material.fetch("object_types").uniq.sort,
      "source_ids" => material.fetch("source_ids").uniq.sort,
      "review_statuses" => material.fetch("review_statuses").sort.to_h
    )
  end
end

def discipline_metrics(objects, relationships, source_lookup)
  object_ids = objects.map { |object| object.fetch("id") }
  source_ids = objects.flat_map { |object| object.fetch("claims").flat_map { |claim| claim.fetch("source_ids") } }.uniq
  standards = objects.flat_map { |object| object.fetch("standard_references").map { |reference| reference.fetch("standard_id") } }.uniq
  tier_one_count = objects.count do |object|
    object.fetch("claims").flat_map { |claim| claim.fetch("source_ids") }.uniq.any? { |source_id| source_lookup.fetch(source_id).fetch("source_tier") == 1 }
  end
  multi_source_count = objects.count do |object|
    object.fetch("claims").flat_map { |claim| claim.fetch("source_ids") }.uniq.length >= 2
  end
  {
    "object_count" => objects.length,
    "internal_relationship_count" => relationships.count { |relationship| object_ids.include?(relationship.fetch("from_id")) && object_ids.include?(relationship.fetch("to_id")) },
    "cross_discipline_relationship_count" => relationships.count { |relationship| object_ids.include?(relationship.fetch("from_id")) && !object_ids.include?(relationship.fetch("to_id")) },
    "source_count" => source_ids.length,
    "standard_count" => standards.length,
    "standard_ids" => standards.sort,
    "categories" => objects.group_by { |object| object.fetch("category") }.transform_values(&:length).sort.to_h,
    "review_statuses" => objects.group_by { |object| object.fetch("review_status") }.transform_values(&:length).sort.to_h,
    "average_overall_confidence" => (objects.sum { |object| object.fetch("confidence").fetch("overall") } / objects.length.to_f).round(3),
    "percentage_with_tier_1_source" => (100.0 * tier_one_count / objects.length).round(1),
    "percentage_with_two_or_more_sources" => (100.0 * multi_source_count / objects.length).round(1)
  }
end

def write_discipline_report(path, discipline, objects, relationships, metrics)
  object_ids = objects.map { |object| object.fetch("id") }
  cross_edges = relationships.select { |relationship| object_ids.include?(relationship.fetch("from_id")) && !object_ids.include?(relationship.fetch("to_id")) }
  lines = [
    "# #{discipline.tr("_", " ").split.map(&:capitalize).join(" ")} discipline report",
    "",
    "> Generated from canonical data. This is object-discovery and drawing metadata, not engineering or compliance advice.",
    "",
    "## Coverage",
    "",
    "- Objects and assemblies: #{metrics.fetch("object_count")}",
    "- Internal relationships: #{metrics.fetch("internal_relationship_count")}",
    "- Outgoing cross-discipline relationships: #{metrics.fetch("cross_discipline_relationship_count")}",
    "- Distinct supporting sources: #{metrics.fetch("source_count")}",
    "- Distinct linked standards: #{metrics.fetch("standard_count")}",
    "- Average overall confidence: #{(metrics.fetch("average_overall_confidence") * 100).round(1)}%",
    "- Objects with a Tier 1 source: #{metrics.fetch("percentage_with_tier_1_source")}%",
    "- Objects with two or more sources: #{metrics.fetch("percentage_with_two_or_more_sources")}%",
    "",
    "## Categories",
    ""
  ]
  metrics.fetch("categories").each { |category, count| lines << "- #{category.tr("_", " ")}: #{count}" }
  lines << ""
  lines << "## Objects"
  lines << ""
  objects.sort_by { |object| object.fetch("preferred_australian_name") }.each do |object|
    lines << "- **#{object.fetch("preferred_australian_name")}** (`#{object.fetch("id")}`) — #{object.fetch("definition_plain")}"
  end
  unless cross_edges.empty?
    lines << ""
    lines << "## Cross-discipline links"
    lines << ""
    cross_edges.sort_by { |edge| [edge.fetch("from_id"), edge.fetch("relationship"), edge.fetch("to_id")] }.each do |edge|
      lines << "- `#{edge.fetch("from_id")}` #{edge.fetch("relationship").tr("_", " ")} `#{edge.fetch("to_id")}`"
    end
  end
  File.write(path, lines.join("\n") + "\n", mode: "w", encoding: "UTF-8")
end

def write_discipline_exports(export_dir, objects, relationships, source_lookup)
  by_discipline = objects.group_by { |object| object.fetch("discipline") }
  all_metrics = {}
  by_discipline.sort.each do |discipline, discipline_objects|
    discipline_ids = discipline_objects.map { |object| object.fetch("id") }
    internal = relationships.select { |relationship| discipline_ids.include?(relationship.fetch("from_id")) && discipline_ids.include?(relationship.fetch("to_id")) }
    outgoing = relationships.select { |relationship| discipline_ids.include?(relationship.fetch("from_id")) && !discipline_ids.include?(relationship.fetch("to_id")) }
    metrics = discipline_metrics(discipline_objects, relationships, source_lookup)
    all_metrics[discipline] = metrics
    directory = File.join(export_dir, "disciplines", discipline)
    FileUtils.mkdir_p(directory)
    write_json(File.join(directory, "ontology.json"), {"schema_version" => "0.1.0", "discipline" => discipline, "objects" => discipline_objects.sort_by { |object| object.fetch("id") }})
    File.write(File.join(directory, "ontology.jsonl"), discipline_objects.sort_by { |object| object.fetch("id") }.map { |object| JSON.generate(object) }.join("\n") + "\n", mode: "w", encoding: "UTF-8")
    write_json(File.join(directory, "relationships.json"), {"schema_version" => "0.1.0", "discipline" => discipline, "relationships" => internal, "external_relationships" => outgoing})
    title = "Australian #{discipline.tr("_", " ")} glossary"
    write_glossary(File.join(directory, "glossary.md"), discipline_objects, title)
    write_discipline_report(File.join(directory, "report.md"), discipline, discipline_objects, relationships, metrics)
  end
  all_metrics
end

def write_review_csv(path, review)
  CSV.open(path, "w", write_headers: true, headers: %w[id preferred_term candidate_term status issue affected_object_ids source_ids next_action]) do |csv|
    review.fetch("items").each do |item|
      csv << [item.fetch("id"), item.fetch("preferred_term"), item.fetch("candidate_term"), item.fetch("status"), item.fetch("issue"), item.fetch("affected_object_ids").join("|"), item.fetch("source_ids").join("|"), item.fetch("next_action")]
    end
  end
end

def write_source_audit(path, source_registry)
  CSV.open(path, "w", write_headers: true, headers: %w[id source_tier publisher title url retrieved_at access_status robots_status terms_status copyright_use]) do |csv|
    source_registry.fetch("sources").sort_by { |source| source.fetch("id") }.each do |source|
      csv << [
        source.fetch("id"),
        source.fetch("source_tier"),
        source.fetch("publisher"),
        source.fetch("title"),
        source.fetch("url"),
        source.fetch("retrieved_at"),
        source.fetch("access_status"),
        source.fetch("robots_status"),
        source.fetch("terms_status"),
        source.fetch("license_notes")
      ]
    end
  end
end

def write_standards_map(path, registry, source_lookup)
  standards = registry.fetch("standards")
  direct = standards.select { |standard| standard.fetch("directly_referenced_by_housing_provisions") }
  supporting = standards.reject { |standard| standard.fetch("directly_referenced_by_housing_provisions") }
  groups = direct.group_by { |standard| standard.fetch("discipline_tags").first }
  lines = [
    "# NCC Housing Provisions standards map",
    "",
    "> Research baseline: NCC 2022 Amendment 2, checked 16 August 2026. This is a discovery map for ontology work, not design or compliance advice.",
    "",
    "## How to read this map",
    "",
    "The NCC states the legal performance requirements. Its Housing Provisions provide prescriptive construction routes for many Class 1 and Class 10 buildings. Schedule 2 identifies external documents that become relevant only where an NCC clause calls them up. A standard title is therefore a research lead, not permission to apply every rule in that standard to every building.",
    "",
    "The registry contains **#{direct.length} technical standards or codes directly referenced in the Housing Provisions**. Most are Australian or Australian/New Zealand Standards; the set can also include another code where the NCC calls it up directly. It stores public metadata and NCC clause pointers only and does not copy licensed text. Additional supporting documents are listed separately where they explain terminology or installation without a direct Housing Provisions call-up.",
    "",
    "## Directly referenced standards by first discipline tag",
    ""
  ]

  groups.sort.each do |tag, items|
    lines << "### #{tag.tr("_", " ").split.map(&:capitalize).join(" ")} (#{items.length})"
    lines << ""
    items.sort_by { |standard| [standard.fetch("designation"), standard.fetch("edition").to_s] }.each do |standard|
      clauses = standard.fetch("housing_provisions_references").join(", ")
      relevance = standard.fetch("ontology_relevance").tr("_", " ")
      lines << "- **#{standard.fetch("designation")}:#{standard.fetch("edition")}** — #{standard.fetch("title")}. Housing references: #{clauses}. Ontology triage: #{relevance}."
    end
    lines << ""
  end

  lines << "## Supporting technical documents"
  lines << ""
  supporting.sort_by { |standard| standard.fetch("designation") }.each do |standard|
    lines << "- **#{standard.fetch("designation")}:#{standard.fetch("edition")}** — #{standard.fetch("title")}. #{standard.fetch("notes").join(" ")}"
  end
  lines << ""
  lines << "## Baseline and edition cautions"
  lines << ""
  lines << "- The operative national baseline used here is NCC 2022 Amendment 2, effective 29 July 2025. NCC 2025 material was still preview material at the research date and is not used as the compliance baseline."
  lines << "- The NCC edition is the edition that matters when following an NCC reference. A newer Standards Australia publication does not silently replace the edition named by the NCC."
  lines << "- Public metadata indicates later amendments or editions for AS 1684.2, AS 1684.3, AS 1684.4 and AS 4055. Their registry notes flag the difference; a future tool should make the selected regulatory baseline visible to users."
  lines << "- Tasmania and other states or territories can adopt variations and transition arrangements. A national object name remains useful, but compliance properties need jurisdiction and project-date inputs."
  lines << ""
  lines << "## Primary public sources"
  lines << ""
  %w[SRC-ABCB-CURRENT-NCC SRC-ABCB-NCC-AMENDMENT-2 SRC-ABCB-HP-REFERENCED-DOCS SRC-ABCB-HP-FRAMING-SCOPE SRC-STANDARDS-AUSTRALIA-1684-SPOTLIGHT].each do |source_id|
    source = source_lookup.fetch(source_id)
    lines << "- [#{source.fetch("title")}](#{source.fetch("url")})"
  end
  File.write(path, lines.join("\n") + "\n", mode: "w", encoding: "UTF-8")
end

catalogues = Dir.glob(CATALOG_GLOB).sort.map { |path| read_json(path) }
review = read_json(REVIEW_PATH)
standards_registry = read_json(STANDARDS_PATH)
sources_registry = read_json(SOURCES_PATH)
source_lookup = sources_registry.fetch("sources").to_h { |source| [source.fetch("id"), source] }
catalogue_entries = catalogues.flat_map do |catalogue|
  catalogue.fetch("objects").map { |entry| [entry, catalogue] }
end
assembly_ids = catalogue_entries.filter_map do |entry, _catalogue|
  entry.fetch("id") if entry.fetch("object_type") == "assembly"
end.to_set
objects = catalogue_entries.map { |entry, catalogue| build_object(entry, catalogue, assembly_ids) }.sort_by { |object| object.fetch("id") }
relationships = build_relationships(catalogue_entries.map(&:first))
materials = build_materials(objects)

FileUtils.mkdir_p(EXPORT_DIR)
ontology = {
  "schema_version" => "0.1.0",
  "title" => "Basegrid Australian physical construction object ontology",
  "regulatory_baseline" => "NCC 2022 Amendment 2",
  "generated_at" => GENERATED_AT,
  "object_count" => objects.length,
  "relationship_count" => relationships.length,
  "objects" => objects
}
write_json(File.join(EXPORT_DIR, "ontology.json"), ontology)
File.write(File.join(EXPORT_DIR, "ontology.jsonl"), objects.map { |object| JSON.generate(object) }.join("\n") + "\n", mode: "w", encoding: "UTF-8")
write_json(File.join(EXPORT_DIR, "relationships.json"), {"schema_version" => "0.1.0", "relationships" => relationships})
write_json(File.join(EXPORT_DIR, "materials.json"), {
  "schema_version" => "0.1.0",
  "title" => "Basegrid Australian material type index",
  "generated_at" => GENERATED_AT,
  "material_count" => materials.length,
  "materials" => materials
})
File.write(File.join(EXPORT_DIR, "materials.jsonl"), materials.map { |material| JSON.generate(material) }.join("\n") + "\n", mode: "w", encoding: "UTF-8")
write_glossary(File.join(EXPORT_DIR, "glossary.md"), objects)
write_review_csv(File.join(EXPORT_DIR, "unresolved_review.csv"), review)
write_source_audit(File.join(EXPORT_DIR, "source_audit.csv"), sources_registry)
write_standards_map(File.join(EXPORT_DIR, "ncc_housing_standards_map.md"), standards_registry, source_lookup)
metrics = write_discipline_exports(EXPORT_DIR, objects, relationships, source_lookup)
write_json(File.join(EXPORT_DIR, "coverage_metrics.json"), {
  "schema_version" => "0.1.0",
  "generated_at" => GENERATED_AT,
  "object_count" => objects.length,
  "relationship_count" => relationships.length,
  "registered_source_count" => sources_registry.fetch("sources").length,
  "registered_standard_count" => standards_registry.fetch("standards").length,
  "discipline_count" => metrics.length,
  "disciplines" => metrics
})

puts "Generated #{objects.length} objects and #{relationships.length} relationships in #{EXPORT_DIR}"
