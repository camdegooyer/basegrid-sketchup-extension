# Custom flashing

Open **Extensions > Basegrid > Create / Edit Flashing**. Set the material family, fold count, leg lengths and signed bend angles. The live cross-section shows the shape and developed girth, with rotation, mirror, path side and advanced thickness side. Zero to six folds are supported; zero folds is one flat leg with no turns. Click a profile vertex to select the drawing anchor, or cycle with Tab while drawing.

## Material selection

- Colourbond maps to `Flashings Colourbond` or the current web name `Flashings Colorbond`.
- Zincalume maps to `Flashings Zinc` or the current web name `Flashings Zincalume`.
- Perforated maps to `Flashings Perforated`.

Only active flashing-profile materials measured in metres are eligible. Matching uses numeric `girth`, `folds` and `thickness` inside `dimensions_mm`, also accepting the suffixed `girth_mm` and `thickness_mm` forms, not parsed material names. For the actual fold count, choose the smallest available girth greater than or equal to the sum of profile legs. If no suitable item exists at that fold count, try the next higher available fold count. Never round either dimension down. Exact girths remain exact; floating-point noise below 0.000001 mm is ignored.

The matched item supplies thickness, appearance and takeoff identity. The drawn profile retains the entered dimensions; it is not stretched to the stock girth. Missing or ambiguous automatic matches stop creation with an error. Sync the library after adding or changing products. The subtle **Change material** control allows an explicit override from any active flashing family, or a return to automatic matching. Overrides require valid metadata, warn when stock girth/folds are insufficient, and retain the drawn dimensions. There is no manual thickness input.

## Named profiles

Expand **Custom profiles** to save current input defaults with a name. Load a saved profile, adjust inputs, and use **Update** to replace it (including renaming). **Save new** rejects duplicate names; **Delete** asks for confirmation. Profiles include material family/override, legs, turns, orientation, sides and anchor, not path geometry. They persist in SketchUp preferences on Windows and macOS across restarts. They are local to that SketchUp installation, not cloud-shared. Existing placed flashing is unaffected by profile changes.

## API and MCP

The updated contract requires extension 0.3.5+:

- `basegrid_create_flashing` accepts one leg with an empty `angles_deg` array for flat flashing, `settings.material_id` for an explicit override (empty for automatic), and optional `profile_name` to use saved defaults. Explicit settings take precedence over the saved profile. `replace_ref` retains the existing guarded edit workflow.
- `basegrid_list_flashing_profiles` lists names and complete settings in inspect mode.
- `basegrid_save_flashing_profile` accepts `name` and `settings`; supply the exact `previous_name` to update or rename an existing profile. Omitted settings fields use tool defaults, not a partial update.
- `basegrid_delete_flashing_profile` accepts `name` and deletes only the saved defaults.

Profile writes require edit permission but no model GUID because they change preferences, not geometry. Hosted MCP additionally targets `device_id` and requires `request_id` for writes. Returned flashing parameters include override status and warnings. UI and API share the same profile storage and validation.

Takeoff is the drawn path length in metres, recorded once on the flashing sheet. The assembly also records actual girth/folds, matched girth/folds and material ID. No bend allowance, lap, waste, purchasing-length rounding or perforation-hole geometry is added. Perforated flashing uses its material appearance over the same sheet representation.

## Drawing and editing

Click the path start and subsequent corners. Enter a distance in SketchUp's Measurements box to add a segment along the current hover direction. Double-click, Enter or the context menu finishes the path. The tool stays active for another flashing.

Tab cycles profile vertices as the path anchor. The context menu flips the profile side. Arrows lock the native axes/current inference; Shift locks inference while held. Backspace on Windows and backward Delete on Mac remove the last point, except while entering a measurement. Space is not rebound. Escape clears an unfinished path; Escape again exits.

Paths can lie in horizontal, vertical or inclined planes. The path determines its plane when it bends; a picked face supplies an orientation hint. Very sharp corners, runs too short for the profile, self-overlapping profiles and non-planar paths are rejected. Closed-loop and self-crossing flashing paths are not detailed by this version.

Select a generated assembly and reopen the command to edit. **Create Similar Flashing** starts a new path with its profile settings. Editing regenerates geometry and re-resolves the material; it does not preserve manual edits to faces. The path follows a moved or rotated assembly. Last-used setup settings persist across SketchUp restarts. Tab changes during drawing apply to the current tool session.

## Reference and verification

Reviewed `C:\dev\OB_ToolsExtension\overland_builders\ob_tools\custom_flashing.rb`. No PlusSpec, WindowTape or old material-library dependency was imported. Unlike the reference's extended Follow Me runs followed by destructive trimming, this implementation constructs common mitre sections and a closed sheet shell directly. Each build or edit has one undo operation; completion is deferred from mouse callbacks and guarded against duplicate events and changed contexts.

Offline tests cover rounding, family filtering, missing/ambiguous metadata, profile validation, arbitrary planes, shell winding, anchors, measurement editing and deferred tool lifecycle. Native SketchUp geometry, preview rendering, undo and physical Windows/Mac shortcuts still require live verification. No user model geometry was changed during implementation.
