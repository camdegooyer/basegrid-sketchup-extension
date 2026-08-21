# Confirmed decisions

## 2026-08-16 — Fresh start

- The previous Buildgrid contents were cleared.
- The repository begins with no chosen architecture or implementation stack.
- Earlier SketchOB and Buildgrid work is reference material only.
- Development proceeds through small, explicit decisions and changes.

## 2026-08-16 — Construction ontology pilot

- The product goal is a SketchUp extension backed by an Australian-first ontology of physical building objects and assemblies.
- Canonical ontology data uses dependency-free JSON so it is portable across Windows and macOS and can be consumed by SketchUp's Ruby environment.
- Materials and product specifications remain separate from the construction roles they can fulfil.
- The first end-to-end research deliverable is timber wall, floor and roof framing.
- Existing catalogue facts retain their stated NCC 2022 Amendment 2 extraction baseline. From the 16 August 2026 research date onward, project applicability must select jurisdiction, approval pathway, relevant date and adopted NCC edition because NCC 2025 adoption is occurring independently and is not assumed nationally.
- Definitions are original plain English. Paid standards are referenced by metadata and provenance only; their text is not reproduced.
- Uncertain Australian terminology is retained for review and is not silently merged.
- Every researched discipline is exported both as part of the combined ontology and as an independent JSON/JSONL/relationship/glossary/report slice.
- Supporting ground, constructed footings, concrete material and reinforcement roles remain separate identities even when builders use overlapping shorthand.
- Masonry generation starts by selecting the wall arrangement—veneer, cavity, single leaf, reverse veneer or reinforced—before placing leaves, units, ties and moisture-control parts.
- Masonry unit material and unit form are separate classifications. For example, a clay brick can also be a cored unit without creating a canonical object for every material-and-shape combination.
- Wall cavities, weepholes and articulation gaps are physical negative-space objects because their geometry and continuity affect drawing and checking tools.
- Damp-proof courses and masonry flashings remain separate functional roles even when one sheet product can perform both roles in a particular detail.
- Reinforced masonry is included for whole-building discovery, but the Housing Provisions Section 5 prescriptive wall rules are not treated as a design route for it.
- Cold-formed steel framing and hot-rolled structural steel remain separate disciplines because their member families, section geometry, connection systems and NCC pathways differ.
- Steel-frame member roles remain separate from section shapes. A C-section can be a stud, joist, bearer or rafter, and the selected proprietary system supplies the actual profile and capacities.
- Empty service holes and the grommets that line them are separate physical objects; a tool must not create extra holes without the frame design permitting them.
- NASH Standard Part 2 and ISO 8336 are recorded as directly referenced technical documents alongside, but not mislabelled as, the 62 directly referenced AS and AS/NZS documents.
