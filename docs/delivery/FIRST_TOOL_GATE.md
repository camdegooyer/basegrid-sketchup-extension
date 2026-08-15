# First-tool vertical-slice gate

No drawing tool is production-registered in Foundation 0. The first tool should be selected for its ability to prove the architecture, not for catalogue breadth.

## Recommended candidate

A path-anchored linear member is the strongest default candidate because it can prove:

- an AI-constructible path anchor;
- intrinsic product selection by material role;
- deterministic local-axis and profile geometry;
- preview/build plan-hash parity;
- parent/child metadata and authoritative quantity carriers;
- linear cut-list demand;
- context and work-stage routing without changing material identity;
- inspect, parameter rebuild and delete;
- visually obvious verification in the host model.

The candidate is not accepted until its real construction scope and exclusions are named. “Generic line extruder” is not a sufficient product definition.

## Selection questions

1. What real construction object does the user believe they are creating?
2. What is the minimum stable anchor an AI can construct without UI state?
3. Which parameters change geometry, and which belong to context or recipes?
4. Which product roles are selectable, and what compatibility facts constrain them?
5. What raw demand is authoritative: count, cut list, length, area, volume, instance or event?
6. Which external sources shaped the tool, and what do they not authorize?
7. What must inspect, rebuild and delete preserve?
8. Which cases must fail or require human confirmation?

## Definition of done

- Strict tool contract and example intents.
- Envelope, tool-specific and domain validation before mutation.
- Pure deterministic planner with canonical plan hash.
- Preview using the actual plan.
- Atomic build with rollback and idempotency.
- Stored normalized intent and complete lineage metadata.
- Typed demand with one authoritative quantity carrier per priceable output.
- Inspect, rebuild and delete lifecycle.
- Contract, planner, failure, lifecycle and replay tests.
- Real host-application smoke evidence.
- Reviewed source references, exclusions and deliberate `ai_enabled: true` decision.
