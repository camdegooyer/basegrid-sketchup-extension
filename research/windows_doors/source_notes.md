# Windows and glazed doors source notes

## Scope of this slice

This research slice identifies the physical parts needed to draw external residential windows and framed glazed external doors. It covers complete product types, frame members, sashes and door panels, installation parts, hardware, insect screens, fall-protection components and air seals.

It does not yet cover solid timber doors, internal doors, fire doors, garage doors, shutters, security-screen door systems or every proprietary fenestration profile. Opening flashings already live in the external-cladding catalogue so the same head, sill and jamb weathering objects can serve multiple window products.

## Regulatory path in plain English

NCC Volume Two H1D8 is the first routing point. For the house-scale products within its scope, it directs external window assemblies and framed external glazed door assemblies through AS 2047 and Housing Provisions Part 8.2. Other glass selection and installation can follow Housing Provisions Part 8.3 or AS 1288. Human-impact locations can follow Part 8.4 or the relevant standards path.

That routing matters because the window is assessed as a complete assembly. A compliant pane placed in an arbitrary frame does not create a compliant window. Frame profiles, mullions, sashes, seals, drainage openings, hardware, fixings and glass all contribute to the installed product.

Housing Provisions Part 8.2 also separates the window from the building structure. The opening should not transfer structural building loads into the window product. The installation keeps a gap at the head, packs the sides and bottom at suitable points, fixes the frame and keeps packing clear of flashing and drainage paths. For a drawing tool this means the wall opening, installation clearance, packers, fixings, flashing and window frame must remain separate objects.

Housing Provisions Part 13.4 adds the air-sealing layer. An external door may need a bottom draft-exclusion device and compressible, fibrous or similar seals at its other edges. The installed frame-to-wall gap can require caulk, foam or another sealing arrangement. Those are not the same components as glass-to-frame glazing gaskets.

Housing Provisions Part 11.3 identifies circumstances where openable windows need a screen, opening restrictor or barrier to limit falls. A normal insect flyscreen must never be promoted to that role without suitable product evidence. A child-resistant release is also a separate fitting, not a label attached to an ordinary latch.

Energy provisions in Part 13.3 assess external glazing through whole-window properties such as U-value and solar heat gain coefficient. These values belong to the scheduled glazed product or rated system, not to frame material or glass colour alone.

## Product hierarchy used in the ontology

The complete window or door assembly is the scheduled product. A future SketchUp component should keep the product's overall size, rating, handing and panel configuration at this level.

Inside that assembly:

- the perimeter frame has a head, jambs, sill or threshold, and may contain mullions and transoms;
- a coupling mullion joins separate window units and may need a cover and structural insert;
- a sash is the framed glazed moving part of a window;
- a sliding door has opening and fixed panels with rails, meeting or interlock stiles, rollers and tracks;
- a hinged door uses leaf or panel members, hinges, handle and lock hardware;
- weatherseals close moving frame joints while glazing gaskets retain glass;
- installation fins, lugs, packers and fixings connect the product to the wall opening;
- drainage slots remain open paths from the frame rebate to the exterior;
- flyscreens, fall-protection screens and opening restrictors remain distinct products.

The catalogue includes fixed, awning, casement, hopper, horizontal-sliding, single-hung, double-hung, pivot and adjustable-louvre windows. It also includes one-piece window walls and bay-window assemblies. The framed glazed-door types are hinged, French, bifold and sliding products.

These type objects describe physical operation and component layout. They do not supply structural size, wind classification, water rating, hardware capacity or glass selection.

## Australian terminology

AGWA's public terminology drawings support head, jamb, sill, threshold, mullion, transom, sash rails and stiles, meeting rails and door-panel stiles. Its broader fenestration glossary supports the window operation types, fixed lites, coupling mullions, nailing fins, fixing lugs, storm moulds, seals and IGU language.

Several short terms are unsafe drawing commands:

- **Window frame** can mean the manufactured perimeter product or the timber and steel members forming the rough wall opening.
- **Sill** can refer to the lower window frame, a door threshold, the structural wall sill or a separate flashing.
- **Mullion** can mean a fixed-frame division, while meeting and interlock stiles belong to moving panels.
- **Fixed window** can mean the complete product, while fixed light means one non-opening glazed field.
- **Screen** does not say insect, security or fall-protection performance.
- **Rubber** does not distinguish a moving-panel weatherseal from a glass-retaining gasket.

These conflicts are recorded in `data/review/unresolved_terms.json` so a future command can ask a useful question rather than inventing geometry.

## CAD implications

A useful window tool should work from a selected product definition or a deliberately generic concept mode. At minimum it should keep:

- rough-opening size and host-wall depth;
- product overall width, height and frame depth;
- outside face, sill or threshold datum and handing;
- frame-member and sash-member profiles;
- panel or light layout and operation;
- glass make-up by light;
- hardware and opening limits;
- perimeter installation gaps, packers, fins or lugs, and fixings;
- head, sill and jamb flashing relationships;
- internal and external perimeter seals;
- drainage openings that must not be blocked;
- whole-product performance and evidence fields.

The tool must not scale a tested window component non-uniformly and assume the ratings remain valid. It should generate or place a new scheduled size, retain the correct member profiles and show when performance evidence is absent.

## Main sources

- ABCB, NCC Volume Two H1D8, glazing.
- ABCB, Housing Provisions Parts 8.1, 8.2, 11.3, 13.3 and 13.4.
- Standards Australia public metadata for AS 2047:2014, AS 4420.1:2016 and AS 5203:2016.
- Australian Glass and Window Association, *Window Terminology*, *Book of Fenestration Terms*, residential installation guide and compliance FAQ.

Licensed standards were not copied. Their public metadata and the NCC routing are recorded so later authorised rule research can use the exact applicable editions.
