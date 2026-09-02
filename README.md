# HQ Buildgrid

Buildgrid is a fresh-start SketchUp extension project for drawing real Australian building objects. Completed research slices now cover timber framing, cold-formed steel framing, structural steel, concrete foundations and reinforcement, site preparation and drainage, termite-management components, residential masonry, roof coverings, above-ground roof drainage, external wall cladding, external windows and framed glazed doors, reusable glass and glazing components, internal door leaves, frames, trim and hardware, domestic internal wet-area waterproofing systems, external decks, balconies, terraces and above-ground waterproofing, internal wall linings, direct-fixed and suspended ceilings, boards, panels, support grids, fixings, adhesives and joints, residential fire- and smoke-safety construction, residential thermal insulation, condensation control, air sealing and ventilation paths, house-scale stairs, ramps, landings, barriers and handrails, H8 livable-housing construction, H4 dwelling facilities and sound-insulating walls, H7 pools and ancillary construction, house-scale water services, heated water, rainwater, sanitary plumbing, sanitary drainage and onsite wastewater systems, domestic electrical supply, wiring, lighting, communications, solar PV, batteries, EV charging, fixed security and temporary construction power, residential air conditioning, ductwork, evaporative cooling, heat-recovery ventilation and hydronic heating, and architectural paint, clear timber finishes, stains and installed wallcoverings.

The capstone drawing-capture layer adds broad SketchUp object families for the major remaining systems: lifts, platform lifts, escalators, fire sprinklers, hydrants, hose reels, fire indicator panels, smoke-control equipment, gas services, LPG cylinder banks, gas flues, generators, lightning protection, curtain walls, automatic and revolving doors, rapid roller doors, loading dock levellers, access-control hardware, accessible paths, tactile indicators, grabrails, accessible sanitary groups, accessible parking, commercial kitchen hoods, grease arrestors, laboratory benches, fume cupboards, cleanroom panels, retaining walls, subsoil drainage, detention outlet controls, gross pollutant traps and trench drains.

The internal-floor slice adds structural sheets and preparation, timber, laminate, hybrid, bamboo, carpet, resilient sheet and modular flooring, cork, dry-area tile and stone, adhesives, underlays, seams, coving, skirtings and transitions.

## SketchUp extension: first tool slice

The extension entry point is `buildgrid.rb`. Its first vertical slice provides:

- authenticated materials, takeoff-groups and generated-role configuration sync with a last-known-good local cache;
- selection of active `Concrete` / `bulk` / `m3` web materials;
- a face-based slab generated below one selected horizontal face while retaining the source face and its openings;
- stable tool, generated-role and material UUID metadata on the slab group;
- a user-specific default tag folder, with the initial `Slab | Concrete` tag under `Structure`;
- selectable web-managed takeoff groups stored on each slab, plus grouped totals, refresh and CSV export; and
- a model-wide toolbar command that switches generated objects between synced model and display textures without changing takeoff.

The web endpoint required by the extension is specified in [the material sync contract](docs/MATERIAL_SYNC_CONTRACT.md).

For local SketchUp development, install the direct loader for the installed SketchUp version:

```powershell
.\scripts\install_dev_loader.ps1 -SketchUpVersion 2026
```

Restart SketchUp after installing the loader. The commands appear under **Extensions > Buildgrid**. **Materials > Connect** opens the browser-based OAuth connection. **Connect with Token** remains available during migration.

The decorative-finishes slice adds 105 physical objects and assemblies covering substrate repairs, primers, sealers, undercoats, opaque and clear coating films, texture coatings, timber oils and stains, lead-paint encapsulation fields, wallpaper materials and adhesives, installed drops and mural panels, seams, corners and trimmed edges. Decorative paint remains separate from structural-steel protection, fire coatings, wet-area membranes and external-wall weatherproofing evidence.

The concrete-structures slice adds 186 physical objects and assemblies covering concrete constituents, cast-in-place frames and suspended floors, piles and pile caps, reinforcement products and arrangements, joints, waterstops, embeds, blockouts, post-tensioning, prefabricated concrete and formwork or falsework. It keeps permanent structure, temporary works and lifecycle states separate, and does not infer structural adequacy from drawn geometry.

The expanded masonry slice now contains 176 objects and assemblies. It adds purpose-made units and bonds, reinforced blockwork, connectors and shelf supports, AAC block and panel systems, four distinct stone-construction methods, mud-brick, compressed-earth and rammed-earth construction, and solid-render layers and accessories. Material, product shape, installed role and temporary construction state remain separate, and engineered geometry must come from project evidence.

The external-door slice adds 237 physical objects and assemblies covering solid and composite entrance doors, security and insect screens, louvred and roller shutters, sectional, roller and tilt garage doors, counterbalance mechanisms, supports, powered operators, controls and protective devices. Moving, stored and service envelopes remain separate, and security, wind and safety performance must come from selected-system evidence.

The decks-and-balconies slice adds 219 objects and assemblies covering open-jointed and waterproof platforms, framing and connections, timber and manufactured decking, external membranes and terminations, bonded tile finishes, point and linear drainage, scuppers and overflows, pedestal-supported pavers and deck tiles, built-in planters, under-deck drainage and balcony soffit interfaces. Housing Provisions Part 12.3 remains a narrow waling-plate attachment route; NCC Volume Two H2D8 and AS 4654 Parts 1 and 2 provide the external-waterproofing spine where applicable.

Start with the [research guide](docs/ONTOLOGY_RESEARCH_GUIDE.md), the [drawing-ontology coverage note](docs/DRAWING_ONTOLOGY_COVERAGE.md), the generated [plain-English glossary](exports/glossary.md), the generated [material type index](exports/materials.json), the [SketchUp tool definitions](docs/SKETCHUP_TOOL_DEFINITIONS.md), and the [NCC Housing Provisions standards map](exports/ncc_housing_standards_map.md).

## Generate and validate

The tooling uses Ruby's standard library only, matching SketchUp's implementation environment and remaining portable across Windows and macOS.

```powershell
ruby scripts/generate_ontology_outputs.rb
ruby scripts/validate_ontology.rb
```

The current export contains 3,570 objects and assemblies, 8,836 deduplicated directional relationships, 5,707 indexed material labels, 213 standards, 547 sources, claim-level provenance and a separate unresolved-terminology queue. Thirty discipline folders can also be consumed independently. It is research and drawing metadata, not engineering or compliance advice.

## Repository map

- `config/` — jurisdiction, baseline, research policy and SketchUp tool definitions.
- `data/` — reviewed catalogues and source, standards and review registries.
- `schemas/` — portable JSON record contracts.
- `scripts/` — deterministic generation and validation.
- `exports/` — generated ontology, material index, relationships, glossary, standards map and audits.
- `docs/` — confirmed decisions and the research guide.
- `src/` — product code for consuming the ontology and, later, SketchUp command implementations.
- `test/` — focused checks for implemented behaviour.
