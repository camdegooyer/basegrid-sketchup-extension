# frozen_string_literal: true

require "json"
require "minitest/autorun"

class OntologyValidationTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def read_json(path)
    JSON.parse(File.read(File.join(ROOT, path), encoding: "UTF-8"))
  end

  def setup
    @ontology = read_json("exports/ontology.json")
    @relationships = read_json("exports/relationships.json").fetch("relationships")
    @standards = read_json("data/standards/standards_registry.json").fetch("standards")
    @sources = read_json("data/sources/source_registry.json").fetch("sources")
    @sketchup_tools = read_json("config/sketchup_tool_definitions.json")
  end

  def test_pilot_has_every_planned_framing_category
    categories = @ontology.fetch("objects").map { |object| object.fetch("category") }.uniq

    %w[wall_framing floor_framing conventional_roof_framing nailplated_roof_trusses].each do |category|
      assert_includes categories, category
    end
  end

  def test_completed_disciplines_are_present_and_independently_exported
    disciplines = @ontology.fetch("objects").map { |object| object.fetch("discipline") }.uniq

    %w[timber_framing concrete_foundations site_civil termite_management].each do |discipline|
      assert_includes disciplines, discipline
      path = File.join(ROOT, "exports", "disciplines", discipline, "ontology.json")
      assert File.file?(path), "missing discipline export for #{discipline}"
      exported = JSON.parse(File.read(path, encoding: "UTF-8")).fetch("objects")
      assert exported.all? { |object| object.fetch("discipline") == discipline }
    end
  end

  def test_every_relationship_resolves_to_objects_and_sources
    object_ids = @ontology.fetch("objects").map { |object| object.fetch("id") }
    source_ids = @sources.map { |source| source.fetch("id") }

    @relationships.each do |relationship|
      assert_includes object_ids, relationship.fetch("from_id")
      assert_includes object_ids, relationship.fetch("to_id")
      assert_empty relationship.fetch("source_ids") - source_ids
    end
  end

  def test_every_claim_has_registered_provenance
    source_ids = @sources.map { |source| source.fetch("id") }

    @ontology.fetch("objects").each do |object|
      refute_empty object.fetch("claims")
      object.fetch("claims").each do |claim|
        refute_empty claim.fetch("source_ids")
        assert_empty claim.fetch("source_ids") - source_ids
      end
    end
  end

  def test_sketchup_tool_definitions_reference_existing_ontology_objects
    object_ids = @ontology.fetch("objects").map { |object| object.fetch("id") }
    tool_ids = @sketchup_tools.fetch("tools").map { |tool| tool.fetch("id") }
    detail_levels = @sketchup_tools.fetch("detail_levels")

    assert_equal tool_ids.uniq.length, tool_ids.length
    assert_operator tool_ids.length, :>=, 10

    @sketchup_tools.fetch("tools").each do |tool|
      assert_includes detail_levels, tool.fetch("default_detail_level")
      refute_empty tool.fetch("required_object_ids")
      refute_empty tool.fetch("draw_behaviour")
      refute_empty tool.fetch("never_infer")

      referenced_ids = [tool.fetch("root_object_id")] + tool.fetch("required_object_ids") + tool.fetch("optional_object_ids")
      referenced_ids.each do |id|
        assert_includes object_ids, id, "#{tool.fetch("id")} references missing ontology object #{id}"
      end
    end
  end

  def test_housing_provisions_standards_count_is_locked_to_audited_baseline
    direct = @standards.count { |standard| standard.fetch("directly_referenced_by_housing_provisions") }

    assert_equal 64, direct
  end

  def test_disputed_terms_are_not_accepted_as_exact_aliases
    objects = @ontology.fetch("objects").to_h { |object| [object.fetch("id"), object] }
    jack_terms = objects.fetch("AU-TF-JACK-STUD").fetch("aliases").map { |item| item.fetch("term").downcase }
    jamb_terms = objects.fetch("AU-TF-JAMB-STUD").fetch("aliases").map { |item| item.fetch("term").downcase }

    refute_includes jack_terms, "trimmer stud"
    refute_includes jack_terms, "jamb stud"
    refute_includes jamb_terms, "jack stud"
  end

  def test_foundation_roles_that_share_shapes_remain_separate_objects
    objects = @ontology.fetch("objects").to_h { |object| [object.fetch("id"), object] }

    assert_equal "foundation material", objects.fetch("AU-CF-FOUNDATION-MATERIAL").fetch("canonical_name")
    assert_equal "strip footing", objects.fetch("AU-CF-STRIP-FOOTING").fetch("canonical_name")
    assert_equal "slab edge beam", objects.fetch("AU-CF-EDGE-BEAM").fetch("canonical_name")
    refute_equal objects.fetch("AU-CF-STRIP-FOOTING").fetch("id"), objects.fetch("AU-CF-EDGE-BEAM").fetch("id")
    refute_equal objects.fetch("AU-CF-SLAB-VOID-FORMER").fetch("id"), objects.fetch("AU-CF-WAFFLE-POD").fetch("id")
  end

  def test_internal_door_construction_roles_remain_separate_and_linked
    objects = @ontology.fetch("objects").to_h { |object| [object.fetch("id"), object] }
    interior_doors = objects.values.select { |object| object.fetch("discipline") == "interior_doors" }

    assert_equal 98, interior_doors.length
    assert_equal "leaf", objects.fetch("AU-ID-HOLLOW-CORE-FLUSH-DOOR-LEAF").fetch("object_type")
    assert_equal "frame", objects.fetch("AU-ID-TIMBER-INTERNAL-DOOR-JAMB-SET").fetch("object_type")
    assert_equal "member", objects.fetch("AU-ID-DOOR-LEAF-STILE").fetch("object_type")
    refute_equal objects.fetch("AU-ID-DOOR-LEAF-STILE").fetch("id"), objects.fetch("AU-LH-INTERNAL-DOOR-FRAME-JAMB").fetch("id")
    refute_equal objects.fetch("AU-ID-INTERNAL-DOOR-STOP-ASSEMBLY").fetch("id"), objects.fetch("AU-LH-INTERNAL-DOOR-STOP-MOULDING").fetch("id")
    assert interior_doors.all? { |object| object.fetch("claims").all? { |claim| claim.fetch("source_ids").length >= 2 } }
  end

  def test_floor_finish_layers_products_and_installation_roles_remain_separate
    objects = @ontology.fetch("objects").to_h { |object| [object.fetch("id"), object] }
    floor_finishes = objects.values.select { |object| object.fetch("discipline") == "floor_finishes" }
    triples = @relationships.map { |edge| [edge.fetch("from_id"), edge.fetch("relationship"), edge.fetch("to_id")] }

    assert_equal 146, floor_finishes.length
    assert_equal "sheet", objects.fetch("AU-FF-STRUCTURAL-PARTICLEBOARD-FLOOR-SHEET").fetch("object_type")
    assert_equal "assembly", objects.fetch("AU-FF-FLOOR-UNDERLAYMENT-SHEET-ASSEMBLY").fetch("object_type")
    assert_equal "layer", objects.fetch("AU-FF-FOAM-FLOATING-FLOOR-UNDERLAY").fetch("object_type")
    refute_equal objects.fetch("AU-FF-CARPET-PRIMARY-BACKING").fetch("id"), objects.fetch("AU-FF-CARPET-SOFT-UNDERLAY").fetch("id")
    refute_equal objects.fetch("AU-FF-ENGINEERED-TIMBER-WEAR-LAYER").fetch("id"), objects.fetch("AU-FF-LAMINATE-WEAR-OVERLAY").fetch("id")
    refute_equal objects.fetch("AU-FF-LUXURY-VINYL-PLANK").fetch("id"), objects.fetch("AU-FF-HYBRID-RIGID-CORE-PLANK").fetch("id")
    refute_equal objects.fetch("AU-FF-DRY-AREA-CERAMIC-FLOOR-TILE").fetch("id"), objects.fetch("AU-WP-WET-AREA-FLOOR-TILE").fetch("id")
    assert_includes triples, ["AU-FF-ENGINEERED-TIMBER-FLOORBOARD", "has_part", "AU-FF-ENGINEERED-TIMBER-WEAR-LAYER"]
    assert_includes triples, ["AU-FF-RESILIENT-SHEET-SEAM", "has_part", "AU-FF-HEAT-WELDED-RESILIENT-SEAM"]
    assert floor_finishes.all? { |object| object.fetch("claims").all? { |claim| claim.fetch("source_ids").length >= 2 } }
  end

  def test_decorative_finish_coats_timber_finishes_and_wallcovering_roles_remain_separate
    objects = @ontology.fetch("objects").to_h { |object| [object.fetch("id"), object] }
    decorative_finishes = objects.values.select { |object| object.fetch("discipline") == "decorative_finishes" }
    triples = @relationships.map { |edge| [edge.fetch("from_id"), edge.fetch("relationship"), edge.fetch("to_id")] }

    assert_equal 105, decorative_finishes.length
    assert_equal "assembly", objects.fetch("AU-DF-ARCHITECTURAL-SURFACE-FINISH-SYSTEM").fetch("object_type")
    assert_equal "coating", objects.fetch("AU-DF-OPAQUE-PAINT-DRY-FILM").fetch("object_type")
    assert_equal "sheet", objects.fetch("AU-DF-WALLPAPER-DROP").fetch("object_type")
    assert_equal "panel", objects.fetch("AU-DF-WALL-MURAL-PANEL").fetch("object_type")
    refute_equal objects.fetch("AU-DF-TIMBER-PRIMER").fetch("id"), objects.fetch("AU-DF-PAINT-UNDERCOAT").fetch("id")
    refute_equal objects.fetch("AU-DF-WATER-BORNE-TIMBER-STAIN").fetch("id"), objects.fetch("AU-DF-PENETRATING-TIMBER-OIL").fetch("id")
    refute_equal objects.fetch("AU-DF-FACTORY-READY-PASTE-COATING").fetch("id"), objects.fetch("AU-DF-PRESSURE-SENSITIVE-WALLCOVERING-BACKING").fetch("id")
    refute_equal objects.fetch("AU-DF-WET-AREA-DECORATIVE-PAINT").fetch("id"), objects.fetch("AU-WP-WET-AREA-MEMBRANE").fetch("id")
    assert_includes triples, ["AU-DF-LEAD-PAINT-ENCAPSULATION-SYSTEM", "has_part", "AU-DF-LEAD-PAINT-RETAINED-FIELD"]
    assert_includes triples, ["AU-DF-WALL-MURAL-ASSEMBLY", "has_part", "AU-DF-WALL-MURAL-PANEL"]
    assert_includes triples, ["AU-DF-WALLCOVERING-FINISH-SYSTEM", "has_part", "AU-DF-WALLCOVERING-ADHESIVE-FILM"]
    assert decorative_finishes.all? { |object| object.fetch("claims").all? { |claim| claim.fetch("source_ids").length >= 2 } }
  end

  def test_concrete_material_members_temporary_works_and_lifecycle_roles_remain_separate
    objects = @ontology.fetch("objects").to_h { |object| [object.fetch("id"), object] }
    concrete_structures = objects.values.select { |object| object.fetch("discipline") == "concrete_structures" }
    triples = @relationships.map { |edge| [edge.fetch("from_id"), edge.fetch("relationship"), edge.fetch("to_id")] }

    assert_equal 186, concrete_structures.length
    assert_equal "other_physical_object", objects.fetch("AU-CF-CONCRETE-MATERIAL").fetch("object_type")
    assert_equal "panel", objects.fetch("AU-CS-FLAT-PLATE-SLAB").fetch("object_type")
    assert_equal "assembly", objects.fetch("AU-CS-FLAT-SLAB").fetch("object_type")
    assert_equal "cable", objects.fetch("AU-CS-PRESTRESSING-STRAND").fetch("object_type")
    assert_equal "temporary_element", objects.fetch("AU-CS-PRECAST-LIFTING-CLUTCH").fetch("object_type")
    refute_equal objects.fetch("AU-CF-CONCRETE-MATERIAL").fetch("id"), objects.fetch("AU-CS-CEMENTITIOUS-BINDER").fetch("id")
    refute_equal objects.fetch("AU-CS-STARTER-REINFORCING-BAR").fetch("id"), objects.fetch("AU-CS-CONCRETE-JOINT-DOWEL-BAR").fetch("id")
    refute_equal objects.fetch("AU-CS-BONDED-MULTISTRAND-TENDON").fetch("id"), objects.fetch("AU-CS-PRESTRESSING-STRAND").fetch("id")
    refute_equal objects.fetch("AU-CS-CAST-IN-LIFTING-ANCHOR").fetch("id"), objects.fetch("AU-CS-PRECAST-LIFTING-CLUTCH").fetch("id")
    assert_includes triples, ["AU-CF-CONCRETE-MATERIAL", "commonly_used_with", "AU-CS-CEMENTITIOUS-BINDER"]
    assert_includes triples, ["AU-CS-FORMWORK-AND-FALSEWORK-SYSTEM", "has_part", "AU-CS-FORM-FACE"]
    assert_includes triples, ["AU-CS-FORMWORK-AND-FALSEWORK-SYSTEM", "has_part", "AU-CS-FALSEWORK-ASSEMBLY"]
    assert concrete_structures.all? { |object| object.fetch("claims").all? { |claim| claim.fetch("source_ids").length >= 2 } }
  end

  def test_advanced_masonry_units_members_systems_and_construction_methods_remain_separate
    objects = @ontology.fetch("objects").to_h { |object| [object.fetch("id"), object] }
    masonry = objects.values.select { |object| object.fetch("discipline") == "masonry" }
    advanced_ids = read_json("data/catalog/advanced_masonry_catalog.json").fetch("objects").map { |object| object.fetch("id") }
    advanced_masonry = advanced_ids.map { |id| objects.fetch(id) }
    triples = @relationships.map { |edge| [edge.fetch("from_id"), edge.fetch("relationship"), edge.fetch("to_id")] }

    assert_equal 176, masonry.length
    assert_equal 122, advanced_masonry.length
    assert_equal "block", objects.fetch("AU-MA-BOND-BEAM-MASONRY-UNIT").fetch("object_type")
    assert_equal "member", objects.fetch("AU-MA-REINFORCED-MASONRY-BOND-BEAM").fetch("object_type")
    assert_equal "block", objects.fetch("AU-MA-AAC-MASONRY-BLOCK").fetch("object_type")
    assert_equal "assembly", objects.fetch("AU-MA-AAC-BLOCK-WALL").fetch("object_type")
    assert_equal "assembly", objects.fetch("AU-MA-TIED-STONE-VENEER-WALL").fetch("object_type")
    assert_equal "assembly", objects.fetch("AU-MA-ADHERED-STONE-VENEER-SYSTEM").fetch("object_type")
    assert_equal "assembly", objects.fetch("AU-MA-ANCHORED-STONE-FACADE").fetch("object_type")
    assert_equal "layer", objects.fetch("AU-MA-RAMMED-EARTH-LIFT").fetch("object_type")
    assert_equal "mesh", objects.fetch("AU-MA-RENDER-EXPANDED-METAL-LATH").fetch("object_type")
    refute_equal objects.fetch("AU-MA-BOND-BEAM-MASONRY-UNIT").fetch("id"), objects.fetch("AU-MA-REINFORCED-MASONRY-BOND-BEAM").fetch("id")
    refute_equal objects.fetch("AU-MA-AAC-MASONRY-BLOCK").fetch("id"), objects.fetch("AU-CL-REINFORCED-AAC-WALL-PANEL").fetch("id")
    refute_equal objects.fetch("AU-MA-RENDER-REINFORCING-MESH").fetch("id"), objects.fetch("AU-MA-RENDER-EXPANDED-METAL-LATH").fetch("id")
    assert_includes triples, ["AU-MA-REINFORCED-MASONRY-BOND-BEAM", "has_part", "AU-MA-BOND-BEAM-MASONRY-UNIT"]
    assert_includes triples, ["AU-MA-AAC-BLOCK-WALL", "has_part", "AU-MA-AAC-MASONRY-BLOCK"]
    assert_includes triples, ["AU-MA-ANCHORED-STONE-FACADE", "has_part", "AU-MA-STONE-FACADE-PANEL"]
    assert_includes triples, ["AU-MA-SOLID-RENDER-SYSTEM", "has_part", "AU-MA-RENDER-BASE-COAT"]
    assert advanced_masonry.all? { |object| object.fetch("claims").all? { |claim| claim.fetch("source_ids").length >= 2 } }
  end

  def test_external_door_screen_shutter_and_garage_mechanisms_remain_separate_and_linked
    objects = @ontology.fetch("objects").to_h { |object| [object.fetch("id"), object] }
    external_doors = objects.values.select { |object| object.fetch("discipline") == "external_doors" }
    catalogue_ids = read_json("data/catalog/external_doors_catalog.json").fetch("objects").map { |object| object.fetch("id") }
    triples = @relationships.map { |edge| [edge.fetch("from_id"), edge.fetch("relationship"), edge.fetch("to_id")] }
    disciplines = objects.values.map { |object| object.fetch("discipline") }.uniq

    assert_equal 237, external_doors.length
    assert_equal catalogue_ids.sort, external_doors.map { |object| object.fetch("id") }.sort
    assert_equal 30, disciplines.length
    assert File.file?(File.join(ROOT, "exports", "disciplines", "external_doors", "ontology.json"))

    assert_equal "leaf", objects.fetch("AU-ED-EXTERNAL-DOOR-LEAF").fetch("object_type")
    assert_equal "mesh", objects.fetch("AU-ED-WOVEN-STAINLESS-SECURITY-MESH").fetch("object_type")
    assert_equal "section", objects.fetch("AU-ED-ROLLER-SHUTTER-SLAT").fetch("object_type")
    assert_equal "panel", objects.fetch("AU-ED-SECTIONAL-DOOR-PANEL").fetch("object_type")
    assert_equal "member", objects.fetch("AU-ED-GARAGE-DOOR-TORSION-SPRING").fetch("object_type")
    assert_equal "cable", objects.fetch("AU-ED-GARAGE-DOOR-LIFT-CABLE").fetch("object_type")
    assert_equal "assembly", objects.fetch("AU-ED-GARAGE-DOOR-PHOTOELECTRIC-BEAM-ASSEMBLY").fetch("object_type")
    assert_equal "unit", objects.fetch("AU-ED-GARAGE-OPERATOR-SMART-CONTROLLER").fetch("object_type")

    refute_equal objects.fetch("AU-ED-SECURITY-SCREEN-SYSTEM").fetch("id"), objects.fetch("AU-ED-HINGED-INSECT-SCREEN-DOOR").fetch("id")
    refute_equal objects.fetch("AU-ED-DOMESTIC-EXTERIOR-ROLLER-SHUTTER").fetch("id"), objects.fetch("AU-ED-ROLLER-GARAGE-DOOR").fetch("id")
    refute_equal objects.fetch("AU-ED-SECTIONAL-DOOR-PANEL").fetch("id"), objects.fetch("AU-ED-ONE-PIECE-TILT-DOOR-PANEL").fetch("id")
    refute_equal objects.fetch("AU-ED-GARAGE-DOOR-COUNTERBALANCE-ASSEMBLY").fetch("id"), objects.fetch("AU-ED-GARAGE-DOOR-OPERATOR-SYSTEM").fetch("id")
    refute_equal objects.fetch("AU-ED-GARAGE-DOOR-LIFT-CABLE").fetch("id"), objects.fetch("AU-ED-GARAGE-OPERATOR-DRIVE-CHAIN").fetch("id")
    refute_equal objects.fetch("AU-ED-GARAGE-DOOR-PHOTOELECTRIC-BEAM-ASSEMBLY").fetch("id"), objects.fetch("AU-ED-GARAGE-DOOR-SAFETY-EDGE").fetch("id")

    assert_includes triples, ["AU-ED-SECTIONAL-GARAGE-DOOR", "has_part", "AU-ED-SECTIONAL-DOOR-PANEL"]
    assert_includes triples, ["AU-ED-SECTIONAL-DOOR-PANEL", "has_part", "AU-ED-SECTIONAL-DOOR-VISION-INSERT"]
    assert_includes triples, ["AU-ED-GARAGE-DOOR-COUNTERBALANCE-ASSEMBLY", "has_part", "AU-ED-GARAGE-DOOR-TORSION-SPRING"]
    assert_includes triples, ["AU-ED-ROLLER-GARAGE-DOOR", "has_part", "AU-ED-ROLLER-GARAGE-DOOR-WIND-LOCK"]
    assert_includes triples, ["AU-ED-GARAGE-DOOR-OPERATOR-SYSTEM", "has_part", "AU-ED-GARAGE-DOOR-PHOTOELECTRIC-BEAM-ASSEMBLY"]
    assert_includes triples, ["AU-ED-SECTIONAL-GARAGE-DOOR", "is_a", "AU-ED-LARGE-ACCESS-DOOR-SYSTEM"]
    assert_includes triples, ["AU-ED-DOMESTIC-EXTERIOR-ROLLER-SHUTTER", "is_a", "AU-ED-ROLLER-SHUTTER-ASSEMBLY"]

    assert external_doors.all? { |object| object.fetch("claims").all? { |claim| claim.fetch("source_ids").length >= 2 } }
  end

  def test_deck_balcony_waterproofing_and_raised_finish_families_remain_separate_and_linked
    objects = @ontology.fetch("objects").to_h { |object| [object.fetch("id"), object] }
    decks_balconies = objects.values.select { |object| object.fetch("discipline") == "decks_balconies" }
    catalogue_ids = read_json("data/catalog/decks_balconies_catalog.json").fetch("objects").map { |object| object.fetch("id") }
    triples = @relationships.map { |edge| [edge.fetch("from_id"), edge.fetch("relationship"), edge.fetch("to_id")] }

    assert_equal 219, decks_balconies.length
    assert_equal catalogue_ids.sort, decks_balconies.map { |object| object.fetch("id") }.sort
    assert File.file?(File.join(ROOT, "exports", "disciplines", "decks_balconies", "ontology.json"))

    assert_equal "assembly", objects.fetch("AU-DB-OPEN-JOINTED-DECK-ASSEMBLY").fetch("object_type")
    assert_equal "board", objects.fetch("AU-DB-DECKING-BOARD").fetch("object_type")
    assert_equal "membrane", objects.fetch("AU-DB-EXTERNAL-WATERPROOFING-MEMBRANE").fetch("object_type")
    assert_equal "assembly", objects.fetch("AU-DB-BALCONY-POINT-DRAIN-ASSEMBLY").fetch("object_type")
    assert_equal "assembly", objects.fetch("AU-DB-ADJUSTABLE-PEDESTAL-SUPPORT-SYSTEM").fetch("object_type")
    assert_equal "panel", objects.fetch("AU-DB-EXTERIOR-BALCONY-TILE").fetch("object_type")
    assert_equal "membrane", objects.fetch("AU-DB-PLANTER-ROOT-BARRIER").fetch("object_type")
    assert_equal "drain", objects.fetch("AU-DB-UNDERDECK-DRAINAGE-TRAY").fetch("object_type")

    refute_equal objects.fetch("AU-DB-OPEN-JOINTED-DECK-ASSEMBLY").fetch("id"), objects.fetch("AU-DB-EXTERNAL-WATERPROOFED-PLATFORM-ASSEMBLY").fetch("id")
    refute_equal objects.fetch("AU-DB-EXTERIOR-PORCELAIN-TILE").fetch("id"), objects.fetch("AU-DB-PORCELAIN-PEDESTAL-PAVER").fetch("id")
    refute_equal objects.fetch("AU-DB-BALCONY-DRAINAGE-SYSTEM").fetch("id"), objects.fetch("AU-DB-BALCONY-OVERFLOW-SYSTEM").fetch("id")
    refute_equal objects.fetch("AU-DB-BALCONY-SOFFIT-ENCLOSURE-ASSEMBLY").fetch("id"), objects.fetch("AU-DB-UNDERDECK-DRAINAGE-ASSEMBLY").fetch("id")

    assert_includes triples, ["AU-DB-DECK-SUPPORT-FRAME", "has_part", "AU-DB-DECK-JOIST-FIELD"]
    assert_includes triples, ["AU-DB-EXTERNAL-WATERPROOFED-PLATFORM-ASSEMBLY", "has_part", "AU-DB-EXTERNAL-WATERPROOFING-MEMBRANE"]
    assert_includes triples, ["AU-DB-TILED-BALCONY-ASSEMBLY", "has_part", "AU-DB-EXTERIOR-BALCONY-TILE"]
    assert_includes triples, ["AU-DB-TERRACE-PLANTER-WATERPROOFING-ASSEMBLY", "has_part", "AU-DB-PLANTER-ROOT-BARRIER"]
    assert_includes triples, ["AU-DB-UNDERDECK-DRAINAGE-ASSEMBLY", "has_part", "AU-DB-UNDERDECK-DRAINAGE-TRAY"]

    assert decks_balconies.all? { |object| object.fetch("claims").all? { |claim| !claim.fetch("source_ids").empty? } }
  end

  def test_relationship_triples_are_unique_and_required_inverses_exist
    triples = @relationships.map { |edge| [edge.fetch("from_id"), edge.fetch("relationship"), edge.fetch("to_id")] }
    assert_equal triples.uniq.length, triples.length
    edge_set = triples.to_h { |triple| [triple, true] }
    inverses = {
      "part_of" => "has_part",
      "has_part" => "part_of",
      "supports" => "supported_by",
      "supported_by" => "supports",
      "connects_to" => "connects_to",
      "adjacent_to" => "adjacent_to",
      "alternative_to" => "alternative_to",
      "commonly_used_with" => "commonly_used_with"
    }

    @relationships.each do |edge|
      inverse = inverses[edge.fetch("relationship")]
      next unless inverse

      expected = [edge.fetch("to_id"), inverse, edge.fetch("from_id")]
      assert edge_set[expected], "missing inverse edge #{expected.join(" ")}"
    end
  end
end
