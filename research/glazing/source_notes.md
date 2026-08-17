# Glass and glazing source notes

## Scope of this slice

This slice identifies the physical glass products, manufactured make-ups, support components, seals and human-impact features that recur across windows, doors, shower screens, mirrors, splashbacks and larger glazed fields.

The catalogue deliberately separates glass from the window-and-door catalogue. The same toughened pane, laminated make-up, setting block or visibility marking can occur in many hosts. That reuse is essential for a building-wide drawing system.

The slice does not yet attempt glass engineering, balustrade design, pool barriers, fire-rated glazing systems, security glazing, blast glazing, photovoltaic glazing or every proprietary fixing. Structural glass fins and structural silicone are included as identifiable physical objects, but their dimensions and connections remain engineered inputs.

## Regulatory path in plain English

NCC Volume Two H1D8 routes glazing according to what the assembly is and where it is used. Housing Provisions Part 8.3 provides a limited house-scale path for supported glass and points outside its limits toward AS 1288. Part 8.4 deals with locations where people may strike the glass, including doors, panels beside doors, full-height glazing and wet areas.

The consequence for a model is simple: glass type cannot be selected from appearance alone. The host, pane size, support on every edge, wind action, human-impact location, door relationship, wet-area location and special application all affect the required path.

AS 1288:2021 is the NCC-referenced selection-and-installation standard. The public Standards Australia description identifies wind loading, human impact and special applications. AS/NZS 2208:2023 is recorded as a supporting current safety-glazing material test standard. A project still has to establish which edition and amendments its actual regulatory path requires; a newer product standard is not silently substituted into an older NCC call-up.

AS 4666:2012 covers insulating glass units. It originated as AS/NZS 4666:2012 and Amendment 1:2018 redesignated the Australian publication as AS 4666:2012. The registry keeps this history so imported schedules using either label resolve to one standard record.

## Pane, light, lite and assembly

A **pane** is one cut piece of glass. Its record carries size, thickness, processing, coatings, edgework, holes, notches and identification.

A **lite** is one pane occupying a defined position in an insulating glass unit. Outer, centre and inner lites may have different products and coatings. Their faces also create numbered coating surfaces.

A **light** is a glazed field bounded by frame members. It may be one pane, one IGU or a more complex make-up. A fixed light can be glazed directly into the main frame or held in a fixed sash.

A **glazing system** includes the pane or unit and everything that safely retains it: frame or channel, bead, gasket, blocks, tapes, bedding and sealant joints. Fully framed, partly framed, unframed and butt-jointed systems have different edge-support maps. A future tool must store the support condition of every glass edge instead of treating these labels as appearance styles.

## Glass product families

Monolithic glass is one solid thickness. Annealed glass has not received the strengthening treatment used for heat-strengthened or toughened products. Float glass describes the flat-glass manufacturing process and does not by itself prove final strength or safety classification.

Patterned or obscure glass changes vision through a textured or decorated surface. Body-tinted glass is coloured through the glass body. Reflective and low-emissivity products use coatings on a particular face. The coating is a separate object so it can keep its numbered surface when a pane is reversed or placed in a laminate or IGU.

Toughened safety glass and heat-strengthened glass are separate. Both are heat treated, but they have different strength and breakage behaviour. Heat-strengthened monolithic glass must not be called safety glass simply because it is stronger than annealed glass.

Laminated glass bonds two or more glass plies with an interlayer. The interlayer is physical material and can affect fragment retention, structural, acoustic, security, colour and ultraviolet performance. Laminated safety glass is the subset with suitable safety classification. Toughened laminated glass identifies another physical make-up, not a universal performance level.

Wired glass remains identifiable in existing buildings, but visible wire does not prove modern safety or fire performance. The actual product and evidence must be found.

## Insulating glass units

An IGU is a factory-sealed assembly, not merely two panes installed near one another. It contains:

- two or more glass lites;
- one or more sealed cavities;
- dry air, argon or another documented gas fill;
- a perimeter spacer establishing cavity width;
- desiccant associated with the spacer;
- a primary low-permeability seal;
- a secondary perimeter seal providing mechanical integrity and protection.

A double-glazed unit has two lites and one cavity. A triple-glazed unit has three lites and two cavities. “Double glazing” remains an ambiguous search phrase because people also use it for secondary glazing or two separate window layers.

AGWA's public IGU drainage guidance says the edge seal must be protected from prolonged moisture contact. This creates an important interface between the factory unit and the window frame: setting blocks carry the glass, location blocks maintain clearances, and frame drainage removes water without exposing or submerging the unit edge. An IGU spacer is not a glazing block and is not a window installation packer.

The primary seal and secondary seal are separate objects. They should not be confused with the site glazing sealant around the pane or with the frame-to-wall perimeter caulk.

## Retention and seal components

A glazing bead retains glass in a rebate. A glazing channel receives a glass edge. A gasket cushions and seals glass against hard framing. A wedge gasket locks a compatible dry-glazing system. Glazing tape or bedding compound provides another product-specific cushion and seal.

A setting block carries glass self-weight at designed points. A location block controls movement and edge clearance without being the main gravity support. Their material, hardness, width, position and relationship to drainage matter.

A glazing sealant joint seals glass to a frame or adjacent pane. Structural silicone is a distinct engineered bond that also transfers specified loads. A generic silicone bead must not be upgraded to structural silicone in the data model.

True glazing bars physically divide panes and support their edges. Applied colonial or Georgian bars can be decorative only, including bars fitted between IGU lites. This distinction changes pane count, IGU manufacture, quantities and load support.

## Human-impact components

A safety-glass identification mark is a small durable product mark used for traceability and classification. A visibility marking or manifestation is a much larger contrasting band, motif or dot pattern intended to make transparent glazing visible to people. They are separate physical markings with separate purposes.

A chair rail or crash rail can provide a visible and physical obstruction in front of a glazed field where the applicable detail permits. It is not automatically a substitute for safety glazing.

Door side panels, unframed glass doors, shower screens, mirrors and glass splashbacks are kept as explicit hosts because their edges, fixings, human-impact exposure and wet-area interfaces differ.

## CAD implications

For each glass pane or unit, a future tool should be able to retain:

- host assembly and opening location;
- pane outline, thickness and orientation;
- every supported, free or jointed edge;
- glass product and full make-up;
- numbered surfaces and coatings;
- edgework, holes and notches;
- setting and location blocks;
- beads, channels, gaskets, tapes and sealant joints;
- IGU spacer, cavities, gas, desiccant and edge seals where detailed modelling is needed;
- safety classification and identification mark;
- human-impact context and visibility marking;
- wind, thermal, solar and acoustic properties as documented inputs;
- source product, certificate and applicable regulatory path.

The tool should support levels of detail. A concept model may carry one overall glass envelope plus make-up metadata. A construction model may draw separate lites, cavities, coatings, blocks and seals. Both must refer to the same ontology objects so quantities and schedules remain consistent.

## Main sources

- ABCB, NCC Volume Two H1D8 and Housing Provisions Parts 8.1 to 8.4.
- Standards Australia public metadata for AS 1288:2021 and AS/NZS 2208:2023.
- Authorised public metadata for AS 4666:2012 and Amendment 1:2018 history.
- Australian Glass and Window Association glass-and-glazing guide, selecting-glass guidance and IGU drainage fact sheet.
- Viridian Glass public Australian glossary and processing explanations for generic product distinctions.

No licensed standard text is reproduced. Dimensions, tables and selection rules remain future authorised implementation inputs.
