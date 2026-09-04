# Electrical, communications and consumer-energy object research

## Scope and result

This slice identifies the house-scale physical objects needed to draw permanent electrical services, communications, lighting, solar generation, stationary batteries, electric-vehicle charging, fixed security equipment and temporary construction power in Australia.

It adds or confirms:

- 306 `electrical` objects;
- 13 electrical and communications standards records;
- 45 public sources used directly by electrical objects; and
- 28 electrical terminology decisions, numbered `TERM-263` to `TERM-290`.

The catalogue is deliberately broader than the electrical clauses in the NCC Housing Provisions. Most electrical safety rules for a house are not written in the Housing Provisions. They come through state or territory electrical-safety law, the locally adopted Wiring Rules, network service rules, communications cabling rules, product regulation and selected equipment instructions.

This is an object vocabulary and drawing guide. It does not certify an installation, calculate maximum demand, size a cable, set a circuit-breaker rating, prove discrimination, design an earthing system, approve a network connection, select a solar string, assess a battery location, prove wireless coverage or test electrical work. Those results require the applicable jurisdiction, licensed standards, network documents, selected products, project conditions and licensed or otherwise authorised practitioners.

The public research was checked on 16 August 2026. Exact legal adoption must still be checked for each project date and jurisdiction.

## Where the NCC stops and electrical law starts

For a normal Class 1 house, the NCC Housing Provisions have a narrow direct electrical path compared with framing, fire separation, waterproofing or plumbing.

Housing Provisions Part 13.7 covers services in the energy-efficiency section. Clause 13.7.6 addresses artificial lighting power and controls. It is mainly a calculation and control requirement. It is not a catalogue of wiring methods, switchboards or socket-outlets. New South Wales deletes this clause through its Housing Provisions variation, so even this narrow NCC path is jurisdiction-sensitive.

The Housing Provisions do not provide a complete domestic electrical installation code. They do not replace:

- state or territory electrical-safety legislation and regulations;
- the adopted edition and amendments of AS/NZS 3000, the Wiring Rules;
- electricity distributor service and installation rules;
- metering requirements;
- communications cabling regulation;
- solar, inverter and battery standards;
- electrical equipment product regulation; or
- the installation instructions and evidence for a selected product.

For a future SketchUp tool, this means the NCC selector and the electrical-law selector are related but separate. At minimum, every generated electrical rule result needs:

- state or territory;
- project and approval or work date;
- electricity distributor where network rules are relevant;
- NCC edition and amendment where an NCC clause is used;
- electrical standard edition and amendment state;
- service or network document edition;
- selected product and instructions where product geometry controls; and
- evidence or verification record supporting the result.

“NCC compliant electrical object” is not a useful or defensible object class.

## Edition control and current standards path

### AS/NZS 3000:2018

The base installation standard recorded here is AS/NZS 3000:2018. Public Standards Australia metadata lists Amendments 1:2020, 2:2021 and 3:2023, and public regulator material also identifies Ruling 1:2024. A project must use the edition and amendment state adopted by its electrical regulator; publication metadata alone does not establish the legal start date.

AS/NZS 3000 is attached as the default electrical standard because it supplies the general installation framework. That does not mean every low-voltage data connector or passive antenna part is governed only by it. Communications objects additionally use the AS/CA S008 and S009 path. Solar, battery and inverter objects add their specialist standards.

### AS/NZS 3008.1.1:2025

AS/NZS 3008.1.1:2025 is recorded for cable-selection inputs. Western Australia publicly announced a transition requiring the new edition from 19 June 2026. Other jurisdictions can use different transition dates. A tool must not silently replace an earlier legally adopted cable-selection edition merely because the 2025 edition is newer.

Cable size is not derived from its drawn diameter. It depends on conductor material, insulation, installation method, grouping, ambient conditions, load, protective device, voltage drop, fault duty and other design inputs.

### Product and assembly standards

The registry includes:

- AS/NZS 3112:2025 for plugs and socket-outlets, with product transition issues to be checked;
- AS/NZS 61439.3:2016 for distribution boards intended to be operated by ordinary persons;
- AS/NZS 61009.1:2015 for RCBO product construction;
- AS/NZS 60598.2.2:2026 for recessed luminaires;
- AS/NZS 3012:2019 for construction and demolition site installations; and
- AS/NZS 3017:2022 for verification guidance and methods.

These standards add product or installation requirements. They do not turn a generic SketchUp component into a certified product.

### Solar, inverter and battery standards

The specialist records are:

- AS/NZS 5033:2021 for photovoltaic arrays;
- AS/NZS 4777.1:2024 for grid connection of energy systems through inverters; and
- AS/NZS 5139:2019, including Amendment 1:2025 in the registry notes, for battery systems used with power-conversion equipment.

Jurisdictional adoption still matters. New South Wales and Western Australia have each published specific battery-standard or transition information. The catalogue stores those sources rather than pretending one national publication date answers every legal question.

### Communications standards

The Australian Communications and Media Authority identifies:

- AS/CA S009:2020 for installing customer cabling; and
- AS/CA S008:2020 for customer-cabling products.

These sit under telecommunications cabling regulation, not the NCC Housing Provisions. The physical separation, pathways, cable products, terminations and registered-cabler work must therefore retain their communications compliance path even when drawn inside the same walls as electrical wiring.

## The electrical distribution tree

The catalogue starts with one domestic electrical installation, then separates the supply and circuit roles.

### Network supply and service connection

The supply connection can be overhead or underground. Depending on network rules it can include:

- overhead service conductors;
- point-of-attachment bracket and insulators;
- underground service cable;
- underground service conduit;
- service pit;
- service protection or service fuse; and
- the transition to consumer mains, metering and the main switchboard.

The network boundary and ownership are stored as instance data. A service line and consumer mains are not interchangeable merely because they are drawn as one continuous-looking route.

### Consumer mains, submains and final subcircuits

These three roles form different levels of the electrical tree:

1. consumer mains connect the supply or metering boundary to the main switchboard arrangement;
2. a submain connects one switchboard to another distribution board; and
3. a final subcircuit runs from a protective device to lighting points, socket-outlets or fixed equipment.

The cable product may look similar at each level. The circuit role controls its endpoints, protection, switching, identification and design evidence.

The catalogue includes lighting, socket-outlet and dedicated-appliance final-subcircuit assemblies. These are electrical graph objects with physical cable, conductors, connectors, routes and terminations. A final subcircuit is not a single straight cable solid.

## Metering and switchboards

Metering and main switching commonly share a cabinet, but the model retains separate physical parts:

- meter enclosure;
- meter panel;
- electricity meter;
- smart meter variant;
- main switchboard;
- switchboard enclosure, door and escutcheon;
- DIN rail;
- main switch;
- miniature circuit breaker;
- RCCB;
- RCBO;
- fuse and fuse carrier;
- surge protective device;
- busbars and links;
- neutral link;
- earth bar;
- MEN link;
- circuit schedule and labels; and
- downstream sub-board.

This separation allows one combined meter box to be drawn without treating the revenue meter, customer switchgear and enclosure as one indivisible object.

### RCD language

“Safety switch” is common Australian language but is not precise enough for object generation.

- RCD describes the residual-current protective function.
- RCCB is a residual-current circuit-breaker without integral overcurrent protection.
- RCBO combines residual-current and overcurrent protection.
- MCB provides overcurrent protection but is not an RCD.

The tool should store functions and product type separately. A device that has the same one-module outline as another device is not electrically equivalent.

## Earthing, bonding and MEN

The earthing and MEN family includes:

- main earthing conductor;
- earth electrode;
- electrode clamp;
- inspection pit;
- protective earthing conductors;
- earth bar;
- neutral link;
- MEN link;
- equipotential bonding conductors;
- pool and spa bonding where applicable; and
- bonding of other services or exposed conductive parts where the design requires it.

The MEN link is not the earth bar. The earth bar is not the neutral link. Their proximity inside a switchboard does not make them one connector.

Earthing effectiveness cannot be proved by drawing an electrode at a conventional length. Soil, electrode type, connections, installation design and verification are evidence inputs.

## Cable anatomy and wiring systems

The fixed wiring catalogue includes:

- active, neutral, protective-earth and switched-active conductors;
- thermoplastic-sheathed cable;
- multicore cable;
- armoured cable;
- underground cable;
- aerial cable;
- flexible cord;
- outer sheath; and
- conductor insulation.

Cable is separate from the route that contains or supports it. Containment and protection families include:

- rigid PVC, corrugated and metal conduit;
- bends, couplings, adaptors, saddles and termination bushes;
- draw wire;
- cable trunking with covers and dividers;
- cable tray and catenary supports;
- clips, cleats and cable ties;
- concealed nail or screw protection plates;
- penetration sleeves;
- junction and adaptable boxes;
- terminal blocks, connectors, lugs and ferrules;
- cable glands and entry bushes; and
- cable markers.

Conduit fill, bend capacity, current-carrying capacity, voltage drop and fire or acoustic penetration performance are not inferred from the linework. They are separate rule and evidence results.

A sleeve through a fire-resisting element is commonly used with a firestop assembly, but the sleeve alone is not the firestop.

## Socket-outlets, switches and fixed equipment

### Socket-outlets

The catalogue separates:

- the complete installed socket-outlet point;
- single, double, weatherproof, dedicated, high-current, floor and USB outlet variants;
- the visible faceplate;
- socket mechanism;
- safety shutter where present;
- mounting box;
- mounting block;
- plaster bracket; and
- blank plate.

“Power point” and “GPO” commonly mean the complete visible point, but they can also be used for only the socket or plate. Tool commands should place the installation assembly and allow its internal parts to be edited.

### Switching

Lighting controls include one-way, two-way and intermediate switches, dimmers, push buttons, timers, occupancy sensors, daylight sensors, smart relays and weatherproof switches.

Two-way describes a switching topology. It does not mean two-gang. One plate can contain multiple mechanisms, and a single mechanism can participate in a multi-location circuit.

An ordinary control switch is not automatically an isolator. Appliance isolators, weatherproof rotary isolators, air-conditioning isolators, water-heater isolators and cooker controls retain their actual function and connected equipment.

### Fixed appliance connections

Fixed connection objects include connection units, ceiling outlet or plug-base arrangements and selected appliance connectors. The water-heater isolator can link to the hydraulic water-heater assembly, but the electrical connection is not the heater itself.

Portable appliances are not decomposed unless the user explicitly chooses a furniture, equipment or product scope. The building ontology records the fixed connection and spatial allowance.

## Lighting

The lighting model uses three levels:

1. the lighting point is the fixed wiring, support and connection location;
2. the luminaire is the complete light fitting; and
3. a lamp or LED module is the light source inside it.

Luminaire families include recessed LED downlights, surface ceiling lights, pendants, wall lights, linear battens, weatherproof battens, floodlights, step or path lights, track lights and fixed LED strip systems.

Internal components include:

- replaceable lamps and LED lamps;
- lampholders;
- integrated LED modules;
- LED drivers;
- lighting transformers;
- diffusers and reflectors;
- downlight trims;
- mounting brackets;
- ceiling roses;
- pendant flex; and
- optional downlight guards.

AS/NZS 60598.2.2:2026 is recorded as the current recessed-luminaire publication found during this research. Selected-product insulation classification, cut-out, heat management and required separation still control the model.

A downlight guard is physical and drawable when selected. An IC rating or clearance requirement is not a solid object. A tool can display a clearance overlay, but it must not count that overlay as material or assume a guard is required.

### NCC artificial-lighting calculation

The Housing Provisions artificial-lighting rule concerns power density and controls. A future checker should use spaces, installed lamp or luminaire power and jurisdictional rules. It should not make a special “compliant light” component.

## Communications and nbn

The communications catalogue covers three linked but distinct layers.

### Lead-in and carrier equipment

The lead-in system can include:

- communications pit;
- lead-in conduit and draw path;
- lead-in fibre, copper or coaxial cable;
- nbn premises connection device, also called the utility box or PCD;
- internal pathway conduit;
- nbn network termination device, also called the connection box or NTD; and
- compatible nbn power supply.

The current nbn guide makes clear that equipment varies by access technology. The catalogue therefore does not force a PCD, NTD shape or location into every property.

The PCD, NTD and customer router are different. The PCD is the external network transition where used. The NTD terminates the access network and presents service interfaces. The customer router or gateway connects the local network to that service.

nbn states that it stopped providing new battery-backup units in June 2024. Existing legacy units and customer- or provider-arranged backup remain real objects, but a backup unit is optional rather than a default part.

### Customer cabling

The customer-owned distribution system includes:

- communications cabinet;
- RJ45 patch panel;
- network switch;
- router or residential gateway;
- wireless access point;
- balanced twisted-pair data cable;
- optical-fibre cable;
- coaxial communications cable;
- retained telephone cable;
- patch cords;
- data, telephone, television and fibre outlets;
- RJ45 mechanisms and faceplates;
- optical termination tray; and
- splitters and connectors.

Cable category, tested performance, screening, PoE loading and optical loss are evidence. A generic cable diameter or RJ45-looking socket cannot prove category performance.

Wi-Fi coverage is an analysis overlay. Metal cabinets, walls, furniture, interference and product settings affect it, so access-point geometry alone does not prove coverage.

### Television and satellite reception

Terrestrial television reception includes antenna, mast, structural mounting bracket, coaxial cable, optional masthead amplifier, power injector, splitters, connectors and outlets.

The antenna direction, gain and need for amplification come from reception conditions and measured losses. An amplifier is not added by default.

Satellite reception includes dish reflector, LNB, mount, coaxial cable, optional multiswitch and outlets. The dish line of sight and antenna or dish wind action are analysis and structural design inputs.

## Solar photovoltaic systems

The PV model separates generation, support, DC wiring and conversion.

### Modules, strings and arrays

A photovoltaic module is a factory assembly containing:

- front glass;
- encapsulated photovoltaic cell laminate;
- rear layer;
- aluminium frame where present;
- rear junction box;
- bypass components; and
- output leads and connectors.

A module is not an array. A string is a series-connected electrical group of modules and can cross geometric rows. The array is the broader connected group at the generation area.

The tool should therefore keep three independent but linked structures:

- module placement geometry;
- racking rows and supports; and
- electrical string membership.

### Roof mounting

The roof-mounting system includes:

- aluminium rail;
- rail splice;
- roof interface or adaptor;
- tile-roof hook;
- hanger bolt;
- module mid clamp;
- module end clamp;
- optional tilt leg;
- bonding clip;
- grounding lug; and
- cable clips.

Rail spans, support spacing, edge-zone rules, fastener capacities, roof-cladding interfaces, corrosion class and wind design remain selected-system engineering evidence. A generic rail family cannot generate a compliant support spacing on its own.

The roof cladding is not assumed to be the load-bearing support. The physical path must reach the structural element or use an evidence-backed non-penetrative interface designed for that cladding.

### DC wiring and isolation

PV wiring includes purpose-selected solar cable, matched connector pairs, optional combiner box, selected DC protection and the documented means of isolation or disconnection.

AS/NZS 5033:2021 changed the former blanket rooftop-DC-isolator approach. The model uses a general PV DC isolation or disconnection object and instantiates it only at the locations in the selected design.

Connectors that look mechanically similar are not assumed compatible. Manufacturer, type and compatibility evidence are stored with the mated pair.

### Inverters and monitoring

The inverter installation can use:

- a string inverter;
- microinverters beneath modules;
- DC power optimisers with a compatible inverter;
- a hybrid solar and battery inverter;
- inverter mounting bracket;
- selected AC isolator;
- main switch for inverter supply;
- energy monitoring meter; and
- monitoring gateway.

These devices are not aliases. They create different equipment quantities, cable routes, roof-space components and isolation arrangements.

Network settings, export limits and commissioning are evidence and configuration, not visible solids.

## Battery energy storage systems

The complete BESS can contain:

- one or more stationary battery units;
- internal battery modules or a modular battery cabinet where that product uses them;
- battery management system;
- battery inverter, hybrid inverter or inverter-charger;
- high-current battery DC cable;
- DC protection and isolation assembly;
- energy control gateway;
- optional backup transfer equipment;
- mounting bracket, base or plinth;
- optional emergency stop;
- optional vehicle-impact bollards; and
- labels and emergency information.

“Battery” is not enough to select an object. The complete BESS, sealed battery product and internal module are different levels.

Backup is optional. A grid-connected battery does not automatically power a house during an outage. Backup needs compatible conversion, islanding and transfer equipment plus a defined whole-house or selected-load arrangement.

### Battery location and clearances

AS/NZS 5139 location, separation and installation inputs are stored as evidence and analysis. The actual rule must be read from the licensed standard and current jurisdictional adoption.

The plugin should not turn a prohibited-location zone or clearance into a billable material solid. It can display a non-physical overlay. If the selected solution includes a physical bollard, cabinet, barrier, wall or plinth, that object is drawn separately with its own evidence.

Battery units can be very heavy. Mounting must reach a verified wall, slab, frame or foundation. Product clearance and impact protection do not replace structural fixing design.

## Electric-vehicle charging

The Australian Government describes two common home paths:

- charging from a suitable standard socket-outlet; or
- installing dedicated AC EV supply equipment, commonly 7 to 22 kW, by a licensed electrician.

The dedicated path can require a switchboard or supply upgrade.

The catalogue uses “EVSE” for the fixed supply equipment. The vehicle usually contains the onboard AC charger. Everyday language calls the wallbox a charger, so the alias is retained, but the object definition stays precise.

Physical EV charging parts include:

- wall-mounted EVSE;
- pedestal-mounted EVSE;
- mounting post;
- tethered charging cable;
- vehicle connector;
- socket on untethered EVSE;
- cable holster;
- load-management controller;
- selected local isolator; and
- circuit and equipment labels.

Parking position, connector reach, cable sweep, trip exposure, impact risk, phases, supply capacity and dynamic-load management are design inputs. A charger symbol placed on a wall does not prove that a vehicle can park and connect safely.

The March 2026 Australian Government consumer-energy-resource work covers future interoperability for new solar inverters, batteries and EV chargers. It is recorded as emerging policy and device functionality, not a retroactive requirement for existing equipment.

## Fixed security, CCTV, intercom and doorbell systems

These systems are common fixed building services even though they are not a general NCC Housing Provisions mandate.

The intruder-alarm family includes control panel, keypad, PIR detector, door or window contact, glass-break detector, siren, strobe, backup battery and cellular or IP communicator.

The CCTV family includes fixed IP cameras, mounting brackets, camera junction boxes and network video recorder. Existing data cable, network switch and cabinet objects are reused rather than duplicated.

The video-intercom family includes outdoor door station, indoor station, power or PoE supply and selected electric strike. Fire-door, egress and accessibility questions remain attached to the actual door assembly; adding a wire does not make a strike suitable.

The simpler doorbell family includes push button, internal chime, transformer or power supply and fixed video doorbell variant.

Camera fields of view, PIR coverage, privacy masks and wireless signal areas are analysis overlays. They are not materials and cannot prove coverage without commissioning and site conditions.

## Temporary construction electrical work

AS/NZS 3012:2019 supplies the specialist construction-site path recorded here. Physical objects include:

- temporary construction electrical installation;
- construction switchboard;
- board stand or post;
- construction socket-outlet bank;
- portable RCD unit;
- heavy-duty extension lead;
- cable ramp or protector;
- temporary work light;
- temporary lighting string; and
- electrical inspection and test tag.

The site installation changes as work progresses. Objects need an installed-from and removed-at status or equivalent phase information.

The inspection and test tag is physical. The test result, instrument, method, inspector and date are evidence. A coloured tag does not prove current safety by appearance.

## Product evidence and marks

The Electrical Equipment Safety System and Regulatory Compliance Mark apply to selected products and responsible suppliers. The catalogue stores them as evidence fields.

The following are not physical objects:

- RCM registration;
- EESS supplier registration;
- test certificate;
- standards conformity statement;
- switchboard verification record;
- cable calculation;
- maximum-demand result;
- inverter network approval;
- battery commissioning result;
- luminaire insulation-contact classification;
- IP or IK rating;
- fire or thermal classification;
- wireless coverage result; and
- electrical test result.

The following can be physical objects when present:

- product nameplate;
- warning label;
- circuit schedule;
- cable marker;
- inspection tag;
- equipment enclosure;
- selected guard or barrier; and
- access or service cover.

The drawing tool should link the first list to objects in the second list without confusing evidence with material quantities.

## SketchUp generation rules from this research

The electrical catalogue supports several practical tool patterns.

### Place assemblies, then expose parts

User-facing placement tools should usually place an assembly:

- socket-outlet installation;
- lighting point and selected luminaire;
- meter and switchboard arrangement;
- nbn and communications installation;
- PV array and inverter installation;
- BESS;
- EV charging installation; or
- security or intercom system.

Advanced editing can expose the internal plate, mechanism, box, bracket, cable, rail, clamp, label and connector objects.

### Keep graph and geometry together

Electrical behaviour depends on connections. Every cable or conductor run needs explicit start and end objects. Every switch, protective device, connector, meter, isolator and terminal needs a defined place in the circuit graph.

Geometry without the connection graph is not an electrical model. A graph without supports, access and spatial routing is not a buildable model.

### Use selected products when geometry matters

Generic geometry is suitable for early design. Product-specific geometry becomes necessary for:

- switchboard capacity and device ways;
- luminaire cut-outs and clearances;
- socket and faceplate mounting;
- inverter and battery dimensions, mass and cable entries;
- PV module clamp zones and racking interfaces;
- nbn equipment reservations;
- camera, intercom and EVSE mounting; and
- enclosure doors, service covers and working access.

The product model must carry evidence provenance. A downloaded shape without a model number, document revision and applicable ratings is only approximate geometry.

### Do not count analysis overlays as materials

Useful non-physical overlays include:

- switchboard working space;
- equipment service clearance;
- downlight thermal or insulation zone;
- PV roof access and exclusion zones;
- battery clearance and prohibited-location zones;
- camera and detector coverage;
- Wi-Fi coverage;
- EV cable reach and parking envelope; and
- cable calculation or voltage-drop warnings.

They should be shown on an analysis layer and excluded from quantity take-off.

## Source hierarchy and copyright boundary

The research uses public NCC pages, regulator pages, Standards Australia metadata and spotlight pages, Australian Government guidance, ACMA, nbn and Australian manufacturer material.

The licensed text of Australian Standards has not been reproduced. Public standard titles, editions, status, scope summaries and regulator adoption information are recorded. Exact mandatory clauses, figures, tables, test methods and design values must come from authorised copies and the applicable regulator or network source.

Manufacturer sources support component anatomy and common Australian product arrangements. A manufacturer example does not become the universal construction method.

## Known gaps and future research

This electrical pass is broad enough to begin SketchUp tool design, but it is not the end of the building ontology. Future specialised passes should consider:

- full smart-home bus systems, blind actuators, HVAC gateways and distributed control panels;
- generators, automatic changeover systems and stand-alone power systems;
- lightning protection and surge design beyond domestic switchboard components;
- swimming-pool and spa electrical equipment in greater depth;
- lifts, stair lifts and platform lifts;
- electric heating, underfloor heating and heated towel rails;
- pumps, motors and controls coordinated with hydraulic and mechanical systems;
- commercial fire detection, sprinklers and emergency warning systems outside normal house scope;
- accessibility and public EV-charging requirements for larger or shared buildings;
- strata EV distribution and billing systems;
- larger ground-mounted PV, carport PV and commercial battery installations;
- audio-visual, speaker, MATV and home-theatre systems in greater detail;
- access control, magnetic locks and gate operators with complete egress and door-hardware analysis;
- state-by-state legal adoption tables for every electrical standard; and
- network-specific service rules outside the NSW example used for detailed public service anatomy.

Each should be a separate small research slice. They should extend the current object graph instead of importing assumptions from older Basegrid or SketchOB work.
