# Cold-formed steel framing research notes

Research date: 16 August 2026. Regulatory baseline: NCC 2022 Amendment 2.

These notes record public evidence used to discover physical objects. They do not reproduce licensed NASH or Australian Standard content and do not provide member design or connection capacities.

## Regulatory path

NCC Volume Two H1D6 states that steel framing can satisfy the structural Performance Requirement through NASH Standard Residential and Low-Rise Steel Framing Parts 1 and 2, AS 4100, or AS/NZS 4600. The Housing Provisions Section 6 does not contain the full cold-formed wall, floor and roof framing solution; Part 6.1 points other steel framing back to H1D6.

NASH Part 2 is separately published and is directly listed in the Housing Provisions schedule. It is recorded as a referenced code, not mislabelled as an Australian Standard. NASH Part 1 is directly referenced by Volume Two H1D6 and is retained as a supporting code for this discipline.

## Public object evidence

The NASH General Guide identifies prefabricated floor frames, wall frames and trusses. Its wall-frame list includes top and bottom plates, studs, lintels or beams, noggings and bracing. It also identifies self-drilling screws, rivets, clinched connections, anchors, pre-punched service holes, plastic grommets, steel roof trusses, roof battens and ceiling battens.

The NASH/CSIRO “Innovation in Steel Framing” paper identifies roof battens, rafters and beams; wall studs, plates and posts; floor bearers, joists and stumps; bracing systems; and typical C and top-hat sections. It explicitly explains that proprietary light-steel components cannot all be standardised by one section geometry. This supports separating a member's construction role from its selected section shape.

NASH Part 2 public metadata confirms that the design-solution family covers roof beams and rafters, walls, floors, bracing, connections, durability and tolerances. The licensed rules and span tables are not stored.

BlueScope Technical Bulletin TB-34 supports physical bottom-plate separation membranes, interface isolation, compatible fasteners and permanent frame earthing. These are manufacturer details. Warranty-specific statements remain labelled as such rather than being promoted to NCC requirements.

## Modelling boundaries

- Cold-formed steel framing is separate from the structural-steel slice. A light-gauge floor bearer is not automatically the universal beam or tubular bearer described in Housing Provisions Part 6.3.
- Member roles and section forms are separate. A C-section may be scheduled as a stud, joist, bearer, rafter or beam.
- A frame system is more than its members: bracing, hold-downs, anchors and member-to-member connections complete the load path.
- A steel roof truss is an engineered assembly. The ontology records its supplied parts without authorising member movement, cutting or connection changes.
- A service hole is an opening and a grommet is a lining fitting. Neither authorises an additional penetration.
- A bottom-track moisture separator and a thermal break can look similar but have different roles and are not synonyms.

## Linked technical documents

- NASH Standard Part 1:2005 — Residential and Low Rise Steel Framing — Design Criteria, incorporating NCC-listed amendments A, B and C.
- NASH Standard Part 2:2014 — Residential and Low Rise Steel Framing — Design Solutions, incorporating amendment A.
- AS/NZS 4600:2018 — Cold-formed steel structures.
- AS 1397:2021 — Continuous hot-dip metallic coated steel sheet and strip.
- AS 2870:2011 and AS/NZS 2904:1995 are linked only to applicable bottom-track separation details.

## Known gaps

- proprietary stud, joist, truss and connector profiles from individual frame systems;
- sill trimmers, deflection-head tracks, boxed sections and proprietary built-up posts;
- steel stumps and adjustable subfloor support systems using hollow sections;
- detailed bracing collectors, diaphragm straps and floor-opening trimmers;
- eave, fascia, valley, hip and gable-end light-steel framing;
- temporary erection bracing, lifting points and transport restraints;
- electrical earthing conductors and clamps, to be handled with the electrical discipline; and
- licensed span, capacity, fastener, durability and tolerance rules.

Full URLs and access notes are stored in `data/sources/source_registry.json` and generated into `exports/source_audit.csv`.
