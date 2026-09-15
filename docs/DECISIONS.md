# Confirmed decisions

## 2026-09-15 - Steel dimensions display

- Selected-material section dimensions are shown as read-only text, not input boxes.

## 2026-09-15 - Structural steel reference

- The user identified `C:\Users\cam\HQ SketchOB` as the reference for recreating
  structural steel tools in Basegrid.

## 2026-09-15 - Connection and background activity UI

- Provide visible UI for account/cloud connections and useful background activity status.

## 2026-09-15 - Visible material sync

- The material sync command opens a UI showing sync progress and its outcome.

## 2026-09-15 - Profile-driven flashing tool

- Recreate Sketch OB's flashing tool with Colourbond, Zincalume and Perforated selectors.
- Match the takeoff material from the drawn profile under the corresponding web flashing material type, rounding developed girth up to an available size.
- Use the actual fold count where available; round up to an available higher fold count when missing.

## 2026-09-15 - Material-driven starter bar diameter

- Starter-bar diameter comes from the selected material metadata and is not displayed as an input, including optional starter bars in piers. Concrete pier diameter remains an input.

## 2026-09-15 - Starter bar accessory material filters

- Filter starter-bar chair materials to the web material type `Bar Chairs`, and safety-cap materials to `Reo Bar Safety Caps`.

## 2026-09-15 - Concrete pier tool

- Review and recreate the concrete pier tool from OB Tools in Basegrid. Reference reuse is authorised for this tool only.

## 2026-09-15 - Step Z Bars in combined UI

- Include Step Z Bars for joining bars across level changes in the combined Starter Bars UI.

## 2026-09-14 - Trench mesh support height

- Trench mesh supports are always 50 mm high; mesh stacking must not stretch the support geometry.

## 2026-09-14 - Reinforcement profile resolution

- Starter bars and trench-mesh bars use 8 segments around their circular profiles.

## 2026-09-14 - Combined starter-bar tool

- Recreate the starter-bar tools from `C:\dev\OB_ToolsExtension` in Basegrid, combining them in one UI.
- Reference reuse is approved for these tools only; unrelated previous extension code and requirements remain out of scope.

## 2026-09-14 - Remember strip-footing inputs

- Use the last-used strip-footing inputs and material selections as defaults for the next session, including after restarting SketchUp.
- Remember step-height changes made while drawing. The starting anchor remains top left.

## 2026-09-14 - Nominated footing step height

- Include step height in the strip-footing setup UI and allow it to be changed while drawing.
- Initially use U/D for step up/down and reserve arrows for inference locking. The bracket-key decision below supersedes U/D.

## 2026-09-14 - Strip footing supports and Bogar spacers

- Label the material selectors Supports and Bogar spacers; filter to Trench Mesh Supports and Bogar Spacers from the web library.
- A 450 mm footing defaults to a 350 mm Bogar spacer: nominal spacer height is footing depth minus 100 mm. Mesh diameter determines the compatible product gauge, not an additional height deduction.

## 2026-09-14 - Tool keyboard conventions

- While drawing a strip footing, Backspace on Windows and the ordinary backward Delete key on Mac undo the last point without leaving the tool. While entering a measurement, these keys retain normal text editing. This is an explicitly requested contextual binding; forward Delete and global model undo retain their native roles.

- Basegrid tool shortcuts must be available on compact Windows and macOS laptop keyboards, without requiring a numeric keypad, dedicated navigation keys or function keys.
- Do not repurpose SketchUp's native shortcuts for Basegrid-specific actions. Preserve native drawing and measurement conventions, including arrow inference locks and Shift inference locking.
- Use Tab consistently to cycle through a tool's anchor points on both platforms.
- Footing step commands are separate from arrow inference locks. Provide a context-menu alternative to keyboard commands.
- Check new shortcuts against SketchUp's native bindings and apply the same pattern across future tools.

## 2026-09-14 - Strip footing inputs and drawing

- The setup inputs are footing width, footing depth, mesh layers and material selections.
- Every strip-footing drawing session starts with the top-left anchor. There is no anchor selector in the setup UI; Tab cycles the anchors during drawing.
- Carry available selected-material dimensions into the remaining settings.
- Clear cover is fixed at 50 mm on all faces.
- Allow free drawing directions, native-style inference locking and typed lengths in SketchUp's Measurements box.

## 2026-09-12 — Strip footing first version

- Build a Basegrid strip-footing tool using SketchOB as an inspected reference.
- Include concrete and reinforcement; the requested overall scope includes steps and T/cross junctions.
- Filter material selection by the web application's material types.
- When matching materials are missing, allow dimensioned, unassigned geometry and retain its quantities.
- The requested end state uses actual product shapes and the user's connection detail; that detail has not yet been supplied.
- The inspected footing's concrete segment groups, mesh assemblies, paired-bar spacers and rectangular support shapes are the reference for the next tool update; Basegrid group names may be chosen independently.
- Repeated parts should use component instances, with each placed part counted separately in takeoff.

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

## 2026-09-11 — Remembered SketchUp sign-in

- Basegrid should show a sign-in window when SketchUp starts without a usable session.
- Sign-in should persist between SketchUp sessions and restore the cloud connection automatically.

## 2026-09-15 - Joined strip footing concrete

- Generate one joined concrete solid per footing assembly, including runs and step overlaps, matching the user's manually unioned reference. This supersedes the earlier separate concrete-segment grouping.
- Keep reinforcement separate and record the concrete net union volume once.

## 2026-09-15 - Spacer and cross-arm positioning reference

- The user's moved spacer set and top-mesh cross arm are the desired positioning reference for the strip footing tool. Preserve this reference without editing the model.
- Measurements are recorded in `docs/STRIP_FOOTING.md`. Implement the relationship to the mesh, not a hard-coded global axis or the incidental 104 mm move.
- The cross arm centreline must align with the centre of the spacer pair (midway between its two legs). This explicit clarification overrides the incidental 4 mm offset in the hand-positioned reference.
- This records the reference only. Exact outward spacer clearance remains unconfirmed.

## 2026-09-15 - Step mesh continuation and support placement

- Continue cross bars, supports and spacers through the extended mesh at their existing spacings; do not extend longitudinal bars alone.
- Offset supports 50 mm along the mesh from the spacer stations. Which side of the spacer receives the support remains to be clarified.
- Provide an end support 200 mm from the mesh end, measured from the actual extended mesh end rather than the drawing-path endpoint.
- Retain the confirmed cross-arm centreline alignment with the spacer-pair centre.

## 2026-09-15 - Default step backfill length

- Default step backfill/overlap is footing depth multiplied by 1.5: 300 mm depth gives 450 mm, 450 mm gives 675 mm, and 600 mm gives 900 mm. The user corrected the earlier 625 mm example to 675 mm.

## 2026-09-15 - Deformed-bar lap convention

- User-specified project/tool convention: deformed-bar lap length is 50 times the selected bar diameter in millimetres. N12 gives 600 mm and N16 gives 800 mm.
- The 600 mm legs on the sample N12 step Z bars are confirmed correct.
- Apply the formula using material metadata, not a fixed 600 mm length for every diameter. This is a project convention, not a claim of universal structural-code compliance.

## 2026-09-15 - Optional strip-footing step Z bars

- Add an include/exclude option and editable maximum step height without Z bars, default threshold 200 mm.
- Generate Z bars only when enabled and the actual step height is strictly greater than the threshold. At a 200 mm threshold, a 200 mm step has no Z bars and a 300 mm step has them.

## 2026-09-15 - Footing piers and starters

- Add optional piers at nominated centres, with corner, intersection and even-spacing options.
- Keep each generated pier independently grouped and editable after entering the footing assembly.
- Pier starters are optional and their lengths are editable. Default below-pier-top length is pier depth minus 100 mm.
- The starter rises halfway through the footing from the pier top, not above the footing top face: default rise is half footing depth.
- Default upper cog is footing width divided by two minus 50 mm.

## 2026-09-15 - Tool dialog presentation

- Start the UI refresh with strip footing, preserving its drawing behaviour and keyboard conventions.
- Use restrained, consistent engineering-tool styling with Footing, Reinforcement, Steps and Piers sections.
- Keep material-derived dimensions as read-only text. Reveal optional settings when enabled.
- Use contextual technical diagrams and brief hover guidance, with expandable help available by keyboard; keep the main form uncluttered.

## 2026-09-15 - Double trench mesh

- Advanced reinforcement allows double trench mesh independently at the top, bottom or both existing mesh layers.
- Position two strips toward opposite sides at 50 mm clear cover. Permit central overlap, with at most 100 mm clear between the nearest longitudinal bars.
- Reject arrangements that cannot meet the cover and gap limits instead of silently changing the selected material.

## 2026-09-15 - Footing pier ends and concrete

- At open footing ends, inset the pier centre by its radius so the outside of the pier aligns with the footing end. Keep corner and intersection piers at their nominated nodes.
- Provide a separate pier concrete selector, initially filled from footing concrete, preserving subsequent user selections.

## 2026-09-15 - Bracket step shortcuts

- Replace U/D with `[` for step down and `]` for step up while drawing strip footings.
- Support standard English-layout Windows and Mac laptop keyboards without Fn keys. Preserve native arrows, Shift, Tab anchors and measurement entry.
- Keep right-click step commands available as an alternative for custom or non-English keyboard layouts.

## 2026-09-15 - Configurable drawing shortcuts

- SketchUp manages shortcuts for launching Basegrid menu commands. Basegrid manages configurable in-tool actions with persistent settings and Restore Defaults.
- Check registered SketchUp shortcuts and duplicate Basegrid assignments before saving. Never take over a conflicting registered shortcut during drawing.
- Start with strip-footing step down, step up and change step height. Preserve shared inference, anchor, undo and measurement keys.

## 2026-09-15 - Repeated placement

- Drawing and placement tools remain ready for another placement after successful creation, with the same settings. Selecting another tool or pressing Space exits through SketchUp's normal tool selection.

## 2026-09-15 - Flat flashings

- Flashings include a zero-fold option: a single flat leg with no turns. Accept zero-fold material metadata and retain rounding up to available girth and fold counts when needed.
- Provide a subtle material override control so users can select another flashing material instead of the automatic match.
- Allow named custom flashing profiles that store input defaults, with load and update actions. Profiles do not store placed geometry.
