# BuildGrid development instructions

These instructions apply to the entire HQ BuildGrid workspace.

## Team and platforms

- The founding development team is Cam de Gooyer and Daniel Perrem.
- Cam develops on Windows; Daniel develops on macOS. Treat both as first-class development and release platforms.
- Do not commit user-specific absolute paths, drive letters, backslash-only paths or filename assumptions that fail on a case-sensitive filesystem.
- Resolve repository and runtime paths with platform APIs. Keep persisted identifiers and API locators independent of filesystem paths.
- Keep text-source line endings governed by `.gitattributes` and UTF-8.
- Any developer command must be cross-platform or documented with tested Windows PowerShell and macOS shell equivalents.
- CI must include Windows and macOS checks where host/runtime behaviour can differ.
- A tool is not production-ready until its host-application lifecycle smoke pass succeeds on both supported platforms, or a time-bounded platform exclusion is explicitly documented and approved.

## Product discipline

- Build one tool at a time as a complete vertical slice. Do not bulk-port SketchOB tools or preserve an old abstraction merely because it exists.
- Study existing code for proven geometry, tests and edge cases; rebuild it behind BuildGrid contracts and naming.
- Keep cloud orchestration, model-runtime execution, domain rules and user interfaces separated.
- Keep contracts language-neutral. A Ruby SketchUp runtime and a TypeScript cloud service must implement the same published protocol.
- Treat every breaking contract change as a new major schema or tool version. Never silently reinterpret stored intent.

## AI-to-tool execution

- AI may submit only structured, schema-validated drawing intent. Never expose arbitrary Ruby, JavaScript, SQL, shell or unrestricted model traversal.
- A tool must expose deterministic `validate`, `preview` and `build` paths from the same planner before it can be AI-enabled.
- Bind build approval to the preview `plan_hash`, tool version, contract version and expected model revision.
- Run all host-application model mutations on its required main thread and inside an atomic operation.
- Require idempotency keys for mutations and return structured, actionable errors.
- Store original intent, normalized intent, plan hash, tool/contract versions, context IDs and result evidence on authoritative generated entities.
- Support inspect, rebuild and delete before marking a tool production-ready for AI.

## Tool contract

Every registered tool must declare:

- stable tool ID and versioned contract;
- strict parameter, anchor, context and material-role schemas;
- output and metadata schemas;
- lifecycle and AI-release flags;
- priceable outputs, authoritative quantity carriers and takeoff exclusions;
- rule surfaces, catalogue dependencies and source references;
- known limits, unsupported cases and compliance exclusions.

Default `ai_enabled` and `production_ready` to `false`. Enable them only after the release gate passes.

## Materials, demand and commercial data

- Keep product identity separate from application, location, work stage, estimating category and financial allocation.
- Emit typed raw demand before recipes, waste, supplier conversion or grouping.
- Preserve granular evidence and group late into estimate, procurement, cutting and revision views.
- Version recipes, routing, supplier offers and policies. Freeze their versions into issued exports.
- Treat tags and folders as repairable projections of authoritative metadata, never as silent costing authority.

## Sources and claims

- Declare machine-readable source references for every standard, manufacturer document, builder policy or dataset that shapes geometry, validation, compatibility, demand or recipes.
- An empty source-reference array is valid only when no external source applies.
- Record source edition, applicable sections, purpose and authority. Never infer equivalence between editions.
- Keep modelling scope, coordination guidance and compliance authority distinct.
- Preserve truthful exclusions for structural design, member selection, bracing, tie-down, certification, availability, price currency and site productivity unless reviewed authoritative rules support them.

## Commercial quality

- Design for tenant isolation, least privilege, auditability, privacy, regional data controls and supportable migrations.
- Never put secrets, access tokens, supplier credentials or private model content in prompts, logs or fixtures.
- Use correlation IDs, structured logs, metrics and traces across cloud-to-runtime jobs.
- Make mutations retry-safe and failure-safe. Partial geometry must not survive a failed operation.
- Accessibility, performance, observability, backups, restore testing and security review are release requirements, not later polish.

## Verification

- Add contract, validation, deterministic-planner, lifecycle, idempotency and failure-path tests for every tool.
- Test malformed and undeclared input, stale model revisions, stale previews, repeated mutation requests and rollback.
- Verify declared local source locators exist.
- Require a real host-application preview/build/inspect/rebuild/delete smoke pass before production AI release.
- Record verification evidence beside the tool's release decision.
