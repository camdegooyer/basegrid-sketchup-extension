# Roof drainage research notes

Research date: 16 August 2026. Regulatory baseline: NCC 2022 Amendment 2.

These notes identify physical roof-drainage objects for future SketchUp tools. They do not reproduce licensed hydraulic tables, calculate capacity, select a lawful discharge point or prove compliance.

## Regulatory path and system boundary

Housing Provisions Part 7.4 addresses gutters and downpipes. It exposes eaves-gutter materials, installation, continuous and dedicated overflow measures, and downpipe construction. It directs box gutters to AS/NZS 3500.3 rather than treating them as ordinary eaves gutters.

The roof-drainage catalogue starts where runoff leaves or concentrates on the roof covering and ends at the underground stormwater drain, tank inlet, lower-roof spreader or other documented discharge connection. The existing site-civil catalogue continues the route below ground.

The physical system includes more than a gutter and pipe:

- gutter channels, ends, corners, joins, expansion details and supports;
- outlets, sumps and rainheads;
- explicit overflow openings, edges, gaps and fittings;
- downpipe lengths, bends, offsets, joins, clips and lower connections; and
- interfaces with valley channels, lower roofs, tanks and underground stormwater drains.

## Eaves gutters and overflow

An eaves gutter system includes the gutter profile, brackets, stop ends, corners and joints, outlets and its chosen overflow provision. Profile attributes must retain front and back levels, effective cross-section, material, fall, bracket layout, roof-sheet overhang and outlet positions.

Housing Provisions Part 7.4 illustrates continuous overflow measures such as:

- repeated front-face slots;
- a controlled back gap maintained with compatible spacers, clips or brackets; and
- a controlled front bead or lowered front overflow edge.

It also illustrates dedicated measures such as:

- an end-stop weir;
- an inverted overflow nozzle;
- a front-face weir; and
- a rainhead with a visible overflow opening.

These are separate drawable objects or voids. A high-front gutter profile is not safe merely because its outline looks plausible. The tool needs to preserve an outward escape path and should flag any fascia, packing, sealant, leaf guard or adjacent construction that blocks it.

The catalogue records overflow geometry but not capacity. Catchment area, design rainfall intensity, gutter and outlet capacity, downpipe layout, blockage assumptions and site-specific discharge still require the applicable hydraulic design path.

## Box gutters, sumps and rainheads

A box gutter is internal or concealed within the roof footprint. Its sole width, depth, fall, freeboard, support, thermal movement, sump or outlet and independent overflow route form one coordinated assembly. It should never inherit the simplified assumptions of an external eaves gutter.

A box gutter sump is a depressed internal collector attached to the box-gutter flow path. A rainhead is an external collection box that receives a gutter or outlet and relieves surcharge visibly outside. The objects may look similar, but their location and failure behaviour are different, so they are not interchangeable synonyms.

## Valleys and soakers

A valley gutter is the formed channel below the cut edges of two converging roof planes. “Roof valley” can also mean only the geometric intersection line, while “valley flashing” is overlapping trade language for the formed weathering piece. The ontology gives the physical water-carrying channel a valley-gutter ID and keeps the other words for search and review.

A soaker gutter is a narrow continuous concealed channel beside an abutment or beneath a covering edge. It differs from a local soaker tray flashing and from individual soakers beneath tiles or slates. This terminology remains under review because public Australian usage overlaps.

## Outlets and downpipes

The neutral object name is **gutter outlet**. Dropper, pop and nozzle are retained as Australian search language. “Nozzle” alone is ambiguous because it may also mean a dedicated overflow fitting.

A downpipe can be round or rectangular and may include:

- direction-changing bends;
- a two-bend offset or swan-neck assembly;
- sockets, couplings or joiners;
- repeated wall clips or saddles;
- an open shoe, lower-roof spreader or closed stormwater adaptor; and
- a connected underground stormwater drain or tank line.

The above-ground downpipe and buried stormwater drain have separate IDs. Their geometry, supports, joints and access differ. The downpipe-to-stormwater adaptor is the explicit transition rather than an invisible change of object class.

A spreader distributes water from an upper downpipe across a lower roof. Its presence does not prove the lower roof covering, gutter and downpipes can accept the added catchment.

## Materials, compatibility and maintenance

AS/NZS 2179.1 is the Housing Provisions-referenced product standard for metal rainwater goods and AS 1273 is referenced for unplasticized PVC downpipes and fittings. AS/NZS 3500.3 provides the broader stormwater drainage path and is specifically relevant to box gutters and hydraulic design. SA HB 39 and the Lysaght manual provide supporting public terminology and installation context.

Material compatibility applies across roof covering, valley or gutter, fasteners, sealants, downpipes and runoff from upstream surfaces. The ontology records product families but does not infer that any two selected metals, coatings or plastics can be connected safely.

Gutter guards and rainwater chains are included as recognised physical accessories with pending review. A gutter guard can change water entry, maintenance and overflow behaviour. A rain chain is an exposed water-guiding element, not a universal capacity-equivalent replacement for a closed downpipe.

## Known gaps

- roof outlets, sumps, overflows and siphonic drainage for membrane or flat roofs;
- parapet scuppers, overflow pipes and emergency spillways outside the current eaves examples;
- detailed box-gutter expansion, support, sump and overflow subtypes;
- balcony, terrace, podium and planter drainage;
- rainwater tanks, first-flush devices, leaf diverters, charged systems and reuse plumbing;
- downpipe strainers, cleanouts, inspection openings and proprietary acoustic systems;
- underground pits, junctions, grates and lawful point-of-discharge systems beyond the current site-civil slice;
- bushfire ember guards and product-specific gutter-guard systems;
- rain chains, collection basins and splash-control details by tested system; and
- hydraulic calculation objects such as catchments, rainfall inputs and capacity results, which should remain evidence-backed data rather than physical construction objects.

Full URLs and access notes are stored in `data/sources/source_registry.json` and generated into `exports/source_audit.csv`.
