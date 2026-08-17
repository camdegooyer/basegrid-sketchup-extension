# Capstone Drawing Capture Notes

This slice exists to close the main SketchUp drawing ontology gaps at a practical object-family level.

It deliberately captures broad physical systems and their visible or coordinatable parts, including:

- lifts, platform lifts and escalators;
- fire sprinkler, hydrant, hose reel, extinguisher, FIP, smoke-control and damper objects;
- gas services, LPG cylinder banks, gas pipes, isolation valves and flues;
- curtain walls, mullions, transoms, pressure caps, spandrels and perimeter fire safing;
- automatic doors, revolving doors, rapid roller doors, loading dock levellers and access-control hardware;
- accessible paths, tactile indicators, grabrails, accessible sanitary fixture groups and accessible parking bays;
- commercial kitchen hoods, grease arrestors, lab benches, fume cupboards, cleanroom panels and HEPA modules;
- standby generators, transfer switches and lightning protection objects;
- retaining walls, geogrid, subsoil drainage, detention outlet controls, gross pollutant traps and trench drains.

## Boundary

These are accepted for drawing identity and tool grouping, not for compliance, engineering or product selection.

A SketchUp tool may use these records to decide:

- what object family to draw;
- what smaller parts can be shown at higher detail;
- what host or route input is required;
- what the tool must ask the user instead of inventing.

A SketchUp tool must not use these records to decide:

- fire-system hydraulic design;
- gas-service design or approval;
- lift, escalator or platform-lift clearances;
- facade wind, waterproofing, fire or structural adequacy;
- AS 1428 or AS 1657 compliance;
- retaining-wall engineering;
- stormwater detention or treatment sizing;
- cleanroom, lab or kitchen exhaust performance;
- electrical engineering, earthing or generator sizing.

## Review Status

Most capstone records use `accepted_pending_review` because they are sufficiently clear as physical drawing objects, but still need deeper specialist research before they should become rule-aware plugin tools.
