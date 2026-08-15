# BuildGrid system architecture

Status: foundation baseline
Scope: AI request to deterministic model execution and commercial evidence

## Architectural thesis

BuildGrid is a hybrid SaaS. The cloud is the secure control plane; the desktop extension is the model execution plane. The AI never receives arbitrary access to the host application and the cloud never calls an unauthenticated localhost server.

```text
Web / desktop UI / customer AI
             |
             v
Cloud API gateway
  identity · tenant · entitlement · policy · rate limit
             |
             v
Drawing job service ---- immutable audit / observability
             |
             v
Authenticated outbound model session
             |
             v
Desktop runtime
  contract registry -> validator -> planner -> preview/approval guard
                                         |
                                         v
                              main-thread atomic executor
                                         |
                                         v
          geometry + metadata + typed demand + lifecycle result
             |
             v
Cloud job result / ledger projection / user explanation
```

## One capability, two boundaries

### Public SaaS boundary

The public API creates and monitors drawing jobs. It authenticates the user or agent, establishes organisation/project/model scope, enforces entitlement and records the audit trail. It does not execute host geometry.

Conceptual operations:

- discover tools available to a connected model session;
- create a validate or preview job;
- confirm a preview using its plan hash;
- create a build, rebuild or delete job;
- read job status, structured result and evidence.

### Model-runtime boundary

The model runtime exposes each registered capability through stable tool-addressed operations:

- `GET /v1/tools/{tool_id}`
- `POST /v1/tools/{tool_id}/validate`
- `POST /v1/tools/{tool_id}/preview`
- `POST /v1/tools/{tool_id}/build`
- `GET /v1/entities/{entity_id}`
- `POST /v1/entities/{entity_id}/rebuild`
- `DELETE /v1/entities/{entity_id}`

The checked-in OpenAPI contract defines this runtime protocol. During local development it may use a loopback transport. In production the desktop runtime should initiate an authenticated outbound session and receive the same protocol as signed jobs through that session.

## Required execution flow

1. The client reads tool contracts for the active, authorised model session.
2. The AI or UI creates a drawing intent containing a tool ID, contract version, anchor, parameters, context and canonical material references.
3. The cloud attaches trusted actor, tenant, project and policy claims. Client-supplied metadata cannot elevate authority.
4. The runtime validates the envelope, the specific tool schema, material compatibility and model preconditions without mutating geometry.
5. Preview runs the deterministic planner and returns a plan hash, geometry summary, demand summary, warnings and required approvals.
6. The user or authorised policy confirms that exact plan hash.
7. Build requires the same normalized intent, tool version, plan hash and expected model revision. A stale preview fails closed.
8. The executor opens one host-model operation, materializes the plan, records lineage and commits atomically. Failure aborts the operation.
9. The result records created entity IDs, new model revision, demand evidence, warnings and trace IDs.
10. The cloud closes the job and appends immutable audit events. Estimate and procurement views are downstream projections, not geometry authority.

## Determinism boundary

AI reasoning ends before the planner. For a given normalized intent, tool version, contract version, source/rule bundle and relevant model snapshot, the planner must produce the same canonical plan and plan hash.

Randomness, current time, live prices and network results are not planner inputs unless converted into explicit, versioned input records. Floating-point serialization and entity ordering must be canonicalized before hashing.

## Tool anatomy

Each tool is a cohesive capability package:

```text
contract
  -> normalizer
  -> validator
  -> pure planner
  -> preview serializer
  -> host executor
  -> metadata/lifecycle adapter
  -> typed demand emitter
  -> verification fixtures
```

The UI never owns geometry rules. The API route never owns tool-specific geometry. The executor does not decide materials, recipes or routing that were absent from the approved plan.

## Core data separations

- Product: intrinsic material or explicit technical/purchasing variant.
- Application: what a generated object is doing.
- Context: building, level, zone and room.
- Work stage: delivery or programme package.
- Demand: raw typed measurement with source evidence.
- Recipe output: versioned material, labour, plant or subcontract demand.
- Ledger line: ungrouped, traceable allocation.
- Order line: supplier-specific stock/pack conversion and grouping.
- Export revision: immutable issued snapshot.

These records may join; they must not collapse into a single overloaded row.

## Security and tenancy baseline

- OIDC/OAuth identity at the public boundary; short-lived device/session credentials for the desktop runtime.
- Organisation and project scope derived from verified claims, never request-body IDs alone.
- Per-job authorisation, entitlement and capability checks.
- Encrypted transport and encrypted managed data; managed secrets outside prompts and logs.
- Outbound-only production model sessions with session rotation and revocation.
- Idempotency keys on mutations and replay protection on signed jobs.
- Bounded anchors, parameters, payload sizes, rates and execution time.
- Append-only security and model-mutation audit events.
- Explicit human confirmation for broad, destructive, costly or policy-sensitive operations.

## Reliability and operations baseline

- Job state machine: `queued -> dispatched -> validating -> previewed -> awaiting_confirmation -> executing -> succeeded|failed|cancelled|expired`.
- At-least-once delivery with idempotent mutation handling; never assume exactly-once transport.
- Heartbeats and explicit session/model revision tracking.
- Correlation across API request, drawing job, runtime session, host operation and output entities.
- Structured errors with stable codes, safe user messages and private diagnostic detail.
- Metrics, traces, logs, crash reports and redaction verified before production.
- Database migrations, backups, point-in-time recovery and restore drills are part of release readiness.

## Technology decisions deliberately deferred

Cloud language/framework, queue, database hosting, deployment platform, AI provider and billing provider remain replaceable implementation choices until the first tool proves the protocol. PostgreSQL, a typed cloud service and durable job delivery are likely fits, but no vendor is part of the foundation contract.
