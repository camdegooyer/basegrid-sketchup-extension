# SketchUp Tool Definitions

`config/sketchup_tool_definitions.json` is the first product-facing layer over the ontology. It groups accepted physical objects into drawing tools that a SketchUp extension can implement.

The manifest is intentionally small and practical. It does not create UI code, command classes or a plugin framework yet. It answers the first implementation question: which ontology objects should each SketchUp tool draw, reveal, hide or ask the user about?

## Tool Record Meaning

- `root_object_id` is the main assembly or object the tool creates.
- `required_object_ids` are the minimum objects the tool should place or represent.
- `optional_object_ids` are detail objects the tool can expose when the user chooses a variant or a higher detail level.
- `draw_input` describes the geometric input the command needs, such as a wall path, face selection, opening rectangle or service route.
- `variants` are product-neutral choices the user can make before the plugin asks for specific sizes or products.
- `draw_behaviour` is plain-English implementation guidance for the first generator.
- `never_infer` lists decisions the plugin must not invent from the ontology.

## Detail Levels

The manifest uses four shared detail levels:

- `mass`: draw only the major object or bounding volume.
- `assembly`: draw the primary assembly and major layers.
- `parts`: draw repeated members, panels, boards, trims, rails and fixtures.
- `section_detail`: reveal concealed fixings, membranes, seals, washers, brackets, tapes and similar small parts.

The early SketchUp extension should default to `assembly` or `parts`, then let the user turn detail families on as needed. This avoids drawing thousands of screws, washers or clips when a model only needs wall and roof massing.

## First Plugin Shape

The first implementation should load:

1. `exports/ontology.json`
2. `exports/relationships.json`
3. `config/sketchup_tool_definitions.json`

Then each tool can:

1. look up its `root_object_id`;
2. load required and optional object records;
3. present `variants` and detail levels to the user;
4. draw geometry from `draw_input`;
5. tag created SketchUp groups/components with the ontology object ID.

The SketchUp model should store ontology IDs on generated groups/components. Names are useful for humans, but IDs are what let later tools update, schedule, hide or inspect objects reliably.

## Current First Tool Set

The initial manifest defines tools for:

- timber wall frames;
- slab-on-ground systems;
- timber floor frames;
- roof frame and covering;
- external cladding;
- windows and external glazed doors;
- deck and balcony platforms;
- wet areas and showers;
- stairs and barriers;
- internal linings;
- electrical points and routes;
- plumbing and drainage routes;
- mechanical air distribution;
- specialist services and safety;
- commercial facade, openings and transport;
- accessibility, site and specialist fitout.

These are deliberately broad drawing tools. More specialised commands can be split out later once the first SketchUp implementation proves the data flow.
