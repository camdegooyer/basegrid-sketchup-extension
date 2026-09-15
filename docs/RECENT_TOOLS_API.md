# Drawing API and MCP (0.3.3)

The local HTTP bridge, standalone MCP and hosted MCP share the definitions in
`config/basegrid_api_tools.json`. The hosted copy is `lib/mcp-tools.json` in the
web app. The extension dispatcher calls the same builders as the native tools;
API calls do not open dialogs or overwrite the user's saved UI settings.

## Commands

| Command | Required geometry | Notes |
| --- | --- | --- |
| `basegrid_create_slab` | Existing horizontal face reference or single selected face | Existing endpoint |
| `basegrid_create_strip_footing` | `paths_mm` | Explicit horizontal paths, including separate levels for steps |
| `basegrid_create_starter_bars` | `points_mm` | Straight, tapered or pins; optional `anchor_mm`, `reverse` |
| `basegrid_create_step_z_bars` | `pairs` | Each pair has `upper` and `lower`, each with two centreline `ends` |
| `basegrid_create_concrete_pier` | `top_center_mm` | Extends down vertically; optional `rotation_deg` for starter cranks |
| `basegrid_create_flashing` | `points_mm` | Open planar path, optional dimensionless `normal` |
| `basegrid_create_structural_steel` | `start_mm`, `end_mm`, `settings.material_id` | Arbitrary 3D member; length comes from endpoints |

Every create command requires `model_guid` from `basegrid_status`. Hosted MCP
also requires `device_id` and a UUID `request_id`. Inspect-only mode blocks all
drawing. Never resubmit a pending/uncertain command with a new request ID; poll
`basegrid_command_status`. These rules and the existing main-thread queue apply
to every new endpoint.

Points and lengths are millimetres in world coordinates, including when an
editing context is open. Settings and material selectors are fully described
in the tool schema. Omitted settings use deterministic builder defaults, not
the user's remembered settings. Material dimensions remain authoritative.

For non-slab materials use `basegrid_list_materials` with `concrete_only=false`.
Results include dimension metadata and material type names/profiles/units, but
exclude signed texture URLs and local cache paths. Flashing selects material by
finish/girth/folds automatically. Steel requires an assigned material. Bars and
piers may be unassigned, using the same nominal defaults as their UI tools.

## Replacement and results

Slab and strip-footing `replace_ref` support requires extension 0.3.3 or later.

All seven drawing commands, including slabs and strip footings, accept optional
`replace_ref`. It must reference an unlocked group created by that same tool in
the active editing context. Supply the complete desired world geometry and
settings; this is not a partial patch. The builder creates the replacement and
removes the old group in one Undo operation. Invalid geometry or materials must
not remove the old group. Reference IDs change after replacement.

Slab replacement still requires a source horizontal face in the active context
(`face_ref` or exactly one selected face), thickness and concrete material. The
source face and its openings are retained. Footing replacement requires all
desired `paths_mm`, settings and material bindings; supply existing values to
preserve them. Both regenerate geometry, material metadata and takeoff within
one Undo operation. Neither endpoint infers changes from manually edited solids.

The five newer commands return the generated root reference, resolved parameters,
and takeoff records for its children. Quantities remain creation snapshots;
later manual edits do not recalculate them. Slab and footing keep their existing
response formats. `basegrid_tool_catalog` reports all seven implemented tools;
request one `tool_id` to obtain its complete input schema.

Example native arguments for steel (add routing fields for hosted MCP):

```json
{
  "model_guid": "from-status",
  "start_mm": [0, 0, 0],
  "end_mm": [4000, 1000, 500],
  "settings": {
    "material_id": "from-material-list",
    "usage": "beam",
    "anchor": "top_left",
    "rotation_deg": 0
  }
}
```

New generators require extension 0.3.2 or later. Restart SketchUp after updating.
Reconnect/refresh the MCP client if it caches tool discovery. Automated tests
cover dispatch, nested validation, permissions, replacement and both MCP
transports; live-model geometry smoke testing remains outstanding.
