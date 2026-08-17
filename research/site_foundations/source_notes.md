# Site, foundations and reinforcement research notes

Research date: 16 August 2026  
Regulatory baseline: NCC 2022 Amendment 2

These are concise evidence notes kept outside the canonical ontology. They record why candidates were accepted, held or rejected without copying standards text.

## Authoritative NCC findings

### Housing Provisions Part 3.2 — Earthworks

- The physical site candidates are placed fill and the finished earth form, not the operations of cutting, rolling or testing.
- An unretained fill embankment is a physical earth mass and is drawable. “Cut” is a removal operation and resultant terrain geometry, so it is not accepted as a standalone material object.
- Fill used below slabs leads into the more specific Part 4.2 categories.

### Housing Provisions Part 3.3 — Drainage

- Three distinct physical system families appear: surface-water drainage, subsoil drainage and underground stormwater drainage.
- The current accepted components are subsoil drain, silt pit, sump, stormwater drain, soaker well and stormwater tank.
- Finished surface fall and pipe cover are geometric or compliance attributes, not physical objects.
- Surface swales, channel drains, grated pits, filter aggregate and geotextile are real candidates but need additional Australian source work before acceptance.

### Housing Provisions Part 3.4 — Termite risk management

- The NCC distinguishes a complete system from a component. A slab or single barrier is not automatically a complete termite-management system.
- Publicly identified generic component classes include sheet material, granular material and chemical treatment. The CSIRO guidance also supports ant caps, stainless mesh, penetration collars and treatment reticulation.
- Slab-edge exposure and inspection zones are spaces or visibility constraints, not material components. They remain assembly attributes rather than ontology objects.
- The durable notice is a physical installed object even though its main value is the information it carries.

### Housing Provisions Part 4.1 — Footing and slab terminology

- The NCC diagrams explicitly identify slab, deepened edge beam, reinforcement, foundation, under-slab membrane, edge rebate and internal beam or thickening.
- “Foundation” is ambiguous outside the diagram context. The canonical term **foundation material** is used for supporting soil or rock so it is not confused with a constructed footing system.
- Edge rebate is a subtractive concrete feature. It is retained using the schema’s permitted `opening` object type because its geometry is necessary for wall, flashing and drainage tools.

### Housing Provisions Part 4.2 — Footings, slabs and associated elements

- Physical fill categories: controlled fill, rolled fill and clean quarry-sand bedding.
- Physical foundation families: slab-on-ground, stiffened raft, footing slab, strip footing, stepped strip footing, pad footing, stump and bulk pier.
- Physical reinforcement forms: reinforcing bar, welded wire reinforcing fabric, trench mesh, ligature, tie wire, bar chair and flat chair base.
- The under-slab damp-proofing membrane has distinct joint-tape and penetration-sleeve relationships.
- Site class, bearing pressure, concrete cover, reinforcement designation, lap, strength, slump, curing period and footing dimensions are attributes or rules. They are not objects and are not encoded as universal values.

## Independent terminology cross-checks

### RMIT Learning Lab

- Confirms the role of footing systems in transferring building loads to foundation soil.
- Separates stump-and-pad, continuous strip footing, stiffened raft, footing slab and waffle raft arrangements.
- Identifies slab panels, edge beams, internal beams, reinforcement, void formers and bar chairs as distinct physical parts.
- Uses “pad” or “soleplate” for load-spreading support beneath a stump. The ontology keeps a concrete pad footing separate from a timber soleplate.
- Some RMIT pages retain older BCA references and numerical examples. They support concepts and terminology only; current NCC values take precedence.

### Australian Government YourHome

- Confirms stiffened raft, waffle raft, suspended slab, void former, waffle pod and slab-edge insulation concepts.
- Notes that void formers can use different systems and materials. This supports keeping generic void former and waffle pod as parent and child rather than exact synonyms.

### CAUL Open Educational Resources Collective

- Search-indexed material supports the distinction between slab, raft, ground slab, suspended slab, beam and footing roles.
- Reinforcement material supports separate bar, reinforcing mesh, trench mesh and ligature identities.
- Direct retrieval returned HTTP 403, so these records are marked `search_index_excerpt` and are never the sole evidence for an accepted high-risk regulatory claim.

### CSIRO termite guidance

- Supports physical barrier examples including metal shields, stainless steel mesh, graded stone and penetration collars.
- Supports chemical-treated soil and replenishment reticulation as different physical components.
- Direct PDF retrieval returned HTTP 403; only the lawful search-index excerpt was used alongside the public NCC source.

## Candidates held for later passes

- bored pier, screw pile, driven pile and pile cap;
- masonry pier and timber soleplate;
- articulated footing system and articulation joint;
- construction joint, contraction joint, isolation joint and waterstop;
- starter bar, dowel, reinforcement coupler and bar end anchorage;
- suspended in-situ slab, precast floor panel and permanent structural formwork;
- formwork panel, joist, bearer, prop, brace, waler and form tie;
- drainage aggregate envelope, geotextile filter, grated inlet pit, channel drain and swale;
- surface inlet, legal point of discharge and overflow path;
- termite inspection zone and exposed slab edge as constraint entities rather than physical objects.

These candidates are not rejected as unreal. They remain outside the accepted dataset until their Australian terminology, function and relationships receive a dedicated source pass.

## Rejected as primary physical objects

- site classification;
- allowable bearing pressure;
- compaction method and test result;
- excavation, pouring, compacting and curing operations;
- concrete cover, lap length and spacing;
- finished ground level and natural ground level;
- slope ratio, fall and depth of cover;
- termite inspection and treatment life expectancy;
- compliance pathway, design action and structural capacity.

These belong in project inputs, rules, attributes, processes or evidence—not in the physical-object ontology.
