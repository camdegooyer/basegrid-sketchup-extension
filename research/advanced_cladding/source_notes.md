# Advanced External Cladding Drawing Ontology

This slice adds advanced external cladding and facade objects for SketchUp drawing tools. It deliberately narrows the earlier research direction: the catalogue identifies physical parts that a plugin can draw or select, not every compliance pathway behind them.

The objects sit in the existing `cladding` discipline and extend the base external-wall cladding catalogue. The main new drawable families are:

- ventilated and open-jointed rainscreen facades;
- rail-and-bracket support systems;
- metal cassette, composite metal and honeycomb panel facades;
- insulated sandwich wall panels;
- EIFS and cavity EIFS insulated render systems;
- vinyl/uPVC and WPC board cladding;
- terracotta panels, baguettes, rails and clips;
- continuous external insulation support details;
- facade cavity barriers as drawable cavity objects.

## Drawing Boundary

The useful SketchUp test is simple: if an item can be placed, repeated, cut, hidden, exposed, dimensioned or selected by a modelling tool, it belongs in this slice. If it is mainly a rule result, certification claim, fire classification, energy value, product approval or engineering capacity, it stays as metadata or selected-system evidence.

For example, an aluminium composite panel is drawable as a panel or routed cassette material. Its core type, approval pathway and fire evidence are important project data, but the plugin must not infer compliance from the drawing object alone.

## Reuse Instead Of Duplication

The base cladding catalogue already owns the common external wall cladding system, direct-fixed wall, drained-cavity wall, weather barrier, cladding cavity, battens, flashings, trims and soffit parts.

The masonry catalogue already owns anchored stone facade panels and many solid-render parts. This slice therefore adds facade support hardware that can be shared with stone systems, but it does not clone the stone panel catalogue.

The fire-safety catalogue already owns firestop systems, collars, wraps, sealants, coated batts and linear-joint firestop objects. This slice only adds facade cavity barrier placement objects so a SketchUp section can show the barrier line inside a ventilated facade cavity.

The thermal catalogue already owns generic rigid insulation material families. This slice only adds the continuous external wall-layer context and the long fasteners or washer plates needed to draw cladding supports through that layer.

## Practical SketchUp Tool Inputs

A future facade tool should ask for a small number of modelling choices before drawing:

- facade family: rainscreen, metal cassette, sandwich panel, EIFS, vinyl/uPVC, WPC, terracotta or continuous-insulation support;
- support mode: battens, rail-and-bracket, direct fix, cavity fix, panel clip, hook or face fastener;
- visible module: board course, panel grid, cassette grid, terracotta tile, baguette spacing or sandwich panel run;
- joint style: open, sealed, gasketed, lapped, interlocked, side-lap, control joint or movement joint;
- edge details: base, top, external corner, internal corner, opening jamb, head, sill and parapet termination;
- section detail level: simple surface, construction build-up, exploded panel, or support hardware view.

The ontology intentionally separates these pieces so a command can draw a coarse facade first, then turn on hardware, membranes, cavities, fixings, barriers or render layers only when the user needs detail.

## Standards And Evidence Boundary

NCC Volume Two H2 weatherproofing remains the regulatory context for external walls, and ABCB guidance warns that composite or laminated metal panel systems are not automatically the same as solid metal wall cladding under AS 1562.1. This catalogue uses that distinction only to avoid collapsing solid metal, composite metal and sandwich panel objects into one class.

No new Housing Provisions direct standards were added. Product sources are used for anatomy and Australian terminology only. Exact spans, fixing spacings, fire behaviour, wind capacity, bushfire suitability, weatherproofing performance and product approvals must come from the selected manufacturer system, engineering documents and the project approval pathway.
