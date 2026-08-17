# Concrete structures research notes

Research date: 16 August 2026  
Ontology regulatory baseline: NCC 2022 Amendment 2

This pass adds 186 physical objects for concrete materials, cast-in-place structures, suspended floors, deep foundations, reinforcement, joints, embeds, post-tensioning, prefabricated concrete and temporary works. The purpose is to give future SketchUp tools a useful list of things they may draw and relate.

It does not reproduce licensed Australian Standards, design tables, bar schedules, tendon forces, erection sequences or temporary-works calculations. It is not engineering, construction or compliance advice.

## How to read the regulatory baseline

NCC 2022 Amendment 2 is the controlled baseline used by this ontology. That is a dataset decision, not a statement that it is the law for every project on 16 August 2026.

Before a project tool offers compliance-sensitive defaults, it must obtain and preserve:

- the state or territory and site location;
- building classification and project scope;
- application, approval and construction dates;
- the NCC edition legally adopted for those dates, including jurisdictional variations and transitional provisions;
- whether the work follows a Deemed-to-Satisfy route, a Performance Solution or both;
- the editions of standards called up by that legal pathway; and
- the engineer's documents, geotechnical information, product evidence and approved shop drawings.

The model may report which sources informed an object name. It must not report that an object, assembly or building complies merely because its geometry resembles an NCC diagram.

## NCC scope and boundary

Housing Provisions Part 4.2 supplies a useful house-scale vocabulary for footings, slabs, reinforcement, membranes and associated elements. Its acceptable-construction provisions apply only within their stated building, site, material and geometric limits. A future generator must test those limits or hand the work to the documented structural-design route; it must not silently stretch a prescriptive detail to a larger or different building.

NCC Volume Two Part H1 provides the broader structural compliance map for Class 1 and 10 buildings. Within that map:

- AS 2870 is the residential slab-and-footing route where its scope and project conditions are satisfied;
- AS 3600 is the principal concrete-structures route for reinforced and prestressed structural concrete;
- AS 2159 is relevant to piling through the NCC structural provisions, even though it is not one of the locked 64 direct Housing Provisions Schedule 2 references in this dataset;
- AS/NZS 2327 is relevant when steel and concrete are deliberately designed to act compositely; and
- AS 5216 is relevant to the design of post-installed and cast-in fastenings in concrete.

These pathways explain why the ontology needs many more objects than the house diagrams show. They do not turn supporting product, fabrication or work-practice standards into direct Housing Provisions references. The locked direct-reference count remains 64.

## Standards map for this pass

The standard records provide traceable document identities and subject boundaries. Most public records are catalogue metadata rather than the licensed text, so no unverified clause rule or numerical value is copied into an object.

| Standard | What it helps classify | Modelling consequence |
| --- | --- | --- |
| AS 2870:2011 | Residential slabs and footings | Retain the existing house-scale footing and raft families, site inputs and engineered exceptions. |
| AS 3600:2018 | Concrete structures | Keep concrete members, reinforcement, prestressing, joints and detailing evidence connected but separately identifiable. |
| AS 1379:2007 | Specification and supply of concrete | Treat supplied concrete and its recorded properties as batch or product evidence, not just a grey face material. |
| AS/NZS 4671:2019 | Steel reinforcement for concrete | Separate reinforcing-bar and reinforcing-mesh products from the structural roles and shapes they take in an assembly. |
| AS/NZS 2425:2015 | Bar chairs | Represent reinforcement supports as real products without treating them as the cover dimension itself. |
| AS 3610.1:2018 | Formwork specifications | Separate form surface, form assembly and resulting concrete surface requirements. |
| AS 3610.2 (Int):2023 | Formwork design and construction | Represent the temporary support load path and lifecycle state; never infer its adequacy from drawn props. |
| AS 6669:2016 | Formwork plywood | Distinguish a plywood form-face product from a generic sheet or the permanent concrete finish. |
| AS 3850.1:2024 | Prefabricated concrete elements, general requirements | Keep manufactured elements, cast-in items, lifting devices and documentation linked through manufacture and handling states. |
| AS 3850.2:2024 | Prefabricated concrete in building construction | Keep transport, erection, temporary bracing, final connection and release states explicit. |
| AS 2159:2009 | Piling | Separate a pile system, individual pile, casing, reinforcement cage, pile cap and connecting ground beam. |
| AS/NZS 4672.1:2007 | Steel prestressing materials | Distinguish prestressing strand or wire as a product from the complete tendon assembly. |
| AS/NZS 1314:2003 | Prestressing anchorages | Represent anchor head, wedges, bearing plate, trumpet and other anchorage parts rather than one anonymous end block. |
| AS 3972:2010 | General-purpose and blended cements | Keep cement and supplementary binder categories separate from concrete. |
| AS 2758.1:2014 | Concrete aggregates | Keep fine and coarse aggregate as concrete constituents, normally recorded as material data rather than modelled particles. |
| AS 1478.1:2000 | Concrete admixtures | Keep chemical admixture as a constituent or batch attribute, not a drawable structural member. |
| AS/NZS 2327:2017 | Composite steel-concrete construction | Require documented composite action before linking a concrete slab, steel beam and shear connectors as one system. |
| AS 5216:2021 | Fastenings in concrete | Distinguish cast-in and post-installed fastening systems and preserve their approved product and installation evidence. |

The fourteen standards newly registered by this pass are supporting references, not additions to the direct Housing Provisions list.

## Materials: cement is not concrete

Cement is a binder. Concrete is the composite material made using binder, water and aggregate, with other documented constituents where required. Mortar usually has fine aggregate and is used for bedding, jointing or rendering. Grout is selected to flow into a space or transfer load around bars, ducts, base plates or connections. These words are not interchangeable.

The catalogue therefore identifies cement, supplementary cementitious material, water, fine aggregate, coarse aggregate, chemical admixture and fibre reinforcement as constituents. They are valid ontology materials because they affect specifications, supply and evidence. They will usually be batch data or take-off classifications, not individual three-dimensional particles.

Fibre-reinforced concrete is also not a substitute name for conventional reinforced concrete. Steel, synthetic or other specified fibres belong to a concrete mix. Reinforcing bars, mesh and tendons are placed products with their own geometry, position and connections. A project may use either or both only as documented.

## Cast-in-place structural systems

Cast-in-place concrete is placed into formwork at its final structural location. The object hierarchy separates the overall system from the individual members that make its load path visible:

- suspended slab, flat plate, flat slab, banded slab, one-way slab and two-way slab;
- ribbed slab, waffle slab, band beam and slab band;
- primary and secondary beams, edge beams and transfer members;
- columns, walls, shear walls and cores;
- drop panels, column capitals, corbels, pedestals and upstands; and
- openings, recesses and thickened or local supporting zones.

The names describe arrangements, not automatic design solutions. For example, a flat plate is not simply any slab drawn without visible beams, and a flat slab includes the documented column-head or drop arrangement used by its design. One-way or two-way action, punching shear capacity, fire resistance, vibration and deflection cannot be inferred safely from a SketchUp shape.

A structural topping is concrete that is documented as part of the structural action or diaphragm. A screed is a levelling or finish-preparation layer. They can look almost identical in a model but have different relationships, evidence and consequences. The tool must ask which one is intended rather than deciding from thickness or appearance.

A slab-on-ground transfers load directly to supporting ground. A suspended slab spans between supports. A waffle raft foundation and a suspended waffle floor can share a ribbed visual pattern, but their support conditions and load paths are different ontology objects.

## Deep foundations

A pile foundation is a system. It may contain driven, bored, continuous-flight-auger or other documented pile types, plus reinforcement cages, casings, cut-off zones, caps and connecting ground beams.

A bored pile is not automatically a continuous-flight-auger pile. The construction processes, temporary support of the hole, reinforcement insertion and evidence differ. The tool may offer these as explicit families; it must not infer the family from a circular shaft.

A residential bulk pier is also not a casual synonym for any bored pile. The applicable prescriptive or engineered route, proportions, reinforcement and connection to the supported footing must remain attached to the selected object.

The model can coordinate pile centres, diameters, cut-off levels, cap geometry, starter bars and clashes. It cannot determine geotechnical capacity, founding level, settlement, group effects or installation acceptance without the responsible design and site evidence.

## Reinforcement

Reinforcement needs three separate classifications:

1. **Product** — bar, welded reinforcing mesh, trench mesh, wire or another documented reinforcement product.
2. **Role** — main reinforcement, distribution reinforcement, ligature, stirrup, tie, confinement reinforcement, dowel or starter.
3. **Shape and assembly** — straight, hooked, L-shaped, U-shaped, cranked, spiral, cage, mat or scheduled bent-bar shape.

This prevents one ambiguous “rebar” component from hiding what must be scheduled, placed and checked. A bar mark and bending schedule are evidence attached to bar instances or groups; the mark is not another piece of steel.

Starter bars connect later work to an earlier placement. Joint dowels transfer documented action across a joint while allowing whatever movement the joint design requires. The same-looking short bar must not be assigned both roles without evidence.

A lap splice overlaps reinforcement. A mechanical coupler joins bar ends through a manufactured device. A grouted sleeve is a physical connection with a sleeve and grout. These require different geometry and installation records.

Bar chairs, continuous high chairs, support bars, spacer wheels, cover blocks and flat chair bases locate reinforcement during construction. They are physical supports. Concrete cover is the resulting distance from the concrete surface to the relevant reinforcement; it is a checked dimension, not a chair object. A tool may calculate and display that distance, but must not claim the correct cover from a nominal chair label alone.

## Joints, waterstops, embeds and void geometry

The catalogue separates construction, contraction or control, isolation and expansion joints. These describe different purposes. A saw cut, keyed face, dowel, debonding sleeve, compressible filler, sealant and backing rod are components or features that may form part of a documented joint assembly; none alone defines the complete joint.

A crack is not automatically a designed joint. The tool should never convert detected linework into a joint object without confirmation.

Waterstops used through structural concrete joints are distinct from waterstop angles or perimeter water-control details used in wet-area waterproofing. Profiles and materials can include centrally placed or externally placed products, hydrophilic products or other specified systems. Their compatibility, continuity, intersections and installation evidence matter more than their display colour.

Concrete can contain cast-in ferrules, anchor channels, plates, sleeves, conduits and inserts. It can also contain deliberate empty geometry such as a blockout, recess, penetration or anchorage pocket. These must be modelled explicitly:

- a sleeve is a physical lining or former through the concrete;
- a penetration is the resulting opening;
- a blockout reserves a volume during placement; and
- a recess is a local depression that does not necessarily pass through the member.

Cast-in and post-installed anchors are different installation systems. The ontology may coordinate their locations and host relationships, but anchor capacity, edge breakout, spacing and installation acceptance must come from the documented fastening design and product evidence.

## Prestressing and post-tensioning

Prestressed concrete is the broad family. Pre-tensioning stresses the steel before the concrete member is cast and transfers force after curing. Post-tensioning stresses tendons after the concrete has reached the documented condition.

For post-tensioning, the catalogue separates:

- prestressing strand or wire from the complete tendon;
- bonded multi-strand tendons from unbonded monostrand tendons;
- sheath or duct, grout and vents from the steel inside them;
- live and dead-end anchorages;
- anchor head, wedges, bearing plate, trumpet, coupler and anchorage recess;
- anti-burst reinforcement and local reinforcement around anchor zones; and
- tendon chairs and supports that establish the designed profile.

A strand is a material product. A tendon is the complete force-carrying assembly along its installed path. A live anchorage is used for stressing; a dead anchorage terminates the other end or is not used as the stressing end. These distinctions affect component geometry, access and lifecycle state.

The plugin may draw a tendon from a documented profile and show a protected no-cut zone. It must not calculate a final profile, force, elongation, losses, anchorage-zone reinforcement, stressing sequence or permissible drilling zone unless an authorised engineering workflow supplies and verifies those values.

## Prefabricated concrete

“Precast” describes manufacture away from the final installed position. “Tilt-up” describes a method in which panels are cast, commonly near their final location, then tilted into place. Tilt-up belongs within prefabricated concrete practice but should remain a distinct method and lifecycle family.

Accepted physical families include wall panels, solid and sandwich panels, wythes, insulation and wythe connectors; hollowcore, solid floor and double-tee units; beams, columns, stairs, landings, balconies and other scheduled elements; and their cast-in connection, lifting and bracing items.

Each element can pass through several model states:

1. manufacture and curing;
2. storage and transport;
3. lifting and erection;
4. temporary support and connection; and
5. completed structure after final connections and authorised brace release.

A cast-in lifting anchor stays in the concrete. A compatible lifting clutch is reusable handling equipment that attaches to it. A lifting point is not automatically a permanent structural connection. Similarly, a temporary panel brace must not be hidden or removed merely because a final wall position has been reached; release requires the documented erection procedure and completed load path.

Sandwich-panel wythes, insulation and connectors should be modelled as a related assembly rather than one textured solid when coordination or fabrication detail is required. Thermal, fire, structural and moisture performance remain evidence fields, not visual inferences.

## Formwork, falsework and other temporary works

Formwork is the mould that shapes and contains fresh concrete. Falsework is the temporary supporting structure that carries formwork and construction loads to a reliable support. A complete temporary-works system may include both, but they are not synonyms.

The catalogue exposes the load path through form face or sheathing, joists, bearers, soldiers or walers, props or shores, heads, bases, braces, ties and foundations. It also identifies table forms, jump or climbing forms, slipforms, backpropping and permanent formwork as distinct systems or states.

Form ties can include a reusable tie or rod, cones or sleeves and the resulting tie hole or patch. Release agent is an applied material. A chamfer strip and form liner create deliberate surface geometry. The form face and liner are temporary objects; the resulting off-form concrete surface is a permanent member state, not a coating copied from the form colour.

Ordinary formwork is removed. Permanent formwork remains in the building. Remaining in place does not automatically make it composite, load-bearing, fire-protective, weatherproof or an accepted finish. Each permanent role needs explicit project evidence.

Temporary-works geometry is useful for access, sequencing, quantities and clash detection. It can never demonstrate prop capacity, lateral stability, foundation capacity, pour rate, stripping time, backpropping adequacy or worker safety by appearance alone.

## Rules for future SketchUp generators

### Keep lifecycle views separate

The plugin should support, at minimum, design or coordination, construction, erection and completed states. Temporary formwork, falsework, braces, lifting clutches and stressing equipment must have explicit appearance and removal states. Permanent objects must not disappear just because their construction aid is removed.

### Preserve identity and hierarchy

Use reusable component definitions for genuine repeated products or families, and give each installed instance a stable unique identifier. A system should own or relate its parts without fusing them into one anonymous mesh. Examples include:

- concrete member -> reinforcement assembly -> bars, mesh, supports and splices;
- slab system -> slab zones, drops, beams, openings and joints;
- precast element -> wythes, insulation, connectors, embeds and connections;
- tendon -> strand, duct or sheath, anchorage and supports; and
- formwork system -> face, secondary members, primary members, props and bracing.

Host relationships must survive editing. Moving a beam opening, cast-in ferrule or anchorage pocket must identify the concrete member it modifies and the evidence that authorised it.

### Use predictable local axes

For linear members, local X should run along the member, with a documented local cross-section orientation. For panels and slabs, local X and Y should lie in the element plane and local Z should represent thickness or the consistently defined face normal. For tendons and curved bars, use a path with stable local frames so profiles and cross-sections do not twist unexpectedly.

Store project coordinates separately from component-local geometry. Avoid assumptions tied to Windows path syntax or one operating system; assets and identifiers must work on Windows and macOS when implementation begins.

### Model negative geometry deliberately

Openings, sleeves, blockouts, rebates, recesses, ducts and anchorage pockets need stable objects or features, not unexplained deleted faces. They should know their host, purpose, lifecycle and approval source. A clash is a prompt for coordination, never permission to cut concrete or reinforcement.

### Offer useful levels of detail

- **Symbolic:** overall concrete member, centreline or panel envelope, nominal joint and opening locations.
- **Coordination:** actual member thickness, drops, ribs, openings, embeds, reinforcement zones, tendon paths and temporary-work envelopes.
- **Fabrication or erection:** scheduled bars, cages, couplers, precast cast-ins, lifting anchors, connection parts, individual tendon and formwork components where authorised source data exists.

The tool should not create fabrication-level detail by guessing from a symbolic model.

### Keep design evidence beside geometry

Geometry may carry references to concrete specification, bar schedule, tendon schedule, shop drawing, erection procedure, inspection record and product data. It must not invent or silently default structural dimensions, reinforcement size or spacing, cover, laps, development, concrete strength, pile founding, member span, tendon force, anchor capacity, lifting capacity, brace layout, pour sequence or stripping time.

## Known gaps for later passes

The following are real subjects but are not yet developed enough for accepted object coverage in this slice:

- shotcrete, sprayed-concrete linings and nozzle or rebound process objects;
- three-dimensionally printed concrete and robotic placement systems;
- ferrocement and textile-, glass-fibre- or FRP-reinforced structural systems;
- soil anchors, ground anchors, diaphragm walls, secant walls and major basement retention;
- bridge, marine, pavement, tank, silo and water-retaining concrete systems;
- repair, crack injection, patch repair, cathodic protection and strengthening systems;
- fire spalling protection, sacrificial layers and specialist fireproofing;
- precast façade sealants, fire stops and full façade weatherproofing interfaces;
- prestressing beds, stressing jacks, pumps and other temporary production equipment;
- detailed concrete test specimens, sampling tools and site-testing operations; and
- proprietary reinforcement, coupler, anchor, tendon, formwork and precast product libraries.

These gaps are not permission to map them to the nearest existing object. They require their own Australian terminology and source pass.

## Source and legal limits

Primary regulatory interpretation starts with the official ABCB NCC pages. Standards Australia catalogue records establish document identity and scope; access to catalogue metadata is not access to the licensed normative text. SafeWork NSW guidance, Safe Work Australia material, Australian Government training-unit descriptions, industry bodies and manufacturer educational pages help identify physical parts and common Australian language. They do not replace the NCC, adopted standards, workplace-safety law, engineering documents or product certification.

The Safe Work Australia precast and tilt-up code retained in the source register is useful historical terminology and safety context. Its legal status and jurisdictional replacement must be checked before project use.

Full URLs, access dates, source type, jurisdiction, limitations and object links are stored in `data/sources/source_registry.json` and generated into `exports/source_audit.csv`.
