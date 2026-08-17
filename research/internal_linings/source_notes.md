# Internal linings and ceilings: source notes and drawing ontology

Research date: 16 August 2026  
Catalogue discipline: `internal_linings`  
Primary catalogue: `data/catalog/internal_linings_catalog.json`

## Purpose and result

This slice identifies the physical parts a future SketchUp tool needs to draw ordinary internal wall linings and ceilings in Australian houses. It adds 97 objects and assemblies.

The catalogue covers:

- plasterboard wall linings over timber frames, steel frames, furring and masonry;
- direct-fixed and furred masonry linings;
- single-layer, multilayer and curved linings;
- internal fibre-cement sheets, decorative panels and their joint systems;
- plywood, blockboard, MDF, particleboard, hardboard and solid-timber panelling;
- direct-fixed plasterboard ceilings;
- concealed suspended plasterboard ceilings;
- exposed tee-grid ceilings and lay-in tiles;
- furring channels, primary rails, tees, perimeter members, hangers, anchors, clips and joiners;
- screws, nails, panel clips and four different installed adhesive roles;
- recessed, butt, internal-corner, flush, expressed and movement joints;
- tapes, compounds, beads, trims, cornice adhesive and ordinary paintable gap sealant; and
- service openings, edge support and repair patches.

It deliberately reuses existing wet-area, fire, acoustic, framing, masonry and ceiling objects where they already exist. A green, red, blue or other coloured sheet is never selected by colour alone. Fire, acoustic, moisture, impact and fixing performance require the chosen product or documented system.

This is an ontology and drawing foundation. It is not an installation manual, engineering design, fire or acoustic assessment, building approval, trade licence, defect report or substitute for the NCC, Australian Standards or manufacturer instructions.

## How the authority chain is handled

Four kinds of information are kept separate:

1. **The NCC and adopted Housing Provisions pathway.** This establishes the applicable national provisions, subject to jurisdiction, project date, variations and transitions.
2. **A standard directly called up by that pathway.** Its exact edition matters and only applies where the NCC reference makes it relevant.
3. **A supporting Australian Standard.** This can be strong installation or product evidence without being a direct Housing Provisions call-up.
4. **Regulator and manufacturer guidance.** This exposes real parts, failure modes and compatible system anatomy, but does not create a universal national rule.

The selected baseline remains NCC 2022 Amendment 2 as adopted in the repository. A future tool must store jurisdiction, approval date, NCC edition and chosen pathway with any compliance result.

Standards Australia documents are copyrighted. The repository records public metadata and original summaries. It does not copy licensed clauses, tables, figures, spacings or installation instructions.

## NCC consequences for the object model

### A lining is not every object attached to a wall

The ABCB explanation [“Skirting boards, power points, architraves — are these part of a wall?”](https://ncc.abcb.gov.au/news/2020/skirting-boards-power-points-architraves-are-these-part-wall) describes an internal lining as the material covering and lining the wall, with plasterboard as a common example. Skirting, cornice, architrave and electrical accessories are attachments or adjacent objects rather than the lining material itself.

That distinction matters in SketchUp. A tool may place all of these together, but it should not merge them into one wall surface. Their quantities, materials, junctions, replacement cycles and compliance evidence differ.

Primary source record: `SRC-ABCB-WALL-LINING-ATTACHMENTS`.

### Part 10.2: wet areas

Housing Provisions Part 10.2 establishes wet-area construction pathways. The waterproofing catalogue already owns the wet-area wall assembly, water-resistant plasterboard substrate, fibre-cement wet-area sheet, membrane, bond breaker, seal, waterstop and finish objects.

This internal-linings slice provides the general lining and joint vocabulary but does not turn an ordinary board into a wet-area system. A selected sheet still needs its documented exposure, waterproofing and finish path.

### Part 10.3: room heights

Room height is measured to the finished ceiling lining or other nominated underside and can be affected by bulkheads and projections. The ceiling face, bulkhead and access objects are physical. The minimum height and compliant area are calculations over room and ceiling geometry, not solids to include in material take-off.

### Part 10.7: sound insulation

[Housing Provisions Part 10.7](https://ncc.abcb.gov.au/editions/ncc-2022/adopted/housing-provisions/10-health-and-amenity/part-107-sound-insulation) treats sound insulation as a complete separating construction problem. The health-and-amenity catalogue already holds the separating wall, acoustic lining sheets, insulation, resilient channel, perimeter seal, joint material and service-penetration roles.

The internal-linings catalogue therefore keeps ordinary plasterboard and ordinary gap filler separate from their acoustic-system counterparts. Extra layers add real mass but do not establish an Rw or Rw + Ctr value from geometry alone.

### Wall and ceiling fire-hazard properties

AS 5637.1:2015 is recorded as a direct Housing Provisions referenced test method for wall and ceiling lining fire-hazard properties. The resulting Group Number, smoke result or other classification is selected-product evidence. It is not a different geometric sheet and cannot be inferred from material colour or a generic timber texture.

Fire-resisting wall systems are also more than their face board. The existing fire-safety catalogue keeps fire-resistant plasterboard, screws, tapes, compounds, cavity insulation, junction packing and tested assembly evidence separate.

## Standards map

### Direct Housing Provisions references relevant to the slice

| Standard | What it contributes | Drawing caution |
| --- | --- | --- |
| AS/NZS 2908.2:2000, *Cellulose-cement products — Flat sheets* | Directly referenced for identified cladding and wet-area paths and Schedule material. It supports fibre-cement sheet identity. | The reference does not make every fibre-cement sheet suitable for every interior, wet-area, curved, tiled or ceiling use. |
| AS 5637.1:2015, *Determination of fire hazard properties — Wall and ceiling linings* | Directly referenced fire-hazard test method. | Test classification is evidence attached to a selected lining product or system, not shape generated from a generic material label. |

### Supporting standards, not direct Housing Provisions call-ups in this baseline

| Standard | Ontology contribution | Edition and scope note |
| --- | --- | --- |
| [AS/NZS 2588:2018](https://store.standards.org.au/product/as-nzs-2588-2018), *Gypsum plasterboard* | Product identity for gypsum plasterboard. | Board type, edge, thickness and performance remain selected-product data. |
| [AS/NZS 2589:2017](https://store.standards.org.au/product/as-nzs-2589-2017), *Gypsum linings — Application and finishing* | Substrates, layouts, fasteners, adhesives, tapes, beads, control joints and finishing materials. | Record the 2017 base with Amendment 1:2018 and Amendment 2:2021 where it applies. It is supporting evidence, not a direct Housing Provisions reference here. |
| [AS/NZS 2785:2020](https://store.standards.org.au/product/as-nzs-2785-2020), *Suspended ceilings — Design and installation* | Suspension, grid, tile and panel system context. | Hanger spacing, loads, restraint, bracing, seismic action and anchors need project design and the licensed document. |
| [AS 2753:2018](https://store.standards.org.au/product/as-2753-2018), *Adhesives — For bonding gypsum plaster linings to wood and metal framing members* | Purpose-made gypsum-lining stud adhesive. | The 2018 publication has Amendment 1:2021. It does not cover every masonry, back-blocking, cornice or panel adhesive role. |
| [AS/NZS 2270:2006](https://codehub.building.govt.nz/resources/22702006-asnzs), *Plywood and blockboard for interior use* | Interior plywood and blockboard product identity. | Public government metadata records Amendment 1 incorporated and reconfirmation in 2016. Its scope is fully protected interior use; structural, damp, exterior and fire roles need separate evidence. |

## The physical families

### Plasterboard sheets and wall assemblies

The generic plasterboard assembly includes a selected board, support plane, screws or nails, approved adhesive where used, sheet layout, edge support, joints, corners, perimeter detail, openings and final decoration.

The board family distinguishes:

- standard paper-faced gypsum plasterboard;
- ceiling-grade board;
- high-density or impact-oriented board;
- flexible board for curves;
- perforated acoustic board; and
- fibre-reinforced gypsum sheet.

Existing catalogues retain water-resistant plasterboard, fire-resistant plasterboard and acoustic lining sheet because those are system roles with their own evidence. A multi-performance product may satisfy several selected roles, but the model must preserve the product record and every system membership.

Manufacturer sources include Knauf's [Australian installation guide](https://knauf.com/en-AU/our-services/knauf-gypsum/training/plasterboard-installation-guide), its [product families](https://knauf.com/en-AU/p/products), the CSR Gyprock residential installation guide and the existing Red Book system source.

### Joints are assemblies, not drawn lines

A recessed plasterboard joint contains two factory-recessed edges, base compound, embedded paper tape and finishing compound. A butt joint uses non-recessed ends and normally needs backing or back blocking plus a broader feathered finish.

The catalogue separates:

- paper tape from glass mesh tape;
- setting-type base compound from drying-type base compound;
- finishing compound from all-purpose compound;
- an internal taped corner from an external corner bead;
- stopping, casing, shadowline and control-joint profiles; and
- an ordinary sheet joint from a movement-control joint.

“Level 3”, “Level 4” and “Level 5” are finish requirements and evidence, not three different materials. Glancing light is a viewing condition, not a defect solid. A future tool can show diagnostic overlays, but overlays must stay out of material quantity.

### Adhesives are different installed objects

The slice distinguishes:

- stud adhesive between plasterboard and timber or steel framing;
- direct-fix adhesive beds between plasterboard and masonry;
- back-blocking adhesive between sheet backs and a back-block;
- panel construction adhesive behind decorative panels; and
- cornice adhesive at wall-to-ceiling mouldings.

They can be sold in similar cartridges or bags but have different substrates, patterns, cure conditions and load paths. Adhesive is also not assumed to replace every required mechanical fixing.

The Western Australian regulator's [plasterboard ceiling failures bulletin](https://www.wa.gov.au/government/publications/industry-bulletin-85-plasterboard-ceiling-failures) reinforces why the ceiling sheet, adhesive, mechanical fasteners and support members must remain separately inspectable.

### Fibre-cement internal linings

The fibre-cement family includes general internal sheet, grooved decorative sheet and prefinished panel. Its joint may be:

- flush, using the compatible recessed edge, tape, base coat and top coat;
- expressed, with separately supported square edges and an open, sealed or backed gap; or
- covered by a timber, metal or polymer strip.

The James Hardie fibre-cement [lining installation guide](https://www.jameshardie.com.au/ContentfulCMS/Installation-Guide/Villaboard_Lining_Installation_Guide.pdf) and [Cemintel internal-lining guidance](https://www.cemintel.com.au/application/internal-lining/) support these physical distinctions.

General internal fibre cement, wet-area substrate, compressed floor sheet and external fibre-cement cladding are not synonyms.

### Timber and engineered-wood panelling

[WoodSolutions internal panelling guidance](https://www.woodsolutions.com.au/applications-products/interior/panelling-interior) supports solid timber boards, plywood and other engineered panels fixed to studs, noggings, battens or furring. It also distinguishes face fixing, secret nailing, clips, adhesive, board movement and sheet-panel joints.

The model includes:

- interior plywood and blockboard;
- MDF, particleboard and hardboard panels;
- plain solid timber lining boards;
- tongue-and-groove and shiplap profiles; and
- spaced timber slats over a visible backing.

A slat described casually as a “batten” is a visible finish member. A concealed lining batten supports the finish. A wall nogging belongs to framing. Similar rectangular timber does not make these roles equivalent.

Easycraft's [timber- and steel-frame installation guide](https://www.easycraft.com.au/docs/installation-guides/easycraft-installation-to-timber-and-steel-frames.pdf) supports the separate decorative-sheet, expansion-gap, adhesive, nail, screw, corner and joint-support objects.

### Direct-fixed and suspended ceilings

A direct-fixed plasterboard ceiling carries sheets on joists, truss bottom chords, steel battens or furring channels held by direct-fix clips.

A concealed suspended ceiling has:

1. structural anchor;
2. hanger rod or wire;
3. hanger bracket or clip;
4. primary top cross rail;
5. cross-rail-to-furring clip;
6. secondary furring channel;
7. perimeter track;
8. joiners and restraint required by the design; and
9. plasterboard sheets, fasteners and joints below.

An exposed-grid ceiling instead uses visible main tees, cross tees and perimeter angle with removable mineral-fibre, plasterboard or metal panels. A hold-down clip retains a tile where required. Lights, grilles, diffusers, cable trays and other services need their own documented support rather than being assumed to hang from a tile or grid.

Rondo's [concealed suspended ceiling system](https://www.rondo.com.au/products/ceilings/key-lock-concealed-suspended-ceiling-system) and [exposed-grid ceiling system](https://www.rondo.com.au/products/ceilings/duo-exposed-grid-ceiling-system) provide Australian component anatomy. Proprietary system names remain source context; the canonical objects use generic physical names.

## Cross-discipline boundaries

### Structure and framing

Timber studs, plates, noggings, joists and trusses remain timber-framing objects. Cold-formed steel studs, tracks and ceiling battens remain steel-framing objects. Masonry walls remain masonry objects.

The lining model attaches to them but does not infer that they are straight, strong enough or correctly spaced. Suspended-ceiling anchors must resolve to verified load-bearing structure, not merely intersect a plasterboard surface.

### Wet areas

Water-resistant substrate, waterproof membrane, bond breaker, waterstop, sealant and tile or other finish belong to the wet-area system. A fibre-cement or water-resistant plasterboard sheet is not itself a waterproof wall.

### Fire and sound

Ordinary plasterboard screws, paper tape, joint compound and acrylic filler cannot silently replace tested fire or acoustic components. The selected system must retain its precise lining layers, screw sequence, joints, perimeter seals, cavity construction, services and evidence.

### Electrical, plumbing and mechanical services

A lining cut-out is distinct from the downlight, outlet, grille, pipe or access panel installed in it. The opening owns edge support and trim. The service owns its body, connections, clearances and independent support. Fire, sound, air and moisture continuity need the appropriate separate penetration system.

### Interior trim and painting

Skirting, architrave, door jambs, window boards, decorative mouldings and complete painting systems merit a later interior-trim and finishes slice. This catalogue records their lining junctions but does not duplicate the existing ceiling cornice or invent a full paint-product hierarchy.

## SketchUp generation rules

1. **Generate an assembly, not one surface.** Keep support plane, sheets, fixings, adhesive, joints, edges and openings individually selectable.
2. **Store face and layer order.** Wall side, sheet face, panel grain, groove direction and multilayer sequence affect geometry.
3. **Use product dimensions only after selection.** Sheet size, thickness, edge profile, board radius, grid module and section geometry are product inputs.
4. **Make joint graphs explicit.** Recessed edges, butt ends, back blocks, tapes, compound bands, expressed gaps and control joints need their own paths.
5. **Do not infer fixing from contact.** Every sheet or panel needs explicit supports, fasteners and installed adhesive roles.
6. **Do not hang services from appearance.** Service support must connect to verified structure or a designed support frame.
7. **Keep required empty space out of material take-off.** Gaps, movement allowances and clearances may be drawn as overlays or openings but are not material solids.
8. **Do not infer compliance from colour or count.** Board colour, two layers, a fire-like sealant colour or a shadow gap cannot establish fire, acoustic, moisture or structural performance.
9. **Preserve brands as search aliases only.** “Gyprock” can find plasterboard, but the canonical object is gypsum plasterboard and the selected product stays attached.
10. **Expose uncertainty.** Where support, product, joint or performance system is unknown, stop at a generic accepted object and request the missing selection.

## Licensing and evidence boundary

The NSW Government [dry plastering work page](https://www.nsw.gov.au/business-and-economy/licences-and-credentials/building-and-trade-licences-and-registrations/dry-plastering-work) supports Australian trade scope spanning rigid gypsum, fibrous plaster and fibre-cement board, cornice and false or suspended ceiling work. Its licensing thresholds and practitioner obligations are jurisdictional evidence, not geometry and not a national permission rule.

Similarly, product certificates, installer records, substrate inspection, fastening inspection, finish acceptance and fire or acoustic reports attach to object instances. A clean model can support inspection but cannot prove the work occurred as drawn.

## Deferred work

Later slices should add:

- full fibrous-plaster sheets, casts, ceiling roses and decorative mouldings;
- stretch-fabric, fabric-wrapped, felt, cork and specialist acoustic absorbers;
- linear metal, open-cell, baffle and timber ceiling carrier systems;
- operable, demountable and glazed internal partition systems;
- complete skirting, architrave, jamb, reveal, dado and interior-moulding families;
- full primer, paint, clear finish, stain, wallpaper, vinyl and fabric wall-finish systems;
- wall protection, corner guards, impact rails and hygienic commercial linings;
- access-floor and specialist clean-room systems; and
- product-specific libraries, engineering, quantities, tolerances, inspection and defect workflows.

## Key source records

- NCC and regulators: `SRC-ABCB-WALL-LINING-ATTACHMENTS`, `SRC-ABCB-HP-ROOM-HEIGHTS`, `SRC-ABCB-HP-SOUND-INSULATION`, `SRC-WA-PLASTERBOARD-CEILING-FAILURES`, `SRC-NSW-DRY-PLASTERING-WORK`.
- Standards metadata: `SRC-SA-ASNZS2588-2018`, `SRC-SA-ASNZS2589-2017`, `SRC-SA-ASNZS2785-2020`, `SRC-SA-AS2753-2018`, `SRC-BUILDING-CODEHUB-ASNZS2270-2006`, `SRC-ABCB-HP-REFERENCED-DOCS`.
- Plasterboard: `SRC-KNAUF-PLASTERBOARD-INSTALLATION`, `SRC-KNAUF-PLASTERBOARD-PRODUCTS`, `SRC-GYPROCK-RESIDENTIAL-INSTALLATION`, `SRC-GYPROCK-RED-BOOK`.
- Fibre cement: `SRC-JH-VILLABOARD-INSTALLATION`, `SRC-CEMINTEL-INTERNAL-LINING`.
- Ceiling grids: `SRC-RONDO-KEYLOCK-SUSPENDED`, `SRC-RONDO-DUO-EXPOSED-GRID`.
- Timber and decorative panels: `SRC-WOODSOLUTIONS-INTERNAL-PANELLING`, `SRC-EASYCRAFT-INTERNAL-LINING-INSTALL`.
