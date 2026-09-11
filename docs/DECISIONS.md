# Confirmed decisions

## 2026-08-16 — Fresh start

- The previous Basegrid contents were cleared.
- The repository begins with no chosen architecture or implementation stack.
- Earlier SketchOB and Basegrid work is reference material only.
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

## 2026-08-22 — First SketchUp tool slice

- The first Basegrid drawing tool is a basic concrete slab created from one selected horizontal SketchUp face.
- The slab is generated below the source face, with the source face retained.
- Face openings are retained in the generated slab.
- The tool remembers the last selected compatible concrete material.
- The concrete selector offers the synced materials belonging to compatible material types; it is not limited to a hard-coded list of concrete mixes.
- Concrete takeoff is included in the first slice and is measured in cubic metres from the generated net slab volume.
- Generated material-carrier groups are tagged according to their material role; the globally unique role/tag naming and folder mapping remain to be defined.
- `Basegrid` is the software name only and is not used as a prefix or folder name for model tags, groups, materials or takeoff categories.
- Tag-folder organisation is editable and user-specific, seeded from a product default.
- Basegrid will not adopt or reproduce SketchOB's tag and estimating-folder hierarchy.
- The first slab role accepts active materials under the web Material Type named `Concrete` when that type has profile `bulk` and UOM `m3`.
- The first generated-role ID is `concrete.slab_from_face.slab_body`; its initial visible tag is `Slab | Concrete` and its initial user-editable default folder is `Structure`.
- A user's folder preference applies when a role tag is first created. Existing model tag placement is not silently changed when another user opens the model.
- SketchUp material sync uses a revocable connection token created in the signed-in web app and pasted once into the extension.
- The extension validates a connection token by syncing before saving it. Disconnecting removes the token while retaining the last valid offline cache.
- A model-wide, undoable toolbar command switches generated material carriers between their synced model and display textures without changing material bindings or takeoff.
- The primary SketchUp connection uses OAuth 2.1 Authorization Code with PKCE S256 as a public desktop client, with a fixed registered loopback callback. No client secret is embedded in the extension.
- Existing revocable `bgc_` connection tokens remain supported as a migration fallback until OAuth is confirmed in production.
- OAuth session data is stored atomically in the user's Basegrid application-data directory rather than as a long SketchUp preference value.
- Model and display appearances may each be an image texture or solid colour; the appearance switch supports both without changing material identity or takeoff.

## 2026-08-27 — Web-managed takeoff groups

- The organisation's web library is the source of truth for takeoff groups and the groups available to each generated role.
- SketchUp syncs and caches takeoff groups and generated-role allowlists alongside materials; active permitted groups remain usable from the last valid offline cache.
- The concrete tool presents the permitted takeoff groups as a single-select dropdown at the top; a user may select one group or leave it unassigned, and the last selection is remembered locally.
- Generated takeoff records store stable group IDs with snapshot names so saved models remain understandable offline.
- Existing takeoff records without groups remain valid and appear as Unassigned.
- Overall takeoff totals count each generated object once; grouped views count it once in each group to which it was assigned.
- Uploading model quantities to web projects is a separate future workflow and is not implied by library sync.

## 2026-09-11 — Claude MCP integration

- Claude must be able to drive Basegrid's own drawing tools as well as the native SketchUp API.
- Basegrid is a separate product from SketchAI. Its MCP server and SketchUp connection must operate independently, with no SketchAI runtime dependency.
- Native geometry calls must support workflows such as creating a face before invoking Basegrid's slab generator.
- Claude access is required from both Desktop and the terminal.

## 2026-09-11 — Hosted MCP connection

- Build the hosted Basegrid MCP connection end to end, including OAuth and the SketchUp drawing channel.
- Customers connect with their Basegrid account; SketchAI remains a separate product.
- The same connector must expose native geometry and Basegrid drawing tools as the tool suite grows.
