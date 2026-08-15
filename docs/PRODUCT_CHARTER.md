# BuildGrid product charter

Founding team: Cam de Gooyer and Daniel Perrem.

## Product promise

BuildGrid lets builders and designers ask an AI to create construction-aware model geometry while retaining deterministic control, reviewable evidence and commercial traceability.

The premium experience is not “AI that clicks SketchUp.” It is a governed construction system in which an AI can discover a capability, produce a valid intent, explain a preview, obtain the required approval and invoke a deterministic tool whose output can be inspected, rebuilt, measured and audited.

## Primary users

- Builders and estimators who need drawing decisions to remain connected to quantity and cost evidence.
- Designers and drafters who need fast, predictable construction geometry.
- Business owners who need controlled access, revision history and trustworthy exports.
- AI agents and integrations that need strict, discoverable capabilities rather than UI automation.

## Core jobs

1. Turn a natural-language construction request into a validated drawing intent.
2. Preview geometry and commercial consequences before changing the model.
3. Build deterministic, editable model objects.
4. Inspect why an object exists and how it was calculated.
5. Rebuild safely after a deliberate parameter or context change.
6. Produce typed demand that can become estimates, orders, cut lists and revision explanations.

## Product boundaries

BuildGrid owns:

- capability discovery and versioned tool contracts;
- intent validation, preview, approval and job orchestration;
- deterministic tool execution in the model runtime;
- generated-object lineage and lifecycle;
- product identity, context, demand, recipes and traceable commercial views;
- tenant policy, permissions, audit and entitlement enforcement.

BuildGrid does not silently claim:

- structural design or certification;
- code compliance without a complete reviewed rule source;
- live supplier stock, freight or future prices;
- guaranteed site productivity or programme outcomes;
- contract entitlement or final purchasing approval.

## Commercial posture

- Multi-tenant SaaS control plane with an authenticated desktop runtime.
- Organisation, project and model scopes with role-based access and immutable audit events.
- Subscription and entitlement checks at the cloud boundary, with short-lived signed runtime grants for resilient local work.
- Provider-neutral AI orchestration so customer data and model choice can be governed independently.
- Explicit retention, export and deletion policies for model metadata, prompts, files and audit records.
- Versioned APIs and migrations with backwards-compatibility windows.
- Windows and macOS are supported product platforms from the first vertical slice.


## Success measures

- Preview-to-build success rate and median end-to-end latency.
- Percentage of AI requests resolved without manual contract repair.
- Rebuild and delete lifecycle pass rate.
- Deterministic-plan test pass rate across supported host versions.
- Percentage of commercial outputs with complete source and calculation lineage.
- User corrections per accepted build and time saved per production task.
- Zero cross-tenant access incidents and complete mutation audit coverage.
