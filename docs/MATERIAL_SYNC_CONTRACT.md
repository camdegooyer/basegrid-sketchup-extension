# Material sync contract

The SketchUp extension reads a versioned, organisation-scoped library snapshot from:

```text
GET /api/v1/material-library
Authorization: Bearer <extension access token>
If-None-Match: <previous ETag>
```

The web API remains the source of truth. SketchUp stores a read-only last-known-good cache outside the installed extension and sends the cached ETag on later syncs.

## Connection flow

The primary connection uses OAuth 2.1 Authorization Code with PKCE S256. The
SketchUp extension is a public client without a client secret. It opens the
system browser and receives the authorization callback on the registered
loopback URI `http://127.0.0.1:43821/oauth/callback`. Access tokens presented to
the material endpoint must contain the registered SketchUp client ID. The
existing one-time connection-token flow remains available during migration.

Required production configuration:

- enable the Supabase OAuth 2.1 server and set its authorization path to
  `/oauth/consent`;
- register a public client named `Buildgrid for SketchUp` with the exact
  loopback redirect URI above; and
- set `SKETCHUP_OAUTH_CLIENT_ID` and `SKETCHUP_OAUTH_REDIRECT_URI` in Vercel.

The fallback one-time connection-token flow is:

1. SketchUp opens `https://buildgrid.overlandbuilders.co/app/connections` in the user's browser.
2. The signed-in user creates a revocable connection for one SketchUp installation.
3. The web app displays the opaque token once.
4. The user pastes it into **Extensions > Buildgrid > Materials > Connect**.
5. The extension performs a material sync before saving the token. Failed tokens are not stored.
6. **Disconnect** removes the local token but retains the last valid material and texture cache for offline model resolution.

The connection page must list active connections with their creation date, last-used date and a revoke action. Store only a cryptographic hash of each token in the database. The plaintext token must never be recoverable after its one-time display. Bind each token to the issuing user and organisation, and have the export endpoint derive tenant scope from the token rather than accepting an organisation ID from SketchUp.

## Version 1 response

```json
{
  "api_version": "v1",
  "organisation": { "id": "organisation-uuid", "name": "Example" },
  "takeoff_groups": [
    {
      "id": "takeoff-group-uuid",
      "name": "Concrete slabs",
      "status": "active"
    }
  ],
  "generated_roles": [
    {
      "id": "concrete.slab_from_face.slab_body",
      "tool_id": "concrete.slab_from_face",
      "takeoff_group_ids": ["takeoff-group-uuid"]
    }
  ],
  "material_types": [
    {
      "id": "type-uuid",
      "name": "Concrete",
      "profile": "bulk",
      "uom": "m3",
      "status": "active",
      "materials": [
        {
          "id": "material-uuid",
          "name": "N25 Concrete",
          "status": "active",
          "construction_texture": {
            "texture_id": "texture-uuid",
            "signed_url": "https://signed-texture-url",
            "width_mm": 1000,
            "height_mm": 1000
          },
          "display_texture": {
            "texture_id": "display-texture-uuid",
            "signed_url": "https://signed-display-texture-url",
            "width_mm": 1000,
            "height_mm": 1000
          }
        }
      ]
    }
  ]
}
```

The extension normalizes this nested API response into its flat, versioned local cache. The slab tool offers only active materials whose active type has the exact name `Concrete`, profile `bulk`, and UOM `m3`. Material and type UUIDs are stored in the model. Names are display values, not entity identity.

Appearance objects are optional. They can supply a solid `color` or a signed PNG/JPEG URL. Images are limited to 20 MB. A failed texture download produces a warning without discarding an otherwise valid material snapshot.

Retired records remain in the snapshot so saved models can resolve their existing UUIDs, but they are not offered for new slabs.

`takeoff_groups` contains the organisation's groups. `generated_roles` is the web-managed allowlist that determines which active groups each generated role may offer. Both use stable IDs; names are display values. The extension rejects a snapshot when a role refers to a group that is absent from the snapshot. These arrays may be empty while the web app is being migrated.

When a slab is created, its takeoff record stores the selected group IDs and snapshot names. The names keep an offline model readable, while the IDs remain authoritative. An object assigned to multiple groups contributes to each grouped view but only once to the overall model total.
