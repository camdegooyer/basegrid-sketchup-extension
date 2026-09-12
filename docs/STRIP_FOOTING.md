# Strip footing — 0.3.1

Install the current RBZ through SketchUp Extension Manager, or restart SketchUp
if the Basegrid development loader is already installed. Choose **Extensions >
Basegrid > Draw Strip Footing**.

1. Set width, depth, clear cover and mesh/support dimensions. Choose materials
   from the synced web material types, or leave them unassigned.
2. Click a start point and draw X/Y-aligned runs. Type a length using SketchUp's
   normal units to place the next point precisely.
3. Press **Tab** to move the setout anchor to the next point on the cross
   section. It walks once around the six points — top left, top centre, top
   right, bottom right, bottom centre, bottom left — and the preview re-offsets
   the whole assembly, including points already clicked. Edge anchors are
   relative to the direction each run is drawn in. The status bar names the
   current anchor. The dialog still sets the starting anchor.
4. Right-click for **Close Current Loop**, **Start Branch / New Run**, or
   **Step from Last Point**. Steps accept positive or negative height changes.
   Draw steps on straight runs; the nominated overlap must fit the adjoining run.
5. Press Enter, double-click, or choose **Finish Footing**. Escape cancels without adding model
   geometry. Creation is one undoable operation; failed creation rolls back.

## Geometry and materials

Ordinary paths and loops create separately grouped, mitered concrete segments
under **Concrete**. Straight steps also have **Step Overlap** groups. T/cross
junctions and overlapping step regions retain a **Joined Concrete** union so
overlap is counted once. Width is constant throughout
an assembly. Top/bottom reference and centre/left/right alignment are selectable.
Steps on corners, diagonal runs and disconnected concrete are rejected in v1.
Junctions apply to paths in the current assembly; existing footing groups are
not automatically merged.

Concrete filters by the existing `Concrete / bulk / m3` type. Mesh filters by
the cached `Reo Trench Mesh / m` type. Available `dimensions_mm.bars`, `diameter`
and `width` set longitudinal bar count, diameter and spacing. Width is interpreted
as the centre-to-centre span of the outside longitudinal bars. Cross-wire
dimensions and project cover remain explicit dialog inputs. Chairs and spacers
filter by `Trench Mesh Supports / ea` and `Bogar Spacers / ea` respectively;
empty lists allow unassigned geometry without creating library records.

Clear cover is measured to steel surfaces. Cross wires sit against, rather than
through, longitudinal bars. Rectangular support blocks contact the bottom mesh;
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
three bars). Their height follows clear cover (50 mm by default). Spacers default
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
The axis of the first run drawn stays at nominal cover, and the stacked run's
supports grow to suit, so a straight or single-axis footing is unchanged. The
stacked run's cover increases by one mesh depth, which the depth check includes.

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
