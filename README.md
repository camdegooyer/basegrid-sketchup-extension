# HQ BuildGrid

BuildGrid is a commercial construction-intelligence platform that turns reviewed AI drawing intent into deterministic, inspectable model geometry and traceable commercial data.

This repository is a clean product foundation. Existing SketchOB code may be studied and selectively rebuilt one tool at a time, but it is not being bulk-migrated.

## Team

- Cam de Gooyer — Windows development.
- Daniel Perrem — macOS development.

Both platforms are first-class development and release targets. See [the team workflow](docs/TEAM_AND_WORKFLOW.md).

## Product boundary

```text
Human or AI client
        |
        v
Versioned drawing intent
        |
        v
Tool contract -> validate -> preview -> approved build
        |
        v
Deterministic model geometry + entity lineage + typed demand
        |
        v
Recipes -> ledger -> estimate/procurement/revision views
```

The AI proposes structured intent. It never executes arbitrary model code. Every geometry mutation belongs to a registered tool and is performed by the local model runtime on the host application's main thread.

## Foundation rules

- Build and release one complete vertical-slice tool at a time.
- Tool contracts are the source of truth; UI, AI, MCP and automation are clients.
- Validation happens before geometry mutation.
- Preview and build share one deterministic planner.
- A confirmed build is bound to the preview plan hash and model revision.
- Generated geometry carries enough metadata for inspect, rebuild and delete.
- Materials, applications, physical context, work stages, demand, recipes and purchase lines remain separate records.
- One material row identifies one defensible product or variant, not its use or location.
- External sources and compliance authority are explicit and machine-readable.
- Cloud services manage tenancy, identity, policy, audit and jobs; the desktop runtime owns model mutation.

## Current milestone

Foundation 0 defines the product charter, architecture decisions and AI-to-tool protocol. No production drawing tool is registered yet. The next milestone is to select one first tool and implement its complete contract, planner, preview, build, lifecycle, demand evidence and tests.

The recommended first candidate is a path-anchored linear member because it proves the entire protocol with a small, visually verifiable geometry surface. It is a candidate, not an accepted tool decision.

## Repository map

- `contracts/` — stable, language-neutral API and JSON contracts.
- `docs/architecture/` — system design and accepted architecture decisions.
- `docs/context/` — source working papers retained as decision context.
- `docs/delivery/` — vertical-slice gates and delivery plans.

Start with [the system architecture](docs/architecture/SYSTEM_ARCHITECTURE.md) and [the first-tool gate](docs/delivery/FIRST_TOOL_GATE.md).
