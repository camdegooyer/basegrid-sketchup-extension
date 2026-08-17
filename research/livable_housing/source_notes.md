# Livable-housing physical-object source notes

## Scope of this slice

This slice identifies 114 physical assemblies and components needed to draw the livable-housing construction exposed by NCC Volume Two Part H8 and the ABCB Standard for Livable Housing Design 2022. The standard is organised around six practical subjects:

1. a step-free path to the dwelling;
2. a usable dwelling entrance;
3. internal doors and corridors on the nominated route;
4. an entry-level sanitary compartment;
5. one hobless, step-free shower; and
6. concealed wall construction capable of supporting future grabrails.

The catalogue covers the construction, not just the visible finishes. It includes path slabs and paving layers, raised boardwalk framing, ramp and landing construction, gates, parking surfaces, doors and hardware, threshold profiles, entrance drainage, toilet and basin fixtures, and timber, plywood, light-gauge-steel, metal-plate and solid-wall reinforcement options.

This is a physical-object discovery slice. It is not a livable-housing certificate, an accessibility design to AS 1428.1, a plumbing design, a structural calculation or permission to use a generic detail in every jurisdiction.

## Current regulatory position

The NCC is a model code. State and territory legislation gives it legal effect, with local dates, variations, concessions and transitions. There is therefore no safe Australia-wide answer to "which NCC applies?" based only on the national publication date.

At the research date of 16 August 2026, the ABCB's current-version guidance says NCC 2022 Amendment 2 took effect nationally as an available edition on 29 July 2025, while jurisdictions may consider adopting NCC 2025 from 1 May 2026. Actual adoption remains a state or territory decision. Existing Buildgrid object research continues to record the edition from which each fact was extracted; a future project check must also select the jurisdiction, approval pathway and relevant date.

The H8 position identified from current official jurisdiction sources is:

| Jurisdiction | Public-source position captured for this slice |
| --- | --- |
| New South Wales | The NCC 2022 NSW schedule disapplies H8 to Class 1a buildings. |
| Queensland | Livable-housing requirements commenced on 1 October 2023, with Queensland alternatives and variations in QDC MP 4.5. |
| Victoria | Mandatory commencement was 1 May 2024, subject to transitions and exemptions. |
| Australian Capital Territory | The ACT applies local implementation, alteration, extension and exemption rules that must be checked with the project approval path. |
| Northern Territory | Requirements apply to new-home building-permit applications from 1 October 2023, with local guidance and exemptions. |
| South Australia | The modern-homes provisions commenced on 1 October 2024 with local delivery arrangements. |
| Tasmania | Livable-housing provisions commenced on 1 October 2024, with the current Director's determination and transitions remaining relevant. |
| Western Australia | WA modifications disapply NCC 2022 Parts G7 and H8, and the cited WA guidance says those modifications remain ongoing. |

This table is research metadata, not a substitute for the current legislation or a project-specific approval decision. Software should ask for jurisdiction and date before displaying an H8 compliance result. Objects can still be drawn voluntarily in a jurisdiction that disapplies the minimum requirement.

## What H8 calls up

NCC Volume Two H8 directs the Deemed-to-Satisfy construction to the ABCB Standard for Livable Housing Design. The standard in turn lists documents relevant to structural actions, timber and steel framing, termites and bushfire construction:

- AS/NZS 1170.1:2002 for structural actions;
- AS 1684.2:2021, AS 1684.3:2021 and AS 1684.4:2010 for relevant timber-framing paths;
- AS 3660.1:2014 for termite management;
- AS 3959:2018 for construction in bushfire-prone areas; and
- NASH Standard Parts 1 and 2 for relevant residential steel framing.

The standard PDF's extracted text can visually lose a digit in the termite reference. Its title and the published reference are for AS 3660.1, not AS 3600.1. The registry therefore records AS 3660.1:2014.

AS 3740:2021 is also connected to the selected shower because H8's step-free entry does not remove the wet-area waterproofing path. The waterproofing catalogue retains the shower tray, membrane, screed, waterstop, drain and screen interfaces rather than duplicating them here.

The ABCB Standard does not make an H8 dwelling automatically equivalent to AS 1428.1 accessible design or to specialist disability accommodation. AS 1428.1 is retained as a supporting terminology and later-research source, not silently loaded as the rule set for every H8 path, ramp, doorway, sanitary compartment or shower.

## Draw objects; calculate constraints

The ontology keeps a strict boundary between real construction and the tests applied to it.

Physical objects include:

- concrete path slabs, paving units, bedding, compacted base and edge restraints;
- decking boards, joists, bearers, posts, braces and fasteners;
- ramp surfaces, landings, gates and gate hardware;
- parking hardstands, bituminous surfaces, markings and wheel stops;
- entrance and internal doors, frames, hinges, tracks, rollers, guides, pockets, handles and stops;
- threshold and sill profiles, transition strips and entrance channel drains;
- toilet pans, cisterns, carrier frames, seats, connectors and fixings;
- fixed basins, cabinets, tapware and sanitary-room accessories; and
- structural plywood, timber noggings, steel noggings, backing plates, supports and fasteners behind wall lining.

The following are properties, datums, calculations or review overlays rather than building solids:

- access-path and corridor clear width;
- path gradient, ramp gradient, crossfall and aggregate ramp length;
- parking-space dimensions;
- door clear opening;
- an entrance arrival or door-operation clearance envelope;
- the toilet-pan centreline and front edge;
- sanitary-compartment circulation space;
- shower entry level difference;
- future grabrail fixing zones;
- exemption tests; and
- pass, warning and compliance states.

A SketchUp tool may show these as dimensions, guides, translucent review areas or warnings. It must not count them as concrete, floor area, wall lining or another supplied material.

## Step-free access route

The access assembly connects a permitted origin to the nominated entrance. Depending on the site and dwelling, the origin can be the allotment boundary, an attached garage or carport, or an incorporated parking space for the dwelling. The route should be stored as ordered physical segments rather than one generic line.

For each segment, retain:

- segment type: path, ramp, step ramp, landing, gate crossing or parking transition;
- start and end levels;
- centreline and finished edges;
- finished surface and supporting construction;
- longitudinal fall and crossfall;
- joints, drainage and edge restraints;
- connections to adjacent segments;
- overhead or side obstructions; and
- the compliance path and any exemption evidence.

A concrete path is more than its top face. It can contain subgrade preparation, compacted base, slab, reinforcement or joints, edge interfaces and drainage. A unit-paved path contains individual pavers, bedding, base and restraints. A suspended boardwalk contains decking, joists, bearers, posts, bracing, connections and a drainage or ground surface below.

Path, ramp and step ramp are not interchangeable names. Their physical geometry may look similar, but the selected gradient and purpose determine the route role. If a route contains several separated ramp pieces, each piece remains a real object. Any rule applying to their combined length is calculated from the ordered route; it is not one imaginary ramp passing through the intervening landings.

## Parking, gates and transitions

An incorporated parking space is included when it forms the selected access origin. The catalogue can draw a concrete hardstand, a bituminous surface, line marking, wheel stop and the joint where parking meets the pedestrian route.

This does not automatically create an AS 2890.6 accessible parking bay. H8 parking and an accessible bay can differ in purpose, signs, symbols and adjoining shared-space construction. The selected compliance path must be explicit.

A gate is also more than a clear opening. The leaf, posts, hinges, latch and stop affect the usable passage and approach. A future check should calculate the clear opening from the gate in its installed open state, just as it does for a door.

## Nominated entrance and weatherproofing

The nominated entrance is the external door reached by the compliant route. It need not be the door casually called the front door. The model links its entrance role to the access route while retaining architectural labels such as front, side, rear or garage entry separately.

The entrance assembly includes:

- the doorset and its actual frame, leaf or panel, hardware and open state;
- the outside arrival landing;
- the sill and threshold profile;
- the inside and outside finished floor levels;
- surface falls and drainage;
- flashings, membranes and interfaces with the wall and floor; and
- any roof cover or permeable-deck drainage approach.

Clear opening is derived from installed geometry. It is not the same as leaf width, frame size or the rough opening in the wall. Stops, hinges, handles, sliding-panel overlap and the achievable open position can all reduce the passage.

The catalogue distinguishes a level threshold, a bevelled sill lip, a ramped threshold and a raised weather sill. Product labels such as flush sill or low sill are search terms, not geometry. A reliable component needs the actual section profile, tracks, ridges, drainage paths and adjoining finished levels.

Step-free entrance design must not be achieved by simply deleting a normal weathering upstand. The source material shows coordinated approaches such as an external linear drain, a permeable deck with a lower drainage surface, or suitable weather cover. The selected solution still has to coordinate surface falls, sill drainage, flashings, outlets, termite inspection and, where relevant, bushfire construction.

The entrance-drain family therefore separates the channel body, trafficable grate, outlet, end caps, anchors, waterproofing flange and removable debris basket. A visible slot alone cannot show where water goes or how the membrane terminates.

## Internal doors and corridors

The internal circulation route connects the nominated entrance to the required rooms and features. The catalogue covers swing doors, surface sliders, cavity sliders, folding doors and stacking panels, with leaf or panels, frames, jambs, stops, hinges, tracks, rollers, guides and handles.

Finished clear corridor width is measured between actual finished obstructions. Structural wall spacing or a nominal hallway label is not enough. Linings, skirtings, door hardware, radiators and fixed joinery can change the local clear width.

The door's clear opening is likewise calculated at its fully open state. A cavity slider must retain the moving panel envelope, pocket frame, split studs, track, hanger and base guide. These parts become especially important where the pocket wall is also expected to support a future grabrail.

## Sanitary compartment

Sanitary compartment names the room or space; toilet pan names the fixture. The room assembly contains the finished enclosure, doorway, toilet suite, other fixed fixtures, joinery, accessories and future-grabrail construction.

The H8 layout is assessed from the installed pan geometry. Each pan component therefore exposes a centreline and front-edge datum. These datums move with the selected product and its installed transform. They are not permanent construction lines or separate objects.

The catalogue contains floor-mounted and wall-hung pan options; exposed and concealed cisterns; a concealed carrier frame; flush plate; seat and lid; pan connector; and fixture fixings. A wall-hung carrier is a substantial hidden frame and can compete for the same wall space as services and future-grabrail backing.

A fixed vanity or basin is modelled because it is a real obstruction when present, not because Part 4 necessarily requires one inside the nominated compartment. Cabinet doors, drawers, tapware, accessories and a floor-mounted door stop may also intrude into the reviewed space.

The circulation area around the pan is a review overlay over the real floor. It should be generated from current pan datums and tested against finished walls, doors in the applicable positions, fixtures, joinery, stops and other fixed projections. It must not become a quantity-bearing floor object.

## Hobless, step-free shower

Hobless and step-free are two separate conditions. Hobless means the water-retaining detail does not use a raised shower hob. Step-free concerns the crossing from the adjoining finished floor into the shower. A shower floor can and should still fall to its drain.

Walk-in is an imprecise sales or layout term. A walk-in shower can still contain a step, lip or other obstruction, and an H8 shower is not automatically an AS 1428.1 accessible shower.

The H8 assembly reuses the waterproofing catalogue's level-threshold shower, in-situ tray, screed, membrane, waterstop, drain and penetration objects and the glazing catalogue's screen construction. It adds the nominated step-free role and links the surrounding future-grabrail reinforcement. This prevents two overlapping shower trays or membranes from being generated.

The tool should retain the inside and outside levels, entry line, waterstop profile, floor-fall planes, drain, screen base, door movement, waterproofing route and reinforcement faces. It should report hobless, step-free and any separately selected accessibility result independently.

## Future-grabrail wall reinforcement

Part 6 is about concealed supporting construction for a grabrail that may be installed later. It does not require the visible rail to be generated as part of this H8 slice.

The physical reinforcement options identified are:

- a structural plywood sheet supported and fixed to framing;
- solid timber noggings or blocking between studs;
- formed light-gauge-steel noggings in steel framing;
- a steel or other suitable metal backing plate;
- the sheet-edge supports and fasteners completing the load path; or
- a suitable solid concrete or masonry wall acting as the fixing substrate without an added backing layer.

Ordinary wall noggings do not automatically satisfy the future-rail role. The backing must be positioned from the nominated toilet, shower or bath and retain its material, thickness or section, height and horizontal extent, wall face, framing supports, connections, services, openings, lining build-up and inspection record.

The catalogue has separate fixture-relative assemblies for the bath, shower, toilet side wall and toilet rear wall. The installed fixture is the positioning host. For example, changing the toilet product or moving its pan centreline should flag the related reinforcement for repositioning and review.

Structural plywood does not mean any sheet that looks like plywood. Grade, thickness, supported edges and fastening matter. A solid masonry or concrete wall can be the substrate itself, but hollow cores, chases, thin leaves and services still affect the later anchor path. The tool references the existing wall geometry rather than drawing an invisible duplicate reinforcement layer.

Cavity sliders need deliberate coordination. The moving panel occupies the wall pocket, and a future screw can damage or stop it. A reinforced pocket-wall assembly therefore stores the panel travel envelope, split studs, separate backing construction, safe fixing depth and exclusion zones. It must not assume that a standard cavity-slider frame can accept grabrail fasteners anywhere.

## CAD behaviour implied by the research

A future SketchUp implementation should:

- ask for jurisdiction, approval date or pathway before offering compliance claims;
- let the user nominate the access origin, entrance, internal route, sanitary compartment and shower;
- build the route from editable physical segments and real junctions;
- derive clear widths, openings, slopes, crossfalls and circulation areas from finished geometry;
- keep regulatory overlays out of material quantities;
- use product-specific door, sill, drain, pan and cistern geometry where available;
- expose hidden drainage, service and backing layers in section or inspection views;
- retain one physical object when it carries several roles rather than drawing duplicates;
- flag downstream objects when a host door, fixture, floor level or wall moves;
- distinguish a missing fact from a failed check; and
- identify the edition and evidence source behind every reported rule result.

The safest default is to draw what is known and mark the remaining design input as unknown. The tool should not invent a ramp, drain, backing thickness, fastener pattern or exemption simply to make a green result.

## Boundaries and later research

The following remain outside this slice:

- complete AS 1428.1 accessible paths and circulation;
- installed grabrails and their profiles, brackets and fixings;
- accessible sanitary facilities and showers;
- AS 2890.6 accessible parking construction;
- tactile ground-surface indicators;
- lifts, platforms and other mechanical vertical transport;
- complete plumbing-product and sanitary-drainage standards;
- specialist accommodation design;
- detailed structural sizing and fixing capacity; and
- state or territory approval logic beyond the public status metadata captured here.

These later families may reuse H8 path, door, fixture and wall objects, but their extra requirements must remain separate constraint sets and physical additions.

## Primary source set and licence boundary

Primary sources registered for this slice are:

- `SRC-ABCB-CURRENT-NCC` — ABCB General NCC frequently asked questions;
- `SRC-ABCB-V2-H8-LIVABLE` — NCC Volume Two Part H8;
- `SRC-ABCB-LIVABLE-HOUSING-STANDARD` — ABCB Standard for Livable Housing Design 2022 version 1.3;
- `SRC-ABCB-LIVABLE-HOUSING-HANDBOOK` — ABCB Livable Housing Design Handbook 2022 version 1.1; and
- the individual NSW, Queensland, Victoria, ACT, Northern Territory, South Australia, Tasmania and Western Australia implementation sources in the registry.

The catalogue stores original plain-English definitions, public document identity and broad regulatory relationships. It does not reproduce licensed Australian Standard tables, figures or detailed prescriptive text. Exact design values, referenced editions, jurisdiction variations and product installation requirements must be checked from authorised current documents when implementation reaches a compliance or design feature.

