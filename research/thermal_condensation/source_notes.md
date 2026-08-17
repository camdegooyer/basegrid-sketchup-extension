# Thermal performance, condensation control and ventilation source notes

## Scope of this slice

This slice identifies 134 physical assemblies and components needed to draw the thermal envelope, condensation-control layers, building air seals and closely related residential ventilation paths exposed by NCC Volume Two Part H6 and Housing Provisions Parts 6.2, 10.6, 10.8, 13.2 and 13.4. It covers:

- roof and ceiling, external-wall, suspended-floor and slab-edge thermal assemblies;
- bulk, reflective, loose-fill, blown, rigid-board and sprayed insulation products;
- insulation placement, infill, retaining, support and wind-wash-control parts;
- pliable membranes and their independent water, air, vapour and reflective roles;
- membrane laps, tapes, patches, sleeves, fasteners, cap washers and sealants;
- continuous insulation, thermal-break strips, pads, brackets, battens and fasteners;
- lining, joint, opening, service, door, rooflight, exhaust and appliance air seals;
- roof-space ventilation voids, openings, terminals, flashings, screens and baffles;
- subfloor spaces, external vents, internal transfer passages and ground membranes; and
- room exhaust fans, rangehood and dryer exhaust paths, ducts, terminals, controls and make-up-air openings.

This is a physical-object discovery slice, not a complete energy-rating or condensation-analysis engine. Window and glazed-door energy properties exist in the openings catalogue, but full shading geometry, ceiling fans, service energy, NatHERS inputs, heating and cooling systems, balanced or heat-recovery ventilation and specialist mechanical design need later passes.

## Regulatory path in plain English

NCC Volume Two Part H6 sets the house energy-efficiency performance requirements. A design can use the applicable house-energy-rating route or an elemental Deemed-to-Satisfy route. The elemental route sends physical construction into Housing Provisions:

- Part 13.2 for building fabric;
- Part 13.3 for external glazing and shading;
- Part 13.4 for building sealing; and
- Part 13.5 for ceiling fans in relevant climates.

This slice concentrates on Parts 13.2 and 13.4. It also follows the related health-and-amenity path because thermal layers cannot be designed safely in isolation from moisture and air movement:

- Part 10.6 addresses natural and mechanical ventilation of rooms;
- Part 10.8 addresses condensation management, external-wall membranes, exhaust to outdoors, make-up air and roof-space ventilation; and
- Part 6.2 addresses ventilation below suspended floors.

The applicable climate zone, jurisdiction, NCC edition, building classification and chosen compliance path must be known before rules are applied. A product that is appropriate on one side of an assembly in one climate may be inappropriate in another. A future tool should expose those inputs rather than hide them behind a generic compliant checkbox.

The Housing Provisions call up AS/NZS 4859.1 for insulation materials and AS 4200.1 and AS 4200.2 for pliable building membranes and their installation. AS/NZS 4859.2, AS 3999, AS 4740 and AIRAH DA07 are recorded as supporting sources, not silently substituted for the exact NCC references. Standards Australia public metadata is used to identify editions and scope; licensed clauses, test details and tables are not reproduced.

## Draw the construction; calculate the performance

A drawing tool needs a hard boundary between physical construction and performance metadata.

Physical objects include an insulation batt, board, membrane, airspace, tape, strip, fastener, vent opening, duct and damper. Their thickness, extent, location, orientation and connections can be drawn.

The following are not extra solids:

- R-value or Total R-value;
- thermal transmittance or U-value;
- vapour permeance and membrane classification;
- airtightness or air-leakage rate;
- net free open area, when used as a calculated or certified property of a vent;
- airflow rate and pressure;
- thermal-bridge fraction, linear transmittance or adjusted assembly result; and
- surface temperature, humidity, dew point or condensation risk.

These values belong to a named product, component, assembly, opening or analysis case. The tool can display them as labels or overlays, but it should not create fictional geometry for them.

An R-value must state what it describes. A material or product R-value is not the Total R-value of a roof, wall or floor. The total result can include surface films, airspaces, linings, framing and parallel heat-flow paths. Heat-flow direction can also matter. The model should preserve the input values and calculation boundary rather than copy one product label onto the whole assembly.

## The thermal envelope is an assembly network

The thermal envelope is the connected set of building assemblies separating conditioned or habitable space from outside air, ground, roof spaces, subfloor spaces or other relevant environments. It is a role assigned to real roofs, ceilings, walls, openings, floors and slab edges—not a second shell drawn over the building.

For every segment, the tool should know:

- the spaces or environments on each side;
- the structural and lining assembly carrying the thermal role;
- the primary insulation layer and any secondary or continuous layer;
- junctions with adjacent envelope segments;
- openings, penetrations, service zones and access hatches;
- water-, air- and vapour-control layers crossing the segment;
- repeating framing and local conductive bridges; and
- the evidence and analysis applying to that exact construction.

Continuity is a relationship. At a wall-to-ceiling junction, for example, the ceiling insulation, wall insulation and air-control layers need identifiable edges and connections. Drawing three overlapping coloured regions does not prove that the physical layers meet without a gap.

## Insulation products, forms and placement roles

Insulation needs more than one classification axis. The catalogue keeps separate:

- material family, such as glass mineral wool, rock mineral wool, polyester, cellulose, EPS, XPS, PIR or phenolic foam;
- supplied form, such as batt, blanket or roll, loose fill, blown layer, rigid board or sprayed foam;
- facing, such as reflective foil or wind-wash-control fabric; and
- placement role, such as ceiling, wall cavity, continuous external layer, underfloor, subfloor wall, under slab or soffit.

This matters because a glass-wool batt and a PIR board can fill a similar thermal role but need completely different geometry, supports, fixings, clearances and evidence. Conversely, the same board product can be used in more than one placement role if the product evidence and assembly allow it.

The Housing Provisions expect insulation to form a continuous barrier and retain its position and thickness. A useful model therefore includes small but important physical parts:

- cut infill pieces around framing and openings;
- overlapping or stacked layers where specified;
- support netting below flexible insulation;
- straps, wires, clips or hangers;
- wind-wash-control facing at exposed underfloor locations;
- perimeter pieces around windows, doors and other openings; and
- stops or baffles preventing ceiling insulation from blocking eave ventilation.

Compression, gaps and displaced material are conditions of installed objects. The tool should store design thickness and as-installed thickness separately where inspection information exists. It should also identify services and heat-producing equipment whose clearances must be resolved rather than automatically packing insulation around everything.

Reflective insulation needs an adjacent airspace to provide its intended reflective contribution. The reflective surface, clear airspace, supports, sheet laps and sealed joints are separate geometry. A foil laminate pressed tightly between solid layers should not inherit the performance of the documented reflective-airspace arrangement.

## Thermal bridges and their mitigation

A thermal bridge is a heat-flow condition through more conductive material or geometry. The bridge itself is not a drawable object. Its physical causes can include metal studs, roof battens, steel floor framing, brackets, plates and fasteners crossing insulation.

Physical mitigation can include:

- continuous insulation outside or inside repeating framing;
- roof or wall thermal-break strips;
- a floor thermal-break layer;
- isolation pads behind local brackets;
- thermally broken bracket assemblies;
- spacer battens; and
- fasteners selected and spaced as part of the documented system.

The model should not erase a bridge simply because a thin strip has been drawn. It must retain the conductive member, the extent and continuity of the mitigating layer, all penetrations through it and the calculation or evidence used for the adjusted assembly result.

## Membranes have several independent jobs

Pliable building membrane is a product family. Water control, air control, vapour control and reflective performance are roles or classifications. One installed sheet can perform several of these jobs, but the model must not assume that every wrap does all of them.

For each membrane instance, retain:

- manufacturer and product identity;
- AS 4200.1 classification evidence;
- vapour permeance or class;
- water- and air-control claims where evidenced;
- reflective surface and emittance where relevant;
- printed or functional face orientation;
- location relative to the primary insulation and cladding;
- supported or unsupported installation condition;
- horizontal and vertical laps;
- seam, flashing and double-sided tapes;
- patches or sleeves at penetrations;
- fasteners, cap washers and compatible adhesive or sealant; and
- interfaces with flashings, windows, doors, roof edges and other control layers.

The NCC condensation path places the relevant external-wall membrane outside the primary insulation and applies climate-dependent vapour-permeance requirements. Where a wall does not use the membrane path, the primary water-control layer and drained cavity become important. Layer order is therefore a first-class relationship, not a cosmetic drawing order.

The everyday word breathable is unsafe as a stored classification. Vapour diffusion through a membrane is not deliberate airflow. A vapour-permeable layer can still form part of a sealed air barrier, while a visible hole is an air path regardless of vapour class.

A drained cavity and a ventilated cavity also differ. Drainage needs a downward water path and outlets. Ventilation needs connected air inlets and outlets sized for airflow. A reflective airspace has a thermal role and must remain sufficiently clear. One void can have more than one documented role, but the tool should never infer all three from the word cavity.

## Building sealing

Housing Provisions Part 13.4 exposes many physical leakage-control details. The catalogue includes:

- close-fitting lining joints and an internal-lining air-barrier role;
- sealant beads, expanding-foam fills, compressible strips and fibrous seals;
- architrave, skirting and cornice interfaces used to close lining edges;
- door perimeter seals, sweeps, automatic drop seals and threshold seals;
- rooflight ceiling diffusers, weather seals and shutters;
- backdraft dampers to exhaust fans;
- shut-off dampers to evaporative coolers and chimneys or flues;
- seals around service penetrations and electrical outlets; and
- weather seals around access hatches.

These products are not interchangeable gap fillers. The geometry, expected movement, substrate, backing, exposure, durability, fire or acoustic requirement and access for replacement all matter. Expanding foam used around a service opening is not automatically sprayed-foam insulation, firestop or waterproofing.

The airtight layer can be a membrane, sealed lining or coordinated combination. A future tool should trace it as a connected network across faces, corners, openings and penetrations. Air leakage is then an analysis or test result for that network.

## Roof-space ventilation

The condensation provisions introduce roof-space ventilation in specified climate zones and constructions. The catalogue separates:

- the roof-space or local ventilation void;
- low-level eave, soffit or fascia openings;
- high-level ridge, gable, static, rotary, powered or tile vents;
- the opening through the roof or wall construction;
- the proprietary terminal and its base flashing;
- insect or ember mesh where applicable;
- baffles keeping a path open past insulation; and
- insulation stops at the eaves.

The gross face area of a grille or vent is not its net free open area. Mesh, blades, frames and internal restrictions reduce the usable airflow area. Store certified or calculated free area as an attribute of the physical opening or product, then aggregate only openings connected to the roof volume being assessed.

Distribution matters as much as total area. Low and high openings, or openings on opposing sides, must connect through the intended void without insulation, framing or stored services blocking the route. An arrow can illustrate airflow in a schematic view, but the physical model should carry relationships between openings and spaces rather than draw airflow as a pipe.

A rotary roof ventilator, often called a whirlybird, is different from a static vent or powered fan. The drive type, flashing and performance evidence belong to the product. Roof-space ventilation also remains distinct from room exhaust: a bathroom fan must not discharge moisture into the roof space.

## Subfloor ventilation

Housing Provisions Part 6.2 addresses the bounded space below a suspended floor. Its physical path can include:

- external subfloor openings through perimeter walls;
- brick vents or grilles with a known free area;
- internal transfer openings through subfloor walls;
- aligned passages through the leaves of cavity masonry; and
- a ground vapour membrane used in the applicable alternative path.

The model needs the subfloor volume and each connected opening, not merely vent symbols placed around a plan. It should support checks for distribution, proximity to corners, internal dead-air pockets, cross-flow, ground clearance and obstructions.

A masonry weephole is not automatically a subfloor vent. A weephole primarily drains or ventilates a wall cavity; a subfloor opening connects outside air to the volume below the floor. If an opening has more than one intended role, both connected spaces and the supporting evidence must be explicit.

## Room exhaust and make-up air

Condensation management requires specified bathroom, sanitary-compartment, laundry, kitchen and venting-dryer exhaust systems to discharge to outdoor air. The physical system can include:

- a ceiling-mounted, wall-mounted or inline fan;
- a rangehood exhaust assembly;
- a venting dryer's exhaust connection;
- rigid or flexible duct and fittings;
- a backdraft damper;
- an outdoor wall or roof terminal;
- a run-on timer or light-switch interlock; and
- a designed make-up-air opening or transfer path.

The source room, fan, duct, terminal and outdoor destination must be connected. A fan symbol by itself does not show compliance. A recirculating rangehood filters and returns air indoors; it is not a ducted-to-outdoors exhaust path.

Make-up air is airflow, not a solid component. The drawable objects are the opening, door undercut or transfer grille providing the route. Accidental gaps in the envelope are uncontrolled leakage and should not be presented as an equivalent design component.

This creates a real coordination issue at doors. A door undercut may be deliberately sized to transfer air toward an exhaust room, while a sweep or automatic drop seal is intended to close the same gap. Acoustic, smoke or fire requirements may add further constraints. The tool must resolve the selected path for that door instead of placing mutually defeating parts on the same edge.

The current catalogue stops at house-scale discovery detail. Fan selection, duct pressure loss, noise, condensate, fire and smoke dampers, balancing, commissioning and whole-house mechanical systems need a dedicated services pass.

## CAD implications

A useful thermal, moisture and ventilation tool should retain at least:

- jurisdiction, NCC edition, building class, climate zone and compliance path;
- conditioned spaces and every environment across the thermal envelope;
- roof, wall, opening, floor and slab-edge segment boundaries;
- product material, supplied form, thickness, facing and placement role;
- design and as-installed insulation coverage, gaps and compression;
- primary and secondary insulation layers and their junction continuity;
- framing, brackets, fasteners and other thermal-bridge paths;
- physical thermal-break or continuous-insulation geometry;
- membrane product, independent performance classes, face and layer order;
- every lap, tape, patch, sleeve, fastener and flashing interface;
- the connected air-barrier network and every intentional opening or sealed penetration;
- roof-space and subfloor volumes, openings, terminals and obstructions;
- net free open area as product or opening metadata;
- room exhaust source, fan, duct, damper, terminal, controls and outdoor destination;
- make-up-air route and any conflict with door, acoustic, smoke or fire seals; and
- evidence source, product version, installation assumptions and inspection state.

At concept level, the tool can show thermal-envelope fields, insulation zones, membrane planes and ventilation paths. At detail level, it can expose cut batts, board joints, support netting, thermal-break strips, membrane tapes, door seals, vent baffles and duct fittings. Both views should use the same stable objects.

The tool must not assign compliance because a wall is coloured as insulated or a fan symbol is present. The result depends on the selected regulatory route, complete physical assembly, continuity, installation, climate, connected spaces, product evidence and analysis.

## Main sources

- ABCB, NCC Volume Two Part H6, energy efficiency.
- ABCB, Housing Provisions Parts 6.2, 10.6, 10.8, 13.2 and 13.4.
- ABCB, *NCC 2022 Housing energy efficiency handbook*.
- ABCB, *Condensation in buildings handbook*.
- ABCB, *Understanding the NCC — Thermal bridging in residential buildings*.
- Standards Australia public metadata for AS 4200.1:2017, AS 4200.2:2017, AS/NZS 4859.1:2018 and AS 1668.2:2012.
- Standards Australia public metadata for supporting AS/NZS 4859.2:2018, AS 3999:2015 and AS 4740:2025.
- AIRAH public metadata for DA07 *Criteria for Moisture Analysis in Buildings* (2020).
- Knauf Insulation Australia public product-family information.
- Kingspan Insulation Australia public rigid-board information.
- Ametalin public membrane classification and installation information.
- Bradford public residential roof-ventilation information.
- Fantech public residential exhaust-fan and duct information.
- Raven public weather-seal product information.

No licensed standard text is reproduced. Exact test methods, tables, classification limits, installation requirements and product-specific performance remain authorised-source inputs for later implementation.
