# Starter bars

Open **Extensions > Basegrid > Create / Edit Starter Bars**. One dialog contains straight starters, tapered starters, horizontal pins and step Z-bars. Settings and material selections are remembered between SketchUp sessions.

## Path layouts

Select a connected chain or closed loop of edges for straight starters, tapered starters or horizontal pins. Elevation changes and sloping runs are supported; spacing is measured in plan. Vertical edges represent steps and do not consume spacing distance.

After accepting the settings, pick the first-bar anchor on the selected path. Tab cycles between the path endpoints. Right-click **Reverse layout direction** changes the inside/outside orientation on open paths. Closed paths use the geometric interior. The preview shows the bar centrelines before placement. No arrow, Shift or global SketchUp shortcut is reassigned.

First offset is measured outward from the picked anchor. On open paths bars populate both sides of that anchor, with the nominated spacing. On loops the layout wraps once without duplicating the closing bar. Tapered crank lengths interpolate from path start to end on open paths, and from the picked anchor around closed paths.

Straight and tapered bars have above/below-baseline lengths, top and bottom crank lengths and in/out directions. Pins have in/out lengths. Optional chairs sit under bottom cranks; optional caps sit at the top/free end. Chairs and caps are simplified nominal shapes, not manufacturer profiles. The current chair model is a 50 mm high frustum, placed 100 mm from the crank end (centred on short cranks) and at 800 mm intervals. Caps use a nominal 50 mm diameter and 25 mm depth. Bar geometry uses a circular swept profile with sharp mitred changes in direction; bend allowances are not included in quantities.

## Materials and editing

Bar diameter is not shown in the dialog. A selected bar material must supply valid diameter metadata; missing metadata must be corrected in the library and synced. Unassigned geometry retains the existing nominal default diameter.

Material options come from the cached active web material types: **Reo Bar Processed**, **Bar Chairs** and **Reo Bar Safety Caps**. Selected bar diameter comes from `dimensions_mm.diameter_mm` when available. Unassigned dimensioned geometry is supported. Repeated identical path bars, chairs and caps use component definitions; quantities are written per placed instance. Bar takeoff follows the material type's metres or each unit; accessory quantities use each.

Select a generated assembly and reopen the same command to edit and regenerate it in one undoable operation. Editing replaces that assembly's generated geometry. It does not preserve manual edits inside the assembly. Source path edges are retained. Path and step assemblies cannot be converted into each other through edit mode.

## Step Z-bars

Select two individual bar groups/components, or choose Step Z-bars and pick the upper and lower bars. Repeat picking to place additional pairs; Escape exits. Settings include upper/lower crank lengths and directions and horizontal/vertical adjacency offset. Zero offset uses the bar diameter. This version pairs explicitly selected/picked bars; it does not reproduce the reference's automatic matching of multiple bars by plane/run tolerances.

## Verification

Offline tests cover path ordering, layout/steps/loops, offsets, taper, materials, settings, and deferred placement lifecycle. Live SketchUp geometry and physical Windows/Mac keyboard testing remain necessary. No live model is changed by these tests.
