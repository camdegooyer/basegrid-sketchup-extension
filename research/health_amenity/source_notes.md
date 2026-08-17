# H4 health and amenity object research

## Scope and result

This slice identifies the physical objects needed to represent the remaining house-scale construction in NCC Volume Two Part H4 and Housing Provisions Parts 10.3 to 10.7. It adds 95 objects under the `health_amenity` discipline.

The new catalogue covers:

- required kitchen, personal-washing, laundry, toilet and washbasin facilities;
- sanitary-compartment occupant-recovery door construction;
- natural-light openings through roofs and lightwells;
- Class 1 separating-wall sound-insulation construction and service treatments; and
- internal ceilings, bulkheads and access panels that form physical room-height boundaries.

H4 also covers wet-area waterproofing, ventilation and condensation management. Those physical objects already exist in the waterproofing and thermal-condensation catalogues and are reused rather than copied. Ordinary windows, doors and glazing are likewise reused from the completed openings and glazing slices. H8 toilet, basin, shower and door components are reused where they are the same physical objects.

The catalogue is an object vocabulary and modelling guide. It does not make a project compliant by itself. Jurisdiction, adopted NCC edition, approval pathway, product evidence, engineering and licensed trade requirements remain project inputs.

## Regulatory chain

The source path used for this slice is:

1. NCC Volume Two Part H4 states the health-and-amenity performance and Deemed-to-Satisfy paths.
2. Housing Provisions Part 10.3 deals with room heights.
3. Part 10.4 identifies dwelling facilities and sanitary-compartment door recovery.
4. Part 10.5 deals with natural and artificial light.
5. Part 10.6 covers ventilation and is already represented by the ventilation catalogue.
6. Part 10.7 covers sound insulation for relevant Class 1 separating walls.
7. Part 10.8 covers condensation management and is already represented by the thermal-condensation catalogue.

The H4 label is a regulatory grouping, not one building solid. A future tool should keep one physical kitchen sink, wall, ceiling, window or fan and attach H4 roles and checks to it. It should not duplicate the same construction into separate architectural, waterproofing, acoustic and compliance objects.

## Required dwelling facilities

Part 10.4 identifies facilities rather than prescribing one room arrangement. The kitchen, bath or shower, laundry, closet pan and washbasin can be coordinated across the dwelling subject to the applicable provisions. The model therefore stores a linked facility set rather than inventing one mandatory combined room.

### Kitchen

The kitchen family separates the following real objects:

- sink installation assembly;
- manufactured sink body;
- individual bowl or bowls;
- drainer surface where fitted;
- basket waste and overflow fittings;
- mounting clips and rim seal;
- tapset;
- sink base cabinet;
- food-preparation bench and its benchtop;
- splashback construction;
- cooking facility;
- freestanding cooker, or separate built-in cooktop and oven;
- built-in oven support shelf; and
- freestanding-cooker anti-tip bracket, lock pin and adjustable feet.

This distinction matters in SketchUp. A sink cut-out belongs to the benchtop, the bowl is a formed void below it, clips connect the rim to the support and the waste opening continues into plumbing. A symbolic rectangle cannot show cabinet clashes, bowl depth, mounting, drainage or the usable work surface.

The H4 food-preparation requirement is represented by the actual bench construction. Any minimum usable area is a check over unobstructed finished benchtop faces, not another slab of material. Sinks, cooktops, upstands and fixed appliances can interrupt that area.

Cooker and cooktop installation details remain product-specific. The catalogue includes representative physical support and anti-tip parts because they affect cabinetry and floor or wall connections, but it does not invent gas, electrical, exhaust or combustible-clearance values. Those come from the selected appliance, applicable service rules and authorised installation instructions.

### Personal washing

The personal-washing facility links to an actual bath or shower. The completed waterproofing catalogue already contains shower trays, screeds, membranes, waterstops, drains, hobs and level-threshold shower construction. The glazing catalogue supplies shower screens. H8 adds a nominated step-free role and future-grabrail backing where that path applies.

Reusing those objects prevents duplicate membranes, floors and screens. A project can attach ordinary H4, H8, accessibility and waterproofing roles to one installed shower while retaining the different rule sets.

### Laundry

The laundry family separates:

- the complete laundry-facilities assembly;
- the washtub installation;
- the formed tub fixture;
- its cabinet and tapset;
- basket waste, overflow and rim-mounting parts shared with sinks;
- an optional washing-machine rinse-bypass kit;
- a washing-machine installation and connection assembly;
- the appliance when it is actually selected or shown;
- water inlet hose; and
- drain hose and hose guide.

A laundry washtub is not automatically interchangeable with a kitchen sink or washbasin. Product words such as tub, trough and sink can refer to the formed bowl, the cabinet product or the whole installation, so these levels remain separate.

Space for a washing machine is a clearance or reservation in the layout, not a quantity-bearing object. The machine and hoses are real physical objects but may be owner-supplied. A tool should be able to show the reserved space without pretending that an appliance has been specified.

### Toilet and washbasin

The general sanitary facility set links the required closet pan and washbasin to their installed room or rooms. Existing H8 objects provide the toilet pan, cistern, carrier, seat, flush plate, connectors and basin or vanity components. H4 does not require those parts to be redrawn.

The model distinguishes:

- the dwelling's sanitary-facilities set;
- the enclosed sanitary compartment;
- the toilet suite and washbasin fixtures; and
- the door-recovery construction.

Everyday words such as toilet, WC, powder room and bathroom are useful search terms, but they do not reliably distinguish the enclosure from the ceramic fixture.

## Sanitary-compartment occupant recovery

Where the provision applies, the door arrangement must allow an occupant who has collapsed near the pan to be reached. The identified physical approaches are:

- an outward-opening door;
- a sliding door that does not swing into the compartment; or
- an inward-opening door made externally removable in the required circumstance.

The catalogue adds a recovery assembly, an externally removable door, lift-off hinges, removable hinge pins and an external privacy-latch release. These parts do different jobs. Unlocking a latch does not necessarily let a blocked inward-swinging leaf open, and a removable leaf still needs hardware that can be operated from outside.

A future tool should model the actual leaf, frame, swing or sliding path, hinge connection, latch access and nearby pan. The recovery condition is a geometry and operation test over those objects, not a compliant-door material.

## Natural light and roof openings

Ordinary windows and framed glazed doors already exist in the openings catalogue. H4 adds their role as natural-light openings and introduces the roof-specific chain:

- complete rooflight assembly;
- manufactured rooflight unit;
- roof kerb or upstand;
- lightwell or shaft; and
- internal lightwell lining.

The rooflight still needs the roofing catalogue's opening, support and flashing objects and the glazing catalogue's panes and seals where applicable. The H4 catalogue does not duplicate them.

Rooflight and skylight are often used broadly. A kerbed rooflight, an in-plane roof window and a tubular daylight device can have different geometry and weathering. A lightwell is the shaft between a roof opening and an internal ceiling, not the rooflight itself.

Opening area, visible glass area, light-transmitting area, room floor area and any daylight result remain separate calculated properties. Frames, mullions, opaque panels, shaft shape and product transmission can change the result. A future tool should calculate from the correct physical faces instead of using the rough opening as a universal daylight number.

Artificial-light fittings are left for the electrical slice. Their existence in H4 does not justify building an incomplete lighting-product ontology here.

## Room-height construction

Room height is measured between real bounding surfaces. The catalogue therefore adds:

- a room-height bounding assembly referencing the finished lower and upper faces;
- an internal ceiling lining assembly;
- plasterboard ceiling sheet;
- ceiling bulkhead assembly, frame and lining;
- internal cornice; and
- ceiling access panel assembly.

Existing floor finishes, ceiling battens, ceiling joists, roof members, insulation, cornice air seals and access-hatch seals can be linked to these objects where present.

The following are not new material objects:

- the required minimum height;
- a floor-to-ceiling dimension;
- a sloping-ceiling compliant-area result;
- a projection allowance;
- a stair or corridor head-height result; and
- a pass, warning or failure state.

These are measurements or rules applied to physical geometry. A sloping-ceiling review area can be displayed as a translucent overlay, but it should not be counted as floor, ceiling lining or room volume.

Ceiling height, wall height, floor-to-floor height and storey height are not safe synonyms. Floor finishes, lining thickness, suspended ceilings, beams and bulkheads cause them to differ. The model should identify the actual finished floor and visible ceiling or structural underside used by each test.

## Class 1 sound-insulating separating walls

The national Housing Provisions path is primarily a wall construction path for relevant adjoining Class 1 buildings and the applicable relationship with an unrelated Class 10a building. The model records the two spaces or buildings, their classification and association instead of relying on party wall or common wall as proof of scope.

The catalogue adds:

- Class 1 sound-insulation system;
- complete sound-insulating separating wall;
- discontinuous separating wall;
- wall-leaf assembly;
- double-masonry-leaf wall;
- masonry wall with isolated lining;
- massive single-leaf wall;
- double-row framed wall;
- wall-to-roof and perimeter acoustic junctions; and
- sound-insulating ceiling termination where that physical route is used.

Acoustic performance belongs to the complete construction supported by evidence. It does not belong to one plasterboard sheet or insulation batt. Studs or masonry, wall leaves, cavities, linings, fixings, joints, seals, junctions and services must remain together as an identifiable build-up.

### Discontinuous construction

Discontinuous construction is represented as physically separate wall leaves with controlled connections. Two visible sides do not prove discontinuity. Shared studs, rigid ties, bridging noggings, debris in a masonry cavity, services or another solid connection can couple the leaves.

The object model therefore keeps:

- each supported leaf;
- the cavity between leaves;
- cavity insulation as a separate occupant of that space;
- resilient ties where required;
- every permitted junction; and
- any bridge across the intended separation.

Double-stud, staggered-stud, twin-wall and cavity-wall are not assumed to mean the same thing. The physical framing or masonry arrangement must match the selected construction evidence.

### Linings, joints and resilient supports

The component family includes:

- acoustic plasterboard and fibre-cement lining sheets;
- cement render where part of the wall build-up;
- cavity insulation;
- lining fixings;
- sheet-joint tape and compound;
- perimeter sealant and joint backing;
- resilient lining channel; and
- acoustic isolation clip.

Multi-layer lining joints should remain individually placed so staggered joints can be checked. A single thick-looking face does not reveal layer count, joint positions or fixing sequence.

Resilient masonry ties, channels and clips are different connection objects. They attach different hosts, carry different loads and use product-specific spacing and fixings. One generic rubber mount would not preserve enough information for a reliable drawing tool.

### Perimeters, roof junctions and flanking paths

The separating wall should continue to its documented termination and close residual paths at floors, external walls, ceilings and roofs. The acoustic roof junction can coincide with the completed fire wall-to-roof termination, but it does not replace that assembly. One coordinated physical closure can carry both roles when the materials and evidence are compatible.

The ABCB handbook also highlights flanking transmission around the main wall. The floor, roof, ceiling, facade and services can bypass a high-performing wall. Flanking is a path through connected objects, not a new material. It is best represented by graph relationships and review results over the junction geometry.

## Services in separating walls

Services can create openings, rigid bridges and noise paths. The H4 catalogue adds the physical treatment families most relevant to the public NCC and handbook guidance.

### Access panels

The sound-insulating access-panel assembly contains a panel leaf or door, frame and continuous perimeter seal. A removable piece of wall lining is not assumed to provide the same performance. The actual wall opening, frame, fixings, seal compression and closed position should be modelled.

### Water pipes and ducts

The family separates:

- water-supply pipe assembly in the separating wall;
- resilient pipe clip;
- acoustic pipe or duct wrap;
- wrap closure tape; and
- flexible service connector.

Acoustic wrap is not automatically the same as thermal or condensation insulation. One product can serve several roles if supported by evidence, but its mass, layers, facing, seams and supports must remain known.

### Electrical outlets

The catalogue includes the outlet treatment assembly, mounting box, acoustic barrier or putty pad and acoustic caulk. The offset between boxes on opposite leaves is stored as a measured relationship between actual boxes. It is not a separate offset solid.

Fire, electrical and acoustic roles can overlap at service openings. A fire putty pad or fire-acoustic sealant is reused from the fire catalogue where it is the same selected product and detail. The wall retains both evidence paths rather than generating two pads in the same place.

## Acoustic ratings and standard editions

Housing Provisions 10.7.2 directly identifies AS/NZS ISO 717.1:2004 for airborne sound-insulation ratings. Standards Australia has published AS ISO 717.1:2024 as the current successor publication.

These two facts must remain separate:

- `AS-NZS-ISO-717-1-2004` is the edition directly referenced by the captured NCC 2022 Housing Provisions path; and
- `AS-ISO-717-1-2024` is the later publication but is not silently substituted into that path.

Rw, Ctr and combined rating expressions are evidence metadata, not physical objects and not thermal R-values. Each result should retain the exact metric, standard edition, test or assessment, wall build-up, direction or condition where relevant and governing project path.

The standards themselves are held as metadata-only records. This project does not reproduce licensed test methods, tables or construction details.

## Jurisdiction variation

The Northern Territory publishes a specific variation replacing the national Part 10.7 path. That confirms why jurisdiction cannot be an optional label on an Australian catalogue. A future tool must ask for jurisdiction, project date, adopted edition and approval path before selecting wall types, acoustic targets or service-treatment rules.

The same physical wall objects can support national, territory, performance-solution or project-specification pathways. The rule set and evidence attached to them must remain explicit.

## Drawn objects versus constraints

Draw or reuse these as physical model objects:

- fixtures, appliances, cabinets, benchtops, fittings and mounting parts;
- doors, hinges, pins, latches, leaves, frames and movement states;
- windows, rooflights, kerbs, lightwells and linings;
- floors, ceiling sheets, bulkheads, cornices and access panels;
- wall leaves, framing or masonry, cavities, linings, insulation, ties, channels and clips;
- sealants, backing materials, tapes, joint compounds and fixings;
- pipes, wraps, flexible connectors, electrical boxes, pads and caulk; and
- every penetration, junction and supported opening.

Store or calculate these as properties, relationships or non-quantity review overlays:

- room classification and use;
- minimum room height and measured result;
- sloping-ceiling qualifying area;
- natural-light ratios, transmitting area and daylight result;
- washing-machine reserved space;
- door-recovery clearance and access route;
- Rw, Ctr and other rating evidence;
- discontinuous-construction result;
- electrical-box offset;
- direct and flanking sound paths; and
- pass, warning, unknown and compliance states.

This boundary avoids false materials and quantities while keeping the checks visible and traceable.

## SketchUp behaviour implied by the research

A future implementation should:

- ask for jurisdiction, approval pathway and relevant date before making a compliance statement;
- let the user nominate room uses and the physical objects fulfilling each facility role;
- reuse one fixture, opening, wall or ceiling where several code roles overlap;
- derive room height, daylight opening areas and clearances from finished geometry;
- keep calculation overlays out of material quantities and ordinary clash detection;
- support product-specific sink, tub, appliance, rooflight, door and access-panel geometry;
- expose concealed clips, ties, seals, backing, wraps and service boxes in section or inspection views;
- assemble acoustic walls from explicit leaves, cavities, layers, junctions and penetrations;
- identify rigid bridges and unsealed routes rather than assuming that an acoustic product name proves performance;
- coordinate acoustic, fire, moisture, structure and services at the same physical junction;
- keep the source, standard edition and evidence attached to every reported rating; and
- distinguish unknown information from a failed check.

The safest default remains: draw what is physically known, ask for the missing product or design choice and report uncertainty. The tool should not invent a compliant wall, rooflight, appliance clearance, door-recovery method or acoustic rating to produce a green result.

## Boundaries and later research

The following remain outside this slice:

- complete sanitary plumbing, water supply and drainage systems;
- plumbing-product certification and installation standards;
- gas and electrical appliance connection systems;
- rangehoods, full kitchen exhaust design and complete electrical lighting products;
- artificial-light design and controls;
- detailed roof-glazing and proprietary tubular-daylight systems;
- complete internal room-acoustic treatment;
- apartment and commercial intertenancy floors, walls, doors and service risers under NCC Volume One;
- mechanical plant vibration isolation beyond the identified house-scale connections;
- detailed acoustic test procedures and licensed standard content;
- project-specific acoustic engineering and performance solutions; and
- jurisdictional adoption logic beyond the public source metadata captured here.

These later slices can reuse the facilities, opening, wall, ceiling and service-treatment objects without changing their physical identity.

## Primary source set and licence boundary

Primary public sources registered for this slice are:

- `SRC-ABCB-V2-H4-WET-AREAS` — NCC Volume Two Part H4, used as the overall H4 path as well as the earlier wet-area source;
- `SRC-ABCB-HP-ROOM-HEIGHTS` — Housing Provisions Part 10.3;
- `SRC-ABCB-HP-FACILITIES` — Housing Provisions Part 10.4;
- `SRC-ABCB-HP-LIGHT` — Housing Provisions Part 10.5;
- `SRC-ABCB-HP-ROOM-VENTILATION` — Housing Provisions Part 10.6, already used by the ventilation catalogue;
- `SRC-ABCB-HP-SOUND-INSULATION` — Housing Provisions Part 10.7;
- `SRC-ABCB-SOUND-HANDBOOK-2022` — ABCB Sound transmission and insulation in buildings handbook;
- `SRC-ABCB-NT-HP-SOUND-INSULATION` — Northern Territory Part 10.7 variation;
- `SRC-SA-AS-NZS-ISO-717-1-2004` and `SRC-SA-AS-ISO-717-1-2024` — Standards Australia public product metadata; and
- registered Oliveri and Fisher & Paykel product sources, used only to identify representative manufactured subparts and installation interfaces.

The catalogue paraphrases public NCC and ABCB material and creates original plain-English object definitions. It does not reproduce licensed Australian Standard clauses, acoustic construction tables, figures, proprietary installation manuals or extensive source text. Exact dimensions, ratings, current jurisdiction variations, product instructions and compliance evidence must be resolved from authorised documents when a tool reaches design or compliance functionality.
