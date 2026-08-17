# H7 ancillary-construction object research

## Scope and result

This slice identifies the physical objects needed to represent NCC Volume Two Part H7 and Housing Provisions Section 12 at house scale. It adds 196 objects under the `ancillary` discipline.

The catalogue covers:

- alpine external doorways that remain openable in snow;
- waling-plate attachment of eligible framed decks and balconies;
- in-ground, above-ground and spa-pool construction;
- aluminium and glass pool barriers, self-closing gates and CPR signs;
- pool suction safety, recirculation, filtration, heating and treatment equipment;
- open masonry fireplaces, freestanding and insert wood heaters, hearths, shields, chimneys and flues;
- bushfire ember protection at roofs, walls, subfloors, openings, joints and service penetrations; and
- high-level Class 10c private bushfire-shelter parts.

This remains an object vocabulary and modelling guide. It does not approve a pool, design a flue, assign a bushfire attack level or create a compliant private shelter. Jurisdiction, adopted NCC edition, structural and hydraulic design, product evidence, licensed standards and authority approval remain project inputs.

## Regulatory chain

NCC Volume Two Part H7 contains the performance and Deemed-to-Satisfy paths for:

1. swimming-pool access and water-recirculation safety;
2. construction in alpine areas;
3. construction in designated bushfire-prone areas;
4. heating appliances, fireplaces, chimneys and flues; and
5. private bushfire shelters.

Housing Provisions Section 12 contains:

- Part 12.2, construction in alpine areas;
- Part 12.3, a limited wall-attachment solution for framed decks and balconies using a waling plate; and
- Part 12.4, construction around heating appliances, open masonry fireplaces and freestanding heaters.

Part 12.3 is reached through the structural provisions and is included here because its physical objects sit naturally with the Section 12 ancillary work.

H7 is a regulatory grouping, not one building solid. A future SketchUp extension should create a pool, doorway, waling connection, heater or bushfire closure from the appropriate family and attach H7 roles and checks. It should not make an “H7 component” containing unrelated geometry.

## Exact publication editions

Edition control is essential.

- NCC 2022 calls up AS 1926.1:2012 for pool safety barriers. AS 1926.1:2024, amendment 1:2024 and supplement 1:2025 are later publications and are recorded separately.
- NCC 2022 calls up AS 1926.2:2007 incorporating amendments 1 and 2 for barrier location.
- NCC 2022 calls up AS 1926.3:2010 incorporating amendment 1 for pool water-recirculation safety.
- NCC 2022 calls up AS 3959:2018 incorporating amendments 1 and 2 for its bushfire path. Standards Australia stated in May 2026 that the next revision was still progressing through final development.
- NCC 2022 also offers NASH Standard NS300:2021 as an alternative bushfire construction path for applicable steel-framed construction. The AS 3959 and NASH paths must not be mixed piecemeal.
- Housing Provisions 12.4 calls up AS/NZS 2918:2018. AS/NZS 2918:2026 was published on 6 March 2026 and supersedes it as a publication, but does not silently replace it in the NCC 2022 path.

A future tool must store the exact standard identifier and edition behind every rule result. “Latest standard” is not adequate provenance.

## Alpine external doorways

The existing safe-movement catalogue already contains the alpine external trafficable access assembly, including open mesh walking surfaces and open barriers. This slice reuses it and adds the missing doorway objects:

- alpine external doorway assembly;
- raised threshold or sill plinth; and
- the physical **OPEN INWARDS** sign used on applicable Class 1b doors.

The important modelling distinction is between construction and clearance:

- the door leaf, frame, sill and sign are physical objects;
- the inward-opening or sliding operation is a physical configuration;
- the snow accumulation area and unobstructed movement envelope are constraints.

A raised threshold can conflict with step-free access. The tool should report the conflict and require a selected solution rather than silently deleting either requirement.

## Waling-plate deck and balcony attachment

The Housing Provisions solution is not a general permission to hang any deck from any wall. It has limits covering the wall construction, joist span, deck or tiled-balcony condition, member sizes, fasteners, corrosion exposure and bracing.

The physical assembly contains:

- timber or cold-formed steel waling plate;
- repeated wall-fastener group;
- No. 14 partial-thread self-drilling screws into eligible timber framing;
- M12 bolts and large washers into eligible steel framing;
- M12 chemical or mechanical anchors into eligible core-filled reinforced masonry;
- joist-to-waling support or connector;
- top, bottom and side flashings around opened cladding;
- sealant within correctly lapped flashing joints; and
- opposed diagonal deck-bracing straps and their fixings.

The common word *ledger* is retained as a search alias, but *waling plate* is the Australian canonical term for this NCC detail. Bearers, wall plates and fascia boards are different members.

Fastener position matters. A rendered pattern is only useful when each fixing lands in the required structural member or filled masonry, avoids mortar beds and timber end grain, preserves edge distances and does not collide with the joist connection.

The flashing is a four-sided junction system. A cap over the waling plate does not by itself protect the bottom and side edges of removed cladding.

## Pool object model

The catalogue intentionally separates three connected systems:

1. the water-retaining vessel and surrounding construction;
2. the child-access barrier; and
3. the water-recirculation and suction-safety equipment.

They address different hazards and need different tool behaviour.

### Pool vessels and groundwork

The vessel family includes:

- in-ground pool assembly;
- reinforced-concrete shell;
- prefabricated fibreglass shell;
- above-ground wall, liner and top rail;
- spa-pool assembly and jurisdiction-dependent secure cover;
- excavation;
- prepared base or bedding;
- selected side backfill;
- concrete perimeter bond beam;
- coping;
- interior finish;
- perimeter isolation joint;
- hydrostatic-relief or groundwater-access assembly;
- integrated entry steps;
- ladder; and
- pool handrail.

Excavation is represented as a ground opening because its volume affects set-out, services, access and temporary works. Safe battering, shoring and construction sequencing remain temporary-work decisions.

Concrete and fibreglass shells must not be reduced to different materials on the same generic face. Their manufacture, support, backfill, joints, fitting openings and perimeter connections are different.

The hydrostatic-relief assembly is not a suction outlet. One responds to groundwater outside the shell; the other connects pool water to the circulation pump.

### Pool safety barriers

The barrier is a closed route made from real segments and controlled openings. The model includes:

- isolation-fence assembly;
- boundary-barrier segment;
- aluminium tubular panels, posts, caps, brackets, base plates and covers;
- glass barrier panels, spigots, packers and clamps;
- complete self-closing self-latching gate assembly;
- gate leaf;
- self-closing hinge pair;
- latch;
- striker;
- gate stop; and
- physical CPR instruction sign.

Barrier height, ground gaps, panel openings, non-climbable zones and nearby climbable objects are constraints calculated from the geometry. A non-climbable zone is not another transparent solid placed beside the fence.

A property boundary line is not a barrier. The actual fence or wall must be modelled, including both faces, ground levels, retaining conditions and nearby features.

A glass balustrade and glass pool fence can share glass and spigots but have different hazard roles. Evidence for one is not automatically evidence for the other.

The gate must have operating states. The leaf, hinge action, closing direction, latch engagement and closed gaps cannot be checked from a static panel at one angle.

A normal floating pool blanket is not a child-resistant barrier. A secure spa cover is an access-control option only where the applicable jurisdiction permits and the selected product has evidence.

### Pool recirculation and suction safety

The recirculation graph begins at skimmers and submerged outlets, passes through suction pipes, pump, filter and treatment, and returns through pressure pipework and return inlets.

Skimmer objects include:

- body;
- waterline throat;
- floating weir;
- debris basket;
- access lid; and
- removable vacuum-cleaning plate.

Submerged suction objects include:

- sump;
- safety cover;
- matched cover fasteners;
- additional or auxiliary outlet;
- suction manifold; and
- vacuum-release device where selected or required.

The common term *main drain* is kept only as an alias. The fitting is normally a pumped suction outlet, not a simple gravity floor drain.

A skimmer vacuum plate and suction vacuum-release device do opposite things. The plate intentionally connects a cleaning hose to suction; the safety device relieves or interrupts excessive vacuum.

Plant and pipe objects include:

- circulation pump, motor, wet end and strainer pot;
- filter tank, media, multiport valve, pressure gauge and laterals;
- return inlet and adjustable eyeball;
- suction, return and backwash-discharge pipes;
- isolation valves and unions;
- pool heater, heat pump and solar collector;
- sanitiser assembly and saltwater chlorinator cell;
- timer or automation control; and
- pool cover and roller.

Suction, return and backwash pipes must carry a service identity. Backwash disposal is controlled by plumbing and local authority rules and must not be connected to stormwater by assumption.

South Australia expressly treats the skimmer as an outlet and requires a means of releasing vacuum pressure if it becomes blocked. Tasmania has additional circulation and filtration requirements for relevant pools. Queensland, Northern Territory and New South Wales vary or replace parts of the national barrier route. Jurisdiction must therefore be a required pool-project input.

## Solid-fuel heating

The solid-fuel family has three appliance forms:

- open masonry fireplace;
- freestanding wood heater; and
- closed fireplace insert.

The open masonry fireplace is decomposed into:

- front and back hearths;
- refractory firebox;
- inner and outer masonry leaves;
- separation cavity;
- opening lintel or arch;
- throat;
- existing reusable flue damper;
- tapered smoke chamber;
- masonry chimney;
- flue passage; and
- chimney crown.

The fireplace cavity is a physical void, not insulation. The smoke chamber is a shaped internal volume, while the throat is the narrower opening below it.

The freestanding heater includes:

- metal body and firebox;
- door assembly;
- high-temperature ceramic door glass;
- latch and gasketed closure;
- baffle;
- firebrick or refractory lining;
- optional grate and ash pan;
- combustion-air control; and
- pedestal or legs.

The floor protector and wall shield are building construction around the appliance. The ventilated wall shield only works as the complete sheet, spacers and open air path. The resulting heater clearance is a constraint, not another solid.

The metal flue system separates:

- active inner flue carrying combustion gases;
- intermediate casing;
- outer casing;
- the annular air or insulation arrangement;
- straight lengths and elbows;
- joint clamps;
- support brackets;
- ceiling plate;
- existing reusable roof flashing;
- storm collar; and
- terminal cowl.

Components from different flue products must not be mixed without evidence. Adding untested ember mesh to a solid-fuel cowl can obstruct draft and is not a valid bushfire detail by assumption.

## Bushfire-resisting construction

Bushfire attack level is project metadata. It is not a material or object. The physical response is the complete building construction selected under one pathway.

The catalogue reuses existing wall, roof, floor, deck, window, door and glazing objects. It adds the H7-specific vulnerable-junction objects:

- ember-protection system;
- metal ember mesh;
- frame, fasteners and edge seal;
- weephole screen;
- screened eave, soffit, ridge and roof vents;
- roof-profile closure;
- roof-to-wall closure;
- gutter ember guard;
- roof-penetration closure;
- subfloor enclosure and mesh panels;
- external-opening screen system;
- window screen;
- screen door;
- shutter;
- opening perimeter seal;
- door-bottom seal;
- construction-joint seal;
- service-penetration closure; and
- high-level site firefighting-water supply assembly where the approved path needs one.

Mesh is not enough on its own. Ember protection fails at unsupported edges, gaps beside the frame, incompatible fasteners, corrosion or a screen removed for cleaning and not replaced.

Ventilation and ember control must be coordinated. Blocking a weephole or roof vent can create moisture and condensation failures. The model must preserve the intended drainage or free-open area through a suitable protected opening.

A leaf guard becomes a gutter ember guard only when its material, aperture, edges, fixings and maintenance are supported for that role.

AS 1530.8.1 and AS 1530.8.2 are test-method metadata. They qualify selected specimens and systems; the ontology must not infer performance from a material name.

## Private bushfire shelters

H7P6 has no Deemed-to-Satisfy construction path. The ABCB Performance Standard for Private Bushfire Shelters provides performance guidance, not a prescriptive acceptable design.

The catalogue therefore stays at high-level physical parts:

- Class 10c shelter assembly;
- above-ground and in-ground variants;
- engineered floor, wall and roof shell;
- shell construction joints;
- protected access assembly;
- door or hatch leaf, frame, multipoint latch and high-temperature seal;
- access stair or ladder;
- external location sign;
- internal capacity and maximum-period sign;
- viewing window;
- protected ventilation assembly;
- openable vent, mesh and damper;
- optional entry airlock or tunnel;
- optional external heat shield;
- service-penetration seal;
- emergency lighting; and
- optional engineered air-quality support unit.

The words *bunker*, *cellar* and *safe room* are search aliases only. They do not establish Class 10c classification or safety. The ABCB guidance warns against treating an under-dwelling safe room or cellar as an easy shelter solution because building collapse, fire spread and blocked egress can trap occupants.

Occupant capacity, maximum period, internal temperature, humidity, oxygen, carbon dioxide, smoke, structural resistance and separation from hazards are design inputs and results. They are not solids generated from room area.

A conventional building fire door is not automatically a shelter door. The shelter opening must address the combined leaf, frame, latches, seals, pressure, heat, debris, internal operation and post-fire egress conditions.

Future tools may document engineer-selected shell elements and evidence, but must not offer a one-click “compliant bushfire bunker.”

## Tool-building rules exposed by this slice

1. Ask for jurisdiction and adopted NCC edition before selecting pool or bushfire rules.
2. Store exact standard editions; never use an unqualified “latest.”
3. Lock the AS 3959 or NASH bushfire construction path before choosing details.
4. Keep physical objects separate from clearance, exposure, capacity and performance results.
5. Reuse existing walls, roofs, doors, glazing, decks, gutters and flashings, then attach specialist roles.
6. Treat holes, voids and movement states as first-class geometry where they affect construction.
7. Generate complete connection and closure systems rather than symbolic panels.
8. Require selected-product data for pool equipment, glass barriers, heaters, flues, screens, seals and shutters.
9. Keep inspection, cleaning, replacement and operating state in the model.
10. Prevent automatic compliance claims for Class 10c private shelters.

## Important boundaries left for later work

This slice does not complete:

- electrical installations and equipotential bonding around pools;
- gas appliance and gas pool-heater installation;
- public aquatic facilities and commercial water treatment;
- full pool structural engineering or water-retaining concrete design;
- plumbing approval for pool backwash and drainage;
- bushfire planning, vegetation management, asset-protection zones and fire-service vehicle-access design;
- complete state and territory legislation outside the NCC text;
- product certification for every bushfire screen, shutter, seal or door;
- environmental emissions approval for wood heaters; or
- structural, fire-safety and tenability engineering for a specific private bushfire shelter.

Those need their own authoritative source and product passes.

## Principal public sources

- Australian Building Codes Board, NCC 2022 Volume Two Part H7.
- Australian Building Codes Board, Housing Provisions Parts 12.1 to 12.4.
- Australian Building Codes Board, NCC 2022 Bushfire Verification Methods handbook.
- Australian Building Codes Board, Performance Standard for Private Bushfire Shelters.
- Standards Australia public metadata for the AS 1926 series, AS 3959, AS/NZS 2918 and AS 1530.8 series.
- NASH, NS300:2021 public metadata.
- Australian Steel Institute, NCC 2022 bushfire-path guidance.
- Pentair Australia pool skimmer, suction outlet, pump and filter product information.
- Compass Pools and Narellan Pools public fibreglass installation information.
- Protector Aluminium pool-fence, glass-spigot, gate-hinge and latch installation information.
- HeatCharm wood-heater installation information.
- Flomet domestic solid-fuel flue-system information.
- WoodSolutions domestic timber-deck guide, used only for supporting anatomy while NCC 2022 controls the waling-plate detail.
