# Basegrid construction-object research guide

## What this repository is building

Basegrid needs a vocabulary that tells a drawing tool what a real building object **is**, what job it performs, where it normally sits, and what it connects to. A name alone is not enough. For example, “wall” expands into plates, studs, opening members, noggings, bracing, linings, cladding, membranes, insulation, fixings and services. Each of those objects needs its own geometry and placement rules.

The long-term scope is most of the physical fabric and installed equipment found in an Australian house or similar small building. Current accepted data covers timber and cold-formed steel wall, floor and roof framing; structural-steel members, section profiles, connections and coatings; residential concrete slabs, footings and reinforcement; prepared fill and site drainage; termite-management components; residential masonry walls, piers and accessories; roof coverings, weathering details, gutters, overflow devices and downpipes; external wall cladding, cavities, membranes, joints, fixings and flashings; external windows and framed glazed doors; reusable glass and glazing parts; internal door leaves, frames, trim, swing, sliding, folding, latch, lock, stop and closer hardware; domestic internal wet-area substrates, waterproofing, drainage interfaces and finishes; internal wall linings, direct-fixed and suspended ceilings, boards, panels, supports, fixings, adhesives, joints, beads and trims; residential fire-resisting construction, passive fire-stopping, smoke and heat alarms and evacuation lighting; residential thermal insulation, condensation-control layers, air seals, roof-space and subfloor ventilation and room exhaust paths; house-scale stairs, ramps, barriers and handrails; H8 livable-housing construction; H4 dwelling facilities, rooflights, room-height boundaries and Class 1 sound-insulating walls; H7 pools, alpine doorways, waling-plate deck attachment, solid-fuel heating, bushfire-resistant junctions and private-shelter parts; domestic water, heated-water, rainwater, sanitary-plumbing, sanitary-drainage and onsite-wastewater systems; domestic electrical supply, metering, switchboards, earthing, wiring, outlets, lighting, communications, solar PV, batteries, EV charging, fixed security and temporary construction power; and residential refrigerated air conditioning, ducted air distribution, evaporative cooling, heat-recovery ventilation and hydronic heating.

This is an ontology and drawing foundation. It is not an engineering calculator, a building approval, or a substitute for the NCC, a licensed standard, a manufacturer’s design or professional judgement.

## The regulatory chain in plain English

The National Construction Code is a model code given legal effect through state and territory legislation. The project therefore records both a national NCC baseline and, later, the project jurisdiction and date. A future tool must not assume that a national provision has identical commencement, variation or transition rules everywhere.

Existing catalogue facts retain their stated **NCC 2022 Amendment 2** extraction baseline. At the current research date of 16 August 2026, NCC 2025 can be considered by jurisdictions from 1 May 2026, but adoption is independent. A project must therefore select its jurisdiction, approval pathway, relevant date and adopted edition rather than assuming one nationally operative edition.

The chain works roughly like this:

1. NCC Volume Two states the performance requirements for Class 1 and Class 10 buildings.
2. The ABCB Housing Provisions give prescriptive ways to satisfy many of those requirements.
3. An NCC or Housing Provisions clause may call up a particular edition of an Australian or Australian/New Zealand Standard.
4. The called-up edition matters. A later edition published by Standards Australia does not automatically replace the edition named by the NCC.
5. Project-specific conditions still control which pathway applies: building class, location, wind classification, bushfire exposure, site soil, corrosion environment, climate zone, geometry, spans, loads, materials and many other inputs.

The generated [standards map](../exports/ncc_housing_standards_map.md) records 64 technical documents directly referenced in the Housing Provisions schedule used for this baseline: 62 AS or AS/NZS documents, NASH Standard Part 2 and ISO 8336. Supporting documents called up elsewhere in the NCC, including Volume Three hydraulic-services standards, electrical, communications, refrigerant-safety, internal-door, internal-lining and broader mechanical-services standards, or useful public standards and handbooks are listed separately. The full registry currently contains 171 records.

## Why standards are not copied into the ontology

Most Australian Standards are copyrighted and accessed under licence. Basegrid stores their public metadata, the NCC clauses that cite them, and a short statement of why they matter. It does not copy their tables, figures, prescriptive text or proprietary definitions.

Object definitions in this repository are original plain-English summaries based on public sources. When a future tool needs a design value—such as a permitted span, tie-down capacity, fastener pattern or bracing capacity—that value must come from an authorised, versioned source and be evaluated against the project inputs. It must not be guessed from the object name.

## How an object becomes drawable

Every accepted object export carries four kinds of information:

- **Identity:** stable ID, preferred Australian name, carefully classified aliases and terms that are specifically not synonyms.
- **Meaning:** a plain-English definition, physical functions, material families and source-backed claims.
- **Placement:** geometry class, dimensional axes, repetition pattern, likely host, start and end conditions, opening behaviour and loadbearing role.
- **Connections:** directional relationships such as `part_of`, `supports`, `supported_by`, `bears_on`, `restrains`, `braces` and `connects_to`.

This lets a SketchUp tool ask useful questions. A wall-frame tool can repeat common studs between plates, interrupt that pattern at an opening, place full-height jamb studs beside it, add a lintel above it, place a sill trimmer below a window and populate shortened jack studs only in the remaining spaces. It can still leave sizes and fixing details unresolved until the correct design rules and inputs are available.

## The timber framing pilot

The timber pilot contains 39 objects and assemblies. The combined ontology now contains 2,331 objects across twenty-four disciplines with 5,683 deduplicated directional relationships.

### Wall framing

The wall frame is the assembly. Its current member set is:

- top plate and bottom plate;
- common stud, jamb stud and jack stud;
- structural lintel, sill trimmer and non-loadbearing head trimmer;
- nogging; and
- wall brace.

The important modelling distinction is **role**, not just shape. A common stud, jamb stud and jack stud may all be rectangular timber lengths, but they have different placement constraints and opening relationships. The same timber product could fulfil more than one of those roles.

The terminology also matters. In the Australian public sources used here, a jamb stud is the full-height member at an opening side, while a jack stud is a shortened stud above or below the opening. Some other material uses “jack stud” or “trimmer stud” differently. That conflict is kept in the unresolved review rather than silently merged.

### Floor framing

The floor frame currently contains bearers, repeated floor joists, trimming joists at openings, and solid blocking used to restrain joists. Flooring, stumps, posts, piers, ant caps, ledger members, I-joist accessories and proprietary floor systems are legitimate next objects, but they need their own sourced pass rather than being inferred from this pilot.

### Conventional roof framing

The conventional roof set contains ceiling joists, hanging beams, strutting beams, roof struts, underpurlins, collar ties, common rafters, hip rafters, jack rafters, the ridgeboard and roof battens.

Several visually similar beams have different jobs. A hanging beam supports ceiling joists. A strutting beam is positioned and designed to receive roof struts. A ridgeboard locates and joins rafter tops but is not automatically a structural ridge beam. Keeping those roles separate prevents a drawing tool from making unsafe substitutions.

### Nailplated roof trusses

The truss set contains the generic nailplated truss assembly, top and bottom chords, webs, web ties, nailplates, permanent truss bracing, roof battens and the hip-set variants truncated girder truss, hip truss, jack truss and creeper truss.

A truss should be treated as an engineered assembly. The plugin can place a fabricator-supplied truss definition and preserve its member identity, but it should not invent nailplate sizes, move webs or cut a chord. Those are design and fabrication decisions.

## Site, foundation and ground-interface objects

The second completed slice follows Housing Provisions Sections 3 and 4 from prepared ground into the building.

### Site preparation and fill

The site-civil set distinguishes the prepared building platform, controlled fill, rolled fill, a clean quarry-sand bedding layer and an unretained fill embankment. Controlled and rolled fill are not interchangeable labels: the Housing Provisions treat them as different placement and compaction categories. The ontology records their physical volumes and evidence fields but deliberately does not convert NCC compaction limits into universal drawing defaults.

“Foundation” is context-sensitive. In NCC footing diagrams it can mean the soil or ground that supports construction. In everyday speech it commonly means the constructed concrete system. The ontology therefore uses **foundation material** for the supporting substrate and separate IDs for slabs, strip footings and pad footings.

### Slabs and footings

The foundation set models the generic slab-on-ground assembly and three distinct arrangements:

- stiffened raft slab, with excavated edge and internal beams cast integrally with the slab;
- waffle raft slab, with a regular void-former and concrete-rib grid above a level base; and
- footing slab, supported by a separately poured footing arrangement.

Their parts include slab panels, edge beams, deepened edge beams, internal thickenings, edge rebates, waffle ribs, strip and stepped strip footings, pad footings, stumps, bulk piers, membranes and local seals.

A waffle pod is kept as a child of the broader slab void-former class. This matters to take-off: a tool can count a proprietary-sized pod grid without assuming every void former is made from expanded polystyrene or has the same geometry.

### Reinforcement and temporary works

The reinforcement assembly contains individual reinforcing bars, welded wire reinforcing fabric, trench mesh, ligatures, bar chairs, chair bases and tie wire. Each has different repetition and placement behaviour. “Reo” is useful trade language for search, but it does not tell the tool whether the user means a bar, sheet, strip or complete reinforcement layout.

Concrete is represented separately as a material. The slab, beam and footing IDs describe the construction role occupied by that material. Formwork is a temporary physical object and is included at a high level; shores, props, form ties and other temporary-work parts remain for a dedicated pass.

### Ground moisture, termite management and drainage

The under-slab damp-proofing membrane includes joint tape and penetration sleeves as separate seal objects. “Vapour barrier” is accepted only in the slab context supported by the Housing Provisions; it is not treated as an automatic synonym for every vapour-control layer in the building envelope.

A termite management system is an assembly, not a single magic barrier. Current components include sheet barrier, fine stainless mesh, graded stone barrier, chemical-treated zone, termite shield or ant cap, penetration collar, reticulation pipe and the durable system notice. A concrete slab can contribute to a system without being a complete system by itself.

The site-drainage set contains the subsoil drainage assembly, subsoil drain, silt pit, sump, underground stormwater drain, soaker well and stormwater tank. These records describe physical identity and connectivity. They do not decide whether a subsoil drain is safe on reactive soil or where a soaker well is permitted; those remain project and authority decisions.

## Masonry objects

The masonry slice follows Housing Provisions Section 5 from complete wall arrangements down to the parts a drawing tool must place. Its 54 objects cover veneer, cavity, double-brick, single-leaf, reverse-veneer and reinforced wall arrangements; isolated, subfloor and engaged piers; leaves, cavities, courses, units and mortar joints; ties, fixings, lintels and tie-down parts; and movement and moisture-control components.

### Start with the wall arrangement

“Masonry wall” is not enough information to generate useful geometry. A masonry veneer has one outer leaf tied to a separate structural frame. A cavity masonry wall has inner and outer masonry leaves connected across a cavity. A single-leaf wall has only one masonry leaf. Reverse veneer puts the masonry on the room side of an insulated framed envelope. Reinforced masonry adds grouted cores or qualifying joint reinforcement and follows a different design pathway.

These are not cosmetic options. They change the load path, support width, number and position of leaves, tie role, cavity geometry, flashing route and opening details. The plugin should therefore ask for or infer the arrangement before laying any units.

### Units, courses and joints

The catalogue separates material from unit form. Clay brick, calcium-silicate brick, concrete brick and concrete block describe material and common product family. Solid, cored, hollow and horizontally cored describe draw-relevant internal geometry and bedding. An instance can carry both classifications—for example, “clay brick” and “cored unit”—without creating a separate canonical class for every possible combination.

Units repeat in horizontal courses. Bed joints run horizontally between courses. Perpends are the vertical mortar joints between adjacent units in one course. A weephole is not a special name for every perpend: it is a deliberate open drainage gap at a selected perpend location, normally above flashing or at a cavity base.

### Ties, openings and movement

A veneer tie connects masonry to a structural backing. A cavity tie connects two masonry leaves. Both are wall ties, but their hosts and force paths differ. Their duty, material, corrosion resistance, length, embedment, spacing and compatible fixing remain explicit attributes rather than universal defaults.

Steel lintels are separated into the generic lintel role and angle and flat-bar forms. The lintel supports masonry over the opening; head flashing above or around it performs moisture drainage and must not be mistaken for structural support.

Vertical articulation joints divide brittle masonry into panels that can move. The physical joint contains a gap, compressible filler or backer rod and a flexible face seal. “Control joint” remains unresolved shorthand because the Housing Provisions also use control-joint language at some dissimilar-material junctions.

### Damp control and drainage

A damp-proof course interrupts capillary moisture. A flashing collects water and directs it outward. They can sometimes be made from the same compliant sheet, but their geometry and functions differ, so the ontology keeps them as separate roles. Sill and head flashings are specialised flashing objects, while weepholes are their drainage outlets.

The wall cavity is also a physical object, even though it is empty space. A useful model must know its clear width, path, opening details, ties and obstructions. Modelling only the solid leaves would hide one of the wall’s main moisture-management components.

Reinforced masonry is included for whole-building discovery, but Section 5 explicitly does not provide its general prescriptive design route. The ontology can draw selected hollow cores, core fill and bars only from a project design; it does not invent their layout.

### Advanced masonry, AAC, stone, earth and render

The expanded masonry family now contains 176 objects. Purpose-made closure, corner, jamb, sill, coping, bond-beam, lintel, cleanout, open-end and screen units remain distinct from ordinary units and rough site cuts. Running, stack, header, soldier and brick-on-edge bonds are placement patterns: they control repeated-instance transformations and joint locations rather than changing the unit material.

Reinforced masonry separates the shaped block from the completed member. A bond-beam unit is permanent casing; the reinforced masonry bond beam also contains scheduled steel and grout. Grout material, a filled core, full or partial grouting, cleanout access, grout stops and bar positioners are separate objects so the model can represent construction sequence without inventing an engineering design.

The connector family now includes built-in and remedial ties, cramps, sliding anchors, bed-joint tying mesh and wall-to-wall connectors. Shelf angles, brackets, anchors and shims form a support assembly and do not become lintels merely because an angle section is used. Cavity closers, cavity fire barriers, weepholes and proprietary weep vents also retain different physical jobs.

AAC blockwork and reinforced AAC panels use different generators. Blocks use courses, thin-bed joints and purpose-made lintel, sill, closure or U-section units. Reinforced panels contain a factory-cast reinforcement cage and follow a panel bearing, joint and fixing system. Existing AAC cladding panels and fixings are reused across disciplines rather than copied.

Stone is divided by construction method: solid masonry, tied veneer, adhered veneer and mechanically anchored facade. The method determines whether the tool needs a loadbearing thickness, ties and a cavity, an adhesive bed, or designed support and restraint anchors. Ashlar, rubble, quoins, copings, arches, voussoirs and keystones then describe unit form or role within that construction.

Earth construction separates moulded mud brick, compressed earth block and monolithic rammed-earth lifts. Building earth is a selected and tested mix, not arbitrary site spoil. Formwork is temporary, while each compacted lift is permanent. Plinths, capillary breaks, roof and opening weathering remain visible because moisture management is part of the system geometry.

Solid render is a layered plaster system rather than a decorative texture-coating film. Preparation, bonding, dubbing, base, float and finish coats are separate optional layers. Embedded mesh and mechanically fixed metal lath are different carriers, and corner, casing, movement, drip and screed beads are named by their edge role. HB 161:2005 is retained only as a withdrawn historical source, not a current compliance standard.

The detailed terminology, regulatory boundary, source map and generator rules are recorded in `research/masonry/source_notes.md`.

## Cold-formed steel framing objects

NCC Volume Two H1D6 points residential steel framing to NASH Standard Parts 1 and 2, AS 4100 or AS/NZS 4600. The steel-framing slice concentrates on light-gauge, cold-formed residential systems. Hot-rolled and hollow structural sections, base plates and welded or bolted connections are handled by the separate structural-steel slice below.

The steel-framing catalogue contains 47 objects covering complete wall, floor and roof systems; studs, tracks, opening members and bracing; floor joists, bearers and cassettes; rafters, battens and engineered roof-truss parts; service holes and grommets; moisture-isolation layers; and common screws, rivets, clinches, brackets and anchors.

### Role before profile

Australian light-steel manufacturers optimise many proprietary section shapes. The stable concept is therefore the member role—stud, track, joist, bearer, rafter, batten, chord or web—plus its scheduled capacity and connections. C-section and top-hat remain separate shape objects that can classify those roles. A C-section is not automatically a stud, and a top-hat is not automatically a roof batten.

This matters to a generator. The plugin can lay out repeated studs or joists and assign the selected supplier's section definition. It must not invent a generic flange, lip, embossment or service-hole profile and assume that all frame systems share it.

### Prefabricated assemblies and connections

Wall panels, floor cassettes and steel roof trusses are often prefabricated. Their factory joints—screws, rivets, clinches or proprietary overlaps—are part of the supplied assembly. A floor “ladder frame” is treated as one cassette layout, not an exact name for every prefabricated floor module.

A steel roof truss remains an engineered object. Chords, webs and node connections are identified for selection and inspection, but their layout is not regenerated from a roof outline. The same rule used for nailplated timber trusses applies: preserve the fabricator's definition.

### Services, durability and proprietary language

Factory-punched service holes are physical openings. A grommet or bush is a separate fitting that protects cable insulation or isolates copper pipe. The model can route a service through an existing approved opening; it cannot create a new hole simply because a pipe or cable crosses a stud.

Bottom-track separation and local isolation membranes are separate durability components. BlueScope TB-34 supports their physical purpose, but product-warranty guidance is not rewritten as a universal NCC requirement.

“Tek screw” and “Dynabolt” are retained only as proprietary or genericised search terms. The canonical objects are self-drilling screw and masonry anchor, with product, substrate, coating, embedment and connection schedule left explicit.

## Structural steel objects

Housing Provisions Part 6.3 provides a limited prescriptive path for specified structural-steel bearers, strutting beams, lintels and columns. NCC Volume Two H1D6 also identifies AS 4100 as a broader structural-steel framing pathway. The structural-steel catalogue uses both as regulatory context without treating the Part 6.3 tables as a universal steel design system.

The slice contains 47 objects. It covers the Part 6.3 member roles, common Australian open and hollow section families, bolted and welded connection assemblies, connection plates and cleats, base and splice parts, bolt and service openings, and paint and hot-dip-galvanized coating systems.

### Role before section

A member role describes its job in the building. A beam spans, a bearer supports floor framing, a strutting beam receives roof-strut reactions, a lintel bridges an opening, a column carries reactions down, and a brace stabilises the frame.

A section describes the cross-sectional product used to make that member. Current families include UB, UC, PFC, TFB, EA, UA, WB, WC, RHS, SHS, CHS, beam tee, column tee, plate and flat bar. The plugin must keep both classifications. “Draw a column” does not supply enough information to select a UC, and “place a UB” does not say whether it is serving as a beam, bearer, lintel or column.

This also prevents loose terms such as “I-beam” and “RSJ” from creating false certainty. They remain search prompts until an Australian section designation, verified dimensions or existing-building record resolves the actual profile.

### Connection assemblies and their parts

A connection is not a coloured dot where model lines meet. It can contain bolts, nuts, washers, holes, weld runs, end plates, web side plates, angle cleats, gussets, stiffeners and bearing plates. A member splice is a separate assembly joining two member segments. A column base connection includes the base plate, column weld or attachment, anchor bolts and the support interface.

Keeping those parts separate supports fabrication-level geometry and quantity take-off without pretending to design the connection. A future tool can place a supplied connection template, preserve hole coordinates and count hardware. It must not invent plate thicknesses, bolt groups, weld sizes or anchor embedment.

### Openings and protection

Bolt holes and member web penetrations are modelled as physical negative space. A bolt hole belongs to a connection group. A web penetration belongs to an approved member-opening detail. If a duct or pipe crosses a beam in the model, that clash is a coordination problem—not permission to cut steel.

Protective paint and hot-dip galvanizing are also objects rather than colour labels. Paint has surface preparation, coat sequence and repair zones. Post-fabrication galvanizing affects vent and drain holes, masked faces and repair. The selected exposure, system and fabrication documentation must control the generated attributes.

The linked product, welding, fastener and fabrication standards are supporting technical documents unless the NCC baseline explicitly calls them up. Their metadata helps route future authorised rule work; the repository does not copy their licensed content.

## Roof covering and roof drainage objects

NCC Volume Two H1D7 and Housing Provisions Section 7 expose several distinct roof-covering systems. Metal sheet, plastic sheet, concrete or terracotta tile, and non-interlocking slate or shingle roofs do not share one generic drawing rule. The two completed roof slices contain 98 objects: 59 covering and weathering objects plus 39 above-ground drainage objects.

### Covering systems and their parts

The roof-covering catalogue begins with complete assemblies, then separates the sheets, tiles, slates or shingles from their joints, fixings, underlays, cappings and flashings.

A metal sheet roof resolves its profile and fixing method. Corrugated, trapezoidal and concealed-fixed sheets have distinct geometry. Pierced-fixed roofing uses fasteners through the sheet with compatible sealing washers. Concealed-fixed roofing engages hidden clips. Side laps, end laps, side-lap fasteners, rib end stops and infill strips remain separate parts because they affect set-out, quantities and weathering.

A tiled roof resolves material, tile form, course set-out and fixing method. Concrete and terracotta tiles can be classified separately from interlocking form. Ridge, hip, barge and hip-starter tiles are accessories with different placement. Tile clouts, screws and seven clip roles are separate fixing objects; a tool must not infer a wind-fixing schedule merely from the roof outline.

Mortar bedding and flexible pointing are different components around ridge and hip tiles. Bedding seats and supports the capping tile; pointing finishes and seals its exposed edges. Mechanical fixing remains another object. This separation makes quantities, maintenance and defect recording possible.

Roof sarking is a pliable layer with its own laps, tape, penetrations and drainage direction. “Sarking”, “underlay”, “vapour barrier” and “reflective insulation” are not collapsed into one synonym because the installed material may perform different water, air, vapour and thermal functions.

### Flashings, cappings and penetrations

Flashings bridge or drain junctions and penetrations. Cappings usually cover an exposed ridge, hip, barge or parapet edge. Some folded metal pieces perform both roles, so the ontology records the actual host, cross-section and water path instead of trusting the short name alone.

The current set includes apron, step, counter, change-of-pitch, parapet, penetration-collar, soaker-tray and chimney flashing arrangements. A roof penetration opening is also a distinct object. Future drawing tools should coordinate the opening, support or trimmer, penetrating item, flashing and surrounding covering as a complete supplied or designed detail. Cutting a hole and adding sealant is not treated as a finished penetration.

### Gutters, overflow and downpipes

The roof-drainage assembly connects the covering edge or roof low point to an underground stormwater drain, tank inlet, lower-roof spreader or other documented discharge. It includes eaves, box, valley and soaker gutters; stop ends, corners, joins, brackets and expansion details; outlets, sumps and rainheads; overflow components; and complete downpipe routes.

Eaves-gutter overflow is explicit geometry. The catalogue includes repeated front-face slots, a controlled back gap maintained by spacers or compatible brackets, a controlled front bead, end-stop and front-face weirs, an inverted overflow nozzle and a rainhead overflow opening. The tool should preserve these openings as required voids and warn when fascia, packing, sealant or gutter guards block them.

A box gutter is an internal assembly with its own sole, depth, fall, freeboard, sump or outlet and independent overflow path. Housing Provisions Part 7.4 directs box gutters to AS/NZS 3500.3; they must not inherit simplified eaves-gutter assumptions. A box-gutter sump is an internal depressed collector. A rainhead is external and allows surcharge to be visible outside. They are not interchangeable merely because both are box-shaped.

The downpipe set includes round and rectangular pipes, bends, a two-bend offset assembly, joiners, clips, shoes, lower-roof spreaders and stormwater adaptors. Above-ground downpipe and buried stormwater drain remain separate objects, with the adaptor representing their physical transition.

These records identify what a system contains; they do not size it. Catchment, design rainfall, gutter and outlet capacity, overflow capacity, downpipe layout, blockage scenario and lawful discharge still require the applicable project-specific hydraulic path.

## External wall cladding objects

The cladding slice contains 71 objects. Housing Provisions Part 7.5 covers selected timber, fibre-cement, exterior-hardboard and structural-plywood wall cladding. NCC Volume Two H1D7 separately routes solid metal sheet wall cladding and reinforced AAC panel systems. Other facade materials need their own evidence path rather than being squeezed into these families.

### Wall arrangement before product

A direct-fixed wall and a drained-cavity wall are different assemblies. The first places cladding close to its frame or substrate. The second uses battens or furring to create a clear drainage space outside the inner weather barrier. This distinction is separate from whether fixings are visible through the cladding face.

The cavity is modelled as a physical void with depth, drainage, ventilation, closures, flashings and obstructions. Vertical cavity battens preserve drainage between them. Horizontal structural battens supporting vertical cladding need a documented route around, behind or through them; a drained or castellated horizontal batten is therefore a separate object.

### Board, sheet and panel geometry

Board profiles include splayed or bevel-back, rebated bevel-back, rusticated, shiplap and tongue-and-groove forms. The edge geometry determines effective cover, course direction, engagement and fixing position. The same visible weatherboard form can be timber, fibre cement or exterior hardboard, so “weatherboard” alone is not enough to select cutting, fixing or finishing rules.

The sheet families are fibre cement, exterior hardboard, structural plywood and solid profiled metal. Plywood cladding is not automatically structural bracing: it receives a bracing role only when its separate fixing and structural schedule qualifies it.

Solid metal wall sheets include corrugated, trapezoidal and concealed-fixed profiles. ABCB guidance distinguishes this construction from laminated or composite metal panels, which are not mapped automatically to the AS 1562.1 pathway.

Reinforced AAC external panels, their brackets or fixings, joints, coatings and flashings form a supplied system. They remain distinct from unreinforced AAC blocks. The plugin can place a selected panel definition and its documented fixings; it must not invent reinforcement or approve panel cuts.

### Layers, joints and openings

The wall weather barrier is separate from the cladding. Its water, air and vapour classifications remain explicit, so the words wall wrap, sarking and vapour barrier do not silently become synonyms.

Board laps, shiplap joints, tongue-and-groove joints, board butt joints and expressed sheet joints each have different geometry. A movement joint can contain a clear gap, independent support, flashing, backing strip, bond-breaker tape, flexible sealant and a cover or H-profile. Drawing only the visible H-profile would hide the working joint.

The opening-flashing assembly contains head, sill and jamb flashings tied to the frame, reveal, membrane and cladding. Corner flashing is the concealed water-control piece; corner trim is the visible edge finish. A service penetration likewise needs a complete flashing connection to both the cladding face and inner weather layer, not only perimeter sealant.

The slice also covers cladding base flashings and cavity vent or closure strips, fibre-cement soffit sheets and trimmers, nails, screws, rivets, concealed clips, joiners and product-specific cut-edge treatment roles. Their exact dimensions and layouts still come from the applicable NCC path, authorised standard, project design and selected manufacturer system.

## Windows, glazed doors and glazing objects

The opening research is split into two linked disciplines. The windows-and-doors catalogue contains 82 product, frame, panel, hardware, installation, screen and weatherseal objects. The glazing catalogue contains 58 reusable glass, manufactured-unit, support, seal and human-impact objects. Together they prevent a complete window from being confused with its bare glass or with the structural wall opening.

### Complete product before loose profiles

NCC Volume Two H1D8 routes covered external windows and framed glazed external doors through AS 2047 and Housing Provisions Part 8.2. The complete product carries the relevant wind, water, air, operation and energy properties. A visually similar collection of frame extrusions, glass and hardware is not automatically the tested product.

The product hierarchy includes fixed, awning, casement, hopper, sliding, hung, pivot and adjustable-louvre windows, plus framed hinged, French, bifold and sliding glazed doors. Their perimeter frames contain heads, jambs, sills or thresholds, mullions and transoms. Moving window sashes and door panels contain their own rails and stiles. Hardware, tracks, rollers, hinges, balances, locks and handles are separate parts because they have different placement, movement and replacement data.

Installation remains another layer. The model separates the factory frame from the rough wall opening, head settlement gap, nailing fin or fixing lugs, frame packers, frame fixings, opening flashings, perimeter backer rod and sealant. Packing and drainage are coordinated rather than hidden inside a single window component.

An insect flyscreen, fall-protection screen and opening restrictor are not interchangeable. The intended role and product evidence must be known. A child-resistant release is also a real fitting with an explicit relationship to the protected opening.

### Glass make-up before appearance

A pane is one cut piece of glass. A lite is a pane's position within an IGU. A light is a glazed field bounded by framing. These objects may occupy the same visible rectangle but belong to different hierarchy levels.

The glass catalogue distinguishes annealed, float, patterned, toughened safety, heat-strengthened, laminated safety, toughened-laminated, wired, organic-coated, body-tinted and reflective products. Low-e and ceramic-frit coatings remain separate layers on nominated surfaces. This is important because glass colour or strength alone does not establish safety classification, coating position or regulatory suitability.

Laminated glass includes separate glass plies and a physical interlayer. An insulating glass unit includes lites, sealed cavities, gas fill, spacer, desiccant, primary seal and secondary seal. Double and triple glazing are subtypes of this factory-made assembly. Two panes placed separately in one opening are not silently mapped to an IGU.

### Support, sealing and human impact

Fully framed, partly framed, unframed and butt-jointed glazing have different edge-support maps. A future tool must retain the condition of each edge and must not infer glass thickness or fittings from the opening outline.

Beads and channels retain the glass. Gaskets, wedges, tapes and bedding seals cushion or seal it. Setting blocks carry glass self-weight; location blocks maintain clearance. Those components differ from window installation packers and from the IGU spacer that creates the sealed cavity.

A normal glazing sealant joint seals an interface. Structural silicone is an engineered load-transferring bond and remains a separate object. True glazing bars support separate pane edges; applied colonial bars may be decoration only.

Safety-glass identification and visibility marking are also different. The small permanent product mark supports traceability. The larger contrasting band or motif makes a transparent door or panel conspicuous to people. Door side panels, unframed glass doors, shower screens, mirrors and splashbacks retain their own host objects because their edges, hardware and impact exposure differ.

The detailed regulatory paths, terminology issues and modelling fields are recorded in `research/windows_doors/source_notes.md` and `research/glazing/source_notes.md`.

## Wet-area waterproofing objects

The domestic wet-area catalogue contains 84 objects. It covers complete shower, bath, floor and wall assemblies; concrete and sheet substrates; preparation; liquid and sheet membranes; bond breakers and reinforcement; flashings and waterstops; point and linear drainage interfaces; penetrations; shower bases and hobs; tiles and installation materials; and non-tile sheet or stainless-steel finishes.

### Complete system before coloured membrane

NCC Volume Two Part H4 provides two Deemed-to-Satisfy routes: the complete Housing Provisions Part 10.2 route, or its nominated general clauses together with AS 3740:2021. The selected route is project data. A tool must not take one convenient detail from each route and present the result as a single verified system.

A waterproofing system includes compatible construction, prepared substrate, membrane or other waterproof surface, junction and penetration treatments, flashings, drain connection and terminations. The membrane is only one layer. Likewise, tiles, grout and visible silicone are finish components; they are not substitutes for the concealed waterproofing assembly.

The Housing Provisions distinguish **waterproof** from **water resistant**. The catalogue therefore stores protected spatial extents, required performance and selected physical products separately. This lets a future room tool calculate fixture-based protection zones without painting one imagined membrane over every surface.

### Substrate-to-finish layer order

A tiled floor may contain structure, substrate, preparation and primer, bond breakers, membrane, fall-forming screed or tile bed, adhesive, tile, grout and selected flexible joints. The order is not universal. The wet-area terms internal and external membrane can describe position above or below the tile bed, not indoor or outdoor location. Structural levels, screed levels, membrane levels, drain levels and finished tile levels must remain distinct.

Floor and wall substrates include concrete, cement render, compressed fibre-cement floor sheet, fibre-cement wall sheet and water-resistant plasterboard. Sheet joints, backing, fixings and cut-edge treatment matter. The plugin should select these from a verified product system rather than interpreting cement sheet or wet-area board as an exact specification.

### Shower edges, drainage and junctions

Enclosed or unenclosed, raised hob or level threshold, finished stepdown or flat entry, and preformed base or in-situ tray are independent choices. Walk-in shower is therefore not enough information to draw one. The screen opening, waterstop and point or linear drainage arrangement also need to be known.

A shower hob, waterstop angle, doorway threshold and tile trim can align visually but do different work. A drain likewise contains a visible grate, concealed body, flange or puddle flange, riser and membrane connection. These are separate objects so the drawing can expose coordination mistakes rather than hiding them inside a generic bathroom component.

Pipework, mixers, tap bodies, fasteners, baths, shower bases and wall niches interrupt protected surfaces. Their collars, flanges, seals, upturns and support details remain explicit interfaces. Corners and changes of plane retain bond-breaker and reinforcement roles even when one proprietary tape performs both.

The detailed regulatory paths, layer alternatives, terminology conflicts and modelling fields are recorded in `research/waterproofing/source_notes.md`.

## Residential fire- and smoke-safety objects

The fire-safety catalogue contains 115 objects. It follows NCC Volume Two Part H3 and Housing Provisions Parts 9.2 to 9.5 through fire-resisting external walls, separating walls and floors, garage-top dwellings, protected openings, passive fire-stopping, domestic smoke and heat alarms and Class 1b evacuation lighting.

### Performance belongs to the complete construction

A fire-resistance level (FRL) is performance metadata for a tested or assessed assembly. It is not a physical layer and cannot be drawn as one. The model instead records the complete wall, floor, ceiling or protected-opening assembly and its physical parts: framing or masonry, linings, cavities, insulation, joints, fixings, edge details, penetrations and connections to adjoining construction.

The same caution applies to loose descriptions. Non-combustible material is not automatically a fire-resisting system. Red or pink plasterboard is not automatically suitable for every fire-rated wall. A self-closing solid-core door used by a particular Housing Provisions opening-protection path is not the same object as a tested fire-resistant doorset. Product identity, assembly identity, evidence and applicable regulatory path must remain separate.

### Continuity at boundaries and openings

External-wall protection depends partly on measured distance to a fire-source feature. The distance and resulting regulatory zone are constraints, not building objects. When protection is required, the tool must model the actual fire-resisting wall and its continuity from the supporting construction to the roof or eaves condition.

Separating construction likewise depends on continuity. The catalogue includes masonry and lightweight separating walls, separating floors, protected horizontal projections, garage-top floor and ceiling systems, wall-to-roof junctions, roof-space continuation, mineral-fibre packing and non-combustible roof-space linings. Windows and doors are represented through complete protected-opening assemblies with frames, panels or glazing, closers, seals, anchors and perimeter interfaces.

### Fire-stopping is an installed system

A hole plus a tube of sealant is not a firestop system. The physical catalogue contains service penetrations and linear joints together with collars, wrap strips, bandages, sealants, mortars, coated batts or boards, pillows, plugs, putty pads, sleeves, backing material, cable coatings, joint covers, labels and fixings. Pipe material and size, service movement, opening construction, annular space, backing depth, product arrangement and tested orientation are system inputs rather than guessed defaults.

Electrical boxes, bundles of services, control or movement joints and adjacent service supports need their own geometry. A product may be part of several tested systems, but the plugin must preserve the selected system evidence and must not infer that a named collar, sealant or board is universally interchangeable.

### Domestic alarm assemblies

Smoke alarm, smoke detector and complete detection system are not automatic synonyms. The residential catalogue models self-contained domestic smoke alarms, photoelectric and ionisation sensing variants, heat alarms where a jurisdiction-specific path uses them, mains-powered and battery-powered variants, alarm heads, bases, sensor chambers, sounders, status indicators, test or hush controls, primary and backup batteries, mains connectors, hardwired interconnect cable and optional radio modules.

Alarm placement zones, dead-air-space exclusions and radio communication links are spatial rules or relationships, not fake solids. Interconnection still needs explicit topology so the model can report which alarms must sound together. Class 1b evacuation lights, accessible strobes and vibration pads, relays and durable notices are separate physical objects with their own hosts and power or control relationships.

The detailed regulatory routes, terminology hazards and draw-versus-constraint boundary are recorded in `research/fire_safety/source_notes.md`.

## Thermal, condensation-control and ventilation objects

The thermal and condensation catalogue contains 134 objects. It follows NCC Volume Two Part H6 and Housing Provisions Parts 13.2 and 13.4, together with the related room, roof-space and subfloor ventilation paths in Parts 10.6, 10.8 and 6.2.

### Products, layers and performance are different things

Insulation material, supplied product form and placement role are stored separately. Glass mineral wool and PIR are material families; batt and rigid board are forms; ceiling, wall cavity, continuous wall layer and underfloor are placement roles. This lets one drawing tool reuse a real product without pretending that every material can be installed in every shape or location.

R-value, Total R-value, airtightness, vapour permeance, thermal bridging and condensation risk are metadata or analysis, not physical solids. The catalogue draws the products and assemblies that create the result: batts, boards, airspaces, supports, framing, thermal-break strips, membranes, tapes, fasteners, seals, openings and ducts.

### Continuity is explicit

The thermal envelope is a connected role across roofs or ceilings, external walls, openings, floors and slab edges. Small parts matter. The catalogue includes insulation infills around framing, perimeter pieces at openings, support netting, straps, retaining wire, clips, wind-wash facing and eaves insulation stops.

Thermal bridges are conditions through real metal framing, brackets and fasteners. Their physical mitigation can use continuous insulation, strips, pads, thermally broken brackets or spacer battens. A drawn strip does not itself prove the adjusted assembly performance; the conductive path, penetrations, coverage and evidence remain visible.

### Membrane roles stay independent

Pliable membrane is a product family. Water control, air control, vapour control and reflective performance are separate roles or classifications. One membrane can perform more than one evidenced role, but the tool must not assume every product called wrap, foil, sarking or breathable membrane performs all of them.

The model records layer order and face orientation as well as laps, seam and flashing tapes, double-sided tape, penetration patches, pipe sleeves, fasteners, cap washers and compatible sealants. Reflective performance also depends on a real adjacent airspace rather than a foil-coloured surface alone.

### Airflow belongs to connected spaces

Roof-space ventilation, subfloor ventilation and room exhaust are three separate systems. Their vents, openings, grilles, mesh, baffles, ducts, dampers and terminals are drawable objects. Net free open area and airflow are properties or calculations attached to those objects and the spaces they connect.

Room exhaust retains a complete path from a bathroom, laundry, kitchen or venting dryer through the fan and duct to an outdoor terminal. A fan discharging into a roof space is therefore visible as a broken path. Make-up air is represented by a deliberate opening, transfer grille or door undercut, not by assuming uncontrolled envelope leakage. This also exposes the conflict between an undercut used for transfer air and a door-bottom seal intended to close the same gap.

The detailed regulatory paths, product and role distinctions, terminology hazards and CAD fields are recorded in `research/thermal_condensation/source_notes.md`.

## Safe-movement, stair, ramp, barrier and handrail objects

The safe-movement catalogue contains 157 physical objects. It follows NCC Volume Two Part H5 and Housing Provisions Parts 11.2 and 11.3, with the related external-access construction in alpine areas from Part 12.2.

### Stair geometry and stair construction stay separate

A stairway can contain flights, landings, barriers and handrails. A flight contains physical treads and may contain riser closures. Rise and going are dimensions; they are not extra boards. The catalogue distinguishes straight, turning, winder, spiral, curved, open-riser, closed-riser and external stairs, together with timber, steel, precast, pan and grating tread construction.

Stringers are stored by their real form: cut or housed timber strings, steel plates or sections and central spine assemblies. Brackets, cleats, wedges, glue blocks, bearings and top or bottom connections remain visible. Floating is treated as an appearance, not a structural system.

Tread bodies, walking finishes, formed nosings, applied carrier profiles, slip inserts and full-tread safety plates are separate physical objects. Slip classification is evidence metadata for the tested surface under stated conditions, not geometry inferred from a rough-looking material.

### Barriers belong to hazard edges and host structure

The catalogue includes wall, post-and-rail, baluster, panel, mesh, wire-rope and glass barriers, plus gates, height transitions and supplementary window rails. Every system attaches to a trafficable hazard edge and to real supporting construction. Fall height, barrier height, opening limits and climbability are measurements or rule results applied to that geometry.

Post bases, side-mount brackets, anchors, backing, packers, grout and waterproofing parts are explicit. Tensioned-wire systems include rope, bushes, guides, turnbuckles, swaged or mechanical terminals, ferrules, thimbles, eyes, saddles, pulleys and lock-offs. Installed tension remains a state, not a fitting.

Frameless glass still has supports. Structural and infill panels are connected through spigots, continuous channels, clamps or standoffs, with wedges, gaskets, setting blocks, anchors, drainage and host structure retained. A glass-edge cap rail and an offset graspable handrail are different parts.

### Handrail and accessibility roles are not assumed

A graspable handrail differs from a barrier top rail. Wall- and post-mounted handrail systems include their brackets, backing, anchors, spacers, joins, bends, returns and caps. A rail can perform more than one role only when the selected construction supports both.

The general Housing Provisions ramp is not automatically an accessible ramp designed to AS 1428.1. Complete accessible paths, tactile indicators, installed grabrails, lifts, platform lifts and fixed access ladders now exist at capstone drawing level, but AS 1428, AS 1657 and commercial egress compliance logic remains separate from the object ontology.

The detailed regulatory path, terminology hazards, Australian Standards roles, exclusions and CAD fields are recorded in `research/safe_movement_access/source_notes.md`.

## H8 livable-housing objects

The livable-housing catalogue contains 114 physical objects. It follows NCC Volume Two Part H8 and the six-part ABCB Standard for Livable Housing Design through dwelling access, the nominated entrance, internal doors and corridors, an entry-level sanitary compartment, a hobless step-free shower and concealed wall reinforcement for future grabrails.

### Applicability belongs to the project

H8 is not safely described as an Australia-wide requirement without qualification. The public sources captured here show different commencement arrangements and local rules, including disapplication in the cited NSW and Western Australian paths. NCC 2025 adoption is also occurring independently by jurisdiction.

A future tool must ask for jurisdiction, approval pathway and relevant date before reporting compliance. The same physical path, threshold, door, toilet or backing object can still be drawn voluntarily where H8 is not mandatory.

### Route and entrance are connected construction

The step-free route starts from a permitted allotment, attached-garage, carport or incorporated-parking origin and ends at one nominated entrance. It is stored as ordered physical segments: concrete or unit-paved path, raised boardwalk, ramp or step ramp, landing, gate and parking transition. Slopes, crossfalls, clear widths and aggregate ramp length are calculated from those objects.

The entrance includes the doorset, outside arrival landing, inside and outside levels, threshold profile and a complete weatherproofing approach. Level, bevelled, ramped and raised-weather-sill profiles remain distinct. Where a low threshold uses a channel drain, the channel, grate, outlet, end closures, anchors, membrane flange and cleaning basket are separate drawable parts.

Clear opening is not door-leaf width. It is derived from the installed frame, stops, hinges or sliding-panel overlap, hardware and fully open position. Finished corridor width is likewise measured between actual finished obstructions rather than nominal framing lines.

### Fixtures and empty space are different

The sanitary compartment is the room or space; the toilet pan is the fixture. The catalogue contains floor-mounted and wall-hung pans, exposed and concealed cisterns, a carrier frame, flush plate, seat, connector, fixings and optional fixed basin or vanity components.

The installed pan exposes a centreline and front-edge datum used by the room check. Those datums and the required circulation area are guides or overlays, not extra construction. Fixed joinery, fixtures, door travel and even a floor-mounted door stop remain real obstructions tested against the overlay.

Hobless and step-free are also separate shower conditions. The H8 assembly reuses the completed waterproofing and glazing objects for the tray, membrane, screed, waterstop, drain and screen. Walk-in is not enough information to infer either condition or AS 1428.1 accessibility.

### Future backing is not an installed grabrail

H8 Part 6 provides concealed supporting construction for later grabrail installation. The catalogue distinguishes structural plywood, timber noggings, light-gauge-steel noggings, metal backing plate, edge supports, fasteners and a suitable solid concrete or masonry substrate. Fixture-specific assemblies position these parts around the toilet, shower or bath.

Ordinary noggings or an arbitrary plywood-looking layer do not automatically perform this role. Material, thickness or section, extent, support, connections, services, openings and lining build-up must be retained. Cavity-slider walls need special coordination because the moving panel and future fixing path can occupy the same wall space.

Installed grabrails, complete accessible paths, accessible sanitary fixture groups, tactile indicators, accessible parking, lifts and platforms now exist at capstone drawing level. H8 must still not silently acquire those additional objects or AS 1428 rule sets.

The detailed jurisdiction table, standards relationships, object hierarchy, exclusions and CAD behaviour are recorded in `research/livable_housing/source_notes.md`.

## H4 health-and-amenity objects

The health-and-amenity catalogue adds 95 physical objects. It completes the object-rich parts of NCC Volume Two H4 and Housing Provisions Parts 10.3 to 10.7 that were not already covered by the waterproofing, openings, glazing, thermal-condensation and H8 catalogues.

### Facilities are assemblies, not room labels

The required facility set links a kitchen, bath or shower, laundry, closet pan and washbasin without assuming that they occupy one prescribed room arrangement. The kitchen family separates sink, bowl, drainer, wastes, tapware, rim seal, clips, cabinet, benchtop, splashback and cooking appliances. Freestanding cookers retain anti-tip parts and adjustable feet; built-in ovens retain their actual cabinet opening and support.

The laundry family distinguishes the washtub fixture and cabinet from the washing-machine space. A reserved appliance space is a clearance, while a selected machine, inlet hose, drain hose and guide are physical objects. Sink, washbasin and laundry washtub remain separate facility roles even where everyday language calls all of them a sink.

Existing waterproofing, bath, shower, toilet, cistern and basin objects are reused. This allows one fixture to carry H4, H8, waterproofing and later plumbing roles without duplicate geometry.

### Sanitary-door recovery is real hardware and movement

The sanitary-compartment recovery family covers outward-opening, sliding and externally removable door approaches. Lift-off hinges, removable hinge pins and an external privacy-latch release are distinct parts. Releasing a latch does not automatically remove an inward-swinging leaf blocked by an occupant.

A tool should test the installed leaf, frame, swing or slide, hinge connection, latch access and pan position. The recovery clearance is a result over those objects, not a compliant-door solid.

### Rooflights and room-height boundaries

Windows and glazing are reused for natural light. The H4 catalogue adds a rooflight unit, kerb, lightwell and lightwell lining. Opening area, visible glass, transmitting area and daylight result remain separate calculations because frames, opaque parts and the shaft can change them.

Room height is calculated between actual finished bounding surfaces. Ceiling sheets, bulkheads, cornices and access panels are drawable; minimum height, a sloping-ceiling qualifying area and the pass state are not materials. Ceiling height, wall height, floor-to-floor height and storey height are therefore kept as different dimensions.

### Acoustic performance belongs to the whole wall

The Class 1 sound family covers separating walls formed from massive single leaves, double masonry leaves, masonry with isolated lining and double-row framing. Each complete wall retains leaves, cavities, insulation, linings, fixings, joints, perimeter seals and junctions.

Discontinuous construction is not inferred from a wall looking doubled. Shared studs, rigid ties, bridging, debris or services can connect the leaves. The model exposes those links and distinguishes a wall leaf from the individual sheet or finish layers supported by it.

The component set includes resilient masonry ties, channels and isolation clips; acoustic joint tape, compound, sealant and backing; roof and perimeter junctions; access-panel leaves, frames and seals; resilient pipe clips, wraps and flexible connectors; and electrical boxes, pads and caulk. Outlet offset and flanking sound paths are calculated relationships, not invented solids.

Rw, Ctr and related rating results are evidence metadata. A sheet marketed as acoustic plasterboard does not give the whole wall a rating. The captured NCC 2022 path calls up AS/NZS ISO 717.1:2004; AS ISO 717.1:2024 is recorded as the published successor but is not silently substituted. The Northern Territory Part 10.7 variation also confirms that jurisdiction and project pathway must remain explicit.

Gas and electrical connections, artificial-light products, internal room-acoustic treatment, apartment and commercial separation, specialised hydraulic fixtures and licensed acoustic test procedures remain later work.

The detailed object hierarchy, reuse boundary, standard-edition treatment, exclusions and CAD behaviour are recorded in `research/health_amenity/source_notes.md`.

## H7 ancillary construction

The ancillary catalogue contains 196 physical objects. It follows NCC Volume Two Part H7 and Housing Provisions Parts 12.1 to 12.4 while reusing established access, framing, roofing, drainage, window, door, glazing and general envelope objects.

The pool family separates the water-retaining vessel, child-access barrier and water-recirculation system. It covers in-ground, fibreglass, concrete, above-ground and spa construction; aluminium and glass barriers; full self-closing gate hardware; skimmers and submerged suction outlets; pumps, filters, pipe services, treatment and heating; covers; and pool-entry hardware. Barrier clear zones, hydraulic flow and approval results remain constraints and evidence.

The deck-wall family models timber or steel waling plates, wall-fastener groups, joist connectors, four-sided flashing and diagonal plan bracing. This is the limited Part 12.3 path rather than a universal deck-attachment detail.

The solid-fuel family covers open masonry fireplaces, freestanding and insert heaters, hearths, ventilated wall shields, masonry chimneys and multi-skin flue systems. NCC 2022 uses AS/NZS 2918:2018; the 2026 successor is recorded but not silently substituted.

The bushfire family adds ember mesh as a supported and sealed system; protected weepholes, vents, roof profiles and penetrations; subfloor enclosure; opening screens and shutters; joint and service seals; and high-level firefighting-water parts. Bushfire attack level is metadata. AS 3959:2018 and NASH NS300:2021 remain alternative construction paths.

Private bushfire-shelter objects stay deliberately high-level: engineered shell, access door or hatch, latches and seals, signs, viewing, ventilation, air-quality support and essential services. H7P6 has no Deemed-to-Satisfy path, so no object combination is presented as a compliant template.

The detailed object hierarchy, jurisdiction and edition conflicts, exclusions and SketchUp behaviour are recorded in `research/ancillary/source_notes.md`.

## Plumbing, sanitary drainage and onsite wastewater

The hydraulic-services slice adds 134 `plumbing` objects and 128 `drainage` objects. It follows NCC Volume Three rather than assuming that all house services live in Volume Two or the Housing Provisions.

The water-service graph separates cold, drinking, non-drinking, heated, tempered and rainwater roles. It includes pipe-material families, pressure fittings and joints, isolation and pressure control, backflow assemblies, heaters and their valves and drains, rainwater tanks, pumps, mains switching and marked outlets. Service role remains separate from material: round PVC does not tell the tool whether it is pressure water, sanitary DWV, stormwater or electrical conduit.

The sanitary graph starts at fixture traps and discharge pipes, continues through branches, stacks and vents, then crosses an explicit boundary into graded sanitary drainage. Buried drainage includes gullies, inspection points, shafts, trench, bedding, side support, overlay, backfill, flexible joints and pumped drainage. An overflow relief gully is defined by its level and surcharge function, not just by a grated body.

The onsite-wastewater graph continues from the property drain through septic primary treatment or certified secondary treatment, dosing and land application. It exposes septic chambers and baffles; AWTS blowers, diffusers, media, clarification, sludge return, disinfection, pumps and alarms; greywater systems; composting toilets; absorption trenches; and subsurface or surface irrigation parts. Treatment capacity, effluent quality, soil assessment, loading rate, setbacks and approvals remain evidence and constraints rather than invented geometry.

NCC 2022 nationally calls up the AS/NZS 3500:2021 series. The 2025 series is recorded as published successor material and must be selected only where the jurisdiction, work date and pathway make it applicable. WaterMark and Lead Free WaterMark are product-evidence fields, not physical objects.

The detailed boundaries, object hierarchy, edition treatment, exclusions and SketchUp behaviour are recorded in `research/plumbing_drainage/source_notes.md`.

## Electrical, communications and consumer energy

The electrical slice adds 306 objects. It deliberately extends beyond the narrow NCC Housing Provisions artificial-lighting path because most domestic electrical safety comes through state or territory law, the adopted Wiring Rules, electricity distributor rules, telecommunications cabling regulation, product regulation and selected equipment instructions.

The supply graph separates network service components, consumer mains, submains and final subcircuits. Meter enclosures, meters, switchboards, switchgear, busbars, links, MEN and earthing components remain distinct even when they share one cabinet. Cable anatomy remains separate from conduit, trunking, tray, boxes, connectors, supports and penetration sleeves.

Outlets and controls are decomposed into complete installed points, faceplates, mechanisms, boxes, brackets, switches, isolators and fixed-equipment connections. Lighting separates the lighting point, complete luminaire and lamp or integrated LED components. Downlight classification, clearances and the NCC lighting-power calculation remain evidence or analysis; an optional physical guard is drawn only when selected.

Communications covers nbn lead-in, pit, PCD, NTD, power supply and optional legacy backup; customer cabinets, patching, data, fibre, coaxial and telephone cabling; room outlets; network equipment; and terrestrial and satellite reception. AS/CA S008 and S009 are recorded separately from the electrical and NCC paths.

The consumer-energy graph exposes PV modules, strings, arrays, roof rails, interfaces, hooks, clamps, bonding, DC wiring, disconnection, inverters and monitoring. Batteries separate the complete BESS, battery unit, internal module, conversion, protection, controls, backup switching, mounting and selected impact protection. EV charging separates fixed EV supply equipment from the vehicle's onboard charger and includes wall, pedestal, cable, connector, holster, load-management and isolation objects.

Security and site-power families add alarm panels and detectors, CCTV, intercom, doorbell components, construction switchboards, heavy-duty leads, cable protection, temporary lights and test tags. Coverage volumes and test results are not counted as physical material.

The detailed regulatory split, edition notes, object hierarchy, evidence boundary, exclusions and SketchUp behaviour are recorded in `research/electrical/source_notes.md`.

## Mechanical heating, cooling and air distribution

The mechanical slice adds 220 objects across house-scale refrigerated air conditioning, ductwork, ducted evaporative cooling, whole-house heat-recovery ventilation and hydronic heating.

Refrigerated systems start with topology. A single split has one indoor and one outdoor unit. A multi-split branches one outdoor unit to several indoor units. A ducted reverse-cycle system adds a concealed fan coil, return path, supply plenum, branching duct network and room terminals. Equipment shells remain assemblies containing coils, fans, filters, drain pans, valves, controls, access panels and supports; condenser and evaporator are retained only as mode-dependent coil language.

The air-distribution family separates rigid and flexible duct bodies from insulation, vapour barriers, jackets, seams, joints, sealants, tapes, gaskets and draw bands. It includes route fittings, plenums, cushion-head boxes, grilles, registers, diffusers, return-air components, silencers, test ports, dampers, actuators and hangers. Every path records supply, return, outdoor, extract or exhaust role. A round tube's geometry does not identify its air quality or direction.

The evaporative system exposes wet media, retaining frames, reservoir, pump, water distributor, float and drain valves, blower, motor, roof dropper, support, flashing and controller. It supplies introduced outdoor air and needs a designed relief path; the tool must not add a refrigerated-system return network by analogy.

Balanced heat-recovery ventilation preserves four explicit paths through a packaged unit: outdoor intake, room supply, room extract and outdoor exhaust. The unit contains separated casing passages, heat-recovery core, two fans, two filter roles, bypass damper, optional condensate pan, four labelled ports and controls. HRV and ERV remain distinct until moisture-transfer evidence is known.

The hydronic graph separates closed-loop heating water from potable heated water. It covers air-to-water heat pumps, buffer and expansion vessels, pumps, headers, hydraulic separation, air and dirt removal, safety and control valves, flow and return pipework, insulation and supports. Underfloor heating contains paired manifold bars, circuit hardware, continuous loops, fixings, spreader plates and edge strips. Radiators contain the water-filled body, brackets or feet, thermostatic valve parts, lockshield, connectors and vents.

Housing Provisions Parts 10.6, 10.8 and 13.7 provide the direct room-ventilation, exhaust and services-energy paths. AS/NZS 4859.1:2018, AS 4254.1:2021, AS 4254.2:2012 and the NCC-referenced AS 1668.2:2012 editions remain separate from later or supporting AS 1668.2:2024, AS/NZS 5141:2018, AS/NZS 5149, AS/NZS ISO 817, AS/NZS 60335.2.40 and GEMS performance references.

The detailed clause map, source hierarchy, object breakdown, cross-discipline interfaces, licensing boundary, exclusions and SketchUp generation rules are recorded in `research/mechanical/source_notes.md`.

## Internal wall linings and ceilings

The internal-linings slice adds 97 objects covering plasterboard, fibre cement, timber and engineered-wood panelling; direct-fixed and suspended ceilings; support grids; retained fixings and adhesives; joint systems; edge beads; service openings and repairs.

The wall family separates framed, direct-fixed masonry and furred masonry linings. It includes standard, ceiling-grade, high-density, flexible and perforated plasterboard; general and decorative fibre-cement sheets; plywood, blockboard, MDF, particleboard, hardboard and solid-timber profiles. Existing wet-area, fire-resistant and acoustic sheets remain cross-discipline objects rather than colour-based duplicates.

The ceiling family exposes the whole load path. A direct-fixed ceiling carries sheets on joists, battens or furring held close to structure. A concealed suspended ceiling adds structural anchors, rods or wires, brackets, primary top cross rails, secondary furring channels, clips, joiners and perimeter track. An exposed-grid ceiling instead uses visible main tees, cross tees and perimeter angle with removable mineral-fibre, plasterboard or metal panels. Services are not assumed to be supported by a tile or grid merely because they occupy a module.

Joint geometry remains explicit. A recessed joint differs from a butt joint; paper tape differs from mesh and fibre-cement tapes; setting, drying, finishing and all-purpose compounds retain their actual roles. External-corner, internal-corner, stopping, casing, shadowline and control-joint profiles are separate objects. A named Level 3, 4 or 5 finish is stored as a requirement and evidence, not invented as another material solid.

AS/NZS 2908.2:2000 and AS 5637.1:2015 retain their direct Housing Provisions status where called up. AS/NZS 2588:2018, AS/NZS 2589:2017 with its amendments, AS/NZS 2785:2020, AS 2753:2018 with its amendment and AS/NZS 2270:2006 are recorded as supporting product or installation standards, not silently promoted to direct Housing Provisions references.

The detailed NCC boundary, standards map, assembly anatomy, product-neutral terminology, deferred interior-finish work and SketchUp generation rules are recorded in `research/internal_linings/source_notes.md`.

## Internal door leaves, frames, trim and hardware

The interior-door slice adds 98 objects without duplicating the generic internal doorway, swing, surface-sliding, cavity-sliding and folding assemblies already established by the livable-housing research.

Leaf construction separates flush, hollow-core, solid-core and blockboard-core families. A hollow-core leaf retains face skins, concealed perimeter frame, honeycomb or cellular infill, local lock block and edge lipping. A panelled leaf instead exposes moving stiles, top, intermediate and bottom rails, muntins and infill panels. Glazed and louvred leaves retain their actual openings, glass or repeated blades.

Fixed construction separates timber, rebated, split and flush-finish metal frames from leaf members. Architrave remains a room-side trim rather than wall lining or jamb. A visually frameless opening still contains a formed frame, perforated finishing flanges, hinge support and strike preparation jointed into the lining.

Hardware function is independent from appearance. Passage, privacy, dummy and keyed sets can use the same visible lever or knob design. The graph keeps handles, roses, backplates, spindles, tubular latches, spring bolts, faceplates, strikes, dust boxes, privacy controls, mortice lock bodies, cylinders, escutcheons, deadbolts and inactive-leaf flush bolts separate.

Movement hardware follows topology. Butt, loose-pin, fixed-pin, concealed and pivot hardware belong to swing doors. Surface sliders add wall-supported track brackets, spacers, anti-jump fittings, floor guides, stops and pulls. Cavity sliders add pocket-mouth finishes, closing jambs, lock parts and soft closers around the existing pocket frame, split studs, track, hangers and base guide. Folding doors add their own head track, fixed pivots, travelling guide, jamb bracket, inter-panel hinges, aligners and stops.

AS 2688:2017 and AS 4145 Parts 1, 2 and 5 are recorded as supporting current door and hardware standards, not direct Housing Provisions references. Part 10.4 sanitary-compartment recovery, H8 livable doorways, safety glazing, fire doorsets, acoustic paths and accessibility remain separate role-specific evidence.

The detailed jurisdiction overlay, NCC consequences, standards map, physical hierarchy, terminology traps, deferred work and SketchUp generation rules are recorded in `research/interior_doors/source_notes.md`.

## External pedestrian doors, security screens, shutters and garage doors

The external-door slice adds 237 objects and assemblies. Pedestrian doors separate the structural opening, complete doorset and moving leaf; panelled joinery from moulded panel-look skins; solid timber from solid-core construction; frame members from leaf members; and thresholds, pans, drips, seals, hinges, locks, flush bolts, closers and holdbacks by physical role. Existing glazed external-door, fire-door, livable-entrance, bushfire and glazing objects are reused.

Screen products separate lightweight insect screens, robust barrier screens and classified security systems. Security belongs to the complete infill-retention-frame-hardware-fixing-substrate path, not to stainless mesh or grille appearance. The current AS 5039.1, AS 5039.2 and AS 5039.3 family replaces the older AS 5039, AS 5040 and AS 5041 organisation while retaining exact edition evidence for existing products.

Shutters separate hinged, sliding, folding and fixed louvre panels, solid or boarded leaves and domestic roller shutters. Louvre blades pivot or remain fixed inside a framed panel; roller-shutter slats interlock into a curtain coiling in a head box. A roller shutter is not a roller garage door.

Garage systems start with motion topology. A sectional door articulates rigid horizontal panels along vertical, curved and overhead tracks. A roller door coils a corrugated flexible curtain above the opening. A tilt door moves one rigid panel outward and upward using jamb or track fittings. Their panels, rollers, guides, tracks, brackets, springs, shafts, drums, cables, wind locks, supports and clearances therefore remain different objects.

Counterbalance and powered drive are independent systems. Springs, cables, drums, pulleys or weights offset the door mass; an operator moves and controls a correctly balanced door. The operator family includes rail and axle drives, motor and gearing, chain or belt, trolley, arm, supports, limits, controllers, controls, photoelectric beams, sensing edges, releases and backup battery. Stored-energy objects are identification and coordination data, never generated adjustment instructions.

Housing Provisions clause 2.2.4 and AS/NZS 4505:2012 form the conditional large-access-door regulatory spine. Clause 13.4.4 supplies the external-door sealing consequence. AS/NZS 60335.2.95:2024 and the concurrent transition from the 2020 edition remain explicit product and jurisdiction metadata. The detailed regulatory boundary, standards map, object hierarchy, terminology traps, hazards, gaps and SketchUp generation rules are recorded in `research/external_doors/source_notes.md`.

## Internal floor finishes

The floor-finishes slice adds 146 objects from the top of the structural floor to the exposed walking surface and its edges. It covers structural particleboard and plywood sheets; sheet joints, adhesives, nails, screws and cut-edge treatment; primers, patches, levellers, screeds, crack isolation and moisture-control layers; rigid underlayment sheets; timber, parquetry, engineered boards, laminate, hybrid, bamboo, carpet, resilient flooring, cork and dry-area tile or stone; plus the fixings, seams, underlays, coatings, skirtings, coving and transitions each topology needs.

Structure, substrate, underlayment, underlay and finish remain different roles. A structural sheet can also receive a finish, but that does not make a non-structural hardboard or fibre-cement underlayment load-bearing. Carpet backing remains part of the manufactured carpet while soft underlay is a separate installed layer.

Product anatomy is explicit. Engineered timber retains its real timber wear layer, stabilising core and backing. Laminate instead retains a resin overlay, printed decor, HDF core and balancing layer. Hybrid retains a polymer wear layer, printed film, SPC or WPC core and optional attached underlay. A flexible glue-down vinyl plank is not silently merged with a rigid click hybrid because both show timber grain.

Installation topology is selected before appearance. Solid boards may span supports or act as overlay; engineered boards may be direct stuck or floating; broadloom carpet may be stretch-in or directly bonded; carpet tiles use modular retention; resilient sheet uses planned seams and may use heat or chemical welding; cork tiles are bonded; and dry ceramic or stone tiles use adhesive, grout and movement joints. Wet-area tiles and waterproof flexible sheet floors stay in the existing waterproofing assembly so membranes, falls, drains and waterstops remain visible.

AS 1860.2:2006 supports the NCC Volume Two particleboard structural-flooring path but is not promoted to a direct Housing Provisions Schedule 2 reference. AS/NZS 1860.1:2017, AS 1884:2021, AS 2455 Parts 1 and 2, AS 4288:2003, AS 4786.2:2005, AS 2796.1:1999, AS 4785.1:2002 and AS 13006:2020 are recorded as current supporting standards. AS 3958:2023 and AS 4586:2013 are reused for tile installation and applicable slip evidence.

The detailed NCC consequences, standards boundaries, assembly hierarchy, product anatomy, ambiguity traps, exclusions and SketchUp generation rules are recorded in `research/floor_finishes/source_notes.md`.

## Architectural paint, timber finishes and wallcoverings

The decorative-finishes slice adds 105 objects and assemblies. It starts with the real host surface and separates retained existing paint, repairs, primer or sealer, undercoat, intermediate coats, finish coats and permanent dry film. Internal walls, ceilings, trim, doors, exterior walls, exterior timber, smooth masonry, texture coatings, decorative effects and surveyed lead-paint encapsulation retain different systems.

Primer, sealer and undercoat remain different roles even when one documented product performs all three. Spot primer, plasterboard sealer, fibre-cement and masonry primers, timber and architectural-metal primers, knot sealer, tannin blocker, stain blocker and high-adhesion primer therefore stay explicit. Colour, sheen, VOC data, coverage and wet- or dry-film measurements are attributes rather than extra solids.

Opaque products distinguish wall acrylic, flat ceiling paint, water-borne enamel, solvent-borne alkyd enamel, exterior acrylic and smooth or aggregate-filled masonry coatings. Decorative base, glaze, metallic, pearlescent, magnetic-receptive and chalkboard layers keep their material and pattern roles. Wet-area decorative paint remains an exposed finish and cannot replace the existing waterproofing assembly. Ordinary architectural-metal primer cannot replace the AS/NZS 2312 structural-steel protective-coating path, and ordinary paint cannot replace intumescent fire protection.

Timber finishes separate water-borne clear coat, varnish, polyurethane, lacquer, shellac, hardwax oil, penetrating oil and water- or solvent-borne stains. Clear means the grain remains visible, not that colour and sheen remain unchanged. A stain colours timber, oil penetrates with low build and varnish forms a film; a selected product can combine functions without making the terms synonyms. The existing timber-floor coating remains floor-specific.

Wallcovering topology is chosen before appearance. Paste-the-wall, paste-the-paper, water-activated ready-pasted and pressure-sensitive self-adhesive assemblies contain different adhesive placement and handling. The graph exposes primer-sealer, size, lining paper, installed adhesive film, drops, mural panels, borders, butt and double-cut seams, corner returns, wraps, trimmed edges and optional edge colouring.

Product construction also remains visible: paper, non-woven fibre, woven textile, vinyl-coated paper, solid vinyl, linen-backed vinyl, grasscloth, flock, metallic foil and relief wallcovering are distinct. A mural uses ordered image panels and crop geometry; repeating wallpaper uses roll width, pattern repeat and match rules. Natural grasscloth variation and visible specialist seams are not automatically defects.

NCC Volume Two Part A5 supplies the critical painting documentation boundary: if coating is relied on for external-wall weatherproofing, the selected coating and complete wall system need suitable evidence. AS/NZS 2311:2017, AS/NZS 2310:2002, AS 3730.0:2006, AS/NZS 4548.4:1999 and AS/NZS 4361.2:2017 are recorded as current supporting standards, not direct Housing Provisions references. The locked direct-reference count remains 64.

The detailed regulatory boundary, standards map, physical coat hierarchy, hazardous-paint safeguards, wallcovering anatomy, ambiguity traps, exclusions and SketchUp generation rules are recorded in `research/decorative_finishes/source_notes.md`.

## Concrete structures, reinforcement and temporary works

The concrete-structures slice adds 186 objects and assemblies beyond the earlier house-scale footing catalogue. It covers concrete constituents, cast-in-place frames and suspended floors, deep foundations, reinforcement, structural joints, waterstops, embeds and reserved voids, post-tensioning, prefabricated concrete, formwork and falsework.

Cementitious binder, cement, supplementary cementitious material, aggregate, mixing water and admixture are constituents rather than synonyms for concrete. The existing structural-concrete material object is reused instead of duplicated. Reinforcement also keeps product, role and shape separate: a deformed bar can act as a longitudinal bar, starter, dowel or scheduled bent bar, while mesh, cages, bar chairs, spacers, laps and mechanical couplers retain their own geometry and relationships.

Suspended slab families remain distinct even when their top surfaces look alike. Flat plate, flat slab, beam-and-slab, banded, ribbed, waffle, one-way and two-way arrangements expose different supporting members and zones. A structural topping is not a levelling screed, and a suspended waffle floor is not a waffle raft foundation. The model can coordinate geometry but cannot infer span action, punching shear, fire, vibration or capacity from appearance.

The deep-foundation graph separates the system, pile group, driven, bored and continuous-flight-auger piles, casing, cage, cut-off, pile cap and ground beam. The joint and embed graph similarly separates designed joint purpose from saw cuts, keys, dowels, sleeves, fillers, sealants and waterstops, and distinguishes sleeves, penetrations, blockouts and recesses. A clash never authorises the plugin to cut concrete or reinforcement.

Post-tensioning separates prestressing strand from the complete tendon; bonded multi-strand and unbonded monostrand systems; ducts, grout and vents; live and dead anchorages; wedges, heads, bearing plates and trumpets; tendon supports and anchorage-zone reinforcement. Tendon paths and no-cut zones can be drawn only from authorised project data. Force, losses, elongation, stressing sequence and safe drilling zones are not inferred.

Prefabricated concrete keeps manufacture, transport, lifting, temporary bracing, final connection and completed states explicit. A cast-in lifting anchor is not a reusable lifting clutch or a final structural connection. Formwork is the mould; falsework is its temporary support. Their components remain drawable for sequencing and coordination, but visible props and braces do not prove temporary-works adequacy.

AS 3600, AS 2870, AS 2159, AS/NZS 2327 and AS 5216 define important structural routes or interfaces. Fourteen supporting standards were added for concrete supply, reinforcement, prestressing, bar chairs, formwork, prefabricated concrete, piling and constituents without changing the locked count of 64 direct Housing Provisions references.

The regulatory limits, standards boundary, system anatomy, lifecycle rules, ambiguity traps, exclusions and SketchUp generation rules are recorded in `research/concrete_structures/source_notes.md`.

## External decks, balconies, terraces and above-ground waterproofing

The decks-and-balconies slice adds 219 physical objects and assemblies. It separates open-jointed decks from waterproof platforms; attached from freestanding load paths; and timber, steel, concrete, bonded-finish and pedestal-supported construction. Posts, footings, bearers, joists, rim members, trimmers, blocking, bracing, brackets, bolts, screws, anchors, boards, gaps, clips and feature layouts remain explicit.

NCC Volume Two H2D8 is the external-waterproofing spine for applicable flat roofs, roof terraces, balconies, terraces and similar horizontal surfaces above internal spaces. It calls up AS 4654.1 for membrane materials and AS 4654.2 for design and installation. Its conditional concrete-stepdown, unused-space and spaced-decking exceptions are not treated as exemptions from structure, drainage, durability, termite, barrier, threshold or jurisdictional requirements. Housing Provisions Part 12.3 remains a narrower waling-plate attachment solution with its own wall, fastener, flashing and strap-bracing objects.

Waterproof platforms expose substrate, structural setdown, falls, primer, liquid or sheet membrane, bond breakers, corners, movement joints, upturns, downturns, waterstops, termination bars, overflashings, drains, overflows, thresholds, parapets and penetrations. Bonded exterior tile remains separate from dry-area flooring and from structurally supported pedestal pavers. Adjustable pedestals expose bases, bodies, heads, extenders, slope correctors, spacer tabs, bearer holders, pads, perimeter restraint and drain-access units.

The pass also covers built-in planter shells, root barriers, protection, drainage cells, filter geotextile, primary and overflow outlets; and secondary under-deck trays, supports, wall flashings, outlets and soffit interfaces. Existing barrier, cladding-soffit, concrete-upstand, roof-capping, termite and subfloor-ground objects are reused rather than cloned.

The detailed regulatory map, assembly anatomy, terminology hazards, evidence limits, exclusions and future SketchUp generator inputs are recorded in `research/decks_balconies/source_notes.md`.

## Advanced external cladding and facade drawing objects

The advanced-cladding slice adds a compact drawing-oriented extension to the existing cladding catalogue. It covers ventilated and open-jointed rainscreen facades; rail-and-bracket supports; metal cassette, composite metal and honeycomb panel parts; insulated sandwich panels; EIFS and cavity EIFS; vinyl/uPVC and WPC boards; terracotta panels and baguettes; continuous external insulation support details; and drawable facade cavity barriers.

This pass is deliberately not a deep standards expansion. NCC weatherproofing and ABCB metal-panel guidance are retained as context, but the acceptance test is whether an item can become a SketchUp component, repeated member, panel grid, trim, joint, fastener, layer or section detail. Fire ratings, wind design, weatherproofing certification, product approvals, spans and fixing tables remain selected-system evidence rather than geometry generated by the ontology.

The detailed drawing boundary, reuse rules, practical SketchUp inputs and evidence limits are recorded in `research/advanced_cladding/source_notes.md`.

## Capstone drawing capture

The capstone catalogue captures the major remaining SketchUp-drawable families at broad object level: vertical transport, fire services, gas services, curtain walls, specialist openings, access-control hardware, accessibility objects, commercial kitchen and laboratory fitout, cleanroom components, standby power, lightning protection, retaining walls and site stormwater equipment.

The detailed drawing boundary and non-compliance limits are recorded in `research/capstone_drawing_capture/source_notes.md`.

## What still needs deeper research

The Housing Provisions references and the later capstone capture point to the following object-rich areas for deeper work. Several are now present as broad SketchUp drawing families, but still need product-level, engineering or compliance research before they should drive detailed design decisions:

- **Specialist concrete still remaining:** shotcrete, printed concrete, FRP and textile reinforcement, ground anchors and major basement retention, water-retaining and marine structures, bridges and pavements, repair and strengthening systems, production equipment and proprietary fabrication libraries beyond the completed concrete-structures slice.
- **Specialist masonry still remaining:** glass-block, prestressed and refractory masonry; segmental retaining walls and paving; proprietary dry-stack and insulated-block systems; detailed chimneys and heritage work; repair, repointing and cleaning systems; advanced facade fire, acoustic and cavity-insulation junctions; proprietary libraries; and licensed engineering tables beyond the completed advanced-masonry slice.
- **Remaining structural steel and metalwork:** portal frames, roof steel, composite construction, detailed moment and hollow-section connections, erection parts, fire protection, platforms and architectural metalwork beyond the completed house-scale stair and barrier slice.
- **Remaining roofing and drainage:** insulated and membrane roofs, detailed roof glazing and proprietary tubular-daylight systems, roof access hatches, solar and service penetrations, proprietary verge and dry-ridge systems, parapet scuppers, flat-roof outlets, rainwater harvesting components and detailed below-ground stormwater fittings.
- **Remaining external walls:** structural glass facades, specialist industrial cladding, proprietary curtain-wall libraries and project-specific tested facade systems beyond the broad curtain-wall drawing family.
- **Remaining interiors and specialist linings:** fibrous-plaster ornaments, ornamental and proprietary trim families, fabric and felt acoustic panels, linear and baffle ceilings, wall protection, operable and demountable partitions, hygienic commercial systems, heritage and decorative mineral finishes, fire-protective and industrial coatings, and proprietary product libraries beyond the completed house-scale lining, ceiling, internal-door, floor-perimeter, architectural-paint, timber-finish and wallcovering slices.
- **Remaining floors:** ground-supported external paving and landscape terraces; industrial toppings, polished concrete, terrazzo and resin systems; sports, gym, sprung, stage and raised-access floors; commercial kitchen, laboratory and clean-room floors; tactile indicators; electric underfloor heating; temporary protection; repair and hazardous legacy flooring; and proprietary product libraries beyond the completed domestic internal-floor and external deck-and-balcony slices.
- **Remaining openings:** commercial folding and hangar doors; rolling fire shutters and curtains; broader fire, smoke, acoustic, detention and radiation-shielding doorsets; vehicle gates and gate operators; commercial operable walls; frameless-glass door detail; and proprietary product libraries beyond the completed door slices and broad automatic-door, rapid-door, loading-dock and access-control drawing families.
- **Remaining glazing:** overhead and roof glazing beyond the completed rooflight family, fire-rated and security glazing, structural point fittings beyond the completed house-scale barrier families, photovoltaic glass and secondary-glazing systems.
- **Remaining waterproofing:** specialist trafficable and membrane roofs, vehicle decks, large commercial podiums and intensive green roofs; retaining and below-ground walls; pools and water-retaining structures; steam rooms and commercial wet areas; repair systems; and proprietary libraries beyond the completed domestic wet-area and house-scale external deck, balcony, terrace and planter slice.
- **Remaining fire and smoke:** detailed fire- and smoke-door systems; commercial detection, occupant warning and emergency lighting; fire-rated ducts; cavity barriers; inspection and maintenance access; and product-level fire-service design beyond the broad sprinkler, hydrant, hose-reel, extinguisher, FIP, smoke-control and damper drawing families.
- **Remaining thermal and indoor environment:** external-glazing energy and shading geometry, ceiling fans, thermal mass, house-energy-rating inputs and advanced hygrothermal analysis beyond the completed insulation, condensation, exhaust and heat-recovery paths.
- **Remaining mechanical services:** geothermal loops; larger commercial air-handling, chilled-water and packaged plants; cooling towers; commercial and hazardous exhaust; central humidification and dehumidification; proprietary product libraries; and calculation or commissioning engines beyond the completed house-scale mechanical families and broad gas/flue/smoke-control drawing families.
- **Remaining hydraulic and stormwater detail:** commercial and trade-waste systems beyond the grease-arrestor drawing family, fire-service hydraulics beyond drawing anatomy, broader fixture and appliance product families, detailed below-ground stormwater fittings, infiltration controls, authority infrastructure and specialist treatment processes beyond the completed house-scale water, sanitary, onsite-wastewater and capstone detention/GPT/trench-drain families.
- **Remaining accessibility and specialist access:** AS 1428 and AS 1657 rule logic, detailed commercial egress systems, temporary edge protection and proprietary access equipment beyond the broad accessible-path, tactile, grabrail, sanitary, parking, lift, platform-lift and fixed-ladder drawing families.
- **Remaining electrical and controls:** full smart-home bus and blind-control systems, stand-alone power, pool and spa electrical equipment in greater depth, electrical heating, motors and controls, strata EV infrastructure, larger PV and batteries, detailed audiovisual systems and complete gate-operator systems beyond the existing domestic electrical objects and broad generator, ATS, lightning-protection and access-control drawing families.

Gas, lifts, commercial hydraulic services, specialist electrical systems and many product-specific systems are not fully exposed by the Housing Provisions standards list. The capstone catalogue captures them for SketchUp drawing identity, but deeper design tools will still need additional legislation, standards, manufacturer information, training references and trade glossaries. The NCC schedule is a strong starting map, not the boundary of a building.

## Research and acceptance rules

An object is accepted only when its existence, meaning and main relationships are supported by suitable sources. Primary regulators and standards metadata are preferred for regulatory facts. Australian training, government guidance and reputable industry material are used for plain-language physical terminology.

Conflicts are visible. A term can be:

- an accepted synonym;
- a regional, trade, spelling or proprietary search term;
- related but not equivalent;
- a possible alias requiring review; or
- explicitly not a synonym.

The [unresolved review](../exports/unresolved_review.csv) is therefore a product requirement, not research debris. A drawing command must never collapse a held term into an accepted object without asking what the user means.

## Files and reproducibility

- `data/catalog/` contains independently tagged source catalogues for each researched discipline.
- `data/standards/standards_registry.json` contains the standards metadata and NCC pointers.
- `data/sources/source_registry.json` is the provenance registry.
- `data/review/unresolved_terms.json` keeps terminology conflicts visible.
- `schemas/` defines the export records.
- `scripts/generate_ontology_outputs.rb` creates deterministic JSON, JSONL, Markdown and CSV outputs.
- `scripts/validate_ontology.rb` checks schema fields, controlled enums, IDs, provenance, aliases, graph inverses, duplicate edges, hierarchy cycles and discipline exports without external dependencies.
- `exports/disciplines/` provides independent ontology, graph, glossary and report files for each completed discipline.
- `exports/coverage_metrics.json` reports object, relationship, source, standard, confidence and source-diversity coverage.

Run from the repository root:

```powershell
ruby scripts/generate_ontology_outputs.rb
ruby scripts/validate_ontology.rb
```

Ruby is already the implementation language embedded in SketchUp, and these scripts use only its standard library. The data itself remains ordinary JSON, so research and future tooling are portable across Windows and macOS.
