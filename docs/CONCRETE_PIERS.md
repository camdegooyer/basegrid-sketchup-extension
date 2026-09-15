# Concrete piers

Open **Extensions > Basegrid > Create / Edit Concrete Piers**.

Starter-bar diameter is derived from the selected material and is not displayed as an input. A selected bar material without diameter metadata is rejected. Concrete pier diameter remains visible. Unassigned starter bars retain the existing nominal default diameter.

Set pier diameter, depth and concrete material. Enable the optional central starter bar to set its material, above/below lengths, top/bottom crank lengths and in/out directions. Materials come from the cached Concrete and Reo Bar Processed types. A selected bar product supplies its diameter where available. Unassigned materials are allowed.

Click the pier's top centre; concrete extends downward. With a starter bar enabled, click again to choose its horizontal crank direction. In follows that direction; Out reverses it. Repeat to place more piers. Escape cancels an unfinished direction pick, then exits placement. Native InputPoint snapping and Shift inference locking are used; arrow keys lock the red, green and blue directions, and Down locks the current inference. Space is not rebound. A round pier has one centre anchor.

Select one generated pier and reopen the same command to edit it. Its existing transform and crank orientation are retained, including when adding a bar to a previously plain pier. Rotate the pier with SketchUp's native Rotate tool to change its orientation. Editing replaces generated contents and does not preserve manual edits inside the pier. Each pier is a separate group with Concrete and optional Starter Bar children. Each placement or edit, including materials and takeoff, is one undoable operation.

Last-used inputs and material IDs are saved in SketchUp preferences and survive restart. Concrete uses a 24-sided profile, matching the reference; starter bars use the existing 8-segment swept-profile builder. Crank lengths are centreline lengths with sharp mitred bends. Cover, structural sizing and bend allowances are not calculated or certified. Enter the required detailing dimensions explicitly.

Concrete takeoff records the generated polygonal volume, including enclosing scale, rather than the slightly larger ideal circular volume. Bar takeoff uses transformed centreline length or each, according to its material unit. Manual geometry edits do not recalculate takeoff.

## Reference review

Reviewed `C:\dev\OB_ToolsExtension\overland_builders\ob_tools\concrete_pier.rb` only. The Basegrid implementation does not import the old PlusSpec dependency, material-name identity, model-level preferences or tag hierarchy.

- Reference settings convert text with `to_f` without rejecting invalid or non-positive dimensions. Basegrid validates before mutation.
- Reference edit uses stored centre coordinates after a group can have moved; Basegrid keeps geometry local and preserves the instance transformation.
- Reference checks 3D direction length before flattening Z, permitting a zero horizontal direction. Basegrid validates the horizontal direction.
- Reference placement applies materials in another operation; Basegrid geometry, bindings and quantities share one transaction.

Inference implementation follows the official [SketchUp InputPoint API](https://ruby.sketchup.com/Sketchup/InputPoint.html) and [View.lock_inference API](https://ruby.sketchup.com/Sketchup/View.html#lock_inference-instance_method).

## Verification

Offline tests cover settings, materials, bar profiles, persisted preferences, HTML escaping, repeated placement, pending cancellation, context changes and retry after failure. Native cylinder/sweep generation, editing, undo and physical Windows/Mac key handling still require live SketchUp verification. The user's open model was not changed during implementation.
