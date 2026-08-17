# Roof covering research notes

Research date: 16 August 2026. Regulatory baseline: NCC 2022 Amendment 2.

These notes identify physical roof-covering objects for future SketchUp tools. They do not reproduce licensed Australian Standards, roof-design tables, wind-fixing schedules or manufacturer instructions, and they are not engineering or compliance advice.

## Regulatory paths

NCC Volume Two H1D7 exposes several roof-cladding paths rather than one interchangeable roofing rule:

- metal sheet roofing can follow AS 1562.1, while Housing Provisions Part 7.2 provides a limited metal-sheet path within its stated scope;
- plastic sheet roofing follows AS 1562.3;
- concrete and terracotta roof tiles use AS 2049 for products and AS 2050 or the applicable Housing Provisions Part 7.3 path for installation; and
- non-interlocking terracotta, fibre-cement and timber slates and shingles follow AS 4597.

The project must resolve covering family before selecting geometry or a compliance path. A generic roof plane does not tell a tool whether it needs lapped profiled sheets, concealed clips, individual interlocking tiles or individually fixed non-interlocking slates.

## Metal sheet roofing

Housing Provisions Part 7.2 and the Lysaght installation manual support a component model containing:

- profiled metal roof sheets, including corrugated, trapezoidal and concealed-fixed families;
- pierced-fixed and concealed-fixed roof assemblies;
- roofing screws, sealing washers, concealed clips and side-lap fasteners;
- side laps, end laps, rib end stops and profile infill strips;
- ridge, hip, barge and parapet cappings;
- apron, step, counter, change-of-pitch and penetration flashings; and
- supporting soaker or tray details around larger penetrations.

Profile and fixing method are separate attributes. Two steel sheets with a similar overall width can have different cover widths, rib geometry, lap direction, clip systems, support spacings and penetration details. A tool can repeat the selected product definition; it must not invent a generic profile and treat it as interchangeable.

Metal compatibility is also a system relationship. Roof sheet, flashing, fastener, washer, sealant, upstream runoff and connected rainwater goods must be suitable together. The ontology records materials and relationships but does not infer a safe compatibility decision from colour or appearance.

## Roof tiles, slates and shingles

The tiled-roof assembly is modelled as overlapping courses on roof battens with separate objects for:

- concrete, terracotta and interlocking roof tiles;
- ridge, hip, barge and hip-starter tiles;
- general, head-lap, side-lap, short-course, valley, hip-starter and ridge clips;
- tile clouts and tile screws;
- mortar bedding and flexible pointing;
- roof sarking, joint tape and anti-ponding boards; and
- flashings at walls, steps, valleys, penetrations and chimneys.

Tile type, pitch, course set-out, head lap, side lap, batten spacing, wind classification, roof zone and manufacturer system control placement and fixing. The presence of a tile object does not authorise a universal clip pattern.

Mortar bedding and pointing remain distinct. Bedding seats capping tiles; flexible pointing finishes and seals their exposed edges. Mechanical fixings or clips remain another component. Combining these into a single coloured ridge object would prevent useful quantity, maintenance and defect information.

The non-interlocking slate or shingle branch currently covers the material families exposed by AS 4597: terracotta, fibre-cement and timber. It deliberately does not assume that asphalt shingles, natural stone slate or proprietary composite systems use the same pathway.

## Sarking and anti-ponding

Roof sarking is represented as a pliable layer with separate joint tape. Its product classification, water-control role, vapour permeance, reflective face, support, laps, penetrations and ventilation relationships must remain explicit. “Sarking”, “underlay”, “vapour barrier” and “reflective insulation” are useful search language but are not automatic synonyms.

An anti-ponding board or device supports sarking near the eaves of a tiled roof so water does not collect behind the fascia or first batten. It is not a fascia, gutter flashing or substitute for correct sarking drainage.

## Flashings, cappings and penetrations

A flashing bridges or drains a junction; a capping generally covers and sheds water from an exposed ridge, hip, barge or parapet edge. Some folded pieces perform both jobs, so the catalogue preserves a generic roof-flashing class plus role-specific objects rather than forcing every trade term into a strict dictionary split.

A roof penetration is also modelled as an opening. The opening, support or trimmer, penetrating object, collar or apron, soaker tray and surrounding roof covering are separate geometry. A future tool should create the complete scheduled detail and never treat a cut hole plus sealant as a finished penetration.

## Supporting sources and standards

The public source set includes the NCC Housing Provisions Section 7 overview and Parts 7.2 and 7.3, NCC Volume Two H1D7, Standards Australia public metadata for AS 1562.1, AS 1562.3, AS 2049, AS 4597 and SA HB 39, the current Lysaght Roofing & Walling Installation Manual, Australian Roofing Tile Association technical material, and Australian training or government construction guidance.

SA HB 39 is recorded as a supporting handbook, not an Australian Standard and not a direct Housing Provisions call-up. It is useful for public terminology and source routing but does not replace the applicable NCC path, called-up standard, product manual or project design.

## Known gaps

- insulated roof panels, structural insulated panels and standing-seam subfamilies;
- natural slate, asphalt shingles, thatch, membrane roofs and green-roof build-ups;
- curved, tapered, cranked and secret-fixed product-specific sheet geometry;
- rooflights, skylights, hatches, vents, flues, solar mounts and proprietary penetration systems;
- eaves closures, bird proofing, foam closures and condensation-drainage accessories by product;
- roof expansion joints, movement details and long-run thermal restraints;
- cyclone-specific assemblies, bushfire detailing and corrosion-zone product libraries;
- full underlay, vapour-control, insulation and roof-ventilation assemblies; and
- product-specific tile profiles, half tiles, verge systems, dry ridge systems and restoration coatings.

Full URLs and access notes are stored in `data/sources/source_registry.json` and generated into `exports/source_audit.csv`.
