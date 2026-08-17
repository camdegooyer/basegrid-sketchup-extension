# External decks, balconies, terraces and above-ground waterproofing research notes

Research date: 17 August 2026. Regulatory baseline: NCC 2022 Amendment 2, checked against the current NCC Online text available on the research date. Amendment 2 has been the current NCC edition since 29 July 2025. A real project must still check the edition, transition arrangements and variations adopted in its state or territory.

These notes explain the evidence used to discover physical objects and relationships. They do not reproduce paid Australian Standards, select products, perform engineering or waterproofing design, or certify NCC compliance.

## Result of this research pass

This pass adds a `decks_balconies` catalogue with 219 physical objects and assemblies. It covers:

- open-jointed timber, composite, aluminium, fibre-cement and grating decks;
- timber- and steel-framed, attached, freestanding, post-supported, cantilevered and low-clearance arrangements;
- posts, footings, piers, bearers, joists, rim members, trimmers, blocking, bracing and concentrated-load support;
- brackets, hangers, bolts, anchors, screws, nails, clips, separation pads and corrosion interfaces;
- waterproof concrete, framed and sheet-substrate balconies, roof terraces and podium-style terraces;
- liquid and sheet membranes, primers, adhesives, reinforcement, corners, bond breakers, movement joints, upturns, downturns and terminations;
- door thresholds, wall junctions, parapets, hobs, barrier posts and service penetrations;
- point drains, linear drains, scuppers, overflows, gutters and outlet connections;
- bonded exterior tile finishes and their adhesive, grout, flexible joints, profiles and edge trims;
- adjustable pedestals, fixed supports, pedestal pavers, modular deck tiles and drainage cavities;
- built-in planter shells, root barriers, protection, drainage cells, filter fabric, outlets and overflows;
- under-deck trays, supports, wall flashings and outlets; and
- inspection, temporary protection, flood-test and repair objects.

Existing objects remain canonical where they already describe the physical thing. In particular, the pass reuses structural timber and steel member families, fall-prevention barriers, livable-housing entrances, external doors, cladding soffit products, roof parapet capping, concrete upstands, termite systems and subfloor ground membranes. The new discipline describes deck-specific roles and interfaces rather than cloning those libraries.

## The regulatory map in plain English

### The current NCC baseline

The current national source is NCC 2022 Amendment 2. The NCC only gains legal effect through each jurisdiction, so a plugin cannot answer compliance from geometry alone. Project metadata needs the jurisdiction, adopted NCC edition and amendments, building classification, approval date or transition path, site conditions and chosen compliance pathway.

The ontology records rules and evidence as metadata. It does not bake regulatory dimensions into generic object geometry unless the source, scope and applicability conditions are also stored.

### Housing Provisions Part 12.3 is narrow

Housing Provisions Part 12.3 is not a complete deck-design chapter. It is a particular Deemed-to-Satisfy construction route for attaching a framed deck or balcony to an external wall using a waling plate, subject to the limitations in Volume Two H1D11.

The physical objects exposed by that route include:

- a timber or cold-formed steel waling plate;
- wall framing or reinforced core-filled masonry that actually receives the connection;
- screws, bolts, anchors and large washers;
- joists connecting to or bearing at the waling plate;
- flashing where cladding is removed or interrupted;
- top, bottom and side flashing pieces, laps, seals and outward drainage paths; and
- diagonal steel strap bracing with its repeated fixings.

The clause contains specific sizes, grades, fixing centres, edge distances, corrosion selections, span limits and bracing conditions. Those values belong in a rule set tied to the exact NCC edition and construction case. They are not universal defaults for every deck, every wall or every proprietary connection.

A deck beside a house is not automatically attached. A freestanding deck can be separated from the wall structurally while still needing careful weather, termite, movement and access detailing at the narrow gap.

### Volume Two H2D8 is the external-waterproofing spine

NCC Volume Two H2D8 addresses external waterproofing for flat-roof systems, roof terraces, balconies, terraces and similar horizontal surfaces above internal building spaces. Under its Deemed-to-Satisfy route:

- membrane materials comply with AS 4654.1; and
- design and installation of the external waterproofing system follow AS 4654.2.

The two standards are complementary. Part 1 is about materials. Part 2 is about the designed and installed system. A membrane product statement does not prove that falls, drains, movement joints, door thresholds, upturns, terminations or penetrations are correct.

H2D8 lists three relevant exceptions from that particular requirement for terraces, balconies and similar construction:

- a concrete slab with at least the stated step-down below the internal floor level;
- a suspended concrete slab with that step-down where the subfloor space is not used for habitable or non-habitable purposes; and
- spaced decking used with framing members suitable for external use.

The current clause states a 50 mm minimum step-down in the first two cases. The ontology records that as a sourced regulatory constraint, not as the default height of every balcony setdown.

These exceptions do not mean that the whole deck is “exempt from the NCC.” They do not remove applicable structural, drainage, weatherproofing, durability, termite, barrier, threshold, bushfire, energy, electrical, plumbing or local-authority duties. They only define the boundary of the H2D8 Deemed-to-Satisfy external-waterproofing requirement.

H2D8 also explains that other materials and designs may require a Performance Solution. A plugin must therefore support an explicit `unknown`, `Deemed-to-Satisfy` or `Performance Solution` evidence state instead of marking unfamiliar geometry as non-compliant.

## The first decision: what kind of platform is it?

A robust drawing tool should ask these questions before it creates members:

1. Is the walking surface open-jointed or substantially solid?
2. Is the structure attached to the building, freestanding or a combination?
3. What is below it: ground, open air, a non-occupied void, another exterior area or internal space?
4. What is the structural system: timber frame, light steel frame, structural steel, concrete or a proprietary support system?
5. Where is the primary water-control plane?
6. Where does water leave the assembly?
7. Are there doors, walls, parapets, planters, barrier posts or services interrupting that path?
8. Which selected products and engineering or system documents control dimensions?

Those answers produce very different object graphs even when all examples are called “a deck.”

## Open-jointed deck anatomy

An open-jointed framed deck normally has the following load path:

`people and furniture -> boards or panels -> joists -> bearers -> posts, walls or brackets -> footings or building structure -> ground`

The primary physical layers and members are:

- decking boards, panels, grating or modular surface units;
- side gaps for drainage and movement;
- butt joints and end gaps;
- perimeter clearances at walls and fixed objects;
- face screws or nails, concealed clips, starter clips and their product-specific screws;
- repeated joists;
- rim or boundary joists and trimmers;
- extra joists beneath board ends, breaker boards, picture-frame borders and concentrated loads;
- blocking rows or noggings that perform a stated restraint or support role;
- bearers, edge beams or ledgers/waling plates;
- posts, caps, saddles, stirrups, piers and footings;
- lateral braces, knee braces, ties and hold-downs; and
- material-separation and corrosion-protection layers.

“Decking” means the surface material in this ontology. “Deck” can mean the complete platform. A tool must not generate only boards when the user asks for a deck.

### Attached and freestanding are structural facts

Visual proximity is not enough. An attached deck transfers some action into the building through a documented connection. A freestanding deck has independent vertical support and a documented lateral system. It may sit very close to the building, but the gap, weathering and termite inspection route remain explicit.

The model needs to know which member supports which, where it bears, what restrains lateral movement, and what substrate receives every anchor. A connector shape without a verified host and load path is only a placeholder.

### Low-clearance decks are severe details

A deck close to ground can dry more slowly than a higher exposed deck. Restricted airflow, splash, wet soil, leaf build-up and hidden termites can govern service life.

The catalogue therefore separates:

- the under-deck air or inspection space;
- a graded ground surface;
- a drainage aggregate layer where selected;
- the existing subfloor ground vapour membrane object where relevant;
- post and footing penetrations;
- perimeter ventilation and inspection routes; and
- the deck-to-building termite inspection zone.

Gravel is not a structural footing, a termite barrier or a cure for poor drainage. A ground membrane is not a deck waterproofing membrane.

## Durability is more than choosing a species

Exterior timber selection needs several separate facts:

- species or product family;
- structural grade where the member is structural;
- whether the relevant material is heartwood or sapwood;
- natural-durability evidence under AS 5604 where used;
- preservative-treatment evidence and hazard class under the AS/NZS 1604 family where used;
- treatment penetration and any incised or envelope-treatment condition;
- end cuts, notches, holes and field treatment;
- drainage, ventilation and moisture traps in the detail;
- coating or oil system where selected; and
- inspection and replacement access.

“H3 timber” is not a species, strength grade or member size. “Durable hardwood” does not prove treatment, sapwood durability or suitability in every detail. Colour does not prove either property.

Wood-plastic composite decking is a manufactured product family, not structural timber. Board profile, span, support width, clip type, end treatment, thermal movement and gap rules come from the selected product. Hollow, solid and capped profiles remain separate drawing objects.

Metal components also need exposure and compatibility information. Stainless fasteners, galvanised steel, coated steel, aluminium, copper-containing treatments and dissimilar metals can create different corrosion interactions. The catalogue records isolators, cut-edge coatings and separation pads as objects rather than assuming a compatible connection.

## Waterproof balcony and terrace anatomy

A typical waterproof platform is an ordered system, not one “balcony floor” object:

1. structural slab, framing or sheet substrate;
2. structural setdown or edge geometry where used;
3. prepared surface and compatible primer;
4. falls formed in the structure, a screed or another documented layer;
5. liquid- or sheet-applied external membrane;
6. corners, reinforcement, bond breakers and movement joints;
7. vertical upturns, free-edge downturns and protected terminations;
8. membrane-compatible drains, scuppers and penetrations;
9. permanent protection or drainage layer where required;
10. bonded tile, mortar, raised pavers, deck tiles or another trafficable finish; and
11. accessible inspection and maintenance routes.

The order can vary with an accepted selected system. The tool should therefore store a directed layer graph rather than assuming one hard-coded sandwich.

### Substrate and falls

The substrate can be a concrete slab, exterior flooring sheet, plywood where suitable, metal deck or another documented system. A product being strong enough to walk on does not automatically make it a suitable membrane substrate.

The model must record which physical layer creates falls. A structural slab fall, tapered framing, fall-forming screed and mortar bed are different things. The finish should follow the drainage design; it must not hide a flat or back-falling primary water-control plane.

### Membrane types

Liquid membranes are applied wet and cure into a field. Geometry may include wet-film zones, reinforcing fabric and locally increased build-up.

Sheet membranes arrive at a manufactured thickness and require explicit laps or welded seams, adhesives where used, corner patches and terminations. Bituminous, synthetic-rubber and thermoplastic sheets are separate material families because their joining and compatibility rules differ.

The ontology never infers membrane performance from colour or generic thickness. Product, classification, substrate, primer, application conditions, cure, reinforcement, lap or seam method and compatibility remain evidence fields.

### Movement and corners

Movement joints continue through the relevant layers. A structural or substrate joint, membrane detail and finish joint are related but remain separate objects.

Backing rod supports a sealant and controls its shape. Release tape prevents bonding to an unwanted face. A bond-breaker detail can use one of those products or another accepted form. A corner fillet changes geometry; a sealant fillet forms part of a selected junction system. The terms should not be collapsed.

### Upturns, edges and terminations

An upturn rises from the drained field at a wall, door, hob, parapet or penetration. A downturn wraps over a free edge. A termination bar secures an edge. An overflashing sheds weather over it. A waterstop forms a retained boundary. One generic “flashing” component cannot safely represent all of them.

No universal upturn, threshold or edge dimension is stored in the object definition. The applicable value depends on the adopted clause, exposure, door and wall detail, finish level, overflow behaviour and selected system.

## Doors and level thresholds

A balcony door interface can include:

- internal structural and finished floor levels;
- a balcony structural setdown;
- door frame and sill;
- subsill pan or flashing;
- sill drainage slots or end dams;
- membrane upturn or waterstop;
- wall wrap and cladding cavity flashings;
- external finish level and falls;
- an optional threshold channel drain;
- internal transition or livable-housing entrance objects; and
- sealants that do not block intended drainage.

A channel drain helps collect surface water but is not a substitute for the door sill, subsill, membrane or overflow strategy. A step-free or low threshold is an access condition that must be coordinated with weatherproofing; it is not achieved by deleting the membrane upturn in the model.

## Drainage and overflow

Every waterproof platform needs an explicit route from each fall plane to an accepted discharge system. The catalogue distinguishes:

- point drains with bodies, flanges, clamping rings, grates and connectors;
- linear channels with bodies, grates, end caps and outlets;
- primary scuppers through a parapet or hob;
- edge gutters and downpipe adaptors;
- primary drainage and higher emergency overflow systems; and
- removable access pavers or inspection grates above concealed drainage.

Primary drainage handles normal runoff. An overflow provides a separate high-level relief path when primary drainage is blocked or exceeded. Two outlets are not automatically redundant merely because they look alike. Invert, catchment, capacity, discharge destination and visibility are attributes of each instance.

A raised paver or deck-tile system drains through open joints into the cavity below. The membrane and drains remain the primary water-control system. The visible paver surface is not drawn as a sealed plane.

## Bonded exterior tile finishes

An exterior tiled balcony is not an internal dry-area tiled floor copied outdoors. The catalogue uses separate objects for:

- exterior ceramic, porcelain and suitable natural-stone units;
- exterior-compatible adhesive bed;
- grout at ordinary joints;
- flexible perimeter and movement-joint sealant;
- movement-joint profiles;
- edge trims; and
- the underlying mortar bed, screed, membrane and drainage.

The AS 3958 installation path and AS 4586 slip evidence support this finish family. AS 4654 still controls the external membrane system where applicable. Tile, adhesive and grout are not treated as the waterproof membrane.

A porcelain pedestal paver and a bonded porcelain tile can have the same visible material but different structural behaviour. The pedestal paver spans between discrete supports; the bonded tile transfers load through adhesive to a continuous backing.

## Pedestal-supported finishes

An adjustable pedestal system can include:

- a load-spreading base;
- a protection pad between base and membrane;
- threaded or telescoping body;
- locking collar;
- height extenders;
- slope corrector;
- head;
- paver spacer tabs or bearer holder;
- head pad;
- rails or bearers;
- perimeter and uplift restraint; and
- removable pavers for drain access.

A fixed-height support pad is a different family. “Pod” is avoided as a canonical term because it can also mean a waffle-slab void former.

The geometry tool must check the selected product's height range, support footprint, supported-unit strength, edge and corner conditions, membrane compatibility, imposed loads, wind or uplift conditions, movement and maintenance access. The catalogue does not invent a generic pedestal spacing.

## Planters on terraces

A built-in planter adds stored water, wet growing-medium weight, roots, irrigation and difficult maintenance access. It is a complete assembly with:

- structural shell;
- substrate preparation;
- external membrane;
- root-resistant layer where separately required;
- protection board;
- drainage cell or drainage mat;
- filter geotextile;
- growing medium and planting as project data;
- primary outlet;
- overflow;
- irrigation penetrations; and
- upper terminations and movement separation.

Waterproof, root-resistant, protective, draining and filtering are separate roles. One product may perform more than one only where its evidence says so.

## Under-deck drainage and soffits

An under-deck tray catches water after it passes through spaced decking and conveys it to an edge gutter or outlet. It is a secondary capture plane. It does not turn the open-jointed surface into an AS 4654 membrane system.

A finished soffit is yet another layer. It may sit below drainage trays and services, but it should not conceal leak paths, structural connections, termites or drains without planned inspection access. The model separates tray, tray support, wall flashing, outlet and visible soffit enclosure.

## Barriers, penetrations and concentrated loads

Barrier geometry remains canonical in the `safe_movement_access` discipline. This pass adds only the deck-side structural and waterproofing interfaces:

- doubled joists, blocking, edge beams or other support at barrier posts;
- base plates, anchors or sockets linked to the selected barrier system;
- membrane collars, boots or raised supports; and
- local drainage and inspection around the connection.

A barrier post and a deck support post are different roles. A top-mounted barrier may avoid one membrane penetration but still needs a designed load path and compatible fasteners. Side mounting can reduce interruption of the membrane field but does not automatically solve edge waterproofing.

Planters, screens, spa equipment, outdoor kitchens and heavy point loads also need explicit concentrated-load framing or structural support. Their presence cannot be inferred safely from a surface material.

## Tool-building implications

A future SketchUp generator should treat the discipline as a family of configurable systems, not one “draw deck” command.

Minimum inputs for an open deck include:

- footprint and finished level;
- attachment topology;
- support and span directions;
- selected structural system and engineering source;
- surface product and board direction;
- edge, joint and feature-board layout;
- space below;
- corrosion, durability and termite context; and
- barriers, stairs, doors, walls, services and heavy objects.

Minimum inputs for a waterproof balcony include:

- footprint, structural and finished levels;
- internal-space relationship;
- adopted compliance path;
- substrate and setdown;
- fall planes and primary/overflow drainage;
- selected membrane system;
- every wall, door, parapet and free-edge termination;
- penetrations and movement joints;
- protection and finish build-up; and
- inspection and maintenance access.

Every generated member should retain:

- stable ontology ID and instance ID;
- host and supported objects;
- start and end support conditions;
- material and product evidence;
- structural or weathering role;
- dimensions and their source;
- exposure and durability metadata;
- compliance-path metadata without a compliance claim;
- construction state; and
- inspection or replacement access.

## Evidence limits and deliberate exclusions

The source catalogue proves that the objects and distinctions exist. It does not supply all proprietary geometry, engineering tables or licensed standard content.

This pass deliberately avoids universal defaults for:

- joist, bearer, post or footing sizes;
- spans and spacings;
- screw, bolt, clip or anchor schedules;
- waling-plate selection outside the exact Part 12.3 path;
- board gaps or composite expansion allowances;
- membrane thickness, coverage or cure;
- falls, upturns, stepdowns and threshold heights;
- drain and overflow capacities;
- tile movement-joint layout;
- pedestal spacing or paver strength; and
- barrier loads, heights and openings.

Those are rules or selected-product data, not intrinsic definitions of the physical object.

The pass does not attempt full coverage of vehicle traffic decks, bridges, marinas, swimming-pool surrounds, below-ground tanking, large commercial podiums, intensive green roofs, public-space accessible systems or specialist fire-rated balcony construction. Some physical objects will overlap, but those scopes need their own evidence passes.

## Main public sources

### Regulatory and standards metadata

- [NCC editions and current amendment status](https://ncc.abcb.gov.au/editions-national-construction-code)
- [NCC Volume Two Part H2, including H2D8 External waterproofing](https://ncc.abcb.gov.au/editions/ncc-2022/adopted/volume-two/h-class-1-and-10-buildings/part-h2-damp-and-weatherproofing)
- [Housing Provisions Part 12.3 — waling-plate attachment](https://ncc.abcb.gov.au/editions/ncc-2022/adopted/housing-provisions/12-ancillary-provisions/part-123-attachment-framed-decks-and-balconies-external-walls-buildings-using)
- [AS 4654.1:2012 public metadata](https://www.intertekinform.com/en-au/standards/as-4654-1-2012-120285_saig_as_as_252122/)
- [AS 4654.2:2012 public metadata](https://www.intertekinform.com/en-au/standards/as-4654-2-2012-120284_saig_as_as_252120/)
- [AS 5604:2022 public metadata](https://store.accuristech.com/standards/as-5604-2022?product_id=2506890)
- [AS/NZS 1604.1:2021 public metadata](https://codehub.building.govt.nz/resources/asnzs-1604-12021)

### Technical, training and product-anatomy sources

- [WoodSolutions Technical Design Guide 21 — Domestic timber deck design](https://www.woodsolutions.com.au/publications/technical-design-guides/domestic-timber-deck-design-0)
- [WoodSolutions Technical Design Guide 05 — Timber service life design](https://www.woodsolutions.com.au/system/files/WS_TDG_05_1_17_0.pdf)
- [QBCC timber deck and balcony construction guide](https://www.qbcc.qld.gov.au/resources/guide/timber-deck-balcony-construction)
- [CPCCWP3003 — Apply waterproofing process to external above-ground wet areas](https://training.gov.au/training/details/CPCCWP3003/unitdetails)
- [CPCCWP5002 — Design external above-ground waterproofing](https://training.gov.au/training/details/CPCCWP5002/unitdetails)
- [CPCCCA3003 — Install flooring systems](https://training.gov.au/training/details/CPCCCA3003/unitdetails)
- [MSFFL3120 — Install timber flooring on joists](https://training.gov.au/Training/Details/MSFFL3120)
- [HIA overview of AS 4654.2](https://hia.com.au/resources-and-advice/building-it-right/australian-standards/articles/waterproofing-membranes-above-ground-part-2)
- [ModWood Australian installation and fixing guides](https://www.modwood.com.au/installation/)
- [Hardie Secura Flooring installation guide](https://www.jameshardie.com.au/ContentfulCMS/Installation-Guide/Hardie_Secura_Flooring_Installation_Guide.pdf)
- [Stormtech balcony drainage white paper](https://www.stormtech.com.au/sites/default/files/whitepapers/2024-10-Stormtech-Whitepaper-Balcony-Drainage.pdf)
- [Elmich VersiJack pedestal guide](https://elmich.com.au/wp-content/uploads/2014/11/VersiJack75.pdf)

Public summaries and manufacturer guides support object discovery and vocabulary. Licensed standards, engineering, the selected product documentation and the adopted jurisdictional rules remain necessary before implementing project-specific constraints.
