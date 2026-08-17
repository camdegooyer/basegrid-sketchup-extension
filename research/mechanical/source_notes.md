# Residential mechanical services: source notes and drawing ontology

Research date: 16 August 2026  
Catalogue discipline: `mechanical`  
Primary catalogue: `data/catalog/mechanical_catalog.json`

## Purpose

This research slice identifies the fixed physical parts of residential heating, cooling, air distribution and balanced mechanical ventilation that a future SketchUp extension may need to draw.

The practical question is not only “what is an air conditioner?” It is:

- which complete system is being installed;
- which factory-made units belong to it;
- which internal or separately serviceable parts are useful to identify;
- which pipes, ducts, fittings, insulation, seals, supports and controls connect the units;
- which openings and access paths must be coordinated with the building; and
- which facts are design or compliance evidence rather than physical solids.

This slice adds 220 physical objects and assemblies. It covers common house-scale refrigerated air conditioning, ducted evaporative cooling, whole-house heat-recovery ventilation and hydronic heating. It also links to existing thermal-condensation, electrical and plumbing objects rather than redrawing the same thing under another discipline.

It is an ontology and drawing foundation. It is not an HVAC design, a load calculation, a commissioning result, a refrigerant-handling authorisation, a building approval or a substitute for the NCC, Australian Standards, manufacturer instructions or licensed practitioners.

## How the regulatory chain is recorded

The repository keeps four different kinds of authority separate:

1. **The selected NCC and Housing Provisions pathway.** This tells us which provisions and referenced-document editions apply to the project baseline.
2. **The Australian Standard edition named by that pathway.** A year in a standard designation matters.
3. **A later published standard.** It can be useful current technical guidance without silently replacing the edition adopted by the selected NCC or jurisdiction.
4. **Manufacturer and regulator information.** This establishes real product forms, licensed-work boundaries, connections, service access and installation-specific parts.

The catalogue retains the repository's NCC 2022 Housing Provisions extraction baseline. The project jurisdiction, approval date, adopted NCC edition, variations and transition arrangements must eventually be selected as project data.

Standards Australia publications are copyrighted. These notes identify public metadata and explain why documents matter. They do not reproduce proprietary clauses, tables, figures or installation rules.

## Housing Provisions that directly shape the object model

### Part 10.6: ventilation

[Housing Provisions Part 10.6](https://ncc.abcb.gov.au/editions/ncc-2022/adopted/housing-provisions/10-health-and-amenity/part-106-ventilation) establishes ventilation paths for rooms. A room can be ventilated naturally or mechanically under the applicable pathway.

For drawing tools, the important physical distinction is between:

- an openable window or other natural opening;
- a local exhaust system;
- a deliberate make-up or transfer-air opening;
- a whole-house balanced ventilation system; and
- a heating or cooling system that recirculates room air but does not by itself provide the required outdoor-air ventilation.

An air conditioner is therefore not automatically a ventilation system. A return-air grille is not automatically a make-up-air opening. An unplanned gap around a door is not automatically a designed transfer path.

Primary source record: `SRC-ABCB-HP-ROOM-VENTILATION`.

### Part 10.8: condensation management and exhaust

[Housing Provisions Part 10.8](https://ncc.abcb.gov.au/editions/ncc-2022/adopted/housing-provisions/10-health-and-amenity/part-108-condensation-management) affects domestic exhaust airflow, discharge to outdoor air and replacement-air paths. The existing thermal-condensation catalogue already models ceiling and wall exhaust fans, inline fans, ducted rangehoods, exhaust duct, backdraft dampers, outdoor exhaust terminals, run-on controls, door undercuts and transfer grilles.

The mechanical catalogue reuses those objects. It adds broader HVAC supply, return, intake and heat-recovery objects without creating a second competing bathroom-exhaust vocabulary.

Primary source records: `SRC-ABCB-HP-CONDENSATION-MANAGEMENT` and `SRC-ABCB-HP-ROOM-VENTILATION`.

### Part 13.7: services energy efficiency

[Housing Provisions Part 13.7](https://ncc.abcb.gov.au/editions/ncc-2022/adopted/housing-provisions/13-energy-efficiency/part-137-services) is the main direct Housing Provisions source for the mechanical distribution objects in this slice.

In plain English, its object consequences include:

- insulation around central-heating water pipes;
- protection of insulation exposed to weather, sunlight, moisture, wind or physical damage;
- insulation of heating and cooling ductwork and fittings according to system type, location and climate conditions;
- sealed duct joints and seams;
- particular attention to flexible-duct connections, where the inner core, sealing product and mechanical draw band are separate physical parts; and
- continuity of insulation and protective facing through fittings, connections and exposed routes.

The catalogue therefore does not treat “insulated duct” as one anonymous tube. It can identify the air-carrying core, thermal layer, jacket, sealing tape or mastic, gasket, draw band, protective jacket and support.

It also separates hydronic flow and return pipe from their insulation. R-value, declared material performance, climate zone and installed protection remain attributes and evidence. A tube drawn at a certain wall thickness cannot prove a required R-value.

Primary source record: `SRC-ABCB-HP-MECHANICAL-SERVICES`.

## Standards: direct call-ups and supporting references

### Directly relevant Housing Provisions editions

| Document | Why it matters to the ontology | Edition handling |
| --- | --- | --- |
| AS/NZS 4859.1:2018 | Public metadata for thermal-insulation materials used in building applications. It supports the identity and declared performance of pipe and duct insulation. | Record ID `AS-NZS-4859-1-2018`; use the edition called up by the selected NCC pathway. |
| AS 4254.1:2021 | Flexible ductwork for air handling. It informs the complete flexible-duct product and its connection, sealing, insulation and jacket parts. | Record ID `AS-4254-1-2021`. |
| AS 4254.2:2012 | Rigid ductwork for air handling. It informs sheet-metal and other rigid ducts, seams, joints, fittings and sealing. | Record ID `AS-4254-2-2012`. |
| AS 1668.2:2012 | Mechanical ventilation design and installation edition referenced by the NCC Housing Provisions path used here. | Record ID `AS-1668-2-2012`; do not silently replace it with 2024. |

### Later or supporting standards

| Document | What it contributes | Regulatory caution |
| --- | --- | --- |
| AS 1668.2:2024 | Newer published ventilation design and indoor-air-quality metadata. | It is a separate record, `AS-1668-2-2024`. Use only where the project's adopted pathway, specification or other authority makes it relevant. |
| AS/NZS 5141:2018 | Supporting residential heating and cooling guidance spanning design, selection, installation, commissioning and maintenance. | Helpful broad system evidence; it is not recorded as a Housing Provisions replacement clause. |
| AS/NZS 5149.1:2016 | Refrigerating-system definitions, classification and selection framework. | Supporting refrigerant-safety reference. |
| AS/NZS 5149.2:2016 | Refrigerating equipment and installation design/construction considerations. | Supporting evidence for equipment, piping, joints and installed systems. |
| AS/NZS 5149.3:2016 | Installation-site and personal-protection considerations. | Supports plant location, access and site metadata. |
| AS/NZS 5149.4:2016 | Operation, maintenance, repair and recovery considerations. | Supports serviceable parts and linked work evidence. |
| AS/NZS ISO 817:2016 | Refrigerant designation and safety classification. | Refrigerant identity and class are attributes, not separate building solids. |
| AS/NZS 60335.2.40:2025 | Current public product-safety metadata for electrical heat pumps, air conditioners and dehumidifiers. | Product standard metadata does not prove that a generic model instance is certified. |
| AS/NZS 3823.1.1:2012 and AS/NZS 3823.1.2:2012 | Air-conditioner performance-test references used by Australia's GEMS and energy-rating framework for relevant product classes. | Rated performance belongs to a selected product and test basis, not to generic geometry. |

Useful official public explanations include Standards Australia's [AS 1668:2024 overview](https://www.standards.org.au/blog/spotlight-on-as-1668-2024), its [residential HVAC standard announcement](https://www.standards.org.au/news/easier-to-be-energy-efficient), and its [refrigeration-safety adoption announcement](https://www.standards.org.au/news/australia-adopts-international-standards-for-refrigeration-safety).

## The physical system families

### Refrigerated split and ducted air conditioning

The top-level refrigerated system is divided by topology:

- **Single split:** one outdoor unit, one indoor unit and one paired refrigerant route.
- **Multi-split:** one outdoor unit, two or more indoor units and a manufacturer-defined branch arrangement.
- **Ducted reverse cycle:** an outdoor unit, a concealed indoor fan-coil unit, supply and return plenums, branching ducts and room terminals.

Common indoor-unit forms are high-wall, floor console, ceiling cassette, under-ceiling, bulkhead and ducted fan coil. These are not merely cosmetic variants: their support, return-air path, discharge opening, drain route and service access differ.

The outdoor unit is a complete assembly. Its separately identifiable parts include casing, compressor, outdoor heat-exchanger coil, fan, fan motor, service valves, electrical/control compartment, feet and access panels. “Condenser” is accepted as trade search language, but in reverse-cycle heating the outdoor coil acts as an evaporator. The object model therefore prefers **outdoor unit** for the package and **outdoor heat-exchanger coil** for the coil.

The indoor unit similarly contains an indoor heat-exchanger coil, fan, filter, drain pan, louvres or vanes, casing and controls. “Evaporator” is mode-dependent and must not replace the complete unit.

The refrigerant connection is broken into:

- refrigerant gas pipe;
- refrigerant liquid pipe;
- insulation around the selected pipe or pipes;
- flare, brazed and branch joints;
- service valves and caps;
- support clips;
- sleeves, seals and escutcheons at penetrations;
- protective surface capping and its bends, entries and end pieces; and
- associated condensate and electrical connections.

Gas pipe in this context means refrigerant vapour-side pipe. It is not a fuel-gas service.

The condensate assembly includes drain pan, pipe, fittings, trap where required, condensate pump where gravity fall is unavailable, high-level switch, pipe insulation where surface condensation is possible and a documented terminal. The tool must ask for the discharge destination. It must not assume ground, stormwater or sanitary drainage.

Regulated-air-conditioner information is available from the Australian Government [Energy Rating air-conditioner page](https://www.energyrating.gov.au/industry-information/products/air-conditioners-65kw). Residential system forms are also supported by `SRC-MITSUBISHI-AU-RESIDENTIAL-AC` and `SRC-TEMPERZONE-AIRCORE-DUCTED`.

### Ductwork and air terminals

Every duct segment needs an air-path role:

- supply air;
- return air;
- outdoor air;
- indoor extract air; or
- outdoor exhaust air.

The same circular duct geometry is not safely interchangeable between clean supply air and contaminated exhaust air.

The catalogue covers insulated flexible duct, rigid circular duct, rectangular sheet-metal duct and pre-insulated rigid duct panel. It includes seams, transverse joints, insulation, internal liner, vapour barrier, exposed protective jacket, sealant, tape, gasket, collar, coupling, elbow, tee, wye, reducer, shape transition, branch take-off and splitter.

It also includes:

- supply and return plenums;
- cushion-head and terminal boxes;
- manual volume-control and motorised zone dampers;
- damper actuators;
- flexible equipment connectors;
- access doors;
- silencers and test ports;
- support straps, trapezes, threaded rods, ring hangers and wall brackets; and
- grilles, registers, diffusers, linear slots, multi-directional outlets, floor registers, return grilles and filter grilles.

“Vent” is useful everyday language but not enough to choose geometry. A grille, register and diffuser have different physical forms. A transfer-air grille through a door or wall is also different from a return-air grille connected to a mechanical return path.

### Ducted evaporative cooling

A packaged ducted evaporative cooler is an outdoor-air supply system, not a refrigerated recirculating air conditioner.

Its drawable equipment parts include:

- weather-exposed cabinet and removable panels;
- cooling-media panels and retaining frames;
- water reservoir or sump;
- circulation pump;
- water-distribution header;
- float valve and inlet connection;
- drain or bleed valve and pipe;
- blower and motor;
- roof dropper and transition;
- roof support and roof flashing; and
- wall controller.

The cooler sends introduced outdoor air into the house. A design also needs an air-relief path. The tool must not automatically generate a refrigerated-system return-air grille and return duct.

The existing thermal-condensation object `AU-TC-EVAPORATIVE-COOLER-DAMPER` remains the self-closing air-sealing component at the cooler/duct route. Product and installation forms are supported by `SRC-SEELEY-BRAEMAR-EVAP-INSTALL` and `SRC-SEELEY-BRAEMAR-EVAP-COMPONENTS`.

### Whole-house heat-recovery ventilation

A balanced heat-recovery ventilation system has four air paths:

1. outdoor air into the unit;
2. filtered supply air from the unit to rooms;
3. indoor extract air from rooms to the unit; and
4. exhaust air from the unit to outdoors.

The unit ports must store those roles explicitly. Manufacturers use different labels and layouts, so a tool must not infer role from left, right, top or bottom position.

The packaged unit is broken into casing and internal partitions, heat-recovery core, supply fan, extract fan, outdoor-air filter, extract-air filter, bypass damper, condensate pan where present, four duct ports, controller and hanging brackets. Generic duct collars, access panels, supports, ducts, silencers and outdoor terminals are reused.

HRV and ERV are not automatic synonyms. An HRV transfers sensible heat. An ERV or enthalpy-recovery product may also transfer moisture, but that must come from selected core and product evidence.

Product forms are supported by `SRC-MITSUBISHI-AU-LOSSNAY` and `SRC-MITSUBISHI-AU-LOSSNAY-SPEC`.

### Hydronic heating

Hydronic heating is a closed or controlled heating-water circuit. It is separate from potable domestic heated water.

The system is divided into:

- heat-source assembly;
- distribution pipework assembly;
- safety, pressure, fill, drain, air and dirt components;
- underfloor or radiator emitters; and
- controls.

An air-to-water heat pump is included as one common heat source. Its topology matters: a monobloc unit carries heating water outdoors, while a split product may have refrigerant lines between indoor and outdoor modules. A fuel-gas boiler is intentionally deferred to a gas-services slice because it also needs gas train, combustion-air and flue objects.

Plant components include buffer tank, circulation pump, flow and return headers, hydraulic separator or low-loss header, expansion vessel, automatic and manual air vents, relief valve, pressure gauge, fill connection, drain valve, dirt separator, magnetic filter, Y-strainer, check valve, isolation valve, balancing valve, mixing valve and differential bypass valve.

These objects can look similar while performing different jobs:

- a buffer tank adds water volume or stabilises operation;
- an expansion vessel accepts thermal expansion against a gas cushion;
- a hydraulic separator decouples primary and secondary flow;
- a header distributes or collects branches; and
- a domestic storage water heater contains potable water for fixtures.

Flow and return pipe are separate object roles even where the same product and size are used. Pipe colour or screen position must never be the only source of role.

The underfloor emitter is a continuous pipe loop from one manifold flow port back to its paired return port. The catalogue identifies the paired manifold bars, cabinet, flowmeters, circuit valves, thermal actuators, loop connectors, fixing staples, fixing rails, heat-spreader plates, perimeter edge strip and protective conduit at loop tails.

A room or control zone is not a physical pipe. One zone may contain several loops operated together.

The radiator assembly includes steel panel and column forms, wall brackets or floor feet, thermostatic radiator valve body and head, lockshield valve, union tail and manual bleed vent. Hydronic towel rails are separate emitters. A thermostatic radiator valve modulates one radiator locally; a room thermostat sends an electrical or radio demand to a wider control system.

Hydronic forms are supported by `SRC-REHAU-AU-HYDRONIC`, `SRC-REHAU-UNDERFLOOR-GUIDE`, `SRC-BOSCH-AU-HYDRONIC-INSTALL` and `SRC-BOSCH-AU-HYDRONIC-FAQ`.

## Cross-discipline interfaces

Mechanical tools should create or link interfaces, not claim ownership of every connected service.

### Electrical

Outdoor units, heat pumps, fans, pumps, controls, actuators and heaters require electrical supply, isolation, protection and wiring. The mechanical catalogue links to the existing electrical HVAC isolator where appropriate. Circuit design, cable, protection and electrical compliance remain electrical objects and evidence.

### Plumbing and drainage

Evaporative coolers need a water connection and lawful drain arrangement. Hydronic systems need an approved fill interface. Condensate needs a selected discharge path. The mechanical catalogue models the equipment-side fitting and route but links to plumbing objects for upstream water, backflow protection or connected drainage.

### Structure and envelope

Equipment, filled tanks and radiators create real loads. Ducts and water-filled pipes need supports. Roof-mounted coolers require support and flashing. Every sleeve or penetration also needs the selected weather, air, acoustic or fire-sealing system.

Touching geometry does not prove structural capacity or weatherproofing. The tool must store host, anchor, load and evidence rather than treating intersection as approval.

### Fire and smoke safety

Volume-control dampers, motorised zone dampers and backdraft dampers are airflow devices. Fire, smoke and combination fire-smoke dampers are life-safety systems with different test, access, installation and evidence requirements. They must remain in a dedicated fire-safety research and product path. A generic duct blade must never be upgraded to a fire damper by renaming it.

## Refrigerant licensing and evidence

The Australian Government explains that people who handle controlled refrigerants and businesses that acquire, store or dispose of them can require the relevant refrigerant handling licence or refrigerant trading authorisation. See the [DCCEEW refrigerant and air-conditioning technician guidance](https://www.dcceew.gov.au/environment/protection/ozone/rac/technicians).

The Australian Refrigeration Council's 2024 code source is recorded as `SRC-ARC-REFRIGERANT-CODE-2024`.

The ontology can store physical tubes, insulation, joints, valves and equipment. It can link:

- practitioner and business authorisations;
- selected refrigerant and charge;
- evacuation, pressure-test and leak-test records;
- commissioning results;
- recovery or disposal records; and
- maintenance history.

Those records are not solids. A clean-looking flare joint in SketchUp does not prove correct preparation, torque, evacuation or leak testing.

## SketchUp generation rules implied by this research

### Start with a system topology

The tool should first ask which system is intended. It should not begin by scattering generic boxes and ducts.

Examples:

- single split: one outdoor unit, one indoor unit and one paired service route;
- ducted reverse cycle: outdoor unit, fan coil, return path, supply plenum, branches and terminals;
- evaporative: roof cooler, supply-only distribution and deliberate relief strategy;
- HRV: one unit with four labelled air paths; and
- hydronic underfloor: heat source, paired flow/return distribution, manifold and continuous paired loops.

### Separate product geometry from installation geometry

Factory equipment should normally be a component definition with product dimensions and connection ports. Site-generated ducts, pipes, insulation, capping, supports and seals should follow routes and hosts.

If an internal part affects service access, quantity, connection or maintenance, it can remain an identifiable nested object even when the normal drawing uses a simplified equipment shell.

### Make every port semantic

A connection point needs more than coordinates. Useful fields include:

- service or air-path role;
- shape and size;
- male, female, flange, socket, thread, flare or press form;
- flow direction or bidirectional status;
- permitted connected object types;
- insertion, overlap or engagement depth;
- support and movement requirements; and
- access needed for assembly or service.

### Treat required empty space as an overlay

Airflow, service clearance, filter-removal path, valve-handle sweep, access-panel swing and refrigerant safety volume can be valuable translucent overlays. They are not materials, are excluded from take-off and do not prove compliance unless linked to a selected product and verified rule set.

### Preserve layers and joints

Duct and pipe tools should be able to show:

- carrier geometry;
- insulation;
- protective jacket or capping;
- joints and fittings;
- supports;
- sleeves and seals; and
- connection to equipment or terminal.

This is necessary for coordination and material quantities. A centreline alone is not enough, while a single fused solid loses the identity needed for inspection and repair.

### Keep calculations outside generic shape defaults

The following must not be invented from the ontology name:

- heat load, cooling load or equipment capacity;
- duct diameter, pressure drop or airflow balance;
- pipe size, pump head or expansion-vessel size;
- insulation R-value;
- noise outcome;
- refrigerant charge or room safety assessment;
- support capacity or anchor selection;
- condensate or cooler-water discharge legality; or
- commissioned valve, flowmeter, thermostat or damper settings.

The catalogue tells a calculation engine which physical objects and attributes exist. It does not replace that engine or its authorised data.

## Deliberately deferred scope

The following are real building objects but need separate sourced slices or broader NCC paths:

- gas boilers, gas trains, combustion air, flues and terminals;
- solid-fuel appliances beyond the existing ancillary scope;
- large commercial air-handling units and packaged rooftop plants;
- chilled-water cooling plants, cooling towers and commercial hydronic cooling;
- variable refrigerant flow systems beyond the house-scale multi-split concepts recorded here;
- commercial kitchen and hazardous exhaust systems;
- smoke-control systems and fire/smoke dampers;
- active humidification and central dehumidification plants;
- geothermal ground loops and bore fields;
- pool heating except for existing ancillary equipment boundaries;
- detailed building-management-system networks; and
- proprietary product libraries with exact manufacturer geometry.

Deferral means “research separately before generating,” not “the object does not exist.”

## Principal public sources

| Source ID | Public source | Use in this slice |
| --- | --- | --- |
| `SRC-ABCB-HP-MECHANICAL-SERVICES` | [ABCB Housing Provisions Part 13.7](https://ncc.abcb.gov.au/editions/ncc-2022/adopted/housing-provisions/13-energy-efficiency/part-137-services) | Pipe and duct insulation, protection and duct sealing baseline. |
| `SRC-ABCB-HP-ROOM-VENTILATION` | [ABCB Housing Provisions Part 10.6](https://ncc.abcb.gov.au/editions/ncc-2022/adopted/housing-provisions/10-health-and-amenity/part-106-ventilation) | Natural and mechanical room-ventilation paths. |
| `SRC-ABCB-HP-CONDENSATION-MANAGEMENT` | [ABCB Housing Provisions Part 10.8](https://ncc.abcb.gov.au/editions/ncc-2022/adopted/housing-provisions/10-health-and-amenity/part-108-condensation-management) | Domestic exhaust and make-up-air context. |
| `SRC-SA-AS4254-1-2021` | Standards Australia public metadata | Flexible duct product and connection reference. |
| `SRC-SA-AS4254-2-2012` | Standards Australia public metadata | Rigid duct product and construction reference. |
| `SRC-SA-AS1668-2-2024` | [Standards Australia overview](https://www.standards.org.au/blog/spotlight-on-as-1668-2024) | Later-edition awareness without silent NCC substitution. |
| `SRC-SA-ASNZS5141-2018` | [Standards Australia announcement](https://www.standards.org.au/news/easier-to-be-energy-efficient) | Broad residential HVAC design-through-maintenance evidence. |
| `SRC-SA-REFRIGERATION-SAFETY-2016` | [Standards Australia announcement](https://www.standards.org.au/news/australia-adopts-international-standards-for-refrigeration-safety) | AS/NZS 5149 and ISO 817 public context. |
| `SRC-ENERGY-RATING-AIR-CONDITIONERS-65KW` | [Energy Rating](https://www.energyrating.gov.au/industry-information/products/air-conditioners-65kw) | Regulated product types, GEMS and performance-test context. |
| `SRC-DCCEEW-RAC-TECHNICIANS` | [DCCEEW](https://www.dcceew.gov.au/environment/protection/ozone/rac/technicians) | Refrigerant-handling and trading-authorisation boundary. |
| `SRC-ENERGY-GOV-AU-HEATING-COOLING` | [energy.gov.au](https://www.energy.gov.au/households/heating-and-cooling) | Public explanation of common household heating and cooling systems. |
| `SRC-MITSUBISHI-AU-RESIDENTIAL-AC` | Mitsubishi Electric Australia | Split, multi-split and indoor/outdoor product forms. |
| `SRC-MITSUBISHI-AU-LOSSNAY` and `SRC-MITSUBISHI-AU-LOSSNAY-SPEC` | Mitsubishi Electric Australia | Balanced heat-recovery unit, port, filter, fan, core and control forms. |
| `SRC-POLYAIRE-HVAC-COMPONENTS` | Polyaire | Australian duct, fitting, diffuser, grille and accessory terminology. |
| `SRC-TEMPERZONE-AIRCORE-DUCTED` | Temperzone | Australian ducted unit and air-side product forms. |
| `SRC-SEELEY-BRAEMAR-EVAP-INSTALL` and `SRC-SEELEY-BRAEMAR-EVAP-COMPONENTS` | Seeley International / Braemar | Packaged evaporative cooler, roof, water, fan and control components. |
| `SRC-REHAU-AU-HYDRONIC` and `SRC-REHAU-UNDERFLOOR-GUIDE` | REHAU Australia | Hydronic distribution, manifold, loop, fixing and floor-system components. |
| `SRC-BOSCH-AU-HYDRONIC-INSTALL` and `SRC-BOSCH-AU-HYDRONIC-FAQ` | Bosch Australia | Hydronic plant, controls, radiator and installation forms. |

## Result

The mechanical slice now supports future tools that can reason from complete systems down to individual drawable parts:

- equipment and its nested serviceable components;
- paired refrigerant tubes, insulation, joints and capping;
- condensate drainage;
- rigid and flexible duct layers, fittings, terminals, supports and controls;
- evaporative-cooler air and water components;
- balanced heat-recovery ventilation components and four explicit air paths; and
- hydronic heat source, plant, distribution, underfloor, radiator and control components.

The remaining design values, code decisions and evidence are deliberately visible as unresolved inputs. That is the safest foundation for a SketchUp plugin intended to draw real Australian building objects without pretending that geometry alone is a compliant design.
