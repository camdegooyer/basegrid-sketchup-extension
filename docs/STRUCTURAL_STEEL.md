# Structural steel

Reference reviewed: `C:\Users\cam\HQ SketchOB`, specifically the structural
steel tool, geometry, materials and draw tool, and the separate plate,
base-plate and fastener tool contracts. No dependency on SketchOB is installed.

## First implementation: members

- Extensions > Basegrid > Create / Edit Structural Steel.
- Beams: pick two points in 3D, or pick the start, aim and enter a length in
  SketchUp's Measurements box. Each member is one undo operation.
- Columns: set height, pick the base, then a horizontal orientation point.
  While placing a column, typing a length changes its height without placing it.
  The context menu also offers Set column height.
- Tab cycles nine profile anchors. New drawing sessions start at top left.
  Arrows use red/green/blue and inferred-direction locks; Shift temporarily
  holds inference. Space remains available to SketchUp. Profile rotation is
  available in the UI and in the context menu in 90-degree increments.
- Backspace on Windows / backward Delete on Mac clears the uncommitted start
  point, except while entering a measurement. Esc cancels a pending member;
  Esc again exits. Native Undo handles completed members.
- Select one generated member to edit its material, local length, profile
  rotation, offsets and mark while retaining the group's current transform.
  Editing does not reorient an existing member when changing its usage label.
- Create Similar takes the selected member's settings into a new placement.
- Last accepted settings persist across restarts; the anchor resets for a new
  drawing session. Edits retain the member's existing anchor.

## Materials and geometry

Only active, metre-based Structural Steel PFC / UB / UC / SHS / RHS / CHS
material types are offered. Dimensions come from the selected web material,
not an embedded section catalogue or a parsed material name. Missing or invalid
dimensions prevent drawing. SHS depth may be omitted because it equals width.
PFC uses a channel outline even though its web type profile is `i_section`.

Members have square ends and real hollow-section voids. CHS uses 48 segments.
Root/corner radii use four segments per quarter where metadata supplies them;
missing radii are represented as square corners. This is coordination geometry,
not fabrication or structural certification. Length takeoff uses the transformed
member reference axis in metres. Manual geometry edits do not automatically
update stored quantities.

## Review and remaining work

The reference includes member mitres, fabrication marks and mass/coating
quantities, rectangular plates with holes, column-linked base plates, and
bolt/anchor assemblies. Those are not included in this first implementation.
The old embedded material catalogue is not copied into Basegrid.

Unit tests cover section profiles/voids, filtering, invalid metadata, anchors,
preferences, UI escaping and deferred completion. Native SketchUp checks remain:
solid extrusion for each section, angled/vertical placement, keyboard locks,
typed lengths, editing moved/rotated members and nested contexts, Undo/Redo,
and the dialog on Windows and macOS. The user's open model was not touched.
