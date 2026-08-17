# Drawing Ontology Coverage

I would not treat the current ontology as literally every physical component in every building. That is not a realistic or testable claim.

I would treat it as a strong practical SketchUp drawing ontology. It now covers house-scale work deeply and adds a broad capstone layer for the major commercial, site and specialist-service object families that a drawing tool needs to recognise.

## Strong Current Coverage

- Structural base: site preparation, slabs, footings, reinforcement, timber framing, cold-formed steel framing, structural steel and masonry.
- Envelope: roof coverings, roof drainage, cladding, advanced facade systems, openings, glazing, flashings, membranes and weathering details.
- Interiors: internal doors, linings, ceilings, floor finishes, decorative finishes and wet-area waterproofing.
- Movement and access: stairs, ramps, landings, barriers, handrails, pools and ancillary house-scale construction.
- Services: water, heated water, rainwater, sanitary plumbing, sanitary drainage, onsite wastewater, electrical, communications, solar, batteries, EV charging, mechanical air systems, evaporative cooling, heat-recovery ventilation and hydronic heating.
- Capstone specialist coverage: lifts, escalators, platform lifts, fire sprinklers, hydrants, hose reels, fire indicator panels, smoke-control equipment, gas services, LPG cylinder banks, gas flues, standby generators, lightning protection, curtain walls, automatic doors, access-control hardware, accessible paths, tactile indicators, grabrails, accessible sanitary groups, accessible parking bays, commercial kitchen hoods, grease arrestors, laboratory benches, fume cupboards, cleanroom panels, retaining walls, geogrid, subsoil drainage, detention outlets, gross pollutant traps and trench drains.
- Drawing metadata: each object has IDs, names, plain-English definitions, geometry class, attributes, relationships, provenance and generated exports.
- Product layer: the initial SketchUp tool manifest maps major drawing tools to the ontology objects they should create or reveal.

## Known Limits

The ontology is still not complete for:

- deep proprietary curtain-wall, lift, escalator, fire-service, gas, cleanroom, lab, commercial kitchen and access-control product systems;
- detailed hospital, laboratory, industrial process, data-centre, cold-storage and cleanroom specialist fitout components beyond first-pass drawing families;
- civil infrastructure beyond building-site drawing scope, including roads, bridges, deep drainage networks and authority assets;
- every proprietary product family, bracket, fastener, accessory and manufacturer-specific profile;
- engineering tables, design capacities, approval certificates or installation compliance rules.

## Acceptance Standard Going Forward

For SketchUp drawing work, an object should be accepted when it can be one of these:

- a group or component;
- a repeated member, board, sheet, panel, fixture, fitting, pipe, duct, cable or route;
- a visible or concealed layer;
- a joint, gap, penetration, flashing, seal or trim;
- a support, connector, fastener, bracket or anchor;
- a selectable assembly that owns smaller parts.

Objects should not be added just because a standard, certificate, rating, calculation or rule mentions them. Those belong as metadata unless they change what the plugin draws.

## Current Practical Position

The next useful milestone is no longer more broad research. It is to implement drawing commands that consume the tool manifest, starting with the timber wall frame tool.

The first end-to-end data path now exists:

1. source catalogues define physical objects;
2. generation scripts export ontology and relationships;
3. `config/sketchup_tool_definitions.json` groups objects into SketchUp tools, including three broad capstone tools for specialist services/safety, commercial facades/openings/transport and accessibility/site/specialist fitout;
4. `src/buildgrid_ontology.rb` loads and resolves those definitions;
5. tests prove the wall frame, cladding and relationship lookups work from generated data.
