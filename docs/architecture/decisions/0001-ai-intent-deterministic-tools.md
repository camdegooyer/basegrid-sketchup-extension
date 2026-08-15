# ADR 0001: AI submits intent; deterministic tools mutate the model

Status: Accepted
Date: 2026-08-15

## Decision

AI clients may discover registered capabilities and submit versioned drawing intents. They may not execute arbitrary code or directly mutate host-model entities. A registered tool validates and normalizes intent, generates a deterministic plan, previews it and materializes an approved plan through an atomic host executor.

UI, AI, MCP and future integrations are equal clients of the same contract.

## Consequences

- Every AI-capable tool needs a complete headless contract and lifecycle.
- Natural-language ambiguity is resolved before build, not inside the geometry executor.
- Preview and build can be compared using a canonical plan hash.
- Stored intent remains inspectable and rebuildable across supported versions.
- Some requests will be rejected or require clarification instead of being guessed.

## Rejected alternatives

- Arbitrary Ruby or scripting access: unbounded security and reliability risk.
- UI automation: brittle, untestable and not a stable product API.
- AI-generated raw geometry: weak determinism, lifecycle and commercial lineage.
