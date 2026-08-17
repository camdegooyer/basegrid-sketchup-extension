# Structural steel research notes

Research date: 16 August 2026. Regulatory baseline: NCC 2022 Amendment 2.

These notes identify physical objects for future drawing tools. They do not reproduce licensed Australian Standards, member tables, connection capacities or fabrication tolerances, and they are not engineering or compliance advice.

## Regulatory path and scope

NCC Volume Two H1D6 recognises AS 4100 as a structural-steel framing pathway. Housing Provisions Part 6.3 supplies a narrower prescriptive path for specified structural-steel bearers, strutting beams, lintels and columns. It also exposes physical concepts a model must retain: bearings, lateral restraint, bolts, member connections, web penetrations and corrosion protection.

Part 6.3 is not a general licence to size every steel frame. Its member tables, building limits, loads, support conditions, connections and corrosion provisions must all be checked against the actual project. This catalogue records the objects and relationships but deliberately stores no copied span or capacity tables.

## Role and section are separate

A **role** says what a member does. Beam, bearer, strutting beam, lintel, column and brace are roles in a load path.

A **section** says what cross-sectional product is used. The Australian Steel Institute range source supports these common families:

- universal beam (UB) and universal column (UC);
- parallel flange channel (PFC) and taper flange beam (TFB);
- equal angle (EA) and unequal angle (UA);
- welded beam (WB) and welded column (WC);
- beam tee (BT) and column tee (CT);
- rectangular, square and circular hollow sections (RHS, SHS and CHS); and
- hot-rolled plate and flat bar stock.

The two classifications must be combined. A column is not automatically a UC, and a UB is not automatically used as a beam. A scheduled RHS can act as a column, beam or brace. Future tools should therefore ask for both the role and section designation before generating final member geometry.

“I-beam” and “RSJ” are search language, not reliable Australian product designations. They stay in the terminology review because they do not distinguish UB, UC, TFB, WB or an existing imported or superseded section.

## Connections are assemblies

The Australian Steel Institute connection handbook describes a connection as more than the visible contact between two members. Its physical parts can include bolts or welds, plates, gussets and cleats, plus the supported and supporting members.

The catalogue therefore separates:

- the complete structural-steel connection;
- bolted and welded connection assemblies;
- column base plate and member splice assemblies;
- structural bolts, nuts, washers and their fabricated holes;
- individual weld runs;
- end plates, web side plates, angle cleats and gusset plates;
- base plates and anchor bolts;
- stiffener, bearing and splice plates; and
- bracing cleats.

This separation matters for fabrication, take-off and revision. Changing a bolt group can change hole geometry without changing the member profile. Moving a splice changes plates, bolts or welds and erection logic. A base plate is only one part of the installed base connection, which also includes column attachment, anchors, the bearing interface and any documented grout.

## Openings and corrosion protection

A bolt hole and a member web penetration are both empty space, but they are not the same object. A bolt hole belongs to a connection and matches a fastener group. A web penetration is an individually designed opening through a member for a coordinated service or other documented purpose.

The plugin must never cut a web because a routed service intersects it. It may draw only an approved opening from a structural or fabrication schedule, preserving shape, position, edge details and any required reinforcement.

Protective paint and hot-dip galvanizing are separate coating-system objects. Paint carries surface preparation, coat sequence and repair data. Post-fabrication hot-dip galvanizing also affects venting and drainage openings, masking and repair. Neither should be reduced to a material colour.

## Supporting technical documents

The catalogue links these supporting standards while keeping them distinct from direct Housing Provisions references:

- AS/NZS 1163:2016 — cold-formed structural steel hollow sections;
- AS/NZS 1252.1:2016 — structural high-strength bolt, nut and washer assemblies;
- AS/NZS 1554.1:2014 — welding of steel structures;
- AS/NZS 3678:2016 — hot-rolled structural plates, floorplates and slabs;
- AS/NZS 3679.1:2016 — hot-rolled structural bars and sections;
- AS/NZS 3679.2:2016 — welded I-sections; and
- AS/NZS 5131:2016 — fabrication and erection of structural steelwork.

AS 4100, AS 2312.1, AS/NZS 2312.2 and AS 5216 were already present in the project standards registry and are linked where relevant. A linked standard is a source route, not a claim that every object or project uses every document.

## Known gaps

- portal frames, rafters, purlins, girts, trusses and crane-support steelwork;
- composite steel-and-concrete beams, slabs, shear connectors and metal decking;
- moment-connection subtypes, seated connections, flange plates and haunches;
- packers, shims, erection aids, temporary braces, lifting lugs and transport restraints;
- grout, cast-in anchor cages, post-installed anchor products and concrete breakout geometry;
- welded hollow-section nodes, end caps, diaphragms, through plates and access holes;
- fire-protective boards, sprays and intumescent coatings;
- detailed blast, fatigue, seismic and robustness components;
- stairs, ladders, platforms, balustrades and miscellaneous architectural metalwork; and
- product-specific section libraries, available lengths, fabrication rules and connection templates.

Full URLs and access notes are stored in `data/sources/source_registry.json` and generated into `exports/source_audit.csv`.
