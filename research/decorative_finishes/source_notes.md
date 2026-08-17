# Architectural paint, clear timber finishes, stains and wallcoverings: source notes and drawing ontology

Research date: 16 August 2026  
Catalogue discipline: `decorative_finishes`  
Primary catalogue: `data/catalog/decorative_finishes_catalog.json`

## Purpose and result

This slice identifies the physical surface-finish construction a future SketchUp tool needs to draw architectural paint, clear timber finishes, timber stains and installed wallcoverings in Australian houses and similar buildings. It contains 105 objects and assemblies.

The catalogue covers:

- the complete decorative finish system rather than colour alone;
- internal wall, ceiling, trim and door paint systems;
- exterior wall and opaque exterior timber paint systems;
- smooth concrete or masonry coatings and aggregate-filled texture coatings;
- retained existing paint, local repair filler, timber stopping and paintable caulk;
- plasterboard, fibre-cement, masonry, timber, ordinary architectural-metal and galvanised-metal primers;
- local spot primer, knot sealer, tannin blocker, stain blocker and high-adhesion primer;
- combined primer-sealer-undercoat, separate undercoat, intermediate coat, finish coat and dry paint film;
- water-borne acrylic wall paint, ceiling paint, water-borne enamel, alkyd enamel and exterior acrylic paint;
- wet-area decorative paint kept separate from the waterproofing behind it;
- decorative base, glaze, metallic, pearlescent, magnetic-receptive and chalkboard coatings;
- clear water-borne timber coatings, varnish, polyurethane, lacquer and shellac;
- hardwax oil, penetrating timber oil and water- and solvent-borne stains;
- a lead-paint field and encapsulating layer within a documented hazardous-paint management assembly;
- wallpaper supply rolls, installed drops, mural panels, lining paper and borders;
- paper, non-woven, textile, vinyl, grasscloth, flock, foil and relief wallcoverings;
- paste-the-wall, paste-the-paper, ready-pasted and self-adhesive installation topologies;
- cellulose, starch, PVA, latex, water-activated and pressure-sensitive adhesive layers; and
- butt and double-cut seams, internal-corner returns, external-corner wraps, trimmed edges and seam-edge colouring.

The catalogue deliberately does not duplicate:

- structural-steel protective coating systems already handled with the structural-steel and AS/NZS 2312 path;
- wet-area waterproofing membranes, waterstops, bond breakers and drains;
- fire-protective or intumescent coating systems;
- structural substrates, cladding, plasterboard, doors, trim or other host objects;
- factory floor coatings already represented by the floor-finishes discipline; or
- product certification, test reports, colour swatches and application equipment as if they were permanent building layers.

This is an ontology and drawing foundation. It is not a paint specification, hazardous-material survey, lead-paint work method, facade weatherproofing design, fire assessment, waterproofing design, product-compatibility decision or substitute for the NCC, Australian Standards, selected product instructions and competent professional advice.

## Regulatory baseline and jurisdiction

The repository preserves **NCC 2022 Amendment 2** as the extraction baseline for existing national facts. The edition that applies to a real project is still an input. States and territories adopt the NCC through their own legislation, with their own commencement dates, transition arrangements, exemptions and variations. A project in Tasmania, for example, must be assessed against the Tasmanian adoption position and dates rather than against a national website date alone.

Before a tool makes any compliance statement it needs, at minimum:

- state or territory;
- building classification;
- approval, design and construction dates;
- adopted NCC edition and amendment;
- local variations and transitional arrangements;
- selected Deemed-to-Satisfy route or Performance Solution;
- the standards editions authorised by that route; and
- selected product, substrate and system evidence.

The objects in this catalogue are relatively stable because they describe physical things. NCC clauses, adopted editions, test outcomes and pass states are versioned evidence attached to those things.

## What the NCC contributes

### Part A5 and the painting evidence boundary

[NCC Volume Two Part A5](https://ncc.abcb.gov.au/editions/ncc-2022/adopted/volume-two/a-governing-requirements/part-a5-documentation-design-and-construction) creates an important boundary. Its ordinary-building-work documentation treatment distinguishes general decorative painting from painting relied on to weatherproof an external wall.

In plain English:

- ordinary internal colour and sheen selection is not usually the centre of the NCC evidence system;
- a generic paint layer still needs a sound, compatible substrate and a complete paint system;
- if an external-wall coating is relied on as part of weatherproofing, it is no longer just decoration;
- the coating, substrate, joints, flashings, openings, penetrations and complete wall system then need appropriate evidence; and
- the tool must not declare weatherproofing from a product name containing words such as exterior, weather, shield or waterproof.

The ontology therefore keeps `weatherproofing role` as a recorded attribute and keeps the coating connected to the full external-wall assembly. It does not turn every exterior acrylic paint into a membrane.

### Wet areas

[Housing Provisions Part 10.2](https://ncc.abcb.gov.au/editions/ncc-2022/adopted/housing-provisions/10-health-and-amenity/part-102-wet-area-waterproofing) remains the controlling domestic wet-area context.

A bathroom or laundry paint can provide colour, cleanability and product-declared resistance to humidity or intermittent splashing. It does not replace:

- the required wet-area substrate;
- a waterproofing membrane;
- bond breakers;
- waterstops;
- sealed penetrations;
- falls and drains; or
- junction and doorway termination details.

The `wet-area decorative paint` object is therefore an exposed finish that sits over or outside the appropriate wet-area construction. Its existence must never satisfy waterproofing geometry.

### Fire performance

Ordinary paint does not create a fire-resistance level, make an assembly non-combustible or turn a standard lining into a fire-protective system. Intumescent coatings, fire-retardant coatings, tested finish systems and fire-rated penetrations require their own evidence and object families.

Wallcoverings can also affect fire-hazard properties in some building contexts. A generic paper, vinyl, textile or grasscloth object carries a place for selected test evidence, but the model must not infer performance from thickness, face material, a flame icon or a supplier description.

### Structural steel and long-term corrosion protection

The public scope of AS/NZS 2311 separates ordinary building painting from the long-term atmospheric protection of iron and steel addressed by the AS/NZS 2312 series. This catalogue includes an ordinary architectural-metal adhesion primer so painted internal trim, small metal fittings and similar surfaces can be represented.

It does not duplicate:

- structural-steel surface-preparation grades;
- zinc-rich primers;
- engineered intermediate and topcoat systems;
- environment categories;
- specified protective dry-film builds; or
- inspection and repair systems already associated with structural steel.

If the metal member depends on an engineered corrosion-protection system, the structural-steel protective-coating object is the source of truth.

### Lead paint

The NCC is not a substitute for hazardous-paint investigation. AS/NZS 4361.2 provides the relevant Australian hazardous-paint management route for lead paint in residential, public and commercial buildings.

The ontology follows four strict rules:

1. Do not infer lead from building age, paint colour, chalking, cracking or appearance.
2. Attach lead status to a documented survey, sample, field or other suitable evidence.
3. Keep retained lead paint as a physical existing coating beneath any encapsulating system.
4. Treat encapsulation as management, not removal or proof that the hazard has ceased to exist.

The catalogue describes the retained field and encapsulating coat so a model can preserve boundaries and inspection obligations. It intentionally does not provide do-it-yourself disturbance, sanding, heating, stripping or disposal instructions.

## Standards map

The five new standards below are current supporting sources according to their public Standards Australia catalogue metadata as researched on 16 August 2026. None is recorded as a direct Housing Provisions Schedule 2 reference. The repository's locked count of 64 directly referenced Housing Provisions standards is therefore unchanged.

| Standard | Public scope used here | Ontology boundary |
| --- | --- | --- |
| [AS/NZS 2311:2017](https://store.standards.org.au/product/as-nzs-2311-2017), including Amendment 1:2019 | Guide to painting buildings, including substrate preparation and decorative paint systems. | Main architectural-painting source. It does not select a proprietary product or cover engineered long-term structural-steel corrosion protection. |
| [AS/NZS 2310:2002](https://store.standards.org.au/product/as-nzs-2310-2002), reconfirmed | Glossary of paint and painting terms. | Supports the separation of paint material, coat, wet film, dry film and complete paint system. It is terminology, not a project coating schedule. |
| [AS 3730.0:2006](https://store.standards.org.au/product/as-3730-0-2006), reconfirmed 2016 | General guide to specification, purchasing, testing and properties of paints for buildings. | Supports product-property attributes. Colour, gloss, volume solids and performance evidence are not separate solids. |
| [AS/NZS 4548.4:1999](https://store.standards.org.au/product/as-nzs-4548-4-1999), reconfirmed 2013 | Aggregate-filled latex texture coatings for concrete and masonry. | Supports texture-coating identity. It does not make texture coat synonymous with cement render, crack repair or waterproofing membrane. |
| [AS/NZS 4361.2:2017](https://store.standards.org.au/product/as-nzs-4361-2-2017) | Hazardous paint management for lead paint in residential, public and commercial buildings. | Supports investigation and management routing. It does not allow lead content to be guessed or an ordinary repaint to be called encapsulation. |

Supporting public Australian sources include:

- the [CSIRO Australian Paint Approval Scheme overview](https://www.csiro.au/en/work-with-us/services/testing-and-certification/Independent-verification-and-certification), used to distinguish independent product certification from a physical coat;
- [CPCCPD3027 Remove and apply wallpaper](https://training.gov.au/Training/Details/CPCCPD3027), supporting ordinary wallpaper preparation, removal and hanging vocabulary;
- [CPCCPD3032 Apply advanced wall coverings](https://training.gov.au/Training/Details/CPCCPD3032), supporting specialist coverings, adhesives and seam methods;
- [Dulux preparation guidance](https://www.dulux.com.au/how-to/project-guides/what-to-consider-before-you-start/) and [exterior acrylic product information](https://www.dulux.com.au/paint/weathershield/weathershield-matt/);
- [Wattyl architectural paint technical data](https://wattylproductservice.wattyl.com.au/api/file/4179);
- [Intergrain timber-finish product families](https://www.intergrain.com.au/products/);
- [Milton & King wallpaper installation guidance](https://www.miltonandking.com.au/installation-care/); and
- [Materialised specialist wallcovering guidance](https://materialised.com.au/resources/installation/handcrafted-wallpaper/).

Manufacturer information is used for physical product anatomy, Australian terminology and compatibility examples. It does not create a universal installation rule or a preferred brand.

Standards Australia documents are copyrighted. Buildgrid stores public titles, status and scope metadata plus original summaries. It does not reproduce licensed clauses, tables, figures, test methods or proprietary limits.

## The physical paint hierarchy in plain English

The most important modelling decision is to distinguish the host, the work done to it and the permanent layers left behind.

From the building outward, a paint system commonly contains:

1. **Host object or substrate.** Plasterboard, fibre cement, timber, concrete, masonry, metal, a door leaf or retained existing coating is the real object receiving the finish.
2. **Existing coating.** Sound retained paint remains a physical layer. Loose paint that is removed does not remain in the completed model.
3. **Local repair materials.** Filler, stopping and selected paintable caulk remain where installed. Cleaning, washing, sanding and deglossing are operations or surface states rather than new layers.
4. **Primer or sealer.** A substrate-specific first coat promotes adhesion, controls suction, binds the face, blocks a contaminant or performs a documented combination of those roles.
5. **Undercoat or intermediate coat.** This can create build, opacity, colour uniformity or a compatible transition.
6. **Finish coat or coats.** These form the exposed colour, sheen, texture and maintainable service face.
7. **Dry film.** Each applied coating leaves a permanent solid film after water or solvent has departed. Wet film is a temporary application state and measurement.

A simple project might use one combined primer-sealer-undercoat and two applications of the same acrylic finish. Another might use local spot primer, full primer, separate undercoat and two finish coats. The tool should generate the documented system, not force every wall into one hard-coded recipe.

### Paint material, coat and system are different

- **Paint material** is the product before and during application.
- **A coat** is one continuous application of a product over an area.
- **Dry film** is the permanent material left by that coat.
- **A paint system** is the ordered combination of substrate preparation and all required coating layers.

One can of paint may supply two coats. One multi-role product can be both primer and undercoat. Neither fact makes coat, product and system synonyms.

### Surface preparation is not one object

Preparation asks whether the receiving surface is:

- sound enough to retain;
- clean and free of adhesion-breaking contamination;
- dry enough for the selected system;
- sufficiently smooth for the intended appearance;
- free of unresolved water entry, efflorescence, mould source or active movement;
- suitably cured and chemically compatible; and
- safely assessed where hazardous existing coatings may be present.

Permanent repair materials are drawn. Removed dust, wash water, temporary masking, abrasive paper, ladders, brushes and rollers are not part of the completed building model.

### Primer, sealer and undercoat are roles

A **primer** mainly establishes a compatible bond to a substrate. A **sealer** mainly reduces or regulates absorption, binds a porous face or isolates a condition. An **undercoat** mainly builds and creates a uniform receiving surface below the finish.

A product can legitimately perform more than one role. `Primer-sealer-undercoat` therefore represents one physical multi-role coating when supported by the product, not three automatically generated films.

Special first-coat objects remain separate because they solve different physical problems:

- plasterboard sealer controls the combined board-paper and joint-compound face;
- fibre-cement primer treats a cementitious sheet product;
- alkali-resistant masonry primer is selected for mineral substrates;
- timber primer receives an opaque system;
- metal and galvanised-metal adhesion primers address different surfaces;
- knot sealer treats local resinous features;
- tannin blocker addresses extractive staining from susceptible timber;
- stain blocker addresses a documented discolouration after its cause is fixed; and
- high-adhesion primer bridges a sound but difficult-to-coat face.

The word universal in marketing must never cause the tool to skip substrate, exposure and compatibility inputs.

## Opaque architectural paint families

### Internal wall and ceiling paint

Water-borne acrylic wall paint and flat ceiling paint are separate objects because their intended locations and service properties differ. A ceiling product often prioritises low reflectance and application overhead. A wall product may prioritise washability, scrub resistance or touch-up behaviour.

Flat, matt, low sheen, satin, semi-gloss and gloss are sheen descriptions. Their declared or measured ranges vary between product systems. They are attributes of a selected dry film, not separate boards or automatic synonyms.

### Enamel on trim and doors

Enamel is not one mandatory chemistry or one mandatory high gloss. Water-borne acrylic enamel and solvent-borne alkyd enamel are different coating families that can provide enamel-type service surfaces.

The tool must retain:

- binder and carrier family;
- primer and undercoat compatibility;
- face and edge coverage;
- number of coats;
- colour and sheen;
- blocking and hardness development where relevant;
- hardware, seal, label and moving-contact exclusions; and
- fire, acoustic or other doorset limitations.

Painting a normal door does not create a fire door, acoustic door or smoke door.

### Exterior acrylic paint

Exterior acrylic is modelled as an exposed coating on a real cladding, render, masonry or timber object. The model retains faces, cut ends, edges, joints, flashings, sealants and penetrations.

Dark colour, coastal exposure, UV, moisture, substrate movement and maintenance may affect selection, but the tool must use product and assembly evidence rather than inventing a universal recoat period or colour limit.

### Smooth and texture masonry coatings

A smooth masonry paint follows the surface profile without intentionally introducing coarse aggregate relief.

A texture system can contain:

1. prepared concrete, render or masonry;
2. compatible sealer or primer;
3. fine or high-build aggregate-filled texture coating; and
4. a separate protective topcoat where the documented system uses one.

Texture coating is not cement render. Render is a mineral or polymer-modified levelling and finish layer with its own construction. Texture can visually soften minor irregularity but cannot repair unsound render, moving cracks or water entry.

### Functional and decorative effects

Decorative effect systems retain a uniform base coat and a worked glaze, metallic or pearlescent layer. Tool, direction, pattern scale and sample-panel reference are stored because a colour chip cannot describe the result.

Magnetic-receptive paint contains ferrous particles. It attracts magnets but is not itself a permanent magnet. Chalkboard paint creates a writing surface through its selected formulation, not through black colour alone.

APAS or another certification record can support evidence for a selected product. It remains documentation linked to the coating; it is not drawn as an extra layer.

## Clear timber finishes, oils and stains

### Clear does not mean colourless or invisible

A clear coating leaves the grain visible. It can still:

- warm or amber the timber;
- change contrast and apparent depth;
- create a matt, satin or gloss surface;
- darken end grain;
- show sanding scratches, glue or filler;
- affect UV weathering; and
- form a visibly different repair patch.

The approved appearance therefore depends on timber species, cut, grade, age, moisture, preparation, filler, stain, coat count, application and lighting.

### Film-forming clear finishes

The catalogue distinguishes:

- water-borne clear timber coating;
- solvent-borne varnish;
- polyurethane clear coating;
- lacquer; and
- shellac sealer or finish coat.

These are overlapping product families, not interchangeable names. For example, polyurethane identifies binder chemistry, while varnish is a broader film-finish family. A lacquer commonly builds by fast-drying coats. Shellac can act as a sealer, barrier or traditional finish.

The existing `timber floor protective coating` remains the canonical floor-specific object. The new clear objects cover other architectural timber unless selected product evidence explicitly links the uses.

### Penetrating oil and hardwax oil

A penetrating oil is absorbed into the near-surface timber and normally leaves less film above the face than varnish. Hardwax oil combines drying oils and waxes and can leave a low-build surface-enriched finish.

Neither name proves:

- preservative treatment;
- water exclusion;
- external suitability;
- slip performance;
- food-contact suitability;
- one maintenance interval; or
- compatibility with every earlier coating.

### Timber stain

A stain changes apparent timber colour while leaving grain visible. It can be water-borne, solvent-borne, dye-rich, pigment-rich, penetrating or part of a semi-transparent exterior system.

Stain is not automatically the protective topcoat. Where a separate clear coat is installed, the catalogue stores the colouring treatment and clear film as two physical layers. Where one proprietary product genuinely combines colour and finish, the tool records the combined product without inventing an extra clear layer.

## Lead-paint encapsulation anatomy

A drawable encapsulation assembly contains at least:

1. the real host substrate;
2. the surveyed retained lead-paint field;
3. documented preparation compatible with the management method;
4. the purpose-selected encapsulating coating system;
5. field boundaries, edges, penetrations and damaged areas; and
6. inspection and maintenance information.

The model must preserve the underlying hazard field even when it is hidden from the rendered view. Damage to the encapsulating layer should expose an inspection state, not silently delete the hazard record.

Encapsulation is not appropriate merely because removal is inconvenient. The method, existing-film condition, adhesion, access, likely damage and ongoing management are competent-person decisions under the applicable hazardous-paint framework.

## Wallcovering physical hierarchy

A finished wallcovering is not one image on a wall. From host outward it can contain:

1. **Host substrate.** Plasterboard, fibre cement, masonry, existing suitable painted surface or another approved wall.
2. **Repairs and preparation.** Permanent fillers remain; cleaning and sanding are work operations.
3. **Wallcovering primer-sealer.** Creates a compatible, more uniform receiving surface.
4. **Size coat.** Regulates suction, slip and paste behaviour where the selected system uses it.
5. **Lining paper.** An optional physical paper or fibre underlayer.
6. **Adhesive film.** Site-applied, water-activated or factory pressure-sensitive, according to topology.
7. **Wallcovering sheet.** An installed drop, border or ordered mural panel.
8. **Seams, corners and edges.** Real lines and narrow sheet returns that control layout and repair.

Wallpaper is a decorative finish over a wall lining or solid wall. It is not the plasterboard or other lining itself.

## Wallcovering installation topologies

### Paste the wall

Compatible adhesive is applied to the prepared wall and the dry covering is placed into it. Many non-woven products use this method, but non-woven construction does not prove it for every product.

Permanent layers are wall preparation, adhesive film and covering sheet. The paste bucket, roller and temporary wet state are not completed-building objects.

### Paste the paper

Adhesive is applied to the covering backing. Some papers or specialty materials are then booked or allowed to relax for a documented time before hanging.

Booking is a temporary installation state. It is not an extra folded layer in the completed wall.

### Ready-pasted

A dry factory adhesive is already present on the backing and is activated with water according to the product instructions. This is distinct from site-applied paste and from pressure-sensitive self-adhesive film.

### Self-adhesive or peel-and-stick

A pressure-sensitive factory backing bonds to a compatible smooth, cured surface after its release liner is removed. The pressure-sensitive adhesive stays in the building. The release liner is packaging waste and is not part of the completed assembly.

Removable, repositionable and residue-free are product-evidence claims, not consequences of the words peel and stick.

## Wallcovering product families

### Paper and non-woven wallpaper

Paper wallpaper can absorb moisture and change dimensions during pasting. Non-woven wallpaper uses a dimensionally stable fibre construction, often suited to paste-the-wall hanging. Each still needs its actual backing, width, pattern, batch, adhesive and removal data.

### Vinyl constructions

These terms are not synonyms:

- **vinyl-coated paper** has paper as the main backing with a relatively thin coated face;
- **solid vinyl wallcovering** has a substantial vinyl face on a backing; and
- **linen- or fabric-backed vinyl** uses a woven backing beneath the vinyl face.

Decorative vinyl wallcovering is also not the same as a classified wet-area vinyl wall-sheet lining or vinyl floor covering.

### Textile, grasscloth, flock and foil

Woven textile has a real weave and fibre direction. Grasscloth has natural linear fibres and intentional panel-to-panel variation. Flock has short raised fibres and a pile direction. Foil has a highly reflective thin face that can reveal small substrate and seam irregularities.

The model should retain:

- top direction;
- face and backing;
- batch or dye lot;
- expected shade variation;
- pattern repeat and match;
- face sensitivity;
- adhesive and seam method; and
- selected cleaning and fire evidence.

Grasscloth seams can remain visible and natural fibre can vary. A renderer must not automatically treat every difference as a defect or force a seamless repeating texture.

### Relief and paintable wallcovering

Embossed paintable paper and heavier moulded relief wallcovering are different products. Anaglypta and Lincrusta are retained as useful proprietary or legacy search terms rather than universal canonical identities.

A painted relief system contains both the installed embossed sheet and the later conformal paint film. It must not be simplified to texture paint or a plaster moulding.

### Murals

A mural is one composed image divided across ordered panels. It uses panel number, image datum, overall crop, panel width, overlap or butt arrangement and opening cuts.

Repeating wallpaper uses pattern-repeat logic. A mural uses image-composition logic. The tool must not tile a mural image at every panel.

## Seams, corners and edges

### Butt seam

Two finished sheet edges meet without an intended face overlap. The seam can be geometrically close to zero width but remains important for pattern matching, quantity, repair and inspection.

### Double-cut seam

Two heavy or untrimmed edges overlap temporarily and are cut together. Waste strips are removed so the finished edges meet as a butt joint. The completed model contains one seam, not a permanent double-thickness overlap.

### Internal corner

A narrow return commonly carries one drop through the concave corner. The first sheet on the next wall is then set out independently or overlapped as required. This avoids forcing a full-width sheet to follow an out-of-plumb corner.

### External corner

A sufficiently flexible and compatible sheet can wrap around the convex arris so the vulnerable edge sits away from the corner. Stiff, brittle, deeply embossed or specialist materials may need a cut, trim or another documented detail.

### Trimmed edge

Every wallcovering field has real top, bottom, opening, fitting and finish-change boundaries. A trimmed edge is not automatically sealed, caulked or covered by trim. Add those objects only when physically specified.

Dark or strongly coloured wallcoverings may receive a compatible narrow seam-edge colour treatment. This is separate from face paint and is created only when actually used.

## Pattern, batch and appearance data

The following are normally attributes rather than separate physical objects:

- colour and colourway;
- sheen or gloss;
- pattern artwork;
- straight, drop, half-drop, random or reverse-hang match instruction;
- pattern repeat;
- batch or dye lot;
- top direction;
- expected natural variation;
- declared washability or cleanability;
- declared VOC data;
- coverage rate;
- wet- and dry-film target;
- product code and certification; and
- approved sample or mock-up reference.

They still drive geometry and evidence. Pattern repeat changes drop cutting and waste. Batch affects visible consistency. Sheen changes rendering. Dry-film build can affect inspection. An attribute is not unimportant merely because it is not a separate solid.

## SketchUp generation rules

### 1. Start from a real host face

Every installed finish field must reference a wall, ceiling, door, trim, cladding, timber, masonry or other real host object. Do not create an unhosted rectangle and call it compliant paint or wallpaper.

The host link should survive editing. If the host opening, corner or extent changes, the tool can identify affected finish geometry without guessing from spatial overlap alone.

### 2. Choose the assembly topology before the appearance

For paint, choose substrate and exposure, retained existing film, preparation, first-coat roles and coat sequence before selecting colour and sheen.

For wallcovering, choose paste-the-wall, paste-the-paper, ready-pasted or self-adhesive topology before generating drops. Appearance does not identify adhesive placement.

### 3. Keep graph layers even when geometry is visually collapsed

Paint and adhesive films are often too thin to show as separate solids at normal model scale. The ontology should still keep them as separate objects with ordered relationships.

A practical tool can offer two views:

- **documentation view:** one host-following finish surface carrying the complete layer graph and quantities; and
- **exploded or forensic view:** individually offset layers exaggerated for inspection.

Do not offset many coincident faces by arbitrary real-world thicknesses merely to avoid z-fighting. Store the declared or nominal build and use controlled display offsets.

### 4. Divide finish fields at real boundaries

Paint fields divide at:

- substrate or coating-system change;
- colour or sheen change where separately scheduled;
- corners and returns where quantity or application changes;
- doors, windows, vents and fittings;
- movement joints and intentionally unpainted surfaces; and
- hazardous or repair-zone boundaries.

Wallcovering fields additionally divide at every drop or panel edge, corner return, trim line and mural crop.

### 5. Generate wallcovering drops from roll data

The generator needs:

- usable wall field width and height;
- roll width and usable roll length;
- top and bottom trim allowance;
- pattern repeat and match offset;
- set-out datum and direction;
- opening treatment;
- corner returns;
- panel or drop order; and
- product rules for reversing, booking and seams.

For repeating wallpaper, calculate cut length from wall height, trim allowance and the next usable pattern alignment. For a half-drop or other offset match, neighbouring drops do not begin at the same pattern phase. For murals, ignore roll-repeat logic and place numbered image panels against the mural datum.

Roll coverage printed by a supplier is not sufficient for final quantities because room dimensions, pattern repeat, match, unusable remnants, corners and defects alter yield.

### 6. Make seams selectable

A seam should be an addressable entity connected to its left and right sheets. This permits:

- pattern-alignment checks;
- open- or damaged-seam reporting;
- double-cut versus factory-trimmed method;
- edge-colour and adhesive repair records;
- individual drop replacement; and
- quantity and labour planning.

### 7. Preserve direction

Timber grain, metallic flake, pearlescent work, roller texture, textile pile, grass fibre, flock, foil and wallcovering top direction can all affect appearance. Store a local directional axis on the finish object instead of relying only on world axes or a bitmap rotation.

### 8. Quantities follow physical roles

Useful calculated quantities include:

- net and gross coated area by substrate and system;
- number of application coats;
- product coverage adjusted only by documented factors;
- perimeter caulk length;
- local repair and spot-primer area;
- texture area and declared build;
- timber face, edge and end-grain areas;
- wallcovering drops, cut lengths and roll yield;
- seam, border and trimmed-edge lengths;
- adhesive area by topology; and
- mural panel count and crop.

Do not multiply a combined primer-sealer-undercoat into three product quantities. Do not count release liners or cut waste as installed materials, though the estimator may report them separately as supply waste.

### 9. Evidence is linked, not drawn

Store product data sheets, APAS or other certification, test reports, hazardous-paint surveys, approved samples and inspection records as evidence linked to objects and fields. They must not become visible coating layers or geometric badges that imply compliance.

### 10. Never infer compliance from a rendered texture

A surface that looks glossy, rough, waterproof, metallic, fire resistant, mould resistant or magnetic in SketchUp proves none of those properties. The renderer communicates appearance. The ontology carries identity and evidence. The applicable NCC and project process determine compliance.

## High-risk terminology traps

### Paint, coat and system

Paint is material. A coat is one application and resulting film. A system is the ordered combination. Asking for paint must not silently choose substrate preparation and coat count.

### Primer, sealer and undercoat

These are roles that can be performed by separate products or one multi-role product. They are not universal synonyms.

### Enamel

Enamel does not necessarily mean oil-based or gloss. Record the actual binder, carrier, sheen and performance.

### Flat, matt and low sheen

These are related product descriptions, but their ranges differ. Retain the declared product classification or measured gloss data.

### Clear and colourless

Clear means the grain remains visible, not that the coating causes no colour or sheen change.

### Stain, oil and varnish

Stain colours timber. Penetrating oil enters the surface with low build. Varnish forms a film. One proprietary product can combine functions, but the terms remain physically different.

### Texture coat and render

Texture coat is an aggregate-filled coating. Render is a separate levelling or finish layer. Do not merge them because both look rough.

### Weatherproof, waterproof and exterior

These words do not identify one construction. Record whether the coating is merely weather-exposed, is part of an evidenced wall weatherproofing system or is a classified waterproof membrane.

### Fire-retardant, intumescent and ordinary paint

They are not aliases. Fire performance requires its own tested system and substrate context.

### Wallpaper and wall lining

Wallpaper is a finish. Plasterboard, fibre cement and other sheets are wall linings. Lining paper is a thin wallcovering preparation sheet and is not plasterboard.

### Ready-pasted and self-adhesive

Ready-pasted uses water-activated factory adhesive. Self-adhesive uses pressure-sensitive backing. Their preparation and installation are different.

### Size

In wallpaper work, size can mean a preparatory coat. It does not mean sheet dimensions in that context.

### Butt seam and double-cut seam

A butt seam describes the finished edge-to-edge junction. Double cutting is one way to create matching edges. Not every butt seam is double cut.

### Grasscloth variation

Natural shade, fibre and panel variation can be inherent. Do not classify it as a defect solely because a digital texture can be made seamless.

## Explicit exclusions and future research

This slice does not yet attempt complete object coverage for:

- intumescent, fire-retardant and other fire-protective coating systems;
- engineered structural-steel, marine, immersion and industrial protective coatings;
- powder coating, coil coating, anodising, electroplating and factory metal finishes in depth;
- limewash, mineral silicate paint, distemper, casein paint and specialist heritage systems;
- polished plaster, Venetian plaster, microcement and decorative mineral renders;
- graffiti-removal and sacrificial or permanent anti-graffiti systems;
- hygienic, clean-room, food-production and high-chemical-resistance coatings;
- complete resin floor and trafficable coating systems;
- roof membranes and reflective roof coatings;
- complete mural signwriting, hand-painted art, gold leaf and decorative gilding;
- sprayed acoustic, thermal or fire-protective finishes;
- detailed wallpaper-removal and hazardous-waste process objects;
- temporary masking, access equipment, containment and environmental controls;
- proprietary paint, stain and wallcovering product libraries; and
- calculation engines for coverage, drying, moisture, condensation, fire, weatherproofing or hazardous-material risk.

Those families need their own standards, legislation, test methods, training sources and manufacturer evidence. They must not be manufactured by extending a decorative wall-paint object beyond its documented role.

## Acceptance and confidence rules

An object is accepted only when its physical existence, meaning and main relationships have suitable supporting sources. Primary regulator and standards metadata support regulatory and standards facts. Australian training and reputable industry material support trade vocabulary and physical installation anatomy.

Each object in this catalogue has at least two registered sources. That source count is not the same as project suitability. A real selection still needs the applicable substrate, exposure, product data and project evidence.

Conflicting or overloaded terminology is placed in `data/review/unresolved_terms.json`. A drawing command must resolve the context rather than silently map an ambiguous phrase to one object.

## Files and reproducibility

- `data/catalog/decorative_finishes_catalog.json` contains the 105 source-tagged objects and assemblies.
- `data/standards/standards_registry.json` contains public metadata for the five supporting standards.
- `data/sources/source_registry.json` contains the regulator, standards, training and industry sources.
- `data/review/unresolved_terms.json` keeps terminology boundaries and next actions visible.
- `exports/disciplines/decorative_finishes/` contains the generated ontology, relationship graph, glossary and coverage report.
- `scripts/generate_ontology_outputs.rb` creates deterministic repository outputs.
- `scripts/validate_ontology.rb` checks schema, enums, IDs, sources, graph links, inverses and discipline exports.

Run from the repository root:

```powershell
ruby scripts/generate_ontology_outputs.rb
ruby scripts/validate_ontology.rb
```

Ruby is the language embedded in SketchUp, while the research data remains ordinary JSON that can be consumed on Windows and macOS.
