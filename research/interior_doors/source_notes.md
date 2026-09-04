# Internal doors: source notes and drawing ontology

Research date: 16 August 2026  
Catalogue discipline: `interior_doors`  
Primary catalogue: `data/catalog/interior_doors_catalog.json`

## Purpose and result

This slice identifies the physical parts a future SketchUp tool needs to draw ordinary internal doors in Australian houses. It adds 98 objects and assemblies without duplicating the general internal doorway topology already recorded in `livable_housing`.

The new catalogue covers:

- flush, hollow-core, solid-core and blockboard-core leaves;
- panelled stile-and-rail leaves, including stiles, rails, muntins and infill panels;
- face skins, cellular infill, concealed perimeter frames, edge lippings and lock blocks;
- internal glazed leaves, explicit glazing apertures and links to the existing glass and glazing-bead objects;
- louvred leaves and repeated blades;
- timber, rebated, split and flush-finish metal frames;
- architraves, square-set reveals and concealed frame finishing flanges;
- butt, loose-pin, fixed-pin and concealed hinges, hinge parts and pivot sets;
- passage, privacy, dummy and keyed furniture functions;
- levers, knobs, roses, backplates, spindles, latches, bolts, faceplates, strikes and strike boxes;
- open-position wall, floor and magnetic door stops;
- controlled door closers and their body, arm and slide-rail arrangements;
- surface-sliding brackets, spacers, anti-jump fittings, guides, stops, pulls and pelmets;
- cavity-slider closing and split-jamb finishes, locks, bolts, strikes and soft-close devices; and
- folding-door tracks, pivots, guides, jamb brackets, inter-panel hinges, aligners and stops.

It deliberately reuses existing objects for the internal doorway, swing, surface-sliding, cavity-sliding and folding topologies; frame head and jamb; door stop moulding; sliding head track and hanger; cavity pocket frame, split stud and base guide; generic handle-and-latch set; glass pane and glazing bead; fire-separation door leaf and closer; sanitary recovery hardware; automatic drop seal; frame packer and frame fixing.

This is an ontology and drawing foundation. It is not a door schedule, installation manual, structural assessment, hardware specification, fire or acoustic assessment, accessibility report, building approval or substitute for the NCC, Australian Standards or selected manufacturer instructions.

## Regulatory baseline and the current-edition problem

The repository keeps the edition from which each regulatory fact was extracted. Existing national catalogue facts retain their **NCC 2022 Amendment 2** extraction baseline.

That does not mean one edition applies to every Australian project on the same date. The NCC is given legal effect by each state and territory. The ABCB's [NCC editions page](https://ncc.abcb.gov.au/editions-national-construction-code) and [general NCC guidance](https://ncc.abcb.gov.au/faq/general-ncc) explain the edition sequence and jurisdictional adoption. Tasmania's public commencement notice records that NCC 2025 commenced there on 1 May 2026. Transition or exemption arrangements and later legislative changes still need a live project check.

A future tool therefore needs these project fields before offering a compliance answer:

- state or territory;
- building class;
- approval or certificate pathway;
- relevant application, design and construction dates;
- adopted NCC edition and amendments;
- jurisdictional variations, transitions and exemptions; and
- whether the design uses a Deemed-to-Satisfy route or a Performance Solution.

The door objects remain usable across editions because they describe physical construction. Clause references and compliance results are separate, versioned evidence.

## What the Housing Provisions actually contribute

### Part 10.4: sanitary-compartment door recovery

[Housing Provisions 10.4.2](https://ncc.abcb.gov.au/editions/ncc-2022/adopted/housing-provisions/10-health-and-amenity/part-104-facilities) addresses a door to a fully enclosed sanitary compartment. In plain English, the applicable arrangement is outward opening, sliding, readily removable from outside, or an inward-opening arrangement with the specified clear space between the pan and doorway.

The ABCB article [Construction of sanitary compartments](https://ncc.abcb.gov.au/news/2019/construction-sanitary-compartments) explains the occupant-recovery purpose.

The ontology consequence is important: this is not a special material called a compliant toilet door. It is a configuration of real objects and clearances:

- swing direction or sliding action;
- door leaf and frame;
- lift-off or other removable hinge arrangement where selected;
- externally accessible removable pin where that is the documented arrangement;
- privacy latch with an outside emergency release;
- door stop and hardware that do not defeat removal; and
- the measured relationship between doorway, pan and room geometry.

The existing `health_amenity` objects own that recovery assembly. The interior-door catalogue links to them and supplies ordinary leaf, frame and hardware anatomy.

### Part H8 and the Livable Housing Design Standard

The existing `livable_housing` catalogue owns dwelling-access paths, nominated internal doorways, clear openings, circulation, thresholds and the door-action alternatives recognised by that pathway. Not every internal door in a dwelling automatically falls within the nominated livable-housing route.

For drawing tools, clear opening is calculated from the actual leaf, frame, stop, hinge, handle and open position. It is not the same as nominal leaf width or rough opening width. A surface slider, cavity slider, folding door and swing door need separate movement geometry even when they serve the same circulation role.

AS 1428.1:2021 may be relevant where the NCC or project path calls it up, but an ordinary lever handle must not be labelled accessible from shape alone. Operating height, clearance, return, grip, force, door closer and the applicable access path all matter.

### Part 10.6: ventilation

A door opening can participate in a room-ventilation arrangement where the applicable provision and project calculation allow it. A louvred leaf, transfer grille or undercut can also provide a real flow path.

The ontology does not convert every undercut or louvre into compliant ventilation. Free area, openable area, transfer path, privacy, fire, smoke, acoustic and pressure assumptions are analysis data. The geometry can expose the path; it cannot prove the result by itself.

### Part 10.7: sound insulation

Sound performance belongs to the complete separating construction. A solid-core leaf may add mass, but the result also depends on frame, gaps, seals, threshold, wall, junctions, penetrations and tested or assessed evidence.

The existing `health_amenity` acoustic objects and `thermal_condensation` door seals remain separate. The interior-door catalogue does not invent an acoustic rating from leaf thickness or core name.

### Fire and smoke doors

The existing `fire_safety` catalogue owns the protected-opening door assembly, fire-resistant doorset, solid-core fire-separation leaf, tested closer, frame, latch and related evidence. AS 1905.1:2015 is recorded as supporting metadata for fire-resistant doorsets.

An ordinary solid-core internal leaf and ordinary closer are different objects because they can exist without a fire function. When a fire path applies, the tool must select the complete approved doorset and its installation evidence. Changing a material tag to fire rated is not enough.

## Standards map

### Supporting door and hardware standards

| Standard | What it contributes | Drawing caution |
| --- | --- | --- |
| [AS 2688:2017](https://store.standards.org.au/product/as-2688-2017), *Timber and composite doors* | Public scope metadata supports timber and composite door and doorset families, including flush-panel and joinery construction. | It is supporting evidence here, not a direct Housing Provisions call-up. Fire, acoustic, thermal, security and frameless-glass performance remain separate. |
| [AS 4145.1:2008](https://store.standards.org.au/product/as-4145-1-2008), *Locksets and hardware for doors and windows — Glossary of terms and rating system* | Supports hardware terminology and the principle of classifying selected hardware performance. | A rating belongs to a tested product, not to generic handle or lock geometry. Amendment 1 remains part of the current publication record. |
| [AS 4145.2:2008](https://store.standards.org.au/product/as-4145-2-2008), *Mechanical locksets for doors and windows in buildings* | Supports mechanical lockset product evidence. | Function, security, durability and corrosion results are selected-product evidence. |
| [AS 4145.5:2011](https://store.standards.org.au/product/as-4145-5-2011), *Controlled door closing devices* | Supports controlled door-closer product evidence. | Leaf mass, mounting, opening force, fire role and access role require the selected closer and project path. Amendment 1:2013 is recorded with the base publication. |

These four standards are not silently promoted into direct national Housing Provisions references. They are strong supporting sources for object identity and product selection.

### Standards linked through special door roles

| Standard | Relevant role | Boundary |
| --- | --- | --- |
| AS 1288:2021 and AS/NZS 2208:2023 | Glass selection and safety glazing in a glazed internal leaf where applicable. | Transparency or a generic glass material does not prove safety classification. |
| AS 1428.1:2021 | Accessible door and hardware details where the adopted NCC or project path calls it up. | Do not apply it automatically to every internal door or infer compliance from a lever model. |
| AS 1905.1:2015 | Fire-resistant doorset evidence. | Ordinary solid-core leaves and ordinary closers remain separate. |
| AS/NZS 2589:2017 | Supporting lining and finishing evidence at flush-finish frames. | The frame flange and compound are physical parts; the finished appearance does not remove the frame. |

Standards Australia documents are copyrighted. Basegrid records public metadata and original summaries. It does not reproduce licensed clauses, tables, figures, classifications, test procedures or installation dimensions.

## The physical hierarchy in plain English

### Doorway, frame, leaf and hardware are different things

The **doorway** is the passage and its surrounding assembly. The **frame** is fixed into the wall opening. The **leaf** is the moving closure. The **hardware** supports, moves, latches, locks, stops or closes the leaf. The **trim** covers or finishes the frame-to-wall junction.

A future SketchUp component can group them for selection, but quantity take-off, replacement, finish, movement and evidence stay separate.

### A hollow-core leaf is not empty

A typical hollow-core flush leaf contains:

- two face skins;
- a concealed perimeter frame;
- cellular or honeycomb infill supporting the broad faces;
- a local lock block or other hardware reinforcement;
- bonded edges and possibly separate lippings; and
- selected bores, mortices or other preparations.

The internal cell field can be hidden at ordinary drawing detail while the data still records the correct construction. Hardware must land in documented reinforcement. A tool must not assume that both edges contain full-height solid timber.

### Solid core is construction, not a performance certificate

A solid-core leaf has a substantially continuous dense core. It is heavier and often more robust than a hollow-core leaf. It may be useful within an acoustic or fire system, but core type alone does not prove the system result.

Blockboard is kept as a separate core family because closely arranged timber strips are physically different from a particleboard or other homogeneous dense core.

### Panelled leaves have moving members

A true stile-and-rail leaf contains:

- vertical stiles;
- a top rail;
- one or more intermediate rails;
- a bottom rail;
- optional muntins; and
- timber, sheet, moulded or glazed infill panels.

These members move with the leaf. They are not frame jambs or wall studs. A moulded flush-door skin may imitate panels while remaining a flush leaf with no separate joinery panel construction.

### Frame families

A conventional timber jamb set has two jambs and a head. It may use an integral rebate or a separate loose stop. Packers establish line and level; frame fixings transfer load into wall support. Architraves cover the gap on one or both wall faces.

A split jamb uses overlapping or interlocking halves to wrap the wall thickness. This is different from a cavity-slider split stud.

A flush-finish metal frame uses perforated side flanges jointed into the wall lining. It can look frameless after decoration, but it still contains a physical head, jambs, rebate, hinge support, latch insert, fixings and jointed flanges.

### Hardware function comes before appearance

Passage, privacy, dummy and keyed sets can share the same lever design:

- a **passage set** retracts a latch from either side and has no privacy lock;
- a **privacy set** adds an inside control and outside emergency release;
- **dummy furniture** is fixed and operates no spindle latch; and
- a **keyed set** adds a cylinder or keyed mechanism for controlled access.

The visible furniture then chooses lever or knob, rose or backplate, finish and other product attributes. The tool should ask for function first.

### Swing hardware

A butt hinge contains two hinge leaves, a central pin and fixing screws. Loose-pin, fixed-pin and concealed hinges have different removal, preparation and movement geometry. A pivot set creates top and bottom support instead of a line of side hinges.

Hinge count, size, bearings and fixings depend on leaf mass, dimensions, closer, use and frame. They are not universal values stored against the word hinge.

Door stop is ambiguous. It can mean:

- the jamb stop moulding that locates a closed leaf;
- a wall or floor stop limiting open swing;
- a magnetic stop and hold-open pair;
- a sliding-track end stop; or
- a folding-track guide stop.

The command parser must ask which movement is being controlled.

### Surface sliding doors

A face-of-wall sliding system normally needs a supported head track, rollers or hangers, brackets or rest plates, wall spacers, end stops, anti-jump fittings, a lower guide and operating pulls. A decorative support batten can help coordinate fixings, but it does not prove wall capacity.

The leaf needs clear travel across the wall. Switches, outlets, skirting, architraves, handles and furniture can clash even when the closed doorway geometry looks correct.

### Cavity sliders

The existing livable-housing objects provide the pocket frame, split studs, head track, hangers and base guide. This slice adds visible closing and split-jamb finishes, recessed pulls, edge pulls, privacy or keyed lock parts, strikes and soft-close hardware.

The pocket is a protected movement zone. Wall screws, plumbing, electrical boxes, noggings and lining fixings must not project into the leaf path. The leaf, track and pelmet also need a maintenance strategy.

### Folding doors

A bifold or multi-panel folding door combines rotation and translation. Its head track is not just a sliding-door track. The pivot-side panel uses top and bottom pivots; the guide-side panel uses a travelling top guide; hinges connect panels; a jamb bracket anchors the lower pivot; aligners and stops control the closed geometry.

The folded stack projects into one or both spaces and reduces the usable opening differently from a swing or sliding leaf.

## SketchUp generation rules

The drawing tool should follow these rules:

1. Start with an opening and selected door action: swing, surface slide, cavity slide, fold or pivot.
2. Choose the leaf construction independently from its action. A hollow-core, solid-core, blockboard, panelled, glazed or louvred leaf can require different hardware and preparation.
3. Record handing and room sides explicitly. Do not derive inside, outside, privacy side or lock side from global axes.
4. Draw the frame and wall support before hardware. Hinge, track, strike and pivot loads need real backing.
5. Preserve movement geometry: swing arc, pivot heel path, sliding travel, pocket zone, folding panel sweep and folded stack.
6. Keep nominal leaf size, actual leaf, frame opening, clear opening and rough wall opening as separate dimensions.
7. Model clearances as controlled gaps, not material. Do not include them in material take-off.
8. Treat hardware preparations as openings or machining features in leaf and frame. Do not place a lock body through cellular infill without reinforcement.
9. Store hardware function separately from visible furniture style.
10. Reuse existing glass, fire, acoustic, sanitary, livable, air-seal, electrical strike, packer and fixing objects when those roles are selected.
11. Store manufacturer, product, rating and installation evidence on selected instances or assemblies, not on the generic class.
12. At low detail, hide cores, screws and internal mechanisms without deleting their identity, quantity or host relationships.

## Deliberate exclusions and next door work

This slice does not yet fully model:

- garage, tilt, sectional and roller doors;
- external solid-timber entrance doors beyond existing framed-glazed external doors;
- security screens and screen-door hardware;
- full commercial fire and smoke door systems beyond existing house-scale fire objects;
- acoustic doorsets, automatic operators and complete electronic access control;
- frameless glass doors and patch fittings;
- operable walls and large commercial folding partitions;
- specialised lead-lined, radiation, ballistic, blast, clean-room, cool-room or hygienic doors;
- proprietary product libraries and exact machining templates; or
- automated compliance calculations and door schedules.

These exclusions are scope boundaries, not claims that the objects are unimportant.

## Main public sources used

- ABCB Housing Provisions Part 10.4 and the sanitary-compartment explanation;
- ABCB current-edition and editions guidance plus the Tasmanian NCC 2025 commencement notice;
- Standards Australia public metadata for AS 2688 and AS 4145 Parts 1, 2 and 5;
- Hume Australian flush-door, pre-hung, bifold, timber-jamb and cavity-unit material;
- Lockwood Australian internal leverset, cavity lock and flush-pull product information;
- Corinthian internal face-of-wall sliding-door installation information; and
- EZ Concept Australia flush-finish metal frame installation information.

Manufacturer sources expose real system anatomy and compatibility. They do not create a universal rule for every product. Exact dimensions, capacities, spacings, machining and fixings must come from the selected current document.
