# Plumbing, sanitary drainage and onsite-wastewater object research

## Scope and result

This slice identifies the house-scale physical objects needed to draw water services, heated water, rainwater storage and distribution, sanitary plumbing, sanitary drainage and onsite wastewater management in Australia.

It adds:

- 134 `plumbing` objects for cold, drinking, non-drinking, heated, tempered and rainwater services;
- 128 `drainage` objects for fixture discharge, traps, vents, stacks, buried drainage, pumping, septic and secondary treatment, greywater, composting toilets and effluent land application;
- 30 supporting standards records for the AS/NZS 3500 and AS/NZS 1546/1547 families and related product standards;
- 26 public-source records; and
- 24 terminology decisions that prevent common hydraulic modelling errors.

This is an object vocabulary and drawing guide. It does not size a pipe, select a backflow device, certify a water heater, design a treatment plant, approve effluent quality or assess a land-application area. Those results require the adopted code path, licensed standards, selected products, project inputs and the relevant designer or authority.

## Which NCC volume controls

NCC Volume Three is the Plumbing Code of Australia. It applies to plumbing and drainage work across building classes, including Class 1 and Class 10 work that is otherwise designed from Volume Two and the Housing Provisions.

The main physical boundaries used here are:

1. Part B1: cold-water services;
2. Part B2: heated-water services;
3. Part B3: non-drinking-water services;
4. Part B5 and Specification 41: cross-connection and backflow protection;
5. Part B6: rainwater services from storage to outlets;
6. Part B7: rainwater storage from entry to service connection;
7. Part C1: sanitary plumbing from fixtures to the drainage boundary;
8. Part C2: sanitary drainage from that boundary to sewer or onsite treatment; and
9. Part C3: onsite wastewater treatment and land application.

This matters to a SketchUp tool because a pipe is not defined by shape alone. A cold-water pipe is pressurised and carries a selected water source. A fixture discharge pipe carries wastewater by gravity. A sanitary vent carries air. A rising main again carries wastewater under pressure. Each role changes its allowable fittings, slope, supports, access and connection logic.

## Edition control

The national extraction baseline remains **NCC 2022 Amendment 2**. The national Volume Three referenced-documents schedule calls up:

- AS/NZS 3500.0:2021;
- AS/NZS 3500.1:2021;
- AS/NZS 3500.2:2021 including Amendment 1;
- AS/NZS 3500.3:2021; and
- AS/NZS 3500.4:2021 including Amendment 1.

Standards Australia published new Parts 1 to 4 of AS/NZS 3500 on 17 April 2025. Publication does not itself replace the editions called up by a jurisdiction's adopted NCC. Victoria, for example, announced application of the 2025 series to relevant plumbing work from 20 October 2025. Other jurisdictions can have different adoption dates, transitions and variations.

A future tool must therefore store at least:

- jurisdiction;
- approval or work date;
- NCC edition and amendment;
- compliance pathway; and
- exact standard identifier and edition used for every rule result.

“Current standard” is not adequate provenance.

The standards registry also records AS/NZS 1546 product-family standards and AS/NZS 1547 for onsite domestic wastewater management. Those standards do not turn one generic tank into a universal treatment solution. The certified process, local approval and site assessment still control the physical arrangement.

## Water-service object model

The water-services catalogue starts with one building water-services assembly, then separates the service by source, temperature and permitted use.

### Cold and drinking water

Cold water means water not intentionally heated. Drinking water means water approved for human consumption and related uses and carried through suitable products. The concepts overlap but are not identical.

The physical route can contain:

- utility or alternative-source point of connection;
- property service pipe;
- water meter and meter box;
- main isolating valve;
- copper, stainless, PE, PVC-pressure, PE-X or multilayer pipe;
- bends, tees, reducers, adaptors and joint systems;
- clips, brackets, sleeves and anchors;
- pressure-control valves and gauges;
- fixture and appliance isolation valves; and
- outlet and hose-tap assemblies.

Pipe material and service role are stored separately. PVC pressure pipe, PVC DWV pipe, stormwater pipe and electrical conduit can all look like round plastic tube. The tool must never substitute them from appearance.

### Backflow protection

The catalogue treats backflow protection as a complete assembly. Depending on the selected hazard and pathway it can use a physical air gap, break tank or mechanical device.

The current families include check and dual-check devices, double-check-valve assemblies, reduced-pressure-zone devices, vacuum breakers, hose-connection devices, test cocks, strainers, isolation valves and relief drainage.

The assessed hazard rating is metadata. It is not a coloured solid and cannot be inferred from the device body. A future tool should receive or calculate the hazard assessment through an authorised rule source, then instantiate the accepted certified device with its actual test and service clearances.

### Heated and tempered water

The heated-water service includes more than a cylinder. It can contain:

- storage, continuous-flow, heat-pump or solar water heater;
- storage vessel, insulation, heating element, thermostat and anode;
- cold-water inlet control group;
- expansion, pressure, temperature-and-pressure relief valves;
- visible relief and safe-tray drains;
- heated flow and optional return pipework;
- circulation pump and balancing components;
- pipe insulation and supports; and
- a temperature-control assembly feeding tempered branches.

Heated-water storage, relief discharge and delivery-temperature control are different functions. The tool should split the graph at the heater, each relief outlet and each tempering or thermostatic mixing valve.

### Rainwater storage and distribution

Rainwater storage contains the tank, inlet, strainer, calming inlet where selected, access, screened overflow, outlet, drain, base and anchorage. Buried tanks add access risers, groundwater-resistant shells and engineered anti-flotation where required.

The downstream rainwater service can contain pump, suction line, floating intake, controller, pressure vessel, mains-switching assembly, protected top-up and marked outlets.

Reuse storage and stormwater detention are different roles. One vessel can carry both only when the reserved volumes, operating levels and outlet paths are explicit. The outside tank shape does not reveal those roles.

## Sanitary plumbing and drainage boundaries

Sanitary plumbing carries discharge from fixtures through traps, fixture pipes, branches and stacks to the drainage boundary. Sanitary drainage continues through graded buried or under-building drains to sewer or onsite treatment.

The plugin should preserve that boundary even if the same PVC product continues across it. This allows the model to change:

- support to embedment;
- internal route to buried route;
- branch rules and grade;
- inspection and overflow requirements;
- structural, waterproofing, termite and fire-penetration coordination; and
- ownership or authority metadata at the downstream connection.

### Traps and vents

P-traps, S-traps, bottle traps and integral fixture traps are different geometries. Their retained water seal blocks foul air. A trap-primer assembly can maintain an infrequently used water seal, but its drinking-water connection also raises a backflow-protection question.

The ventilation network includes branch vents, vent stacks, stack vents, relief vents, common vents, header vents, air-admittance valves, outdoor cowls and roof flashings.

The words matter:

- a sanitary stack carries discharge;
- a vent stack is a separate vertical vent-only pipe; and
- a stack vent is the continuation above the highest discharge connection.

An air-admittance valve admits air under negative pressure. It does not automatically provide an outdoor foul-air outlet or positive-pressure relief.

### Buried drainage and access

The buried system contains branch and main drains, junctions, gullies, inspection openings, rodding points, inspection shafts, terminal-maintenance shafts, property sewer connections and optional pumped sections.

An overflow relief gully is defined by function and level. Its open grate must be positioned so surcharge spills outside before protected internal fixtures. A similar-looking disconnector gully is not automatically the relief point.

The pipe is only one part of a buried installation. The model also records trench, bedding, haunch or side support, protective overlay, final backfill, flexible joints and engineered concrete encasement where selected. These volumes matter to excavation, clash detection and load behaviour.

Pumped drainage adds a sealed collection well, access lid, sewage pump, level switches, high-level alarm, non-return and isolation valves and a pressure-rated rising main. Pump duty and emergency volume remain verified design data.

## Onsite wastewater

An onsite system is a source-to-soil hydraulic path, not a tank symbol.

### Septic primary treatment

The septic assembly contains a watertight shell, primary and optional second chamber, internal partition, inlet and outlet tees, optional effluent filter, access risers and secured covers.

The septic tank settles and stores solids. It does not by itself define the land-application method or demonstrate final treatment performance.

### Secondary treatment and AWTS

Secondary treatment is the broad class. An aerated wastewater treatment system is one physical technology within it.

The AWTS catalogue includes:

- aeration chamber;
- air blower, manifold and diffusers;
- fixed or moving biological media;
- clarification chamber;
- sludge-return airlift;
- chlorination or ultraviolet disinfection assembly;
- treated-effluent pump chamber and pump;
- control panel and alarms; and
- treated-effluent sample point.

These are product-configured systems. The tool can preserve a certified manufacturer's component layout and required service envelope. It must not assemble arbitrary chambers and claim the resulting plant has a treatment classification.

### Greywater and composting toilets

A greywater diversion device changes the pipe path but does not treat water. A greywater treatment system adds collection, treatment, disinfection, storage, pumping and a fail-safe sewer path according to its approval.

A waterless composting toilet contains a pedestal, optional drop chute, treatment chamber, dedicated vent and fan, service hatch and excess-liquid path. It does not manage the house's showers, basins or laundry; those need a separate greywater or wastewater route.

### Land application

The catalogue separates four main physical approaches:

- gravity absorption trenches or beds;
- aggregate-filled trenches;
- proprietary open-bottom arch chambers;
- subsurface dripper irrigation; and
- surface spray irrigation where the jurisdiction, effluent quality and site approval permit it.

Supporting parts include dosing tanks, distribution boxes, siphons, pumps, perforated distribution pipe, aggregate, geotextile, filters, valves, valve boxes, dripper lines, flush points and sprinklers.

The assessed application area, reserve area, soil category, loading rates, groundwater, setbacks and nutrient balance are project evidence and constraints. They are not generated merely by scaling the model until a nominated area is reached.

## WaterMark, lead-free evidence and product geometry

The WaterMark schedule identifies plumbing product categories that require certification. From 1 May 2026, relevant copper-alloy plumbing products that convey drinking water must meet the Lead Free WaterMark requirements described by ABCB.

WaterMark, Lead Free WaterMark and WELS are evidence fields, not geometry. A generic valve can exist in the ontology, but a placed product instance should carry its certificate, scope, model, size and material evidence. A future library importer can replace generic geometry with manufacturer geometry without changing the stable canonical object ID.

## Modelling rules for future SketchUp tools

1. Ask for service role before pipe material.
2. Store source, temperature and permitted water use separately.
3. Create physical nodes at meters, valves, devices, tanks, heaters, traps, junctions, pumps and treatment stages.
4. Preserve flow direction, invert levels, grades and pressure zones.
5. Draw maintenance, removal, overflow, relief and spray envelopes as constraints, not building solids.
6. Keep product certification, hydraulic duty, treatment performance and approval as linked evidence.
7. Never create an unprotected cross-connection to make the route graph connect.
8. Never convert a sanitary pipe crossing into permission to cut structure, membranes, fire construction or termite barriers.
9. Treat tanks and treatment plants as full-load objects with base, access, groundwater and vehicle-service conditions.
10. Reuse existing fixture, roof-drainage, stormwater, waterproofing and structural objects instead of duplicating them in the hydraulic catalogues.

## Deliberate exclusions from this slice

This first house-scale hydraulic pass does not yet provide deep catalogues for gas services, fire-hydrant and sprinkler services, swimming-pool hydraulic equipment beyond the existing H7 slice, commercial trade waste, large authority sewer infrastructure, municipal water treatment, industrial process piping or broad landscape irrigation using non-effluent sources.

Those are legitimate future domains, but importing them now would mix different standards, licensing and risk contexts into a completed domestic plumbing and drainage slice.

## Principal public sources

The source registry contains exact URLs, access dates and copyright notes. The principal evidence groups for this slice are:

- `SRC-ABCB-V3-REFERENCED-DOCS` and the Volume Three B1-B7 and C1-C3 part pages;
- `SRC-ABCB-WATERMARK-SCHEDULE`, valve and backflow schedules, and `SRC-ABCB-LEAD-FREE-PLUMBING`;
- `SRC-SA-ASNZS3500-2025-SPOTLIGHT` and `SRC-BPC-VIC-ASNZS3500-2025` for publication and adoption context;
- `SRC-NSW-HEALTH-RAINWATER`, onsite-wastewater, AWTS and composting-toilet guidance;
- `SRC-NSW-OWM-GUIDELINES-2026` and `SRC-WA-HEALTH-SECONDARY-TREATMENT`;
- `SRC-VINIDEX-DWV-SYSTEMS` and `SRC-VINIDEX-WATER-SUPPLY-SYSTEMS` for public Australian product-family anatomy; and
- `SRC-RHEEM-WATER-HEATER-INSTALL` for generic storage-heater component relationships.

Public manufacturer information supports physical anatomy and common terminology only. Product dimensions, capacities, compatibility, warranties and installation rules remain selected-product evidence.
