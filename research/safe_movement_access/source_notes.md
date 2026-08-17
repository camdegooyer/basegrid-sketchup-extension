# Safe movement, stairs, ramps, barriers and handrails source notes

## Scope of this slice

This slice identifies 157 physical assemblies and components needed to draw house-scale stairs, ramps, landings, pedestrian surfaces, fall-prevention barriers and handrails exposed by NCC Volume Two Part H5 and Housing Provisions Parts 11.2 and 11.3. It also includes the physical external-access features called up for alpine areas in Part 12.2.

It covers:

- complete stairways and individual straight, turning, winder, spiral, curved, open-riser, closed-riser and external stair flights;
- timber, steel, precast, pan and grating tread construction;
- strings, stringers, central spines, brackets, cleats, wedges, glue blocks, bearings and end connections;
- treads, risers, open-riser gaps, nosings, applied safety strips, finishes and soffit or skirt linings;
- ramp and landing decks, frames, beams, posts, edge upstands, joints and drainage parts;
- barriers made from walls, posts and rails, balusters, pickets, panels, perforated metal, mesh, wire rope or glass;
- barrier gates, changes in barrier height, connections, anchors, packers, waterproofing collars and covers;
- detailed tensioned-wire terminals, tensioners, guides, bushes, pulleys and lock-offs;
- structural and infill glass panels, spigots, channels, clamps, standoffs, wedges, gaskets, blocks, anchors and drainage openings;
- graspable handrails, wall and post brackets, joins, bends, returns, caps, anchors, backing and spacers; and
- a supplementary barrier rail in front of an openable window, while the main window catalogue retains sash restrictors and protective screens.

This is a physical-object discovery slice. It is not a structural design calculator, accessibility certification system, slip-test laboratory, glass-design package or pool-barrier approval tool. It gives later SketchUp tools the right things to draw and the right facts to retain.

## Regulatory path in plain English

NCC Volume Two Part H5 establishes the house-level objective: people must be able to move safely to and within the building, and must be protected from falls where the change in level creates a hazard. For the Deemed-to-Satisfy route, the physical construction is largely described in Housing Provisions:

- Part 11.2 for stairway and ramp construction; and
- Part 11.3 for barriers and handrails.

Part 12.2 adds provisions for construction in alpine areas. This matters to external access because snow and ice change surface, drainage and open-area needs. A mesh or grating walking surface, open barrier and their supporting frame are physical objects; snow conditions and the applicable structural actions are design inputs.

The NCC stair and barrier FAQ adds an important scope distinction. A stair serving the building is not the same as unrelated landscaping steps elsewhere on a site. The route served, not merely whether it is outside, determines the likely regulatory path. The FAQ also explains that the Housing Provisions do not set a general minimum width for these stairways, though other requirements, uses or jurisdictions may do so. A tool should not invent a universal width default and label it compliant.

Jurisdiction, NCC edition, building classification, use, location, connected levels and chosen compliance path must be stored with the model. State and territory variations, planning conditions, accessibility requirements and product evidence can change the result.

## Referenced and supporting Australian Standards

The standards registry records the standards by edition and public scope without copying licensed clauses, tables or test details.

AS 4586 classifies the slip resistance of new pedestrian surface materials. For this slice it provides evidence metadata for a tread, nosing, landing or ramp finish. A classification is not a surface layer and is not established by how rough a SketchUp material looks.

AS/NZS 1170.1 provides structural actions relevant to barriers, handrails, stairs and associated components. The action, combination and acceptance result are analysis data. The physical model contains the posts, rails, panels, glass, wires, brackets, anchors and supporting structure that carry those actions.

AS 1288 addresses the selection and installation of glass in buildings. It is relevant where glass forms structural barrier panels or framed infill. Glass make-up, supports, holes, edges, interlayers, fittings, cap rails and the supporting building structure must be retained as real geometry and product data.

AS 1428.1 is recorded as a supporting source for access and mobility. It must not be silently applied to every Housing Provisions ramp. An accessible route can require additional clearances, landings, edge protection, handrails and circulation geometry. The model must state whether that compliance path has been selected.

The exact current NCC reference, edition, jurisdictional variation and licensed standard content must be checked when implementation reaches compliance rules. Public Standards Australia metadata confirms identity and broad scope; it does not replace authorised access to the documents.

## Draw the construction; calculate the rule result

A future tool needs a strict boundary between physical objects and measurements or conditions.

Physical objects include a tread, riser board, stringer, bracket, landing frame, ramp deck, barrier post, wire rope, glass panel, base channel, handrail and anchor. They have geometry, material, placement and connections.

The following are not extra solids:

- rise and going;
- stair pitch or ramp gradient;
- flight length, step count or geometric uniformity;
- fall height;
- barrier height;
- an opening-limit sphere or template;
- climbable-zone status;
- slip-resistance classification;
- line, point, distributed or infill design actions;
- wire tension;
- glass capacity or residual-risk assessment; and
- a pass, warning or compliance result.

These values belong to a named object, assembly, hazard edge or analysis case. The application can display dimensions, coloured checks and warning overlays, but it must not generate fictional geometry called a 125-millimetre gap, non-climbable zone or P rating.

## Stair hierarchy and geometry

A stairway is the whole circulation assembly between connected levels. It may contain one or more flights, landings, barriers and handrails. A flight is one uninterrupted series of steps. Each step has a physical tread and may have a riser closure; rise and going are dimensions derived from the step geometry.

That hierarchy is important for editing. Changing floor-to-floor height should recalculate the intended flight geometry, but must not erase the chosen tread construction, stringer system, nosing, finishes, barriers or connections. If the step count changes, the tool should flag all dependent fabrication and barrier geometry for review.

For each stairway, retain at least:

- lower and upper connected levels and finished-surface datums;
- plan path, width, direction changes and landing boundaries;
- flight count, step count, total rise and individual rise and going values;
- nosing line, walk line and clear headroom envelope;
- open or closed risers and every clear opening;
- tread body, finish and separately applied nosing components;
- support family, member sections, bearings and top or bottom connections;
- edge conditions, adjacent walls, barriers and handrails; and
- external exposure, drainage, durability and slip evidence.

Straight, quarter-turn and half-turn stairs describe the route. Winder, spiral and curved stairs also need explicit plan geometry. A winder is a tapered tread used through a change in direction. A spiral stair normally turns around a central axis or post. A curved or helical stair can have an open centre and curved inner and outer support lines. Product names alone are not enough to generate these accurately.

The word floating describes appearance, not support. A floating-looking flight might use a central steel spine, hidden side strings, wall-cantilevered treads or suspended supports. The tool must ask for the actual load path before drawing structural parts.

## Treads, risers, finishes and nosings

A generic tread symbol is insufficient for quantity and fabrication work. The catalogue separates:

- solid or engineered timber treads;
- precast concrete step units;
- steel plate or folded treads;
- open grating treads;
- metal pans and their concrete, screed, resin or stone infill;
- the exposed walking finish;
- the formed front nosing;
- an applied nosing carrier and its replaceable slip insert; and
- full-tread safety overlays.

The tread body carries load. The finish provides the exposed walking surface. The nosing can be an integral edge or a separately fixed assembly. Their material, thickness, wear, joints, fixings and replacement cycles differ, so they must remain separate objects even if they occupy nearly the same visible surface.

Open-riser construction still has a rise dimension. The missing closure creates a real clear opening between adjacent steps, and that void should be measurable. A timber riser board is a physical component of a closed-riser stair. The terms rise, riser and open riser must never collapse into one field.

Slip resistance is evidence attached to the selected walking surface or applied product. A raised pattern, abrasive texture or visible strip does not prove a required classification. Store the test method, class, wet or dry condition, product configuration, substrate, direction, report and maintenance assumptions. When a finish changes, the evidence must be reviewed rather than inherited automatically from the old surface.

## Stringers, supports and connections

Stringer, string and carriage overlap in building language, but the actual construction can be very different. The catalogue distinguishes:

- cut timber strings with stepped bearing seats;
- housed timber strings receiving tread and riser ends;
- fabricated steel plate strings;
- channels, hollow sections or other steel stringer sections; and
- central mono-stringer or spine assemblies with individual tread arms.

A skirt board or wall string can be decorative lining rather than structural support. The tool should identify what carries each tread instead of assuming that a sloping board is a stringer.

Traditional housed stairs expose small physical parts that matter to manufacture: tread and riser housings, wedges, glue blocks and joints. Fabricated steel stairs need plates or sections, tread brackets, cleats, welds, bolts, drainage holes, coatings and end plates. Every stringer system also needs a top connection, bottom connection and bearing geometry tied to the real floor, landing, wall or foundation support.

Structural adequacy cannot be inferred from a member looking deep enough in the model. Section, grade, span, restraint, connection design, corrosion exposure, supporting structure and design actions remain evidence and engineering inputs.

## Ramps, landings and thresholds

A building-serving pedestrian ramp is a sloping circulation assembly. It can be solid-on-ground or framed and elevated. The physical construction can include a deck or slab surface, support frame, sloping beams or stringers, joints, slip-resistant finish, drainage channel and edge upstand.

A landing is a level circulation platform related to a stair, ramp or doorway. It may use normal floor or deck construction, but it must also know which routes and door swings it serves. Its substrate, finish, frame, beams, support posts, fascia, barriers and drainage are separately drawable objects.

A threshold can mean the door-frame weathering profile, a raised transition or a separate step at the doorway. This slice includes the threshold-step and landing relationship; detailed door sills and flashings remain in the opening and weatherproofing catalogues. A tool must coordinate both rather than draw two overlapping threshold solids.

Ramp slope, crossfall, landing length, door clearance and edge-protection rules are constraints on the selected construction. The tool should derive them from the actual surfaces and selected compliance path.

## Barrier systems and hazard edges

A fall-prevention barrier is the complete construction at a trafficable edge. Balustrade is a widely recognised industry term, but baluster means only one repeated infill member. Guardrail can also refer to temporary site protection or road infrastructure, so barrier is the safer regulatory object name.

The catalogue includes:

- trafficable-edge, stair-flight and landing or deck barriers;
- a solid wall or parapet acting as the barrier;
- post-and-rail and vertical-baluster systems;
- panel, perforated and mesh infill systems;
- wire-rope and glass barrier systems;
- barrier gates and their hinges, latches and stops;
- height transitions between sloping and level runs;
- barriers associated with retaining walls on an access path; and
- a supplementary rail in front of a window opening.

Every barrier needs a hazard relationship: the trafficable surface on one side, the lower surface or void on the other, and the edge along which protection is required. Fall height and required barrier geometry should be calculated from those surfaces, not typed into an unrelated post property.

Barrier height, opening limits and climbability apply to defined datums and zones. A sphere used to test an opening is a checking tool, not permanent construction. Climbability depends on the arrangement of horizontal rails, wires, projections and nearby footholds. Preserve the exact geometry so the current rules can be evaluated without baking the rule result into the object name.

A wall can form the barrier when its height, openings and construction satisfy the applicable path. It should remain a wall object carrying an additional barrier role, not be duplicated as an invisible balustrade.

## Posts, rails, infill and host structure

Primary posts, stair newels, repeated balusters and pickets have different roles. Posts transfer barrier actions into the supporting floor, stair or wall. Newels occur at significant stair locations such as ends, landings and turns. Balusters and pickets usually fill the space between primary supports.

The base connection is often the controlling physical detail. A top-mounted post can use a base plate and anchor group. A side-mounted post can use a fascia bracket, but the thin fascia board itself is rarely the whole structural support. Backing beams, blocking, plates, anchors, edge distances, packers, grout, waterproofing collars and covers need explicit objects or relationships.

Top, intermediate and bottom rails can brace posts, retain infill or cap the barrier. A barrier top rail is not automatically a graspable handrail. Rail joiners, wall brackets and end caps remain important fabrication and finishing parts.

## Tensioned-wire barriers

A tensioned-wire barrier is a system, not a row of generic lines. It can include:

- stranded stainless-steel wire rope;
- end, corner and intermediate posts or supporting rails;
- pass-through bushes and intermediate guides;
- turnbuckle or threaded-stud tensioners;
- swaged fork, eye or stud terminals;
- swageless mechanical terminals;
- ferrules, thimbles, eye fittings and saddles;
- pulleys where a designed wire changes direction;
- lock-off hardware, angled washers and termination covers.

Wire tension is a state. It is not the same thing as the turnbuckle or terminal that creates and retains it. The model should store design and installed tension, adjustment range, span, support spacing, wire construction, direction changes and inspection access. A visual straight line cannot prove that the wires, posts, end supports and host structure act together adequately.

Openings and climbability depend on deflection under the applicable conditions as well as initial spacing. Licensed NCC and engineering inputs are needed for exact checks. The catalogue provides the geometry and fittings on which those checks operate.

## Glass barriers

Frameless glass is a visual description. The glass still needs support and connection. The catalogue separates:

- structural glass barrier panels carrying barrier actions through their own support system;
- glass used as infill within a surrounding frame;
- deck-mounted or core-drilled spigot assemblies;
- top-mounted or side-mounted continuous base channels;
- channel wedges, gaskets, setting blocks, anchor groups, end covers and drainage openings;
- edge clamps and through-fixed stand-off buttons;
- a cap rail over the glass edge; and
- a graspable handrail offset on glass-mounted brackets.

The model must retain glass make-up, thickness, heat treatment, laminate interlayer, panel size, exposed edges, holes, notches, joints, support positions and product evidence. It must also retain the concrete, timber or steel host, edge member, anchors, packing, isolation materials, drainage and waterproofing around penetrations.

Structural glass and infill glass are not synonyms. The load path decides the role. A cap rail joining panel tops and an offset handrail for grasping are also different components, although one proprietary design may combine functions when supported by evidence.

AS 1288 and structural actions inform selection and installation, but the ontology does not reproduce their licensed design tables or pretend to size glass. The final design needs authorised documents, supplier evidence and competent engineering where required.

## Handrails

A handrail supports a person while moving on a stair or ramp. It needs a graspable member, supports, connections and safe terminations. The catalogue contains wall-mounted and barrier-top assemblies, wall and post brackets, joins, bends, returns, caps, rosettes, anchors, backing and bracket spacers.

For each run, record:

- the stair flight, ramp or landing served;
- grasp profile and clear finger space;
- height datum and offset from adjacent construction;
- continuity through landings and changes of direction;
- wall or barrier support points and backing;
- joins, bends, ends and returns; and
- material, finish, exterior exposure and structural evidence.

A handrail can sit on a barrier, but the barrier and handrail roles remain separate. Removing or changing one can affect the other. A local grabrail used for accessibility or sanitary support belongs to a later accessibility family and should not be generated as a stair handrail simply because both are grasped.

## Windows, pool barriers and other boundaries

The Housing Provisions include protection at particular openable windows. The physical options can include a sash opening restrictor, protective screen or supplementary barrier. An insect screen or security screen is not automatically a fall-protection screen. Window-specific sash, restrictor, screen and fixing objects remain in the windows and doors catalogue; this slice adds the barrier rail needed when that is the selected solution.

Swimming-pool barriers are deliberately not folded into this family. Pool access, gates, clear zones, state and territory rules and the AS 1926 series require a dedicated research slice. A deck-edge barrier and a pool fence may share posts, panels or glass fittings, but compliance for one hazard must not be assumed for the other.

Also outside this slice are:

- H8 livable-housing construction, now covered by the separate `research/livable_housing/source_notes.md` slice;
- complete AS 1428 accessible paths, tactile indicators and accessible sanitary facilities;
- lifts, platforms and other mechanical vertical transport;
- fixed access ladders, walkways and platforms associated with AS 1657;
- temporary construction guardrails and scaffolding;
- commercial egress stairs and fire-isolated exits; and
- unrelated landscaping stairs and civil pedestrian infrastructure.

These later families should reuse physical members where the construction is genuinely the same, while adding their own roles, constraints and evidence.

## CAD implications

A useful SketchUp tool for this family should retain at least:

- jurisdiction, NCC edition, building classification and selected compliance path;
- lower and upper levels, finished surfaces and connected circulation route;
- stairway, flight, landing, ramp and threshold hierarchy;
- individual step geometry, nosing datums, rise, going and clear openings;
- actual tread, riser, finish and nosing construction;
- stringer or support family, member sections, brackets, bearings and connections;
- external exposure, drainage, corrosion protection and durability;
- walking-surface product and slip-test evidence;
- every trafficable hazard edge and the lower surface or void beyond it;
- barrier family, post locations, rails, infill, openings, gates and transitions;
- backing structure, plates, brackets, anchors, edge distances, packers and waterproofing;
- complete wire rope paths, terminals, tensioners, direction changes and installed tension metadata;
- glass panel make-up, edges, holes, supports, fittings, anchors and host construction;
- handrail profile, continuity, supports, backing, joins, bends and returns;
- rule measurements and analysis results as metadata or overlays; and
- evidence source, product version, design assumptions and inspection status.

At concept level, the tool can generate a coordinated stair or ramp envelope and propose system families. At fabrication detail it should expose every tread, string, post, wire terminal, glazing wedge and anchor. Both levels must use the same stable objects so refinement does not discard decisions.

The tool must not claim compliance because a barrier line, rough tread texture or handrail symbol is present. Compliance depends on the applicable regulatory path, complete geometry, material and product evidence, supporting structure, connections, installation and current authorised rules.

## Main sources

- ABCB, NCC Volume Two Part H5, safe movement and access.
- ABCB, Housing Provisions Part 11.2, stairway and ramp construction.
- ABCB, Housing Provisions Part 11.3, barriers and handrails.
- ABCB, Housing Provisions Part 12.2, construction in alpine areas.
- ABCB, stairways, barriers and handrails frequently asked questions.
- Standards Australia public metadata for AS 4586:2013, AS/NZS 1170.1:2002, AS 1288:2021 and AS 1428.1:2021.
- WoodSolutions, Technical Design Guide 8, *Stairs, Balustrades and Handrails Class 1 Buildings — Construction*.
- Australian Glass and Window Association, industry guidance on barrier glazing.
- Australian Government training material for manufacturing and assembling joinery components, including stairs.
- Australian suppliers' public technical information for tensioned-wire barrier fittings, stair nosings, steel strings and proprietary glass barrier systems.

No licensed standard text is reproduced. Exact limits, test methods, tables, structural design, glass selection, wire-system rules, accessibility details and product-specific installation requirements remain authorised-source inputs for implementation and review.
