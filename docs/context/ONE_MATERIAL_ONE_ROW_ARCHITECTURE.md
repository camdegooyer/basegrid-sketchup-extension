# One material, one row

**SketchOB material, tag, recipe and takeoff architecture — decision report**
Working paper · 14 August 2026 · prepared for Cam and Daniel
Recommendation: **proceed with revisions**

A pressure-tested architecture for SketchUp geometry, tags, categories, recipes, costing and procurement.

---

## 01 · Executive finding

### The principle is right. The joins determine whether the rebuild works.

Daniel's "one material, one row" thesis fixes a genuine defect in the current library. The rebuild should adopt it, while separating physical location from procurement stage, separating measurement from recipes, and treating SketchUp tags as a visible, repairable projection of authoritative metadata.

- **Accept the principle**
- **Revise the data model**
- **Prove one vertical slice**

Key evidence:

| Figure | Meaning |
|---|---|
| 19 | cached 90×35 MGP10 application records |
| 1,000 | materials in the current local cache |
| 1 → many | one product row to contextual demand lines |
| v2 | ledger schema required for the rebuild |

### Core recommendation — adopt a demand-led, recipe-versioned, group-late architecture

```
Geometry            tool-owned and measurable
   ↓
Application         what the object is doing
   ↓
Context             level, zone and work stage
   ↓
Demand              raw, typed measurement
   ↓
Recipes             material, labour and plant
   ↓
Ledger              traceable ungrouped lines
   ↓
Views               estimate, PO, cuts, revisions
```

> **Do not confuse the rows.** A material row identifies a product. A demand record identifies measured construction need. A takeoff line records a recipe output and allocation. A purchase-order line records a supplier-specific order. One material row can legitimately create dozens of takeoff lines and several purchase-order lines.

---

## 02 · Evidence from the current build

This is an architectural migration, not a greenfield invention.

**What is already valuable**

- Canonical `sketchob_id` material identities.
- Cloud material library with a deterministic local cache.
- Tool contracts with named material roles.
- API-first drawing intents and lifecycle operations.
- Tool-owned geometry planners and member manifests.
- Native takeoff rows with quantities and cut evidence.
- Catalogue mappings, exclusions and source references.
- Persistent entity metadata suitable for lineage.

**What still carries the old coupling**

- Application and level are embedded in material names and subtypes.
- Materials carry `default_tag_id`.
- Several tools derive takeoff category from the selected material's tag or folder.
- The ledger has no explicit level, zone or work-stage fields.
- There is no versioned recipe engine.
- Supplier offers, stock sizes and pack rules are absent.
- Labour, plant and subcontract demand are not first-class outputs.
- Historic exports are not immutable takeoff snapshots.

**Current code paths that demonstrate the coupling**

The structural wall has good application-like roles — studs, plates, noggings, lintels and insulation — but its takeoff writer asks the material library for the material's tag and containing folder. The category therefore still comes from the product record rather than from tool + object + context.

The ledger records one material, category, usage, scalar measurement, tag and optional cuts. Its summary groups by category, material, usage and unit. This is sufficient for a native quantity pilot but not for stage-aware procurement or explainable recipe evaluation.

**Retain — stable foundations**
ToolContract, DrawingIntent, API/MCP bridge, geometry planners, entity lifecycle, canonical IDs, source governance and local-cache patterns.

**Rebuild or extend — business joins**
Product schema, tag routing, context, ledger v2, recipes, supplier offers, optimisation, revisions and legacy-material migration.

---

## 03 · Domain vocabulary

Ambiguous nouns are currently doing more damage than difficult formulas.

| Term | Definition | Example |
|---|---|---|
| **Material** | The physical product or explicit product variant being selected. It is not its construction use. | `90×35 MGP10 untreated pine` |
| **Tool** | The deterministic system that creates or measures construction geometry. | `structural_timber_wall` |
| **Object role** | What a generated object is doing within a tool. | `common_stud · top_plate · lintel` |
| **Application** | The tool/object behaviour presented to recipes and routing. May group several internal member roles. | `wall_stud_installation` |
| **Location** | Where the geometry physically belongs: building, level, zone and room. | `level_1 · east_wing` |
| **Work stage** | The delivery or programme package against which work is ordered. | `l1_frame_east` |
| **Estimating category** | The visible work-breakdown category used to organise geometry and estimate views. | `120 L1 Frame` |
| **Cost code** | An accounting allocation on an output line. Supply and labour may use different codes. | `580 Timber Supply` |
| **Demand record** | The authoritative raw measurement emitted before business conversion. | `38 pieces with actual cut lengths` |
| **Recipe** | A versioned transformation from demand and context to resource outputs. | `stud count → nails + carpenter hours` |
| **Supplier offer** | One supplier's purchasable SKU, stock format, rate and effective date for a material. | `BT-9035-5400` |
| **Export revision** | An immutable snapshot of quantities, rules, products, prices, allocations and labels. | `Estimate Revision B` |

---

## 04 · SketchUp tags and estimating folders

The proposed folder/category structure is technically supported, but it needs an authority model.

Supported tag carriers: groups ✓ · child groups ✓ · components ✓ · faces ✓ · edges ✓ · nested folders ✓ · scenes ✓

```
SketchOB
└── 04 Structure                    (organisational)
    └── 120 L1 Frame                (estimating category)
        ├── 120 | L1 | Wall | Assembly
        ├── 120 | L1 | Wall | Plates
        ├── 120 | L1 | Wall | Studs
        ├── 120 | L1 | Wall | Noggings
        └── 120 | L1 | Wall | Lintels
```

### Recommended convention

The direct folder containing a tag represents the estimating category. Higher folders exist for navigation and visibility only.

| | |
|---|---|
| Folder names | Human-readable, with spaces |
| Tag names | `Code \| Level \| Tool \| Object` |
| Machine IDs | `snake_case` metadata |
| Tag creation | Lazy — only when used |
| Active tag | Always Untagged |

### Authority options

| Option | Description | Verdict |
|---|---|---|
| **A — Tags are authoritative** | Immediate manual control and easy inspection, but renaming, moving or mistagging geometry silently changes the estimate. | Not recommended |
| **B — Metadata is authoritative** | Deterministic and versionable, but the visible model can drift away from the takeoff without users noticing. | Incomplete alone |
| **C — Metadata authority, tag projection** | The tool writes stable context IDs, derives the tag/folder, and audits visible state. Retagging prompts repair or explicit adoption. | **Recommended** |

> **Duplicate-count trap.** A wall parent, child member group, individual stud, face and edges can all be tagged. Tags classify geometry; they do not prove that every tagged element is an independent takeoff carrier. Tool metadata or an explicit manual-measurement record must identify the authoritative source.

---

## 05 · Context and routing

Tool + stage + object is close, but "stage" should not swallow every contextual dimension.

```
Tool + Object role + Location + Work stage  →  Category + tag + allocations
```

- **Where?** Building, level, zone and room describe physical location — `level_1 / east_wing`
- **When?** Work stage describes delivery or programme sequence — `l1_frame_east`
- **Where costed?** Category and cost-code allocations describe estimate/accounting treatment — `120 / 580`

### Pressure test: why "one axis: stage" is too lossy

- A ground floor can be framed in east and west delivery packages.
- Internal framing can span multiple levels under one accounting category.
- A Level 1 suspended slab can belong to a concrete stage whose sequence differs from its physical level.
- A builder may need a quantity by level even when procurement is grouped by stage.
- Changing procurement packages should not rewrite the geometry's physical location.

### Routing example — one material, several valid contexts

| Tool | Level | Object | Material identity | Category folder | Derived tag | Allocations |
|---|---|---|---|---|---|---|
| Structural Timber Wall | Level 1 | Studs | `TIM-9035-MGP10` | 120 L1 Frame | `120 \| L1 \| Wall \| Studs` | Supply 580 · Labour 120 |
| Structural Timber Wall | Ground Floor | Studs | `TIM-9035-MGP10` | 100 GF Frame | `100 \| GF \| Wall \| Studs` | Supply 580 · Labour 100 |
| Structural Timber Wall | Level 1 | Bulkheads | `TIM-9035-MGP10` | 240 Internal Framing | `240 \| Internal \| Wall \| Bulkheads` | Supply 580 · Labour 240 |
| Internal Framing Tool | Level 2 | Noggings | `TIM-9035-MGP10` | 240 Internal Framing | `240 \| Internal \| Internal \| Noggings` | Supply 580 · Labour 240 |

The material identity does not change with application. The category, tag, work stage and labour allocation all do.

---

## 06 · Material identity and compatibility

One row must mean one defensible product identity — not one vague description.

**Master material: 90×35 MGP10 kiln-dried structural pine**

| | |
|---|---|
| Master SKU | TIM-9035-MGP10 |
| Base unit | metre |
| Grade | MGP10 |
| Treatment | untreated |
| Section | 90 × 35 mm |
| Supply code | 580 Timber Supply |

- **Applications** — stud · nogging · plate where compatible · batten · blocking
- **Supplier offers** — 4.8 m · 5.4 m · packs · price dates · supplier SKUs
- **Appearance profiles** — estimating render · presentation render

### Where one row stops

| Difference | Same master row? | Reason |
|---|---|---|
| 4.8 m versus 5.4 m stock length | Usually yes | Supplier-offer formats of the same base material. |
| Untreated versus H2 treated | No | Different technical suitability and purchasing identity. |
| MGP10 versus MGP12 | No | Different structural grade. |
| Generic MGP10 from two merchants | Usually yes | Two offers mapped to one master product, subject to equivalent specification. |
| Manufacturer-specific warranted cladding | Variant | Brand, profile, size and warranty may require explicit variants. |
| Same tile in different colour | Variant | Appearance and supplier SKU differ even if installation behaviour is shared. |

> **Compatibility must survive deduplication.** Object selectors should match intrinsic facts — product class, section, grade, treatment, dimensions and certification — not application-shaped material subtypes such as `wall_framing` or `internal_framing`.

---

## 07 · Recipe architecture

The hard problem becomes tractable once "recipe" is divided into distinct responsibilities.

| # | Rule | What it does | Owner |
|---|---|---|---|
| 1 | Geometry rule | Determines what is drawn: stud positions, openings, laps, intersections and solids. | Tool |
| 2 | Measurement rule | Emits actual cut lists, net regions, counts, areas or unioned volumes. | Application |
| 3 | Consumption recipe | Adds selected products and accessories: nails, tape, adhesive, brackets, chairs or compounds. | Application + conditions |
| 4 | Material conversion | Converts installed demand using intrinsic coverage, coats, laps or product-specific usage. | Material |
| 5 | Labour recipe | Calculates hours from count, length, area, weight, complexity, setup and handling conditions. | Application + material/context |
| 6 | Supplier conversion | Applies stock length, sheet size, pack quantity, minimum order and rate. | Supplier offer |
| 7 | Routing rule | Assigns stage, estimating category and financial allocations. Does not calculate quantity. | Profile/context |

### Recipe selectors

A recipe may match a combination of tool, object role, material or material properties, construction method, builder profile and context. Stage should only enter a recipe when it genuinely changes consumption or effort — not merely because the line is reported in a different category.

```yaml
recipe_id: wall.stud.installation
version: 3
match:
  tool_id: structural_timber_wall
  object_role: common_stud
outputs:
  - kind: selected_material
    quantity: actual_cut_list
  - kind: material
    material_id: framing_nail_75
    quantity: connection_count * 2
  - kind: labour
    resource_id: carpenter_wall_frame
    quantity: member_count * 0.08 hours
```

### Evaluation rules

- **Additive by default** — selected timber, nails, labour and handling can all emit independently. Matching recipes should not silently replace one another.
- **Named overrides only** — a modifier or replacement must target a recipe ID. Two equal-priority replacements are a validation error.
- **Typed units** — the expression engine rejects incompatible operations such as adding metres to square metres.
- **Acyclic dependencies** — recipe outputs form a directed graph. Circular recipes fail before takeoff execution.
- **Version and provenance** — every result records recipe version, source references, assumptions and authority status.
- **No arbitrary code** — use a bounded expression DSL rather than executable Ruby or JavaScript stored in the database.

### Typed demand, not "geometry everywhere"

| Demand type | Example | Used for |
|---|---|---|
| Scalar | 18.7 m³ | Concrete volume, net insulation area or coating area. |
| Linear cut list | 38 × 2550 mm | Timber, steel, flashing, battens and pipe. |
| Planar region | Boundary + openings | Sheet cladding, plasterboard, tile and membrane setout. |
| Instances | 3 × window type W04 | Windows, doors, brackets and fixtures. |
| Event | 1 concrete pour | Pump setup, mobilisation, crane visit and testing fee. |
| Volumetric | Canonical solid evidence | Excavation, fill or complex concrete where shape affects output. |

---

## 08 · End-to-end wall example

This is the vertical slice that should prove the architecture before the library is migrated.

Context: **Wall W-042 · Level 1 · East Wing · L1 Frame East**

1. **Geometry** — the wall tool generates 38 studs at 2550 mm, 92 noggings at 410 mm, 72 m of plates and two 1800 mm lintels.
2. **Classification** — tool + L1 + object resolves category folder 120 L1 Frame and separate Studs, Noggings, Plates and Lintels tags.
3. **Demand** — the tool records member-by-member cuts and connection counts instead of only four scalar totals.
4. **Recipes** — stud and nogging recipes emit the selected timber, framing nails and carpenter hours. Both timber outputs reference one master material.
5. **Optimisation** — supplier stock formats are tested against actual cuts. The lowest rate per metre does not automatically win.
6. **Views** — demand remains separated for estimating, while purchase lines may aggregate by material, supplier and delivery stage.

### Why stock length matters — 38 studs at 2.55 m

| Offer | Lengths required | Yield |
|---|---|---|
| 5.4 m | 19 lengths | 2 studs per length · 102.6 m ordered |
| 4.8 m | 38 lengths | 1 stud per length · 182.4 m ordered |

The optimiser must compare feasible total order cost after cutting, pack rules and minimum orders. Unit price alone is not an adequate supplier policy.

### Resulting ledger

| Source | Application | Category | Output | Cost code | Raw demand | Order result |
|---|---|---|---|---|---|---|
| W-042 | Studs | 120 L1 Frame | 90×35 MGP10 | 580 Timber Supply | 96.9 m / 38 cuts | Optimised stock |
| W-042 | Noggings | 120 L1 Frame | 90×35 MGP10 | 580 Timber Supply | 37.72 m / 92 cuts | Combined within stage |
| W-042 | Stud fixings | 120 L1 Frame | 75 mm nails | 580 Timber Supply | Recipe count | Rounded boxes |
| W-042 | Stud labour | 120 L1 Frame | Carpenter hours | 120 L1 Frame | 3.04 h | 3.04 h |

---

## 09 · What information can come out of the takeoff model?

The ledger becomes a common evidence layer for estimating, procurement, production and audit.

**Model lineage** — project, building and entity IDs · tool and contract version · assembly and object role · geometry signature · creation and rebuild history

**Physical context** — level and storey · zone, room and area · work stage and sequence · tag and category folder · manual context overrides

**Measurement evidence** — count, length, area and volume · cut lists and sheet layouts · opening deductions and laps · connections and setout · measurement basis and formula version

**Resource demand** — selected materials · accessories and consumables · labour and crew hours · plant and mobilisation · subcontract quantities

**Procurement** — master and supplier SKUs · stock and pack sizes · required versus ordered quantity · supplier alternatives · stage and supplier PO grouping

**Cost planning** — supply, labour and plant codes · cost by level, stage or zone · rate dates and stale warnings · estimate versus order view · allocation and override evidence

**Production** — timber and steel cut lists · sheet and panel layouts · member labels · window and door schedules · prefabrication packages

**Quality assurance** — tag/category drift · missing material or recipe · unknown stage · unit and rule conflicts · unsupported or stale selections

**Revision analysis** — scope movement · specification movement · recipe/method changes · price and supplier movement · routing and override changes

**Future extensions** — embodied carbon · waste streams · certification and provenance · warranty data · offcut and reuse inventory

> **Truth boundary.** The model cannot guarantee live stock, freight, future prices, site productivity, damage, weather, as-built substitutions, schedule dates, contract entitlement or structural compliance. Every output should identify whether it was measured, calculated, assumed, overridden, externally supplied or unverified.

---

## 10 · Decision-by-decision review of Daniel's proposal

| # | Decision | Assessment | Verdict |
|---|---|---|---|
| D1 | One material is one row | Adopt, subject to an explicit master-product and variant boundary. | Accept |
| D2 | Tag is an output, never an input | Adopt for generated tools. Add repair/adoption handling for manual retagging. | Accept |
| D3 | Application plus level resolves the category | Good default, but store level, zone and work stage separately rather than flattening them. | Revise |
| D4 | Stage is the single contextual axis | Too lossy. Physical location and procurement stage answer different questions. | **Challenge** |
| D5 | Every takeoff line carries stage | Adopt, and also carry level, zone and source context. | Accept |
| D6 | Group late | Strong architectural rule. Preserve granular demand and allocation lineage through every view. | Accept |
| D7 | Immutable export revisions | Adopt. Export snapshots should never depend on mutable live library or pricing data. | Accept |
| D8 | Scope, specification and price diff | Add recipe/method, supplier/pack, routing and manual-override movements. | Revise |
| D9 | Recipes live on applications | Consumption and labour often do; intrinsic conversion belongs on materials and stock/pack conversion on offers. | Revise |
| D10 | Factor, linear and setout derivation | Retain as concepts but implement typed demand payloads, including instance, event and volumetric demand. | Revise |
| D11 | Demand always carries geometry | Carry canonical demand features and source references, not unrestricted duplicated SketchUp geometry. | Revise |
| D12 | Waste cascade | Adopt with explicit replacement semantics and distinct fabrication, damage and pack surplus. | Accept |
| D13 | Pack optimisation in takeoff | Adopt, but supplier selection and quantity optimisation must be evaluated together. | Accept |
| D14 | Versioned spine | Adopt as configuration history; keep it separate from immutable export revisions. | Accept |
| D15 | Claude remaps the builder's spine | Claude can propose mappings, but changes need deterministic validation, review and approval. | Revise |
| D16 | Override level, not tag | Correct for location errors. Add a separate work-stage override for delivery-package changes. | Revise |
| D17 | Auto scenes by level | Adopt. Also provide stage, category and QA scenes with ancestor visibility handled correctly. | Accept |
| D18 | Uploaded price list is the supply map | It creates candidate offers, not proof of current availability or suitability. | Revise |
| D19 | Cheapest and preferred-supplier policies | Adopt both, but compare total feasible order cost and supplier fragmentation rather than unit rate alone. | Revise |
| D20 | Stale prices warn on the line | Adopt. The export should freeze both the rate and its warning state. | Accept |
| D21 | Setout presets plus manual adjustment | Adopt, with the resulting layout, preset version and override recorded as evidence. | Accept |
| D22 | Hard-coded obvious stages | Ship versioned defaults, but allow explicit builder configuration rather than AI-only reorganisation. | Revise |
| D23 | Claude oversight of the whole workflow | API-first supports this; price imports, remapping and POs still need permissions and confirmation. | Revise |
| D24 | Stage position, not date | Adopt inside SketchOB. Export an external programme key so PM software can supply dates. | Accept |

---

## 11 · Risk register and flip-of-the-coin choices

The architecture should surface these choices instead of burying them in implementation.

| Risk | Consequence | Likelihood | Recommended control |
|---|---|---|---|
| Tag/category drift | Visible model disagrees with costing | High | Metadata authority, audit and explicit adopt/repair |
| Material over-deduplication | Technically different products collapse into one row | High | Documented variant boundary and intrinsic properties |
| Tag explosion | Unusable Tags tray and scene maintenance | Medium | Lazy creation and user-facing role aggregation |
| Recipe ambiguity | Double counting or hidden replacement | High | Additive defaults, named targets and conflict rejection |
| Stage/location collapse | Historic data cannot regroup by level or zone | High | Store dimensions separately |
| Supplier chosen by unit rate | Higher total order cost and waste | High | Offer-aware cut and pack optimisation |
| Manual geometry double count | Parent, child and faces counted together | Medium | Explicit takeoff carriers and manual measurement records |
| Recipe version drift | Historic estimate cannot be explained | High | Immutable exports with formula snapshots |
| Price list treated as availability | Invalid PO suggestion | Medium | Offer status, date and confirmation state |
| AI remap without review | Silent financial reclassification | Medium | Proposals, validation, approval and audit log |
| Full geometry stored per line | Large models and unstable history | Medium | Canonical demand payloads and geometry signatures |
| Big-bang library migration | Thousands of ambiguous mappings | High | Vertical slice, aliases and review queue |

### Coin flips

| Question | Heads | Tails | Call |
|---|---|---|---|
| Tag authority | Manual retag changes estimate immediately | Metadata ignores retagging | Metadata authority with audited projection |
| Material cost code | Absolute product allocation | Entirely contextual allocation | Material default with routing override |
| Stage model | One flattened stage axis | Separate location and work package | Preserve both, derive defaults |
| Recipe precedence | Most specific wins | Every match executes | Additive emitters, explicit named overrides |
| Supplier policy | Cheapest unit price | Preferred merchant | Policies compare feasible stage-order cost |
| PO scope | Plugin builds full purchasing system | Plugin exports raw quantities only | SketchOB resolves order lines; PM system owns dates/approval |

---

## 12 · Versioning and revision explanation

Configuration history and issued-export history are related but different.

**Mutable, versioned configuration — live system history**
Material and variant definitions · compatibility rules · routing/spine versions · recipe bundles · waste policies · supplier offers and rates

**Immutable — issued export revision**
Measured quantities · selected products and suppliers · recipe inputs and outputs · rates and warning state · category and code labels · overrides and source lineage

### Example revision movement: **+$18,600**

| Cause | Movement |
|---|---|
| Geometry / scope | +$12,400 |
| Specification | +$3,100 |
| Recipe / method | +$700 |
| Price | +$1,500 |
| Supplier / pack | +$600 |
| Routing correction | +$300 |

The attribution order must be formally specified. Without a defined calculation sequence, some movement can be assigned to more than one explanation category.

---

## 13 · Source, standards and compliance governance

A takeoff formula is only trustworthy when its origin, applicability and authority are inspectable.

### Every rule needs provenance

Tool contracts already declare machine-readable source references. The rebuild should extend the same discipline to recipes, material conversions, setout presets and compatibility rules.

```yaml
source_references:
  - id: manufacturer_installation_manual.v2
    applies_to: [joint_width, fixing_spacing]
    purpose: setout_and_quantity
    compliance_authority: false
    effective_from: 2026-06-01
```

### Authority must be explicit

- Distinguish modelling scope from a verified compliance rule.
- Record applicable sections rather than citing an entire document vaguely.
- Freeze source and recipe versions into issued exports.
- Declare assumptions when no complete external rule exists.
- Preserve exclusions for member selection, bracing, tie-down and certification.
- Never infer equivalence across different standards editions without a reviewed mapping.

| Rule surface | Likely source | What the ledger should retain | Authority caution |
|---|---|---|---|
| Timber object inventory | AS 1684 modelling inventory and reviewed tool scope | Object role, properties, relationships, omissions and source ID | Informative modelling scope is not structural certification |
| Cladding setout | Manufacturer installation manual | Sheet size, orientation, joints, fixing zones and preset version | Product-specific and edition-sensitive |
| Membrane laps and coverage | Manufacturer data plus builder policy | Gross region, openings, laps, coverage and waste source | Separate manufacturer requirement from company allowance |
| Labour productivity | Builder history or reviewed estimating policy | Dataset/profile version, sample basis and manual override | Not a guaranteed site outcome |
| Supplier pack and price | Dated supplier offer/import | Raw row, mapping decision, price date and status | Price-list presence is not live stock confirmation |

> **Recommended ledger evidence.** Each calculated output should retain the tool version, demand schema version, recipe ID/version, source-reference IDs, builder-policy version and any manual override. That allows a future reviewer to distinguish a geometry change from a rule change, and a rule change from a compliance claim.

---

## 14 · Migration from the current build

Preserve old model identity while progressively removing application-shaped product records.

```
Legacy records                          Master material
GF Wall Framing — 90×35 MGP10
L1 Wall Framing — 90×35 MGP10     →     90×35 MGP10
Internal Framing — 90×35 MGP10          TIM-9035-MGP10
Ceiling Battens — 90×35 MGP10
```

Legacy IDs become aliases; application is recovered into context and role.

### Migration rules

1. **Never discard old canonical references.** Map them to the new master or explicit variant.
2. **Recover embedded context.** Old name, subtype, tag and folder data can propose tool/object/level mappings.
3. **Do not guess ambiguous mappings.** Send them to a review queue.
4. **Keep ledger v1 readable.** New tools emit v2; old models remain inspectable.
5. **Deprecate `default_tag_id`.** Preserve it only for legacy/PlusSpec compatibility.
6. **Do not migrate all 1,000 rows first.** Prove product boundaries and routing on a deliberately small set.

> **PlusSpec bridge.** `plusspec_id` remains a compatibility mapping. The new master material plus application context may resolve to a legacy PlusSpec record during transition, but PlusSpec identity must not replace SketchOB identity.

---

## 15 · Recommended rebuild sequence

Build the joins before scaling the catalogue.

| Phase | Work | Type |
|---|---|---|
| 0 | **Lock vocabulary and authority** — material/variant boundary, context dimensions, tag authority, cost-code semantics and recipe responsibilities. | Architecture gate |
| 1 | **Context and routing registry** — levels, zones, work stages, estimating categories, tag templates, metadata IDs and drift audit. | Foundation |
| 2 | **Ledger schema v2** — typed demand, source lineage, context, category, recipe provenance, raw/adjusted/ordered quantities and overrides. | Foundation |
| 3 | **90×35 vertical slice** — one material across studs, noggings, GF, L1 and internal framing. Prove tags, supply codes and labour lines. | Proof |
| 4 | **Recipe engine** — selected timber, nails, labour, waste, modifiers, versioning, unit checks and explanation output. | Core engine |
| 5 | **Supplier offers and optimisation** — supplier imports, unmatched review, stock formats, pack rounding and feasible total-order comparison. | Procurement |
| 6 | **Immutable exports and diffs** — estimate, procurement and cut-list views with decomposed revision movement. | Audit |
| 7 | **Migrate and scale** — legacy aliases, review queues, broader materials and recipe coverage only after the vertical slice survives review. | Scale |

---

## 16 · Decisions Cam and Daniel should lock next

These are the architecture gates; everything else can follow incrementally.

1. **Material boundary** — exactly when does a supplier format remain an offer, when does it become a variant, and when is it a separate material?
   *Recommended: technical/purchasing differences create explicit variants; lengths and packs remain offers.*
2. **Context model** — will level, zone and work stage remain separate fields?
   *Recommended: yes, even when a builder's current codes flatten them.*
3. **Tag authority** — does manual retagging immediately alter cost classification?
   *Recommended: no silent change; prompt to adopt or repair.*
4. **Cost-code semantics** — is the folder category also the accounting code, or can supply and labour route elsewhere?
   *Recommended: store estimating category and financial allocations separately.*
5. **Recipe ownership** — which rule types live on tools, applications, materials, profiles and offers?
   *Recommended: use the seven-part split in this report.*
6. **Labour model** — will v1 calculate hours, installed units, subcontract quantities or only material demand?
   *Recommended: make labour a first-class output, but begin with a small reviewed recipe set.*
7. **Procurement boundary** — how much PO logic remains in SketchOB versus the PM/accounting system?
   *Recommended: resolve order lines and stage sequence in SketchOB; dates, approvals and commitment live externally.*
8. **Override governance** — which changes require a reason, approval or revision?
   *Recommended: require reasons for context, recipe, waste, supplier and allocation overrides.*

### Recommended architecture decision

**Proceed — after revising the stage model and formalising recipe ownership.**

Daniel's proposal supplies the correct organising principle. SketchOB already has enough contract, geometry, identity and API infrastructure to prove it without restarting the product. The rebuild should concentrate on the business joins: context, routing, typed demand, recipes, supplier offers, ledger lineage and immutable exports.

---

## Sources

**SketchOB** — `docs/PROJECT_MEMORY.md`, `docs/MATERIAL_SYSTEM.md`, `docs/TOOL_CONTRACT.md`, `docs/TAKEOFF_CATALOGUE_LINKAGE.md`, `sketchob/core/takeoff_ledger.rb` and the current local material cache.

**Working paper** — Daniel Perrem, "One material, one row", v1.1, 13 August 2026.

**SketchUp** — [Drawingelement tag/layer API](https://ruby.sketchup.com/Sketchup/Drawingelement.html), [nested tag-folder API](https://ruby.sketchup.com/Sketchup/LayerFolder.html), [tag visibility guidance](https://help.sketchup.com/en/sketchup/controlling-visibility-tags).

**Interactive version** — `sites/material-takeoff-architecture-report/index.html`
