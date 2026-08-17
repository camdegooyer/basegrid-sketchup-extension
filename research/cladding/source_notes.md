# External wall cladding research notes

Research date: 16 August 2026. Regulatory baseline: NCC 2022 Amendment 2.

These notes identify physical external-cladding objects for future SketchUp tools. They do not reproduce licensed fixing tables, wind capacities, test procedures or manufacturer details, and they are not engineering or compliance advice.

## Regulatory paths and limits

Housing Provisions Part 7.5 provides a limited construction path for:

- timber weatherboards and profiled boards;
- fibre-cement and exterior hardboard cladding boards;
- fibre-cement, exterior hardboard and structural plywood cladding sheets;
- fibre-cement eaves and soffit linings;
- flashings to exposed openings and penetrations;
- lower cladding terminations and ground clearance; and
- parapet cappings.

It does not cover every external wall material or system. Masonry belongs to Section 5. NCC Volume Two H1D7 separately routes reinforced AAC wall cladding through AS 5146.1 and solid metal wall cladding through AS 1562.1. ABCB guidance confirms that the AS 1562.1 pathway is for solid metal sheeting and does not automatically include laminated or composite metal panels.

NCC Volume Two H2P2 sets the weatherproofing outcome. H2V1 distinguishes direct-fixed cladding walls from cavity walls and exposes the junctions a complete wall model must preserve: control joints, wall junctions, windows, doors, electrical boxes, balcony and parapet flashings, and header and footer terminations. A cladding product by itself is not a tested wall.

## Start with the wall arrangement

The catalogue separates two common arrangements:

- a **direct-fixed wall**, where cladding is fixed close to the frame or substrate without a deliberately drained cavity; and
- a **drained-cavity wall**, where battens or furring hold cladding away from an inner water-control layer to create a clear drainage path.

This arrangement is separate from fastener visibility. “Direct fix” describes the wall build-up. “Face fix” describes a visible fastener through the cladding face. A cavity-fixed panel can be face-fixed, and a direct-fixed board can use a concealed edge fixing.

The cavity is a physical void. Its depth, drainage route, ventilation openings, battens, closures, flashings, fire barriers, bushfire screens and obstructions all affect how the wall works. A horizontal batten must not silently block the drainage path. Vertical, counter-battened, discontinuous and castellated supports are kept distinct where their geometry changes flow.

## Boards, sheets and panels

A board is long and narrow. A sheet is broad and relatively thin. A reinforced panel can carry its own scheduled actions between discrete supports. “Cladding panel” is therefore search language, not enough information to create an object.

The current board profiles include:

- splayed or bevel-back weatherboard;
- rebated bevel-back weatherboard;
- rusticated board;
- shiplap board; and
- tongue-and-groove board.

Their edge geometry controls course set-out, effective cover, weather-facing direction and fixing location. Timber, fibre cement and exterior hardboard can use visually similar board forms but remain separate materials with different product evidence, cut treatment, fastening and finishing.

The current sheet families are fibre cement, exterior hardboard, structural plywood and solid profiled metal. Structural plywood cladding is not automatically a bracing panel: the structural fixing and bracing schedule remains a separate role.

The solid-metal family includes corrugated, trapezoidal and concealed-fixed profiles. Profile, cover width, support direction, fixing system, base metal thickness, coating, laps, flashings and thermal movement remain product attributes. “Colorbond wall” is a finish or product-family cue, not a complete wall-sheet definition.

Reinforced AAC panels are kept distinct from unreinforced AAC blocks. The assembly includes supplied panels, fixings or brackets, joints, control joints, flashings and coating. Panel reinforcement, support, approved cuts and fixing geometry must come from the selected documented system.

## Membranes, joints and movement

The external wall weather barrier is a separate membrane behind cladding. Wall wrap and wall sarking are accepted search terms. “Vapour barrier” is not an automatic synonym: the material's water, air and vapour classifications, climate, wall position and intended function must be resolved first.

Board laps, shiplap joints, tongue-and-groove joints, board butt joints and expressed sheet joints have different geometry. A movement-joint assembly can contain:

- a deliberate expansion gap;
- independent support to both sides;
- flashing or a drained backing strip;
- bond-breaker tape and flexible sealant where specified; and
- a cover, H-profile or inter-storey flashing.

The visible H-profile is not the whole movement joint. A drawing tool should create the gap and water path before adding its selected cover or joiner.

## Openings, corners and terminations

An exposed window or door opening needs a coordinated weathering assembly. Head flashing intercepts water from above. Jamb flashings connect the sides to the sill. Sill flashing collects and drains water outward. The frame, reveal, membrane, cladding, trim and sealant meet at this assembly but remain separate objects.

A corner flashing sits behind the joint as secondary weather protection. A corner trim is the visible edge finish. Some products combine both functions; the tool should only merge them when the supplied detail proves that role.

The base flashing or starter profile terminates the membrane or cavity and discharges water clear of the lower wall. The model also retains its relationship to finished ground, paving, termite inspection zones and bushfire screening. Numeric clearances are project rules, not universal object dimensions.

Service penetrations need a complete collar, boot, tray or folded-flashing connection to both cladding and the inner weather layer. A hole with sealant around the service is not treated as a complete penetration detail.

## Soffits and cut edges

The eaves or soffit lining is an external underside assembly with fibre-cement sheets, trimmers, fixings, joints, vents, trims and service openings. “Fibro” is retained only as legacy search language because an existing sheet may contain asbestos and the word does not identify a safe modern fibre-cement product.

Cut-edge treatment is a role rather than one universal material. Timber may need end-grain treatment or primer, fibre cement may need product-compatible edge sealing, and coated metal damage may need a different repair process. The selected product system controls the treatment.

## Referenced and supporting documents

ISO 8336:2017 is now recorded alongside the other documents directly named by Housing Provisions Part 7.5. This corrects the direct-reference inventory to 64 documents: 62 AS or AS/NZS documents, NASH Standard Part 2 and ISO 8336.

AS 5146.1, AS 5146.2 and AS 5146.3 are stored as supporting reinforced-AAC records because H1D7 calls up the series path outside the national Housing Provisions Schedule 2 mapping used by the registry. FWPA Standard D01:2025 is public supporting industry guidance, not an NCC call-up. Manufacturer manuals are evidence for physical terminology and product relationships only; their proprietary details are not made universal defaults.

## Known gaps

- aluminium composite, laminated metal and other facade-panel systems requiring their own evidence paths;
- EIFS, insulated render, stucco, solid plaster and proprietary lightweight render systems;
- vinyl, uPVC, WPC, bamboo, terracotta, ceramic, stone and thin-brick cladding systems;
- natural timber shingles, open-jointed screens and decorative battens over separate weather skins;
- cassette panels, hook-on rainscreens, rail-and-bracket facades and pressure-equalised compartments;
- facade fire-stopping, cavity barriers and non-combustible-system classifications;
- bushfire ember screens, BAL-specific junctions and cyclone-tested product systems;
- external continuous insulation, thermal clips and condensation-control layers;
- parapet framing and capping details beyond the existing roof-capping object;
- balconies, decks, awnings, meter boxes, vents and large service-interface assemblies; and
- product-specific libraries, coating systems, colours, profiles, module sizes, fixing templates and tested capacities.

Full URLs and access notes are stored in `data/sources/source_registry.json` and generated into `exports/source_audit.csv`.
