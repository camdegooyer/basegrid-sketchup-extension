# ADR 0002: Cloud control plane with a local model runtime

Status: Accepted
Date: 2026-08-15

## Decision

BuildGrid uses a multi-tenant cloud control plane for identity, policy, entitlement, orchestration and audit, paired with a desktop runtime for host-model inspection and mutation. The desktop runtime initiates the production connection outbound. The tool protocol is transport-neutral so loopback development and brokered production sessions use the same messages.

## Consequences

- Cloud AI services do not require unsafe inbound access to a user's machine.
- Model mutations remain on the host application's required thread and operation model.
- Offline and degraded modes need explicit entitlement leases, queues and reconciliation rules.
- The cloud and runtime need version negotiation, heartbeats, replay protection and idempotency.
- Model content sent to the cloud can be minimized and governed by policy.

## Rejected alternatives

- Cloud-only geometry execution: cannot safely or faithfully control an active desktop model.
- Unauthenticated localhost HTTP as the production boundary: weak identity, reachability and enterprise control.
- Embedding the entire SaaS inside the extension: poor tenancy, audit, deployment and commercial operations.
