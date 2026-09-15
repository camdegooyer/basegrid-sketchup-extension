# Strip footing — 0.3.1

## Measured spacer and cross-arm reference (2026-09-15)

The user confirmed their moved set as the desired tool positioning reference.
Inspected read-only in model `2b611d04-142a-4f08-89d0-ef343e2684cf`,
footing persistent ID `44981`: 450 x 450 mm, 4L11 top/bottom mesh, first run
along +X. Parent assembly, reinforcement and mesh transforms are identity.
Coordinates below are world millimetres and are reference measurements, not
global-axis rules to hard-code into the generator.

- `Mesh Spacers 01 / Spacer Pair 05` (PID `50158`): pair centre
  `(2050, -384)`, moved 9 mm outward from Y=-375. Bounds X=2040..2060,
  Y=-387..-381, Z=-400..-50.
- `Mesh Spacers 01 / Spacer Pair 06` (PID `50159`): pair centre
  `(2050, -66.149026)`, moved approximately 8.851 mm outward from Y=-75.
  Bounds X=2040..2060, Y=-69.149026..-63.149026, Z=-400..-50.
- Outer longitudinal bar centres remain Y=-375 and -75, diameter 11 mm.
  The moved 6 mm spacer legs therefore sit outside the longitudinal bars,
  with measured surface gaps of approximately 0.5 and 0.351 mm. Pair leg
  centres remain at X=2043 and 2057; spacer height remains 350 mm.
- `Top Mesh 01 / Mesh Frame / Cross Bar 07` (PID `46568`): centreline
  from `(2046, -375, -65)` to `(2046, -75, -65)`, diameter 8 mm.
  Moved from X=2150 to X=2046 (104 mm towards the run start); height and
  transverse span unchanged. Its centre is 4 mm before the spacer-pair station
  X=2050, and its forward surface is at that station. The user subsequently
  clarified that the intended cross-arm CENTRELINE is at the spacer-pair centre,
  X=2050, midway between the two legs. Do not reproduce the measured 4 mm offset.

Use this moved set, not the other unchanged sets, as the placement reference:
spacers outside the outer mesh bars and the cross arm coordinated with their
station: align the cross-arm centreline with the midpoint between the spacer
legs. The slight asymmetric outward gaps are measured hand-placement
differences; an exact outward clearance remains unconfirmed.
This is a recorded reference only; spacer/cross-arm generator changes have
not yet been applied. The inspected model was left unchanged.

## Repositioned step Z-bar reference (2026-09-15)

Read-only inspection after the user repositioned the sample Z bars:
model `ba3e5b43-6888-4c22-8220-b7e40f7894d5`, root PID `50591`.
Root transform is identity. All eight bars retain N12 section, 600 mm
horizontal legs, a 200 mm rise and the original transverse/vertical placement.

- Bottom set, `Step Z Bar 001` through `004` (PIDs 50593, 50738, 50880,
  51022): moved +344 mm along the run. Vertical bend centreline is X=3394;
  its forward surface is X=3400, aligned with the extended lower mesh end.
  Lower leg runs X=2794..3394 at Z=-394.5, upper leg X=3394..3994 at
  Z=-194.5. This places the bend's forward surface 50 mm before the end of
  the concrete step overlap at X=3450.
- Top set, `Step Z Bar 005` through `008` (PIDs 51164, 51306, 51448,
  51590): moved approximately +4.452265 mm along the run. Vertical bend
  centreline is X=3054.452265, near the higher mesh start at X=3050.
  Lower leg runs X=2454.452265..3054.452265 at Z=-55.5, upper leg
  X=3054.452265..3654.452265 at Z=144.5. The bend's rear surface is
  X=3048.452265, approximately 48.452 mm past the concrete riser at X=3000.
- Both sets retain Y centre coordinates -363, -263, -163 and -63, i.e.
  12 mm beside their corresponding mesh longitudinal bar centres.

The observed relationship is staggered bend stations: top Z bars near the
higher mesh start, bottom Z bars near the extended lower mesh end. Do not
place both sets on one vertical plane. Exact general placement/clearance
formula remains to be confirmed; do not hard-code the incidental 4.452265 mm
hand adjustment. These are measured sample positions, not a verified
structural design. No model edits or generator changes were made during inspection.

## Running the tool

### Optional piers

**Include piers** defaults off. When enabled, nominate maximum centres
(initially 1800 mm), diameter (450 mm) and depth below the footing (600 mm).
**Piers at corners**, **Piers at intersections** and **Even spacing** initially
default on. Spacing follows the physical footing centreline, including edge
alignment and rotated runs. Shared T/cross junctions get one pier. Endpoints
and changes of level are anchors; optional corner/intersection anchors split
the spacing intervals. Even spacing does not exceed the nominated maximum.
Without even spacing, the remainder is taken at the interval end.

Piers use the footing concrete material and begin at its underside. Near steps,
the top is limited to the lowest underside touched by the pier footprint to
avoid double-counting concrete. Pier volume is separately recorded by the pier
tool; the footing's concrete-volume response still excludes piers.

**Pier starter bar** enables a processed-bar material selector and editable
below-top length, rise into the footing, and upper cog. Defaults are pier depth
minus 100 mm, half footing depth, and footing width / 2 minus 50 mm respectively.
The diameter comes from the selected material; N16 is initially selected when
available. An unassigned bar uses the existing pier tool's nominal N16 default.
Untouched derived lengths follow dimension changes; manually entered lengths
remain as entered. These selections are remembered between SketchUp sessions.

Each pier is a unique **Concrete Pier** tool group under **Footing / Piers**.
To edit one, enter the footing and Piers groups, select that pier, then run
**Concrete Piers**. Do not explode it: retaining the group retains edit metadata.
Each pier has independent concrete/starter geometry, settings and takeoff.
Rebuilding the whole footing regenerates its piers from the assembly settings;
it does not preserve later individual pier overrides. The footing build and
its piers use one Undo operation. Live SketchUp verification remains pending.

The **Include step Z bars** checkbox defaults off. **Z bars above step height
(mm)** defaults to 200 and is editable (zero is allowed). Only steps strictly
above the threshold receive bars: 200 mm does not qualify at a 200 mm threshold;
300 mm does. These inputs and the Z-bar material selection are remembered.

Z-bar materials filter to **Reo Bar Processed / m**. N12 is initially selected
when available; diameter is taken from material metadata and each lap leg is
50 times that diameter. Qualifying steps require a selected compatible material.
No mesh means no Z bars; bottom-only mesh receives bottom Z bars only.
Bars are individually grouped under Reinforcement / Step Z Bars, with their own
material and centreline-length takeoff, within the footing's single Undo operation.
The preview includes the Z-bar centrelines. Width/cover and available lap lengths
are checked before building. The implementation uses the staggered bend reference,
with 50 mm face cover rather than incidental hand-placement offsets.

Mesh extends into step backfill while cross wires and accessories continue at
their existing spacings. The separately recorded support/spacer offset and end
support refinements have not yet been implemented.

Install the current RBZ through SketchUp Extension Manager, or restart SketchUp
if the Basegrid development loader is already installed. Choose **Extensions >
Basegrid > Draw Strip Footing**.

1. Set width, depth, mesh layers and step height (initially 200 mm). Clear cover is fixed at 50 mm. Choose materials
   from the synced web material types, or leave them unassigned.
2. Click a start point and draw level runs at any angle. Type a length using SketchUp's
   normal units and press Enter to place the next point precisely. Re-entering a
   length before moving the cursor adjusts the last segment.
   Right/left arrows lock red/green directions; Up locks blue (a level footing
   cannot extend vertically). Down locks the inferred direction. Hold Shift to
   retain the current inference while referencing other geometry.
3. Press **Tab** to move the setout anchor to the next point on the cross
   section. It walks once around the six points — top left, top centre, top
   right, bottom right, bottom centre, bottom left — and the preview re-offsets
   the whole assembly, including points already clicked. Edge anchors are
   relative to the direction each run is drawn in. The status bar names the
   current anchor. Every drawing session starts at top left; there is no anchor
   selector in the dialog.
4. Click the end of a run, then press **]** to step up or **[** to step down
   by the nominated height. A labelled vertical preview marks the step; draw the
   next run at the new level to complete it. The right-click menu also offers
   **Step Up**, **Step Down**, **Close Current Loop**, and **Start Branch / New Run**.
   Right-click **Change Step Height...** to enter a new height while drawing.
   It updates an unfinished step and the height for future steps; completed runs
   retain their levels.
   These keys work on compact Windows and Mac keyboards. Arrows remain inference
   controls. Step height must be less than the footing depth.
   Draw steps on straight runs; the nominated overlap must fit the adjoining run.
5. Press Enter, double-click, or choose **Finish Footing**. Escape cancels without adding model
   geometry. Creation is one undoable operation; failed creation rolls back.

While drawing, **Backspace** on Windows or the ordinary **Delete** key on a Mac
laptop removes the last point and keeps the tool active. Repeated presses can
remove a step start and return to the preceding run. While entering a length,
the key edits the measurement text instead. **Undo Last Point** is also available
in the right-click menu.

## Geometry and materials

Starting the tool saves width, depth, mesh layers, step height and material
selections in SketchUp preferences, so they restore next time and after a restart.
Step-height changes made while drawing are also saved. Explicitly choosing
Unassigned is remembered. Materials no longer available in the synced library
appear as Unassigned; changing depth or mesh still recalculates the Bogar default.
The anchor always starts at top left.

All runs, corners and step overlaps create one **Joined Concrete** solid under
**Concrete**, with no internal partition faces between runs or step overlaps.
Takeoff records the net union volume once. Width is constant throughout
an assembly. Top/bottom reference and centre/left/right alignment are selectable.
Default step backfill/overlap is 1.5 times footing depth (300 -> 450 mm,
450 -> 675 mm, 600 -> 900 mm). Explicit API overlap values remain supported
for reproducing existing assemblies.
Steps on corners and disconnected concrete are rejected. Diagonal runs, corners,
crossings and straight steps are supported; overlapping concrete is counted once.
Junctions apply to paths in the current assembly; existing footing groups are
not automatically merged.

Concrete filters by the existing `Concrete / bulk / m3` type. Mesh filters by
the cached `Reo Trench Mesh / m` type. Available `dimensions_mm.bars`, `diameter`
and `width` set longitudinal bar count, diameter and spacing. Width is interpreted
as the centre-to-centre span of the outside longitudinal bars. Product fields
`cross_diameter_mm` and `cross_spacing_mm`, when supplied in `dimensions_mm`,
set cross-wire geometry. Support `width` and Bogar spacer `height` also carry through;
explicit support/spacer setting keys in `dimensions_mm` are supported. Missing
dimensions use existing modelling defaults. The Supports and Bogar spacers selectors
filter by `Trench Mesh Supports` and `Bogar Spacers` (also the web app's singular
`Bogar Spacer`) respectively, accepting `each` and `ea` units;
empty lists allow unassigned geometry without creating library records.

Bogar selection defaults to footing depth minus 100 mm and the selected mesh
gauge: a 450 mm footing with 11 mm mesh selects the 11 x 350 product. The mesh
diameter is not subtracted from the nominal spacer height. Changing depth or mesh
updates this default; if no exact product exists, the selector becomes Unassigned.
An explicitly selected Bogar product supplies its nominal modelled height, with
its base 50 mm above the footing bottom. Its diameter field denotes compatible
mesh gauge, not the thickness of the generic spacer representation.

Clear cover is measured to steel surfaces. Cross wires sit against, rather than
through, longitudinal bars. Rectangular support blocks are 50 mm high and sit at the footing base;
each spacer pair contains two round bars between the mesh layers. These shapes are dimensioned
representations, **not manufacturer replicas**. Assigning a material does not
turn a generic support into that product's exact shape.

Under **Reinforcement**, each run has **Bottom Mesh**, **Top Mesh** (when enabled),
**Mesh Supports** and **Mesh Spacers** groups. Mesh groups contain a **Primary Bar**
and a **Mesh Frame**.

Every placed bar is its own group holding its own geometry, so a bar can be
trimmed, moved or reshaped at a junction without changing any other bar. Support
blocks and spacer pairs are manufactured items that should stay identical, so
they keep shared component definitions with individual instances; changing one
of those definitions updates its matching instances. The cost of independent
bars is geometry per bar rather than per size.

The default mesh has three 12 mm longitudinal bars at 100 mm centres, top and
bottom layers, and 8 mm cross bars at 300 mm spacing. Support blocks default to
10 mm wide along the run and span the outer longitudinal bar centres (200 mm for
three bars). Their height is fixed at 50 mm, including on stacked runs. Spacers default
to two 6 mm bars, 14 mm apart, at each side of the mesh. Their height follows the
clear space between the longitudinal layers. Supports begin 200 mm after end
cover and repeat at 900 mm spacing; a short run gets one centred support if it fits.

Mesh runs are carried through corners and T/cross junctions. A run ending at a
perpendicular run at the same level extends to the far face of that run's
outermost longitudinal bar — half the mesh width plus one bar radius past the
vertex — and its cross wires continue at their normal spacing. Free ends keep
end cover, and a step is not a junction: a run meeting another at a different
level still terminates with end cover.

Runs on one axis keep nominal cover; runs on the other stack exactly one mesh
depth above them, so the carried-through meshes touch rather than intersect.
The direction of the first run drawn stays at nominal cover. Supports remain
50 mm high; the current stacked-run layout can leave a gap above them pending the mesh-junction correction. The
stacked run's cover increases by one mesh depth, which the depth check includes.
Additional distinct directions each take the next mesh elevation. Non-right-angle
connections retain square-ended mesh with end cover; their connection steel is
not detailed.

**Bends, hooks and lapped splices are still not modelled.** Bars run straight
through and stop square. Step reinforcement is not connected. This is reported
after creation and stored on the assembly, and still needs the user's connection
detail before the next geometry stage.

## Quantities and MCP

**Material Takeoff** reports concrete in m³, generated mesh run length in m, and
supports/spacer pairs in each. Every placed support and spacer pair has its own
quantity record, including when instances share a definition. Mesh length counts each layer once; it excludes undetailed
connection steel, stock-length cutting and purchase waste. Unassigned parts
retain measured quantities. Records are stored at creation and are not
recalculated after manual geometry changes. Footing records are initially in
the Unassigned takeoff group.

`basegrid_create_strip_footing` uses the same builder as the drawing tool:

```json
{
  "model_guid": "GUID returned by basegrid_status",
  "paths_mm": [
    [[0, 0, 0], [6000, 0, 0]],
    [[3000, 0, 0], [3000, 3000, 0]]
  ],
  "settings": {"width_mm": 450, "depth_mm": 450, "reinforcement": "bottom"},
  "materials": {}
}
```

Paths contain world coordinates in millimetres; each path must be level. A
different-height path sharing an endpoint makes a straight step. The API returns
the assembly reference, net concrete volume and modelling warnings. Use inspect
mode for discovery; creation requires edit/full mode.

## Verification

2026-09-14 completion crash investigation: two local BugSplat reports at 12:08
and 12:22 identify the same access violation in the embedded Ruby runtime
(`x64-ucrt-ruby320.dll`, RVA `0x3fb19`). The user reported completing a drawing.
Completion now runs on a one-shot UI timer after the native tool callback returns,
ignores duplicate finish/repaint events, and avoids a modal warning after switching
to Selection. Warnings remain stored on the assembly and appear in the status bar.
Regression tests cover deferred completion, re-entry, cancellation and retry.
This addresses a suspected callback-lifetime risk; the exact crash cause and the
fix still require confirmation in SketchUp. No additional native instances were
launched during this investigation.

2026-09-14 update: 56 Ruby tests (geometry, drawing callbacks, API and takeoff)
and seven MCP tests pass. Coverage includes free-angle lengths, repeated length
entry, inference-lock callbacks, bracket step commands, fixed cover, the reduced
dialog and the top-left starting anchor. The native smoke script now includes
diagonals, oblique joins, rotated steps and drawing callbacks. A fresh native
run has not completed successfully; interactive Windows and Mac checks remain
outstanding. The native results below describe the earlier version.

Automated tests cover watertight outward-oriented surfaces, net volume, loops,
branches, both step directions and references, short overlaps, invalid input,
clear cover, separated mesh wires, support contact, corner continuation and layer
stacking, steps not treated as junctions, independent bar geometry, Tab anchor
cycling, material filtering and
mixed-unit takeoff, shared component definitions and per-instance quantities. Run `ruby test/strip_footing_geometry_test.rb` and
`ruby test/strip_footing_tool_test.rb`, plus the existing API/takeoff/MCP suites.

Native checks passed in SketchUp 2026.1.252 on Windows: the reference-sized U
created three solid concrete segments totalling 2.4257475 m³, six mesh layer
groups, 15 support instances sharing one definition, and 30 spacer pairs sharing
one definition. Instance quantities matched placements. Straight step, T-junction,
loop and failed-build rollback checks passed. Concrete and exposed reinforcement
were rendered and visually inspected.

The native check is retained in `test/strip_footing_sketchup_smoke.rb`. For a
repeat, copy an installed SketchUp template to
`tmp/footing-inspection/test-template-final.skp` and launch that copy in a
separate SketchUp instance with `-RubyStartup` pointing to the smoke script.
The script refuses other models, writes its report/screenshots/sample to that
temporary directory, and never saves over the input template.

The T-junction check caught a native failure caused by erasing shared coplanar
grid edges during cleanup. Concrete now uses a welded polygon mesh and hides
coplanar subdivisions while preserving their topology.

Manual mouse/keyboard interaction (including the Tab anchor key on macOS),
material switching, rotated/scaled editing
contexts and macOS visual testing remain to be checked.

## Model feedback — 2026-09-12 corner review

Measured from the live L-shaped test assembly (run 01 along +Y on centreline
x = 0; run 02 along +X on centreline y = 5480; 450 wide, 3L11TM, 50 cover).
These are observations of hand edits, not yet implemented behaviour.

Longitudinal bars were extended through the corner:

- Run 01 `Reinforcing Bar 11 × 5380 mm` was lengthened to 5534.763 mm, so its
  bars run y = 50 → 5584.763, finishing 0.737 mm short of the outer face of run
  02's outermost longitudinal bar (y 5585.5).
- Run 02 `Reinforcing Bar 11 × 3805 mm` was lengthened at its start to
  3961.507 mm, so its bars run x = −106.507 → 3855, finishing 1.007 mm past the
  outer face of run 01's outer bar (x −105.5).
- Ends stay square: the end caps are still flat and normal to the bar axis.
  No bends, hooks, cranks or mitres were added.

The apparent rule is that each run's longitudinal bars continue through the
junction to the far face of the other run's outermost longitudinal bar. The
sub-millimetre differences read as hand snapping rather than an intended
tolerance.

Three things the edit did not do, and which the generated result still needs:

- Cross wires were not extended. Run 01's last cross wire remains at y ≈ 5150,
  leaving about 430 mm of bare longitudinal bar through the corner.
- Elevations were not separated. Both runs' bottom bars remain at z −400 to
  −389, so the extended bars pass through each other at the corner. The top
  layer clashes the same way.
- Every longitudinal in the run moved together, because the length was changed
  on the shared component definition. All three bars therefore stop on the same
  line instead of being trimmed individually to the corner.

## Shared definitions make individual bars uneditable

Repeated parts currently share one component definition per distinct size, so
editing one placed bar changes every other bar of that size. In the test model
`Reinforcing Bar 8 × 200 mm` has 60 instances across both runs and both layers,
and each run's longitudinal definition has 6.

This follows the 2026-08-27 decision to use component instances for repeated
parts, but it blocks the per-bar edits a real corner detail needs. Whether bars
become groups, unique components, or stay shared until a bar is edited is an
open decision.
