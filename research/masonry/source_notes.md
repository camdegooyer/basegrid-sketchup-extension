# Masonry research notes

Research date: 17 August 2026. Regulatory baseline: NCC 2022 Amendment 2.

These notes record the public evidence used to discover physical objects and relationships. They do not reproduce paid Australian Standards and are not design or compliance instructions.

## Result of this research pass

The original residential-masonry slice contained 54 objects. This pass adds 122, taking the masonry discipline to 176 objects and assemblies. The added families are:

- special and purpose-made masonry units and common bond layouts;
- reinforced masonry bond beams, lintels, grouted cores, cleanouts and bar-positioning parts;
- connectors, cramps, remedial ties, bed-joint tying mesh, shelf-angle supports and cavity accessories;
- autoclaved aerated concrete (AAC) blockwork and reinforced AAC components;
- solid, tied, adhered and mechanically anchored stone construction;
- mud brick, compressed earth block and rammed-earth construction; and
- solid render materials, coats, reinforcement, lath, fasteners, beads and terminations.

The catalogue separates material, product shape, installed role, assembly and temporary construction state. For example, a bond-beam block is a shaped masonry unit; the reinforced, grouted beam made from a course of those units is a structural member. This distinction is essential for reusable SketchUp geometry and reliable quantities.

## Regulatory boundary

Housing Provisions Part 5.1 divides its masonry content into masonry veneer, cavity masonry, unreinforced single-leaf masonry, isolated piers, masonry components and accessories, and weatherproofing. That remains the discovery spine for house-scale masonry.

The prescriptive pathway is intentionally limited. Part 5 does not make every masonry, stone, AAC, earth or rendered wall compliant merely because the ontology can draw it. AS 3700 and AS 4773 provide broader masonry design and construction pathways, while reinforced masonry is directed outside the general Section 5 prescriptive wall rules. AAC panels, engineered stone facades, earth walls, tall or heavily loaded walls and proprietary systems may require project engineering, evidence of suitability, a different NCC pathway and manufacturer details.

The dataset uses NCC 2022 Amendment 2 as its audited baseline. A project must separately identify the legally adopted NCC edition, state or territory variations, building classification, approvals and contract documents. A later published standard is not silently substituted for the edition called up by that project.

## Wall arrangements

- Masonry veneer has one non-structural or limited-load masonry leaf tied to separate structural backing.
- Cavity masonry has inner and outer masonry leaves connected by ties across a drained cavity.
- Unreinforced single-leaf masonry has one masonry leaf and may rely on returns or engaged piers for stability.
- Reverse veneer places the masonry leaf on the room side of a framed and insulated external envelope.
- Reinforced masonry combines masonry units with grout and reinforcing steel in selected cores, bond beams, lintels, piers or other designed zones.
- Solid stone, tied stone veneer, adhered stone veneer and anchored stone facade are four different construction methods, not style settings for the same wall.
- Earth construction can use laid units such as mud bricks or compressed earth blocks, or monolithic compacted lifts such as rammed earth.

These arrangements change the load path, support width, leaf count, joint pattern, connection method, cavity and moisture route. The drawing tool should select the arrangement before it generates units or panels.

## Masonry materials, unit forms and special units

Part 5.6 names clay brick, calcium-silicate brick, concrete brick and concrete block and distinguishes solid, cored and hollow unit forms. Material and form remain separate axes. A concrete product may be solid, cored or hollow; a clay product may also have more than one form. Combining every material and form into a different master object would create a brittle catalogue.

Hollow units expose face shells, webs and cores. Those parts affect visible cut geometry, mortar bedding, reinforcement routes and grout volume. At coarse display levels they can be represented by an outer block and core metadata. At fabrication or coordination detail they need actual void geometry.

Purpose-made units are not generic blocks with informal names:

- a closure or half unit closes a bond without relying on a rough site cut;
- corner, jamb and sill units shape exposed returns and opening edges;
- coping and capping units weather the top of a wall;
- bullnose and splayed units create a deliberately shaped face or arris;
- a bond-beam or U-shaped unit leaves a channel for reinforcement and grout;
- knockout units allow webs to be removed to continue a bond-beam channel;
- lintel units form permanent masonry casing around a designed reinforced lintel;
- cleanout units or openings provide temporary access to remove debris and inspect a reinforced core before grouting;
- open-end and control-joint units accommodate reinforcement, construction sequence or movement details; and
- screen or breeze blocks are open decorative or ventilation units, not ordinary hollow loadbearing units.

A site-cut unit remains an instance of its parent product with cut geometry and waste data. It should not become a new universal product definition.

## Courses, bonds, mortar and joints

A course is one horizontal run of units. Running bond offsets successive vertical joints, while stack bond aligns them. Header, soldier and brick-on-edge describe unit orientation and role. These terms are retained as bond or placement objects because they determine the transformation of every unit instance, not simply its material appearance.

Mortar bedding and perpend joints are separate physical joint volumes. A bed joint lies horizontally; a perpend is the vertical joint between adjacent units. Flush, raked, weather-struck and other finishes should eventually be represented as joint-face profiles attached to the mortar joint rather than as different wall materials.

A bond layout generator therefore needs unit module, actual unit dimensions, joint thickness, reference face, start condition, corner return, opening rules, purpose-made units and permitted cuts. It must not assume that every wall can be closed by stretching the final brick.

## Reinforced masonry anatomy

The advanced slice exposes the parts needed to draw a design supplied by an engineer or documented system:

- a grouted core is the installed core space plus placed grout; core-fill grout is the material;
- a fully grouted zone fills all nominated cores, while a partially grouted wall fills only scheduled cores or zones;
- vertical and horizontal reinforcing bars remain separate steel objects with cover, lap, anchorage and location supplied by the design;
- bar positioners hold bars during construction but do not replace structural reinforcement;
- a reinforced masonry bond beam is a horizontal member made from channel-form units, reinforcement and grout;
- a reinforced masonry lintel performs the opening-spanning role and must not be confused with an individual lintel block;
- a reinforced pier or pilaster is a local thickened or projecting vertical member; and
- cleanout openings, temporary closures and grout stops record the sequence needed to build the final member.

Bed-joint tying mesh is a connector accessory used to tie or control local masonry arrangements. It is not automatically structural bed-joint reinforcement. The public scope of AS 2699.2 expressly separates its connector and non-structural mesh family from products whose structural capacity is established by other design routes.

The ontology can store the supplied bar and grout schedule. It must not invent core selection, reinforcement size, lap length, grout lift, cleanout spacing or capacity from the appearance of the wall.

## Ties, connectors, supports and cavity accessories

A wall tie connects and restrains leaves or connects a veneer leaf to structural backing. The wider connector family includes wall-to-wall connectors, cramps, frame cramps, sliding anchors and built-in anchors. Remedial and helical ties are installed into existing construction and need host, drilling, embedment and installation metadata distinct from built-in ties.

A shelf angle supports masonry vertically at a nominated level. It commonly needs brackets, anchors, shims, a movement gap and coordinated flashing. It is not the same role as a lintel, even when both are angle sections: a lintel spans an opening, whereas a shelf angle supports a run or storey of veneer from the building structure.

A cavity closer closes or protects an opening edge in a cavity. A cavity fire barrier limits concealed fire or smoke spread. They may occupy a similar line in a section but are not interchangeable. A weephole is the drainage opening itself; a weep vent or insert is a product placed in that opening.

Connection geometry must retain both hosts. A tie floating in the cavity without an embedment end and a backing fixing is incomplete geometry.

## Autoclaved aerated concrete

AAC is a lightweight cellular cementitious material. It should not be stored as a generic concrete block or treated as a brand. “Hebel” is a product-system name encountered in Australian practice, not the canonical material term.

The catalogue distinguishes:

- unreinforced AAC masonry blocks laid as blockwork;
- purpose-made AAC lintel, sill, U-section and closure units;
- thin-bed AAC adhesive and patching mortar;
- reinforced AAC wall panels, floor panels, roof panels and stair elements; and
- an internal reinforcement cage cast into reinforced panels.

The existing external-cladding AAC wall panel and fixing objects are reused rather than duplicated. An AAC block wall and a reinforced AAC panel wall have different module, joint, support and reinforcement logic. Panel joints, anticorrosion treatment, bearing and proprietary connectors must come from the selected system evidence.

AS 5146 Parts 1 to 3 provide the public standards family for reinforced AAC structures, design and construction. Their presence does not turn generic dimensions in the ontology into an engineered panel schedule.

## Stone construction

“Stone wall” is too broad for a generator. The catalogue separates natural stone from manufactured stone units and then separates construction method:

- solid stone masonry uses loadbearing or self-supporting stone thickness bonded with mortar;
- tied stone veneer uses discrete ties or cramps to connect a stone leaf to backing, normally with a cavity;
- adhered stone veneer uses a prepared substrate and adhesive or bedding system with no support cavity assumed; and
- an anchored stone facade uses panels, support brackets, restraint anchors, dowels, kerfs or other designed mechanical connections.

Ashlar uses intentionally squared units and controlled joints. Rubble work uses more irregular stones and requires a different packing and jointing strategy. Quoins, sills, lintels, copings, arches, voussoirs and keystones are role-specific pieces, not simply decorative labels.

Support anchors carry gravity load. Restraint anchors control out-of-plane movement and position. Some proprietary anchors perform both roles only when supported by evidence. Bedding mortar locates and supports a unit; pointing mortar finishes the exposed joint. Their physical locations and replacement lifecycle differ even when compatible formulations are used.

Current Australian training-package units provide useful public descriptions of solid, veneer and mechanically anchored stone work. AS 3958:2023 is relevant where a selected natural or manufactured stone product is installed as a tile system. It is not a universal design standard for every stone wall or facade. Post-installed fastenings into concrete may also intersect AS 5216:2021, but the complete anchor, substrate, load and facade design remains project-specific.

## Earth construction

Building earth is a selected and tested mixture, not whatever soil happens to be excavated on site. The mix can contain controlled proportions of soil fractions, water, fibres and stabiliser. Material identity, source, test results and trial panels or units remain project evidence.

Mud bricks are moulded earth units laid in courses, usually with compatible earth mortar. Compressed earth blocks are mechanically compacted units. Stabilised earth blocks include a documented stabilising binder; this does not make every block waterproof. Rammed earth is compacted in formwork as successive lifts and is monolithic construction rather than unit masonry.

The physical family includes earth mixes, units, mortar, fibre, stabiliser, rammed-earth formwork, individual lifts, plinths or capillary breaks, slurry finishes, earth renders and sealers. Formwork is temporary. Each completed lift becomes part of the permanent wall.

Moisture protection is central to earth geometry: ground clearance, plinth or base detail, roof overhang, copings, sills, openings, splash exposure, compatible render and drainage all need explicit interfaces. The Your Home mud-brick and rammed-earth guides provide Australian plain-English system context, but project engineering, material testing and evidence remain necessary because the Housing Provisions do not offer a complete generic prescriptive path for these walls.

## Solid render systems

Render is a built-up plaster finish applied to a solid or prepared support. It must remain separate from a thin decorative texture-coating film, even though product marketing sometimes uses “texture render” for both.

The physical sequence can include substrate preparation, a bonding or splatter coat, local dubbing to level deep irregularities, a base coat, a float or levelling coat and a finish coat. Not every selected system uses every coat. A cement-lime-sand render, lime render and polymer-modified render remain different material families with system-specific compatibility and curing requirements.

Reinforcing mesh is embedded within a coat. Expanded-metal lath is mechanically fixed to supports where render needs a carrier. Lath fasteners, laps, corrosion exposure and isolation therefore differ from embedded mesh. Corner beads form external arrises; casing or stop beads terminate an edge; movement-joint beads keep a moving separation; drip beads shed water; and screed beads establish a plane or thickness datum. One profile must not be substituted merely because it looks similar in section.

HB 161:2005, *Guide to plastering*, is registered only as withdrawn historical guidance. Standards Australia records its withdrawal in 2018. The current CPCCSP3001 training-unit description still names it, which explains continuing industry references but does not restore current status. Current law, project specifications and selected-product evidence must control implementation.

## Standards linked to the slice

Direct or established masonry references in the audited Housing Provisions map include:

- AS 3700:2018 — Masonry structures;
- AS 4773.1:2015 — Masonry in small buildings — Design;
- AS 4773.2:2015 — Masonry in small buildings — Construction;
- AS 2699.1:2020 — Built-in components for masonry construction — Wall ties;
- AS 2699.3:2020 — Built-in components for masonry construction — Lintels and shelf angles — Durability requirements; and
- AS/NZS 2904:1995 — Damp-proof courses and flashings.

Additional public evidence registered for discovery includes:

- AS 2699.2:2020 — connectors and accessories;
- AS/NZS 4455.1:2008 — masonry units;
- AS/NZS 4456 series — methods of test for masonry units, segmental pavers and flags;
- AS 5146 Parts 1 to 3 — reinforced AAC structures, design and construction;
- AS 1672.1:1997 — building limes;
- AS 3958:2023 — ceramic and stone tile installation where that installation method applies;
- AS 5216:2021 — applicable post-installed and cast-in fastenings in concrete; and
- withdrawn HB 161:2005 — historical plastering terminology only.

The five newly registered masonry references are not marked as direct Housing Provisions references, so the audited direct-reference count remains 64. Public metadata for AS 3700 and AS 4773.2 indicates revision work, but the ontology retains the NCC-called baseline until a later adopted pathway is researched explicitly.

Only public metadata, NCC clause pointers and independent public descriptions are stored. Licensed standard content is still required before implementing sizing, durability, tie spacing, lintel capacity, reinforcement, anchor design, construction tolerances or acceptance tests.

## Public sources used

- ABCB Housing Provisions Parts 5.1 to 5.7 and Schedule 2 referenced-document metadata.
- Standards Australia public catalogue records for the standards listed above.
- Australian Government Your Home guides for brickwork, blockwork, mud brick and rammed earth.
- RMIT Build Right masonry-cladding material covering veneer, ties, cavities, flashings and articulation.
- National Dictionary of Building and Plumbing Terms entries for masonry units and wall parts.
- Think Brick Australia and Concrete Masonry Association of Australia technical-manual indexes.
- Hebel public technical documentation for Australian AAC systems.
- Australian training-package unit descriptions for stone construction and solid plastering or rendering.

Full URLs, access status, retrieval date and copyright-use notes are stored in `data/sources/source_registry.json` and generated into `exports/source_audit.csv`.

## SketchUp generation rules carried forward

- Generate assemblies from reusable definitions for units, panels, anchors and accessories; do not explode every repeated object into unrelated faces.
- Give every unit or panel a documented local origin, reference face and length, height and thickness axes.
- Keep material, geometric form and installed role separate. One instance can be a clay product, a cored form and a jamb unit role.
- Let bond layouts place unit instances and purposeful cuts. Keep cut identity, parent product and waste metadata.
- Represent selected hollow cores and cleanout openings explicitly at coordination detail; use lightweight proxy geometry at concept detail.
- Keep temporary objects such as rammed-earth formwork and cleanout closures separate from the completed wall state.
- Model cavities and openings as meaningful void objects with clear dimensions and obstruction checks, not just missing faces.
- Anchor every connector to its two hosts and store embedment, orientation and selected product evidence.
- Reuse existing cross-discipline objects such as AAC cladding panels, reinforcement bars, concrete fastenings, flashings, insulation, fire barriers and decorative coating films instead of cloning them into masonry.
- Store capacity, fire, acoustic, thermal, durability and compliance results as evidence about a complete selected construction, never as facts inferred from colour or visible geometry.

## Known gaps after this pass

- glass-block masonry, prestressed masonry and refractory or specialist industrial masonry;
- segmental retaining walls, concrete paving and interlocking pavement systems;
- proprietary dry-stack, insulated-block and complete engineered masonry systems;
- detailed chimney, fireplace and heritage-masonry construction beyond existing house-scale objects;
- masonry restoration, crack stitching, repointing, desalination, cleaning and efflorescence treatment;
- facade fire-stopping, acoustic junctions and continuous cavity insulation at detailed system level;
- engineered tables for reinforcement, grout, anchors, lintels, shelf angles and movement joints; and
- proprietary product geometry and licensed rules for dimensions, spacing, durability, capacity, testing and tolerances.
