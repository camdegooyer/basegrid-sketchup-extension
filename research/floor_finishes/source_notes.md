# Internal floor finishes: source notes and drawing ontology

Research date: 16 August 2026  
Catalogue discipline: `floor_finishes`  
Primary catalogue: `data/catalog/floor_finishes_catalog.json`

## Purpose and result

This slice identifies the physical construction a future SketchUp tool needs to draw internal floor build-ups in Australian houses and similar small buildings. It contains 146 objects and assemblies. The scope runs from the top of the structural floor to the exposed walking surface and its perimeter, seams, movement joints and transitions.

It covers:

- structural particleboard and plywood floor sheets, joints, adhesive, nails, screws and cut-edge treatment;
- substrate inspection, priming, patching, levelling, dry-area screeds, crack isolation and moisture-control layers;
- hardboard, plywood and fibre-cement underlayment sheets and their fasteners;
- solid strip timber, overlay flooring, parquetry and engineered timber;
- tongue-and-groove, end-match, secret-fixing, face-fixing, direct-stick and floating installation topologies;
- laminate, rigid-core hybrid, bamboo and their actual product layers;
- separate foam, acoustic and rubber-cork underlays plus factory-attached plank backing;
- broadloom carpet, direct-stick carpet, carpet tiles and planks;
- carpet pile, backing, underlay, gripper, seams, tapes, hot-melt adhesive, edge sealer and modular adhesive;
- PVC, linoleum and rubber sheet flooring;
- flexible vinyl tile and plank, vinyl-composition tile, rubber tile and self-adhesive tile;
- resilient adhesive beds, retention tape, heat and chemical seams, welding rod, coving, cap strips and corners;
- bonded cork tiles, cork adhesive and protective coatings;
- dry-area ceramic, porcelain and natural-stone tiling;
- tile adhesive, grout, flexible joints, movement profiles, edge trims and stone sealer;
- timber, tile and resilient skirtings, scotia and acoustic perimeter seals; and
- T-mouldings, reducers, cover strips, end caps, carpet transitions, naplock, doorway profiles and expansion-joint covers.

The slice deliberately reuses existing structural floor frames and slabs, wet-area waterproofing assemblies, stair and ramp objects, livable doorway thresholds and hydronic underfloor heating. It does not duplicate them just because a floor finish touches them.

This is an ontology and drawing foundation. It is not a flooring specification, structural design, moisture assessment, acoustic report, slip test, waterproofing design, accessibility assessment, building approval or substitute for the NCC, Australian Standards and selected product instructions.

## Regulatory baseline and jurisdiction

The repository preserves **NCC 2022 Amendment 2** as the extraction baseline for the existing national facts. The applicable edition is still a project input. Australian states and territories adopt the NCC through their own legal systems, with their own dates, transitions, exemptions and variations. For example, the Tasmanian commencement source already recorded in this repository identifies 1 May 2026 for NCC 2025 in that jurisdiction.

Before a tool gives a compliance result it needs, at minimum:

- state or territory;
- building classification;
- relevant approval, design and construction dates;
- adopted NCC edition and amendment;
- local variations and transitional arrangements;
- selected Deemed-to-Satisfy path or Performance Solution; and
- the authorised standard editions and selected product evidence used by the project.

The floor objects remain useful between editions because they describe physical things. Clause numbers, limits, test results and pass states remain versioned evidence attached to those things.

## What the NCC contributes

### Structure and structural particleboard flooring

[NCC Volume Two Part H1](https://ncc.abcb.gov.au/editions/ncc-2022/adopted/volume-two/h-class-1-and-10-buildings/part-h1-structure) includes a Deemed-to-Satisfy route for particleboard structural flooring through AS 1860.2:2006. That creates a regulatory consequence for a real assembly containing sheets, supported edges, joints, adhesive, mechanical fasteners, openings, cut edges and the structural frame below.

AS 1860.2 is a Volume Two structural reference in this route. It is **not** recorded as a direct Housing Provisions Schedule 2 reference, so the repository's direct Housing Provisions standard count remains unchanged.

The drawing tool must not infer sheet thickness, joist spacing, fastener pattern, adhesive bead, wet exposure allowance or edge support from the words particleboard floor. Those values come from the applicable structural path, licensed standard, engineering where required and selected sheet instructions.

### Wet areas

[Housing Provisions Part 10.2](https://ncc.abcb.gov.au/editions/ncc-2022/adopted/housing-provisions/10-health-and-amenity/part-102-wet-area-waterproofing) controls the domestic wet-area context. A tiled bathroom or welded sheet finish is not represented as an ordinary decorative floor with a wet material tag. It belongs to the existing wet-area assembly, which keeps falls, membranes, bond breakers, waterstops, drains, penetrations, wall junctions and doorway terminations visible.

This floor-finish catalogue therefore owns **dry-area** tiling and general resilient finishes. It links to, but does not duplicate, the existing wet-area tiles and waterproof sheet-floor objects.

### Stairs, ramps and slip resistance

[Housing Provisions Part 11.2](https://ncc.abcb.gov.au/editions/ncc-2022/adopted/housing-provisions/11-safe-movement-and-access/part-112-stairway-and-ramp-construction) and AS 4586:2013 create slip-resistance consequences at particular stair, ramp and landing conditions. Slip evidence is attached to the selected surface, nosing or strip in its actual location.

The ontology does not label every generic floor compliant because it has a rough-looking texture. Product classification, test method, direction, condition, wear, contamination, coating and project location all matter.

### Livable internal thresholds

The [ABCB Livable Housing Design Standard](https://www.abcb.gov.au/sites/default/files/resources/2023/Livable-Housing-Design-Standard-2022-1.3.pdf) and its [handbook](https://www.abcb.gov.au/sites/default/files/resources/2023/Livable-Housing-Design-handbook-2022-1.1.pdf) already support the nominated internal doorway and threshold objects.

The floor slice adds the physical profiles that can occur at those junctions: flush strips, T-mouldings, reducers, cover plates, carpet transitions and doorway profiles. The existing livable-housing assembly continues to own the compliance-sensitive doorway, clear opening, local rise and circulation context.

### Other floor-related consequences

Finished floor level affects door clearances, room height, sanitary circulation, stair risers, ramps, thresholds, cabinetry, appliance recesses and service outlets. Those are coordination relationships, not extra floor products.

Hydronic or electric heating below a finish also remains a separate system. The selected finish, adhesive, underlay, screed and heating system need compatible temperature and movement evidence. A heating-loop drawing must not be created by converting the floor finish into a heating layer.

## Standards map

The table describes what each source contributes to object identity. It does not reproduce licensed rules.

| Standard | Public scope used here | Ontology boundary |
| --- | --- | --- |
| [AS 1860.2:2006](https://store.standards.org.au/product/as-1860-2-2006), Amendment 1:2010, reconfirmed 2016 | Installation of particleboard flooring. | Structural sheet installation; not a generic rule for plywood, underlayment or finish boards. |
| [AS/NZS 1860.1:2017](https://store.standards.org.au/product/as-nzs-1860-1-2017) | Particleboard flooring product requirements. | Product identity and evidence; not the site installation method by itself. |
| [AS 1884:2021](https://store.standards.org.au/product/as-1884-2021) | Preparation and installation of resilient sheet and tile flooring, including PVC, hybrid modular, linoleum, rubber and self-adhesive products. | Public scope excludes carpet, timber and cork; those families retain separate sources. |
| [AS 2455.1:2019](https://store.standards.org.au/product/as-2455-1-2019) | General textile floor-covering installation. | Broadloom and bonded carpet systems; not resilient vinyl. |
| [AS 2455.2:2019](https://store.standards.org.au/product/as-2455-2-2019) | Carpet-tile installation. | Modular textile products and their set-out and retention system. |
| [AS 4288:2003](https://store.standards.org.au/product/as-4288-2003), reconfirmed | Soft underlays for textile floor coverings. | Fibrous, non-fibrous and combination carpet underlay; not hard-floor acoustic matting or carpet backing. |
| [AS 4786.2:2005](https://store.standards.org.au/product/as-4786-2-2005), reconfirmed | Sanding and finishing of timber floors. | Site sanding and finish sequence; not a universal timber-floor installation standard. |
| [AS 2796.1:1999](https://store.standards.org.au/product/as-2796-1-1999), reconfirmed | Hardwood milled-product grading and product terminology. | Supports solid hardwood floorboard identity. |
| [AS 4785.1:2002](https://store.standards.org.au/product/as-4785-1-2002), reconfirmed | Softwood milled-product terminology and grading framework. | Supports solid softwood floorboard identity. |
| [AS 3958:2023](https://store.standards.org.au/product/as-3958-2023), Amendment 1:2024 | Installation of ceramic and stone tiles. | Supports dry tiled-floor anatomy here and wet tiling in the waterproofing slice. |
| [AS 13006:2020](https://store.standards.org.au/product/as-13006-2020) | Ceramic-tile definitions, classification and product characteristics. | Product identity; appearance alone does not prove porcelain or another class. |
| [AS 4586:2013](https://store.standards.org.au/product/as-4586-2013) | Classification of new pedestrian surface materials for slip resistance. | Test evidence attached to a selected surface and context, not geometry-generated compliance. |

There is no general AS 4786.1 timber-floor installation document in the source set. Timber installation is instead supported by the applicable structural framing and structural flooring route, the [Australian Timber Flooring Association solid timber standard](https://www.atfa.com.au/shop/ebooks-brochures/solid-timber-flooring-industry-standard-ebook/), [engineered flooring standard](https://www.atfa.com.au/shop/ebooks-brochures/engineered-flooring-industry-standard/), [floating floor guidance](https://www.atfa.com.au/fm-engineered/) and selected manufacturer instructions.

Standards Australia documents are copyrighted. Buildgrid records public titles, status and scope metadata plus original summaries. It does not copy licensed clauses, tables, figures, classifications, test methods or installation dimensions.

## The physical hierarchy in plain English

### Structure, substrate, underlayment and underlay

A floor build-up is easiest to understand from load-bearing construction upward:

1. **Structural frame or slab** carries building loads. Examples are joists, bearers and concrete slab panels already stored in other catalogues.
2. **Structural floor sheet or subfloor** spans or covers that structure and receives later work. Particleboard and structural plywood are examples.
3. **Preparation** makes the receiving surface sound, clean, smooth, flat, suitably dry and otherwise compatible. It can include grinding, patching, priming, moisture treatment or levelling.
4. **Underlayment** is a rigid non-structural sheet or smoothing layer installed to provide a suitable finish substrate. Hardboard, plywood and fibre-cement sheets are examples.
5. **Underlay** is normally a resilient or cushioning layer below a finish. Carpet underlay and floating-floor foam are examples.
6. **Floor finish** is the exposed walking surface: timber, carpet, resilient sheet, tiles, cork or another selected product.
7. **Perimeter and transition construction** closes edges, allows movement, protects junctions and coordinates doorways.

One physical product can perform two roles in a verified system. That does not make the terms synonyms. For example, a structural particleboard sheet may also be the direct substrate for a finish, while a fibre-cement underlay sheet is not automatically structural.

### Flat, level, smooth, dry and sound are different checks

- **Flat** describes variation beneath a straightedge or across a defined span.
- **Level** means horizontal relative to a datum.
- **Smooth** means the surface texture will not telegraph through or damage the finish.
- **Dry enough** means moisture is within the selected substrate, adhesive and finish system's accepted condition.
- **Sound** means the surface and layers are sufficiently stable, bonded and free of weak material for the selected system.

A floor can be flat but sloping, level but locally rough, smooth but damp, or dry but structurally weak. A so-called self-levelling compound does not prove all five conditions.

The tool should store measured survey data, test method, date, limits, high and low points and accepted preparation action separately from the generated compound geometry.

## Structural sheet subfloors

A structural sheet floor contains more than a broad panel surface. Drawable parts and attributes include:

- sheet size, thickness, grade and orientation;
- tongue-and-groove or square edges;
- end joints and supported sheet boundaries;
- adhesive beads on framing;
- nails or screws and their field and edge patterns;
- openings and trimmed boundaries;
- cut-edge sealer where the selected product requires it; and
- exposure history and replacement or repair zones.

Yellow tongue is retained as useful Australian trade search language, not as the canonical product identity. The tool must resolve the actual sheet, colour-code owner, thickness, grade, span and installation instructions.

## Timber floors

### Solid strip and overlay

A solid board has real timber through its thickness. It can be a structural strip spanning supports or a thinner overlay fixed over a continuous substrate. Tongue-and-groove side joints, end matching, secret cleats, face fasteners, adhesive beads or beds and perimeter movement are separate objects or attributes.

Species, grade, moisture condition, cover width, profile, board length distribution and coating are not inferred from a wood texture. The generated layout must also distinguish random lengths, fixed modules, staggered ends and parquet patterns.

### Parquetry

Parquet blocks and mosaic panels are modular timber products bonded in patterns. Herringbone, basketweave and other set-outs are generation patterns, not new materials. Border rows, direction changes and cuts at perimeters remain real geometry.

### Engineered timber

An engineered board normally contains:

- a real timber wear layer or lamella;
- a plywood or other stabilising core;
- a backing veneer or balancing construction;
- factory adhesive between layers;
- a machined side and end joint; and
- a factory coating where supplied prefinished.

The real timber wear layer distinguishes it from a printed laminate or vinyl product. Sanding allowance depends on actual wear-layer thickness and product evidence; the tool must not promise future sanding because the visible face looks like timber.

### Floating floors

A floating floor is a joined raft that is not fixed through its whole field to the substrate. It still contains real restraint and movement details:

- click or glued tongue-and-groove joints between boards;
- separate or factory-attached underlay;
- perimeter movement gap;
- intermediate control or movement breaks where the selected system requires them;
- transition tracks fixed independently of the moving raft; and
- skirting or scotia that covers the gap without clamping the floor.

Floating is not a synonym for loose individual pieces.

### Sanding and finishing

The common phrase sand and polish hides several physical operations and materials: sanding cuts, local filler, sealer or first coat, intermediate abrasion and a final protective coating system. Polyurethane, oil, hardwax oil and other finishes are not the same material.

The model can record the layers and process state, but coating selection, cure, slip, maintenance and compatibility remain product evidence. Raw and factory-finished boards also need different workflows.

## Laminate, hybrid and bamboo

Laminate contains a transparent resin-rich overlay, a printed decorative layer, a high-density fibreboard core and a balancing underside. It can look like timber without containing a real timber wear face.

Hybrid is a market family, not one material. A rigid hybrid plank can contain a transparent polymer wear layer, printed decorative film, stone-polymer composite or wood-polymer composite core, click edge and optional factory-attached underlay. The actual SPC or WPC core must be stored.

A flexible glue-down vinyl plank remains a resilient product. A rigid click hybrid remains a floating composite product. Similar timber print does not merge them.

Strand-woven bamboo is also stored separately from solid timber and timber veneer. Its compressed fibre construction, adhesive, factory coating and dimensional behaviour come from the selected product.

## Carpet systems

### Carpet anatomy

Broadloom carpet can contain pile yarn attached to a primary backing, then stabilised by a secondary backing. Tufted and woven constructions remain separate. Cut pile and loop pile describe exposed yarn geometry, not the backing or installation method.

Carpet tiles and planks are modular products. A factory cushion backing is part of the module; it is not the same as a continuous soft underlay installed across a room.

### Stretch-in carpet

A stretch-in system normally includes broadloom carpet, separate soft underlay and perimeter gripper strip. Smooth edge is common trade language for that strip even though it contains angled pins. The timber strip, pins and substrate fixings are separate drawable parts.

Doorway naplock is a transition profile. It is not the same object as concealed perimeter gripper.

### Carpet seams

A broadloom seam can include:

- prepared and aligned carpet edges;
- reinforcing seam tape beneath the joint;
- hot-melt or other selected seam adhesive bonding the back to the tape; and
- cut-edge sealer binding vulnerable textile edges.

Seam adhesive and edge sealer have different locations and functions. Direct-stick carpet adhesive is also a separate full-area bond below the backing.

### Carpet tiles

Carpet tiles or planks need a modular set-out, directional rule, edge cuts and a selected retention method. Pressure-sensitive adhesive can be releasable or permanent depending on the system. The word tackifier does not prove removal behaviour.

## Resilient sheet, tile and plank

[Australian Resilient Floorcovering Association technical guidance](https://www.arfa.org.au/technical-standards.html), [Forbo Australia's installation resources](https://www.forbo.com/flooring/en-au/installation-floorcare/pievf4) and [Polyflor Australia's sheet installation guide](https://www.polyflor.com.au/sites/au/files/2025-03/Section%203%20Installation%20of%20Sheet.pdf) support the product-neutral anatomy used here.

The catalogue separates:

- flexible PVC sheet;
- linoleum sheet;
- rubber sheet;
- luxury vinyl tile;
- flexible luxury vinyl plank;
- vinyl-composition tile;
- rubber tile;
- self-adhesive tile; and
- rigid-core hybrid modular flooring.

Vinyl is therefore a search term that requires another choice, not enough information to generate a floor.

### Adhesive and retention

A full-spread adhesive bed, pressure-sensitive modular adhesive, factory-applied self-adhesive backing and local adhesive-free retention tape are different interfaces. Adhesive-free commonly means no full-spread wet adhesive; it may still include perimeter, seam or grid tape.

The model stores substrate, backing, adhesive chemistry, application geometry, open or tack time, rolling and moisture limits. Generic glue geometry does not prove compatibility.

### Seams

A resilient sheet seam is the meeting of prepared sheet edges. It may be:

- net fitted where the selected product permits;
- heat welded after grooving, using a compatible weld rod; or
- chemically joined with a product-specific seam compound.

Heat weld, chemical weld and ordinary sheet seam are separate objects. A welded finish seam does not by itself make the entire floor a wet-area waterproofing system.

### Coving

A site-formed cove continues flexible sheet around a cove former and up the wall. A cap strip terminates the top edge. Internal and external corners need different formed or welded geometry.

A preformed resilient skirting is a separate profile bonded to the wall; it is not an integral continuation of the floor sheet. A concealed waterproofing upturn is another layer again.

## Cork floors

Australian cork product information from [Cork Imports Australia](https://www.corkimports.com.au/copenhagen) supports dense agglomerated glue-down tiles with possible decorative veneer, backing and factory coating, plus compatible primer and adhesive. Raw tiles can instead require site sanding, sealing and finishing.

Cork flooring, rubber-cork acoustic underlay and a cork-backed floating plank are different objects. AS 1884 is not assigned to cork because its public scope excludes cork products.

## Dry-area tiles and stone

A dry tiled floor contains prepared substrate, adhesive or bed, tile modules, ordinary grout, selected flexible or movement joints, perimeter details and transitions. Ceramic and natural stone remain different product families. Porcelain is a ceramic classification supported by product evidence, not a visual label.

Grout fills ordinary tile joints. It must not replace a movement joint. A flexible sealant joint or proprietary movement profile needs its own route aligned with the relevant substrate movement. An edge trim protects a tile edge; it is not automatically a movement profile or wet-area waterstop.

Natural stone needs its actual stone identity, finish, thickness, calibration, porosity, staining risk, adhesive compatibility and sealer. A stone sealer is a surface treatment, not waterproofing. Its effect on appearance and slip must not be assumed.

Wet-area tiling stays in the waterproofing catalogue because a finish-only model would hide the membrane, falls, drain and waterstop system.

## Perimeters, transitions and movement

Skirting is ambiguous. It may mean:

- a timber or MDF skirting board fixed to the wall;
- tile skirting;
- a separate preformed resilient skirting;
- integral resilient sheet turned up the wall; or
- in casual speech, a small scotia or quad moulding.

These have different profiles and fixing hosts.

Transitions are also selected by function:

- T-moulding generally covers a narrow same-level joint;
- reducer bridges a local height difference;
- cover strip caps a simple junction;
- end cap protects an exposed finish edge;
- hard-floor-to-carpet trim coordinates two different edge constructions;
- naplock clamps a carpet edge;
- doorway profile coordinates the finish junction with door and jamb geometry; and
- expansion-joint cover spans a moving building or substrate separation.

The tool should choose function and adjoining finish build-ups before it chooses an extrusion shape.

## SketchUp generation rules

1. Start from the structural slab or framed floor already in the model. Do not create a finish floating at an unexplained Z level.
2. Store structural level, substrate level, adhesive or underlay level and finished floor level separately.
3. Select the assembly topology before selecting colour or texture: structural strip, overlay, direct-stick, floating, stretch-in, modular bonded, sheet bonded, tiled or cork.
4. Resolve room exposure. Route wet-area floors through the waterproofing assembly instead of adding a membrane tag to a dry finish.
5. Survey the substrate. Store high and low points, flatness, level, moisture, cracks, joints and preparation zones.
6. Generate actual supplied modules: sheet roll widths, board cover widths, tile modules, plank lengths, carpet widths and underlayment sheet sizes.
7. Keep factory product layers distinct from site-installed layers. Carpet backing, attached plank backing and factory coating move with the product.
8. Keep interfaces drawable: adhesive fields, gripper routes, seam tapes, weld rods, cove formers, cap strips, trims and movement gaps.
9. Expose movement. Do not fill floating-floor gaps or tile movement joints with rigid generic material.
10. Coordinate every doorway with the actual jamb depth, door travel, leaf clearance, adjoining levels, transition profile and any livable-housing route.
11. Coordinate fixed cabinetry, appliances, islands, partitions and services with floor-raised levels and floating-raft restrictions.
12. Treat acoustic, slip, fire, wet-area, thermal and accessibility performance as evidence attached to the selected complete assembly.
13. Support levels of detail. Concept display may show one finish surface; construction display retains modules, seams, fixings, underlays, joints and perimeter parts.
14. Keep selected manufacturer rules as project data. Never invent fastener spacing, adhesive notch, seam temperature, expansion allowance or moisture limit from generic object identity.

## Common ambiguity traps

- floor can mean the structural assembly, room surface, storey or finish;
- subfloor can mean the structural sheet or everything below the finish;
- underlayment and underlay are not synonyms;
- floating does not mean loose individual pieces;
- engineered timber is not laminate;
- hybrid is not one material and is not automatically wet-area waterproof;
- yellow tongue is trade or proprietary language, not a complete sheet specification;
- self-levelling does not prove horizontal, flat, smooth, dry and sound;
- moisture barrier can mean under-slab, liquid slab treatment, floating-floor vapour control or wet-area membrane;
- carpet backing is not separate carpet underlay;
- smooth edge contains gripper pins;
- carpet seam adhesive is not cut-edge sealer;
- vinyl can mean sheet, flexible tile, flexible plank, self-adhesive tile or rigid hybrid;
- a welded resilient seam does not prove complete waterproofing;
- skirting can describe four physically different perimeter details;
- threshold, transition and expansion-joint cover have different roles;
- dry tiled floors and wet-area tiled assemblies must remain separate; and
- sand and polish can mean sanding plus a selected coating system rather than literal polishing.

These issues are recorded as `TERM-347` to `TERM-362` in `data/review/unresolved_terms.json`.

## Deliberate exclusions and next research

This pass does not yet attempt complete object libraries for:

- external decks, balconies, terraces, paving and podium finishes;
- industrial toppings, polished concrete systems, terrazzo and resin floors;
- sports, gym, sprung, raised-access and stage floors;
- commercial kitchen, laboratory, clean-room and heavy-duty hygienic floors;
- tactile indicators and full public-building access-floor detailing;
- proprietary acoustic ceiling-floor test assemblies;
- electric underfloor heating anatomy;
- floor protection during construction;
- repair, demolition and hazardous legacy flooring such as asbestos-containing products; or
- product SKU libraries and manufacturer-specific profile dimensions.

Those are legitimate later slices. They should be researched independently rather than inferred from domestic finish objects.

## Primary supporting sources

- Australian Building Codes Board: [NCC editions](https://ncc.abcb.gov.au/editions-national-construction-code), [Volume Two Part H1](https://ncc.abcb.gov.au/editions/ncc-2022/adopted/volume-two/h-class-1-and-10-buildings/part-h1-structure), [Housing Provisions Part 10.2](https://ncc.abcb.gov.au/editions/ncc-2022/adopted/housing-provisions/10-health-and-amenity/part-102-wet-area-waterproofing) and [Part 11.2](https://ncc.abcb.gov.au/editions/ncc-2022/adopted/housing-provisions/11-safe-movement-and-access/part-112-stairway-and-ramp-construction).
- Standards Australia public catalogue metadata for the standards listed above.
- Australian Timber Flooring Association: [solid timber](https://www.atfa.com.au/shop/ebooks-brochures/solid-timber-flooring-industry-standard-ebook/), [engineered timber](https://www.atfa.com.au/shop/ebooks-brochures/engineered-flooring-industry-standard/), [floating floors](https://www.atfa.com.au/fm-engineered/) and [acoustic underlays](https://www.atfa.com.au/uncategorized/installation-over-acoustic-underlays-consumer/).
- Australian Resilient Floorcovering Association: [technical standards](https://www.arfa.org.au/technical-standards.html).
- ARDEX Australia: [flooring-system technical bulletins](https://ardexaustralia.com/tools/technical-bulletins/flooring-systems/).
- Dunlop Trade Australia: [flexible timber floor leveller](https://dunloptrade.com.au/product/dunlop-level-flex-timber-floor-leveller/).
- Godfrey Hirst Australia: [carpet installation](https://www.godfreyhirst.com/au/news/carpet-installation).
- Forbo Flooring Systems Australia: [installation and floor care](https://www.forbo.com/flooring/en-au/installation-floorcare/pievf4).
- Polyflor Australia: [sheet flooring installation](https://www.polyflor.com.au/sites/au/files/2025-03/Section%203%20Installation%20of%20Sheet.pdf).
- Cork Imports Australia: [cork floor-tile construction and installation](https://www.corkimports.com.au/copenhagen).

