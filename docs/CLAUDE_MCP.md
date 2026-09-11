# Basegrid MCP connector

Basegrid has its own MCP server, native SketchUp API dispatcher, object references,
authentication token and local HTTP connection. It is independent of SketchAI.
SketchUp and the Basegrid extension are sufficient on the modelling side.

## Local development setup

The local MCP process needs Node.js 18 or later; no npm packages are required.
From this repository, install its Claude Desktop entry with:

```powershell
node scripts/install_claude_mcp.mjs
```

Use `--dry-run` to preview the entry. The installer preserves other Desktop settings
and creates a timestamped backup. It writes the platform's Claude Desktop config
and uses absolute paths to Node and this repository's `mcp/server.mjs`.

For Claude Code in the terminal:

```powershell
claude mcp add --scope user --transport stdio basegrid -- node C:\Users\cam\basegrid-sketchup-extension\mcp\server.mjs
claude mcp get basegrid
```

Use your own repository path on macOS. Restart Claude Desktop or start a new
`claude` terminal session after installing/updating. `/mcp` shows the registered
server in Claude Code. Local Desktop config files and Claude Code registrations
are separate; a hosted account connector can be shared, as described below.

Open SketchUp with Basegrid enabled. **Extensions > Basegrid > MCP API** has Start,
Stop and Permissions commands. The API also starts when Basegrid loads. It listens
only at `http://127.0.0.1:9878` and rejects browser origins and unauthenticated calls.
`BASEGRID_API_URL` can override the local MCP client's address, but must remain a
loopback HTTP URL. This development listener is not the hosted SaaS MCP endpoint.

The local token lives at `%LOCALAPPDATA%/Basegrid/mcp-token.txt` on Windows or
`~/Library/Application Support/Basegrid/mcp-token.txt` on macOS. It is generated
automatically. The user does not need to copy it into Claude. It is separate from
the web material-library OAuth credentials.

## Tools and native API access

| MCP tool | Purpose |
| --- | --- |
| `basegrid_status` | Current model GUID, selected face references and material connection status |
| `basegrid_list_materials` | Eligible material IDs and permitted takeoff groups |
| `basegrid_sync_materials` | Sync using Basegrid's existing web sign-in |
| `basegrid_create_slab` | Run the actual Basegrid slab generator |
| `basegrid_takeoff` | Stored quantities, grouped totals or CSV text |
| `basegrid_set_appearance` | Change generated objects' model/display appearance |
| `basegrid_set_slab_tag_folder` | Default folder for newly created slab tags |
| `basegrid_tool_catalog` | Implemented generators and planned tool definitions |
| `basegrid_find_objects` | Search or retrieve construction ontology records |
| `basegrid_native_api` | Discover native API classes, methods, units and permissions |
| `basegrid_model` | Inspect selection, model bounds, tags and materials |
| `basegrid_invoke` | One native SketchUp instance-method call |
| `basegrid_batch` | Chained native calls with one geometry Undo operation |
| `basegrid_capture_view` | Return a viewport PNG to Claude |

Common geometry operations have explicit read/edit permissions. Basegrid also
discovers native C-backed SketchUp/Geom instance methods available in the running
SketchUp version; additional methods require the user to enable `full` permission
in the MCP API menu. Inherited general Ruby methods and methods added by other Ruby
extensions are not automatically exposed. Ruby source execution and block/callback
arguments are not supported. Batch transaction control belongs to Basegrid.

`inspect` permits reads, `edit` permits the common drawing operations and Basegrid
tools, and `full` permits the remaining discovered native methods, including
destructive/file operations where the SketchUp API provides them. Discovery lists
what is available. Object references are local to the API session and model;
deleted/undone references and references from another model are rejected.

The local HTTP API is `POST /basegrid/tools` and `POST /basegrid/call` with
`Authorization: Bearer <local token>`. Calls contain a `name` and `arguments`.
All SketchUp work runs on Basegrid's UI-thread queue. Requests that time out before
starting are cancelled; if execution already started, inspect before retrying.

## Example: native face, then Basegrid slab

First call `basegrid_status` for the current `model_guid`, and
`basegrid_list_materials` for the concrete material and optional takeoff group.
Then call `basegrid_batch` with:

```json
{
  "model_guid": "current model GUID",
  "operation_name": "Slab footprint",
  "calls": [
    {"id":"entities","target":{"$root":"active_model"},"method":"active_entities"},
    {"id":"face","target":{"$result":"entities"},"method":"add_face","arguments":[[
      {"$type":"Point3d","x":0,"y":0,"z":0,"unit":"mm"},
      {"$type":"Point3d","x":6000,"y":0,"z":0,"unit":"mm"},
      {"$type":"Point3d","x":6000,"y":4000,"z":0,"unit":"mm"},
      {"$type":"Point3d","x":0,"y":4000,"z":0,"unit":"mm"}
    ]]}
  ]
}
```

Pass the face result's `$ref` to `basegrid_create_slab`:

```json
{
  "model_guid": "current model GUID",
  "face_ref": "bg_session_2",
  "thickness_mm": 150,
  "material_id": "eligible material ID"
}
```

The Basegrid tool writes the same material IDs, role tag and takeoff metadata as
the SketchUp dialog. This example is 24 m² × 0.15 m = 3.6 m³. Source openings are
retained. The footprint and slab are separate Undo operations. Only the concrete
slab generator is implemented today. Other catalogue tools are `definition_only`.
Takeoff is stored at creation and does not recalculate after native/manual edits.

## Adding more tools

Keep the same Basegrid connector as the product grows. For each implemented
Basegrid command, add its MCP description and input schema to
`config/basegrid_api_tools.json`, and connect its handler in `basegrid/api.rb` to
the underlying drawing tool. Both the MCP server and SketchUp API read this
catalogue. Restart SketchUp and the MCP client after a local update to reload it;
there is no separate Claude connector to configure for each new drawing tool.
Adding a planned tool definition alone does not implement a drawing command.

## Hosted connector and OAuth

The hosted implementation uses `https://app.basegrid.com.au/mcp`, account OAuth
sign-in and an outbound HTTPS connection from the extension. Its web routes and
database migration live in the Basegrid web-app repository. Deployment of both
repositories and the migration is required before using the production URL.

Choose **Extensions > Basegrid > Cloud Drawing > Connect** and sign in. Add the
hosted custom connector in Claude and approve access to the same organisation.
Cloud Drawing reconnects on SketchUp startup until disconnected. **Status** shows
the connection state; **MCP API > Permissions** controls allowed operations.
Disconnecting Materials also disconnects cloud drawing. Local MCP still works
independently. Cloud drawing needs neither Node nor a development checkout.

The hosted connector lists devices explicitly; every drawing call includes its
device ID and a unique request ID. Retrying an identical request ID returns the
original outcome. Commands are claimed once, expire before execution after
60 seconds, and execute on the main thread only if the active model still matches.
Separate credentials protect the Claude grant and each SketchUp process.

The complete local integration test used the official MCP client, browser consent,
the real web routes/database and a live SketchUp 2026 process. Face → slab produced
a solid 3.6 m³ slab, repeating the request did not create a second slab, and image
delivery passed. The account/material inputs were fixtures. Production account
sign-in is still required during deployment acceptance.

Build an installable extension with `node scripts/package_extension.mjs`. Install
`dist/Basegrid-0.2.1.rbz` through SketchUp's Extension Manager. All runtime resources
are bundled beneath `basegrid/`; no repository paths are required. Avoid loading
both an installed RBZ and a development loader for the same extension.

With a hosted connector added and authorised through the Claude account, Claude
Code can discover it when using the same claude.ai subscription login. API-key and
third-party-provider sessions have different behaviour. See
[Claude's account connector documentation](https://code.claude.com/docs/en/mcp#use-mcp-servers-from-claudeai).
Claude supports OAuth for custom hosted connectors; see
[custom connector setup](https://support.claude.com/en/articles/11175166-get-started-with-custom-connectors-using-remote-mcp).

## Verification

```powershell
ruby -Itest -e 'Dir.glob("test/*_test.rb").sort.each { |file| require_relative file }'
node --test test/mcp_test.mjs
```

These cover the independent stdio and HTTP transports, token/origin validation,
main-thread execution, cancelled queued requests, native object chaining and
millimetres, rollback, and passing a native face into the Basegrid slab builder.
On Windows with SketchUp 2026, a disposable model also passed a native 6 m × 4 m
face → actual Basegrid 150 mm slab check: a manifold solid with both measured
volume and takeoff of 3.6 m³, the source face retained, and `Slab | Concrete` tag.
Runtime discovery reported 82 native classes, and viewport PNG capture succeeded.
Other SketchUp versions and macOS still need live validation. The underlying
geometry APIs require the main thread:
[SketchUp Ruby API](https://ruby.sketchup.com/).
