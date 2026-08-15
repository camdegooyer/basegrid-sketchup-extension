# ADR 0003: Separate product, context, demand and commercial projections

Status: Accepted
Date: 2026-08-15

## Decision

A material row identifies one defensible product or explicit variant. Application, physical location, work stage, category and allocation are contextual records. Tools emit typed raw demand. Versioned recipes create resource outputs, and supplier offers convert demand into purchasable quantities. Grouping occurs only in derived views.

Tags and folders are visible projections of authoritative metadata. Manual retagging does not silently reclassify commercial data; it triggers repair or explicit adoption.

## Consequences

- The same product may serve multiple tools, roles, levels and work stages without duplicate product rows.
- Estimate, procurement, cutting and revision views can regroup the same evidence.
- Recipe, routing, price and supplier changes can be distinguished from geometry changes.
- More explicit records and joins are required, but each has one clear meaning.

## Source context

This decision adopts the core recommendation of `docs/context/ONE_MATERIAL_ONE_ROW_ARCHITECTURE.md` with separate physical location and procurement stage.
