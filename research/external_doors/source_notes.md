# External pedestrian doors, security screens, shutters and garage-door research notes

Research date: 17 August 2026. Regulatory baseline: NCC 2022 Amendment 2, checked against the current NCC online text available on the research date.

These notes record public evidence used to discover physical objects and relationships. They do not reproduce paid Australian Standards, replace manufacturer instructions or provide garage-door spring service advice.

## Result of this research pass

This pass adds a new `external_doors` discipline containing 237 physical objects and assemblies. It covers:

- solid, timber, composite and metal-faced external pedestrian doorsets;
- leaf cores, skins, joinery members, frames, thresholds, weathering and entrance hardware;
- insect, barrier and classified security-screen doors and window screens;
- woven mesh, perforated sheet, expanded mesh, grille, retention, multipoint locks, tracks, rollers and installation fixings;
- hinged, sliding, folding, fixed, solid-panel and louvred external shutters;
- domestic roller shutters, curtains, slats, guides, head boxes, axles, drives and controls;
- sectional, roller and tilt garage or large access doors;
- panels, curtains, tracks, guides, rollers, hinges, brackets, cables, drums, springs, wind locks and support interfaces;
- manual and powered operation; and
- operator rails, trolleys, arms, controls, limits, photoelectric beams, sensing edges, releases and backup power.

The pass reuses the established glazed external-door, internal hardware, air-seal, bushfire-screen, fire-door, livable-entrance and glazing objects instead of cloning them. The generated ontology now contains 3,225 objects, 7,978 relationships and 29 disciplines.

## Regulatory boundary

### Garage and large access doors

Housing Provisions clause 2.2.4 is the direct NCC spine for qualifying garage doors and other large access doors. It calls up AS/NZS 4505:2012, including Amendment 1, for the door design, construction and installation route described by that clause.

The clause is conditional. Its wind-region wording and opening conditions must be read from the NCC edition legally adopted for the project. The current online presentation reviewed during this pass and earlier baseline extracts do not present the wind-region wording identically. The ontology therefore does not convert “garage door” into a universal AS/NZS 4505 applicability flag. A project record needs, at minimum:

- NCC edition and amendment;
- state or territory adoption and variations;
- building and opening location;
- wind region and site design inputs;
- opening area and door configuration; and
- the documented compliance or performance pathway.

AS/NZS 4505 is also useful public metadata for object discovery because its scope covers door components, wind pressure ratings, actions on supports, installation and safety. The licensed standard and selected product documentation are still needed before implementing sizes, wind configurations, fixings, supports, tolerances, testing or acceptance rules.

### External pedestrian doors and sealing

Housing Provisions clause 13.4.4 addresses sealing of external doors and doors between a conditioned part of a house and an unconditioned garage or similar space. The physical ontology therefore keeps head and jamb seals, threshold seals, automatic door bottoms, meeting-stile seals and penetrations such as mail slots explicit.

That clause does not define every door's structural or weatherproof construction. A tool must not infer water penetration resistance, airtightness, acoustics or energy performance merely because a seal object is present. The selected doorset, wall interface, sill or threshold, flashing, drainage path and installation evidence remain a coordinated system.

AS 2688:2017 supplies current public metadata for timber and composite doors. AS 4420.1 supports the existing methods-of-test route. AS 4145 Parts 1, 2 and 5 support locksets, mechanical locks and controlled door-closing devices. They are registered as supporting standards, not new direct Housing Provisions references.

Framed glazed external doors already exist in the `windows_doors` discipline and retain the AS 2047 route where applicable. This slice focuses on non-glazed and partly glazed entrance-door construction and coordinates with those existing objects. A glazed aperture in a solid leaf does not automatically turn the whole product into the same family as a framed glazed sliding or bi-fold door.

### Livable, fire, smoke and bushfire roles

NCC H8 livable-housing entrance thresholds and clearances remain in the `livable_housing` discipline. This slice supplies physical leaves, frames, thresholds and hardware that may participate in that path, but it does not duplicate or silently apply H8 constraints to every entrance.

Fire doorsets, smoke doors, fire hardware and fire-rated penetrations remain in `fire_safety`. Bushfire screens, shutters, seals and ember protection remain in `ancillary`. The new security-screen and generic-shutter objects can be linked to those systems only where selected evidence supports the combined roles.

“Security”, “bushfire”, “fire”, “cyclone”, “impact”, “acoustic”, “thermal” and “fall prevention” are evidence-backed roles on a complete selected configuration. They are not visual geometry types.

## External pedestrian-door anatomy

A doorset, leaf and wall opening are three levels:

- the structural opening is the supported void in the wall;
- the doorset includes the product frame, one or more leaves, threshold, hardware, seals, fixings and interfaces; and
- a leaf is the moving panel within that doorset.

Leaf construction matters to geometry and take-off. A traditional panelled timber leaf exposes stiles, top, middle and bottom rails, muntins and separate infill panels. A flush leaf contains face skins, perimeter framing, lippings, lock blocks and a core. A moulded composite skin can look panelled without containing traditional joinery. Metal- or GRP-faced insulated leaves introduce skins, edge construction, insulation and local hardware reinforcement.

“Solid core” does not mean one solid timber slab. A substantially filled core can use timber staves, particle material, foam, mineral or another documented construction. Core and face material are therefore separate attributes and objects.

The fixed frame separates head, hinge jamb, lock jamb, sill where present, stops, seals, anchors, packers and wall interfaces. The threshold is the crossed and sealed profile at the floor. A frame sill and a building step can occupy the same area but remain different roles. Weather pans, subsills, head drips and leaf-bottom drips remain separate drainage or shedding objects.

Hardware is split by physical function: hinges or pivots carry and guide the leaf; lock bodies and deadbolts restrain it; cylinders accept a key; handles and pulls accept user force; flush bolts restrain an inactive leaf; astragals close meeting edges; closers return the leaf; and holdbacks retain an open position. One hardware schedule may combine these pieces, but a single “handle” component is not a lock system.

## Security, barrier and insect screens

The current security-screen standards family has been reorganised:

- AS 5039.1:2023, with Amendment 1:2024, covers classification and performance requirements;
- AS 5039.2:2024 covers installation; and
- AS 5039.3:2023 covers methods of test.

This succeeds the older AS 5039:2008, AS 5040 and AS 5041 pathway. Exact product evidence can legitimately refer to an earlier edition according to manufacture, certification and project acceptance, so the edition must be stored rather than silently rewritten.

The main plain-English distinction is:

- an insect screen is primarily lightweight insect exclusion;
- a barrier screen provides a more substantial secondary physical barrier without an automatic security claim; and
- a security screen is a classified complete product and installation.

Security cannot be inferred from stainless-steel mesh, a diamond grille, heavy frame sections or a three-point-looking handle. The complete path includes infill, edge retention, leaf frame, fixed frame, hinges or rollers, anti-lift and anti-jemmy parts, lock points, receivers, frame fixings and the actual substrate.

The ontology separates woven stainless wire, perforated aluminium sheet, expanded metal and grille infill because they require different drawing patterns and retention geometry. It also separates an infill-retention wedge used by a security system from ordinary insect-screen spline.

Fixed security window screens and emergency-release security screens remain different. An egress screen must preserve the required clear opening and release path in the applicable regulatory context. A security screen does not automatically provide fall prevention, ember protection or emergency egress.

## External shutters

The shutter family includes hinged, sliding, folding and fixed louvre panels, solid-panel and boarded shutters, and domestic roller shutters. A louvred shutter contains a frame, stiles, rails and repeated fixed or adjustable blades. Adjustable banks can include blade pivots and a visible or concealed tilt rod. Hinged leaves use latches when closed and holdbacks when open; these are opposite retained states and different load paths.

A roller shutter uses an articulated curtain travelling in vertical guides and coiling in a head box. The curtain can contain interlocking slats, end locks and a bottom rail. The head assembly contains end plates, an axle tube, bearing or motor, curtain attachments and an access cover. Manual control can use a strap reel or crank gearbox; powered products can use a tubular motor, wall switch, transmitter and selected sensors.

A roller shutter is not a roller garage door. The former commonly closes a window or pedestrian opening with compact interlocking slats and an enclosed roll. The latter closes a vehicle opening with a larger corrugated curtain, large guides, drum brackets and a garage-door counterbalance and safety system.

Generic shutter geometry carries no bushfire, cyclone, security, fire, impact or thermal claim. Those roles require product, size, support and installation evidence.

## Garage and large access-door systems

### Sectional doors

A sectional door contains multiple rigid horizontal panels hinged together. Rollers near the panel ends follow vertical tracks, curved transition tracks and overhead tracks. The door therefore changes shape through travel and cannot be represented accurately as one rotating slab.

The physical family includes:

- steel-skinned insulated and aluminium-framed panel constructions;
- vision inserts, end stiles and reinforcing struts;
- centre hinges, end roller hinges, top fixtures and bottom cable brackets;
- rollers, vertical tracks, track curves and horizontal tracks;
- flag brackets, jamb brackets, overhead hangers and rear stops; and
- counterbalance shafts, springs, bearings, drums, cables, pulleys and selected failure-restraint devices.

Track radius, panel heights, hinge offsets and top-fixture geometry determine the moving envelope. They must come from the selected system rather than from an attractive generic animation.

### Roller garage doors

A roller garage door uses a continuous or product-specific corrugated flexible curtain. It travels in paired guides and coils around an overhead drum. The drum or axle assembly commonly contains the counterbalance spring, even though the spring is hidden.

The side load path includes curtain edge, ordinary or wind-lock fittings, compatible guides, guide fixings, jamb supports and building structure. A user centre lock and side locking bars secure the closed door; they are not wind locks. Mounting brackets carry drum, curtain, spring and operator reactions and require verified supporting structure.

### Tilt doors

A tilt door moves one rigid panel outward and upward. The outward sweep can project beyond the facade and must be retained for vehicle, pedestrian and boundary coordination.

Jamb-fitting tilt doors use paired side pivot arms and springs without long overhead guide tracks. Track-fitting tilt doors use rollers or pivots travelling in overhead tracks. A tilt panel is the complete moving closure, not one section of a sectional door.

Applied cladding changes panel mass and centre of gravity. It is not merely a texture. Fitting family, spring selection, panel reinforcement and operator attachment must match the documented panel.

### Counterbalance is not the operator

The counterbalance reduces the force needed to move the door. It may use torsion springs and cable drums, extension springs and pulleys, a spring within a roller-door drum, side springs on a tilt fitting or an engineered counterweight system.

The powered operator moves and controls a correctly balanced door. A ceiling-rail operator uses a drive rail, chain or belt, trolley and articulated door arm. A roller-door operator couples at the drum or axle. The operator does not replace springs, tracks, guides, anchors or structural supports.

Lift cables belong to the counterbalance. Operator chains and belts belong to the drive transmission. Electrical cables belong to the power or control system. These remain separate route objects even when they occupy the same ceiling zone.

### Stored-energy boundary

Garage-door springs, cables, bottom brackets, drums, winding cones, counterweights and some pivots can contain or transmit dangerous stored energy. This ontology identifies those objects for drawing, coordination, inspection records and evidence links. It must not:

- calculate or suggest spring turns, tension or anchor changes;
- generate repair or release steps;
- imply that a spring is safe because its geometry is visible;
- infer a safe service state from an open or closed model position; or
- replace a competent installer, manufacturer procedure or site isolation.

Lifecycle state must distinguish at least unknown, supplied loose, installed without stored energy, tensioned in service, isolated and damaged where the available project process supports those states.

### Powered operators and protective devices

AS/NZS 60335.2.95:2024 provides the current public standard metadata for vertically moving garage-door drives. Standards Australia also records the 2020 edition as current during a transition, with the 2024 edition scheduled to supersede it on 29 November 2027 subject to regulator adoption. Product declaration, manufacture date, regulator position and project acceptance determine the applicable edition.

The operator graph separates motor and gearing, drive rail, chain or belt, trolley, door arm, supports, travel-position sensing, controller, radio receiver, remote transmitter, wall control, manual release, backup battery and network module.

A photoelectric beam monitors a defined line across the opening. A sensing edge travels on the leading door edge and detects contact or deformation. A normal flexible weather seal is not a sensing edge. Device presence in a model does not prove alignment, monitoring, reversal, force limitation or commissioning.

The inside manual release and outside keyed emergency release are separate objects. The external version adds a penetration, cable route, security issue and weather seal.

## Supports, wind path and weathering

Garage-door hardware must connect to actual structure. Plasterboard, cornice, trim, loose packers and ceiling lining are not assumed supports. The support interface records jamb and head members, overhead structure, brackets, anchors, embedment, edge distance, fixing centres and corrosion exposure.

Wind rating belongs to the complete size-and-installation configuration. For a sectional door the path can include panels, struts, end hardware, rollers, tracks, brackets, fixings and supports. For a roller door it can include curtain, wind locks, guides, guide fixings, drum brackets and supports. The drawing tool can reproduce a supplied schedule; it cannot invent a wind-rated configuration from nominal opening dimensions.

Bottom, jamb and head seals close local gaps. A floor threshold strip can give the bottom seal a compression land. Site falls, grated drains, stormwater paths and flood protection remain separate. No weather seal object should create a flood-resistance claim.

## SketchUp generation rules

- Use a stable local coordinate system: opening width, vertical height and inward backroom. Record exterior side and door handing separately.
- Generate the structural opening, product/support frame, moving closure and non-solid clearance envelopes as different groups or components.
- Preserve closed, intermediate and fully open transformations without duplicating the same instance into contradictory lifecycle states.
- Use reusable component definitions for repeated hinges, rollers, brackets, louvre blades, shutter slats and sectional panels.
- At normal detail, represent woven mesh, perforations, corrugations and tightly repeated slats with lightweight proxies or textures. Retain exact pitch, count, open area and profile references as data.
- Keep an optional high-detail mode for cutaways, fabrication coordination or selected product components.
- Treat sectional panels as an articulated chain following roller paths. Treat a tilt panel as one rigid body. Treat roller curtains and shutter curtains as flexible or articulated paths around a changing coil.
- Generate headroom, sideroom and backroom dimensions from documented product geometry. Do not substitute generic clearances.
- Keep moving, stored and service envelopes separate. Service access includes removable head-box covers, motor housings, spring zones, control boards and replaceable batteries.
- Draw beam lines, sensor fields and access zones as non-solid analytical objects that can be hidden independently.
- Attach every bracket, guide, track, spring anchor and operator hanger to a named support object. A fastener terminating in empty space or lining is incomplete.
- Store ratings, capacities, forces, thermal values, security classes and compliance outcomes in an evidence sidecar with source, edition, scope, size limits and configuration identity.
- Never infer capacity or compliance from geometry, colour, component name or inclusion in this ontology.

## Standards linked to the slice

The principal references are:

- AS/NZS 4505:2012, including Amendment 1 — garage doors and other large access doors;
- AS 2688:2017 — timber and composite doors;
- AS 4420.1 — methods of test for doorsets;
- AS 4145 Parts 1, 2 and 5 — locksets, mechanical locks and controlled door-closing devices;
- AS 5039.1:2023 with Amendment 1:2024 — security-screen classification and performance;
- AS 5039.2:2024 — security-screen installation;
- AS 5039.3:2023 — security-screen test methods; and
- AS/NZS 60335.2.95:2024 — safety requirements for drives for vertically moving garage doors for residential use.

AS/NZS 4505 was already present in the standards registry and has been updated with precise public metadata. Four additional supporting standards records were added. Only AS/NZS 4505 is the direct Housing Provisions reference in this slice; the other newly registered records are supporting sources. The audited direct Housing Provisions count therefore remains 64. The full registry now contains 209 standards and 512 sources.

Public metadata is not a substitute for licensed content. Before implementation of test criteria, force limits, fixing schedules, safety distances, wind classifications or installation tolerances, obtain the applicable licensed editions and selected-product instructions.

## Public sources used

- ABCB Housing Provisions clauses 2.2.4 and 13.4.4, related H8 material and referenced-document metadata.
- Standards Australia public catalogue entries for AS/NZS 4505, AS 5039 Parts 1 to 3 and AS/NZS 60335.2.95.
- Australian Government training-package units for installing windows and doors, manufacturing screen products, assembling and installing roller shutters, and manufacturing exterior louvre shutters.
- National Security Screen Association plain-English product guidance.
- Australian Garage Door Association public industry overview.
- B&D public product, Panelift and tilt-door installation manuals.
- Steel-Line public technical support and sectional-door installation material.
- Hume and Corinthian public entrance-door and door-construction information.
- WoodSolutions public door guidance.

Full URLs, access status, retrieval date and copyright-use notes are stored in `data/sources/source_registry.json` and generated into `exports/source_audit.csv`.

## Known gaps after this pass

- commercial rapid, high-speed, folding, sliding and hangar doors;
- rolling fire shutters, fire curtains and smoke curtains beyond the existing fire-door family;
- automatic pedestrian sliding, swinging and revolving doors;
- complete commercial smoke, acoustic, radiation-shielding and detention doorsets;
- loading-dock doors, dock levellers, seals, shelters and vehicle restraints;
- vehicle gates, gate operators, boom gates and full access-control hardware;
- frameless-glass pedestrian doors beyond the existing glazing and door objects;
- industrial shutters, grilles and counter doors;
- proprietary product libraries, certification records and configuration tables; and
- licensed engineering, testing, force, fixing, wind-pressure and installation tables.

The current slice is broad enough to support product-neutral SketchUp generators and schedules. Implementation still needs a second, selected-product layer rather than embedding guessed dimensions in the ontology.
