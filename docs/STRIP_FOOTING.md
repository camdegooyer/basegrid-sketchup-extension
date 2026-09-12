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
and a **Mesh Frame**. Identical bars, support blocks and spacer pairs share
component definitions; their placements remain individual component instances.
Changing a definition updates its matching instances. Concrete segments and mesh
assemblies remain groups because their geometry can differ by run.

The default mesh has three 12 mm longitudinal bars at 100 mm centres, top and
bottom layers, and 8 mm cross bars at 300 mm spacing. Support blocks default to
10 mm wide along the run and span the outer longitudinal bar centres (200 mm for
three bars). Their height follows clear cover (50 mm by default). Spacers default
to two 6 mm bars, 14 mm apart, at each side of the mesh. Their height follows the
clear space between the longitudinal layers. Supports begin 200 mm after end
cover and repeat at 900 mm spacing; a short run gets one centred support if it fits.

**Reinforcement connections at corners, steps and junctions remain undetailed.**
Each run has its own terminated mesh. Intersecting runs may therefore have steel
clashes; v1 does not resolve their elevations, bends or laps. This limitation is
shown in the dialog, reported after creation, and stored on the assembly. It
requires the user's connection detail before the next geometry stage.

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
clear cover, separated mesh wires, support contact, Tab anchor cycling, material filtering and
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
