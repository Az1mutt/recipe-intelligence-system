# Agent Contract v1.1

## Status

**Validated behavioral contract for guarded autonomy; autonomous workers/services are not yet implemented.**

This document defines how Recipe Intelligence ingestion work is split between specialized agents. It is based on the validated [Ingestion contract v1](ingestion-contract-v1.md) and the completed Aaron & Claire creator-scale pilot.

The pilot validated the role boundaries and safety model, but it did **not** authorize unrestricted bulk auto-promotion. The implementation target is guarded autonomy: routine acquisition and deterministic execution should be automated, while semantic ambiguity, taxonomy/model changes, and higher-risk dispositions remain behind strong QA and escalation gates.

## Core principle

Agents do not get broad authority over the recipe database merely because they can reason about recipes.

The workflow separates:

1. discovery,
2. acquisition/resolution,
3. interpretation/classification,
4. quality control,
5. deterministic promotion.

Each role receives the minimum write scope it needs. Ambiguous semantic or architectural decisions escalate instead of being guessed.

The governing data-quality rule remains:

> No claim may become recipe intelligence unless it is supported by resolved evidence, an explicitly identified creator reference, a trustworthy external reference, or manual user context.

## Pipeline

```text
Creator / channel / URL set
        |
        v
Discovery Agent
        |
        v
recipe_inbox staging
        |
        v
Resolver Agent
        |
        v
recipe_inbox_evidence
        |
        v
Classification Agent
        |
        v
recipe_candidates
        |
        v
QA / Review Agent
        |
        +---- ambiguous / new semantics ----> Specialist owner / Igor
        |
        v
approved disposition
        |
        v
Promotion Executor
        |
        v
recipes + sources + bridges + concepts
```

The creator-scale pilot used **explicit review** for newly discovered channel content. Post-pilot v1.1 keeps that conservative default for discovery/channel ingestion while allowing narrower autonomous paths where the review policy and disposition are already approved.

## Roles

### 1. Discovery Agent

Purpose: turn a creator/channel scope into a clean, bounded intake manifest.

Responsibilities:

- enumerate candidate videos/pages within the approved creator scope;
- canonicalize URLs and source identifiers;
- identify obvious already-known URLs before staging;
- preserve creator/channel identity and grouping metadata;
- stage only the approved pilot cohort;
- mark channel-discovered items with `review_policy = explicit_review`;
- avoid interpreting recipe details beyond what is necessary to identify the source.

Allowed writes:

- create or reuse `recipe_inbox` rows for approved scope;
- write intake provenance into `structured_data`;
- set source reference and workflow metadata required for staging.

Not allowed:

- create recipes;
- classify cuisine/protein/main ingredient/tags;
- declare a source resolved;
- create controlled taxonomy values;
- merge or promote candidates.

Idempotency key:

- canonical source identity, e.g. YouTube video ID / canonical URL.

A rerun must reuse the same intake item instead of creating a duplicate.

### 2. Resolver Agent

Purpose: acquire the strongest legitimate evidence available without inventing missing source content.

#### Resolver Service v1 boundary

Agents should not depend directly on Firecrawl or other provider-specific credentials. The target runtime boundary is a narrow resolver service/tool such as `resolve_inbox_item(inbox_id)` or equivalent.

The service owns provider selection, credentials, rate limits, caching, retries, and evidence normalization. Expected adapters include:

- YouTube/source-specific acquisition;
- generic web acquisition through Firecrawl;
- social/browser fallback where supported;
- explicit manual-context fallback.

All adapters normalize into `recipe_inbox_evidence` and truthful resolver state. Firecrawl is therefore infrastructure behind the Resolver boundary, not a general-purpose credential exposed to every reasoning agent.

Preferred YouTube order:

1. metadata,
2. description,
3. creator-owned linked recipe pages,
4. captions/transcript,
5. audio transcription when legitimately accessible and necessary,
6. keyframes/vision when necessary,
7. external reference only when original/creator evidence remains incomplete.

Responsibilities:

- populate `recipe_inbox_evidence`;
- assign the correct evidence role:
  - `source_content`,
  - `creator_reference`,
  - `external_reference`,
  - `manual_context`;
- update `content_resolution_status` truthfully;
- preserve access failures and limitations in `resolution_error`;
- stop expensive resolution steps when existing evidence is already sufficient.

Allowed writes:

- `recipe_inbox_evidence`;
- resolver-related fields on `recipe_inbox`, including extracted text, structured resolution metadata, confidence, resolution status, and resolution error.

Not allowed:

- create or promote recipes;
- invent recipe details to fill evidence gaps;
- relabel a third-party page as original creator content;
- decide final duplicate vs meaningful variant;
- create taxonomy seeds.

### 3. Classification Agent

Purpose: transform actual evidence into zero, one, or many structured recipe candidates.

This role requires a strong reasoning model because it must distinguish recipe identity from incidental wording and preserve uncertainty.

Responsibilities:

- create `0..N` `recipe_candidates`;
- classify only fields supported by evidence;
- apply current taxonomy semantics;
- propose tags and culinary concepts;
- flag uncertainty explicitly;
- perform an initial preference pass;
- identify possible duplicate matches for QA.

Current semantic rules:

- `protein` represents the known protein species/category, not its physical form;
- ingredient identity is concept-first: when evidence supports it, Classification should normally propose roughly 1–3 primary key ingredient concepts rather than forcing one `main_ingredient`;
- protein and key-ingredient concepts may overlap by ingredient family when their roles differ: e.g. eggs can be `protein = Vajcia` in an egg-led dish, but a primary `Vajcia` concept while `protein = Kuracie mäso` in Oyakodon; decide from recipe role rather than enforcing global exclusivity;
- key ingredients are represented in the candidate `concepts` list and, after approval, in `recipe_concepts` with `importance = primary`; ingredient-like concept types may include ingredient, stock, sauce, component, seasoning, condiment, and dough/batter;
- the legacy `main_ingredient` field may remain populated for historical/compatibility reasons, but new ingestion should not force it and should not treat it as the canonical key-ingredient model;
- `side_dish` is reserved for an actual accompaniment, not an integrated starch/noodle base;
- integrated structural bases such as rice, noodles, udon, pasta, or similar components should be represented after approval through `recipe_concepts` with `role = main_component` rather than by adding a new dedicated `base_component` column; candidate JSON may still carry `base_component` as an extraction hint before promotion;
- forms such as `Mleté mäso` and specific reusable ingredients/condiments such as `Gochujang`, `Italian Sausage`, or `Guanciale` belong in culinary concepts when useful;
- tags describe properties of the dish rather than arbitrary ingredients or provenance;
- prep/cook time, servings, and similar fields remain NULL when unsupported;
- non-recipe content may legitimately produce zero recipe candidates.

Allowed writes:

- create/update `recipe_candidates`;
- candidate classification JSON and confidence;
- preference proposal/status where evidence is sufficient.

Not allowed:

- write to `recipes`;
- create new controlled lookup seeds automatically;
- persist a newly proposed culinary concept directly into the canonical concept vocabulary without QA approval;
- silently turn a `possible_duplicate` into a new recipe;
- reinterpret unsupported details from general culinary knowledge as source facts.

### 4. QA / Review Agent

Purpose: be the high-reasoning quality gate between interpretation and persistent recipe identity.

This is the strongest reasoning role in the pipeline.

Responsibilities:

- verify every material candidate claim against evidence;
- validate evidence-role correctness;
- decide whether candidate data is sufficiently supported;
- evaluate:
  - unique recipe,
  - exact duplicate,
  - merge candidate,
  - meaningful variant,
  - reject / non-recipe / insufficient evidence;
- verify preference treatment;
- check that classification did not smuggle in unsupported details;
- propose controlled taxonomy or modeling changes when current semantics are insufficient;
- escalate consequential ambiguity.

Allowed writes:

- validation status;
- dedupe status;
- matched recipe reference;
- preference status/notes;
- review notes;
- approval/rejection disposition;
- approval of straightforward evidence-backed culinary concepts proposed by Classification.

A strong QA agent may approve a new culinary concept when it is a direct, reusable concept supported by the evidence and fits an existing concept type/role without changing model semantics. Examples include ordinary ingredients or established condiments such as Garlic, Panko, Chunjang, or a clearly named reusable component.

Not allowed without escalation:

- create a new cuisine/protein/main_ingredient/tag or other controlled lookup seed;
- create a new concept type, relationship type, aggregate/category semantics, or other concept-model rule;
- redefine taxonomy semantics;
- create a new relationship type;
- introduce a normalized Creator entity;
- approve a meaningful identity split when evidence is genuinely ambiguous;
- promote a candidate during the creator pilot without explicit review outcome.

### 5. Promotion Executor

Purpose: apply an already-approved disposition deterministically.

The implementation target is a reusable transactional executor/RPC/service, not free-form SQL generation by a reasoning model. A caller should submit a candidate plus an approved disposition/version; the executor checks preconditions, applies only the approved writes, and verifies the post-write state.

This should contain as little open-ended reasoning as possible.

Responsibilities:

- create a new `recipes` row for an approved unique/variant candidate;
- or enrich/link an existing recipe for an approved duplicate/merge;
- create/reuse `sources` and `recipe_sources`;
- create/reuse approved tags/concepts and bridges when the QA result explicitly permits them;
- close candidate/inbox workflow state;
- verify post-write state.

Allowed writes:

- recipe/source/bridge rows necessary for the approved disposition;
- approved culinary-concept links;
- candidate/inbox completion fields.

Not allowed:

- independently reinterpret evidence;
- change schema/RLS/security;
- create new controlled taxonomy seeds unless that exact seed was separately approved;
- change the approved identity decision;
- bulk-promote a creator cohort.

If the expected target row changed between QA and promotion, promotion must stop and return to QA.

#### Promotion authority by review policy

- `auto_after_validation`: direct explicit user submissions may proceed through deterministic promotion when validation/dedupe/preference gates are clean and no escalation condition is present.
- `explicit_review`: discovery/channel/playlist items may run autonomously through Discovery, Resolver, Classification, and QA, but new identities, meaningful variants, partial-source cases, preference adaptations, and other consequential dispositions remain in a review queue until explicitly approved.
- `hold`: no promotion.
- Exact-duplicate source-link enrichment is a candidate for later autonomous execution once its deterministic preconditions are implemented and verified; v1.1 does not require this optimization.

## Controlled taxonomy vs open-ended concepts

Agent v1 distinguishes controlled lookup dimensions from the more extensible culinary knowledge layer.

Controlled dimensions include, at minimum:

- cuisine,
- protein,
- legacy main ingredient lookup,
- preparation type,
- meal usage,
- dish type,
- recipe status,
- tags.

A missing controlled value is an **escalation**, not permission to invent a new seed.

Culinary concepts are more extensible but still evidence-driven. Classification may propose new concepts. Strong QA may approve straightforward evidence-backed concepts that fit existing concept types and semantics. Controlled lookup creation and any concept-model novelty remain specialist-owned escalation points.

## Escalation conditions

Any agent must stop or escalate when one of these occurs:

- source identity is uncertain;
- evidence sources conflict materially;
- a third-party reference is the only support for a consequential recipe claim;
- candidate identity vs existing recipe is genuinely ambiguous;
- meaningful variant vs duplicate cannot be defended from evidence;
- a new controlled taxonomy seed appears necessary;
- current schema cannot represent an important distinction without distortion;
- preference adaptation risks changing recipe identity;
- a resolver appears to have attached content from the wrong source;
- promotion target has changed since QA;
- a new creator-normalization requirement emerges;
- the agent would otherwise need to guess.

Escalation target:

1. Recipe Intelligence technical specialist / senior reviewer;
2. Igor when the decision is subjective, preference-driven, or changes project semantics.

## Model-strength policy

Not every stage needs the strongest available model.

### Mechanical / lower-reasoning tier

Suitable for:

- URL canonicalization;
- channel enumeration;
- metadata extraction;
- deterministic duplicate URL checks;
- source-page fetching;
- evidence packaging;
- promotion execution after approval.

### Strong-reasoning tier

Required for:

- candidate extraction from messy multi-recipe content;
- cuisine/protein/key-ingredient interpretation;
- duplicate vs variant reasoning;
- source-provenance QA;
- preference adaptation;
- deciding whether missing information is safe to leave NULL;
- reviewing conflicting or partial evidence.

The pipeline should optimize model spend by using strong reasoning only where semantic judgment materially affects data quality.

## Write-safety rules

All automated writes must be:

- scoped to the approved creator/batch;
- idempotent;
- auditable from source -> evidence -> candidate -> disposition;
- reversible at the bridge/candidate level where practical;
- verified after execution.

Agents must never:

- disable RLS;
- broaden anonymous access;
- modify Auth;
- run destructive bulk deletes;
- run schema migrations merely to unblock one ingestion case;
- store secrets in recipe data or repository documentation.

Schema/security changes remain specialist-owned work.

## Retry and resume behavior

A failed resolver or model call must not restart the whole creator cohort from scratch.

Each source progresses independently through durable checkpoints.

Expected behavior:

- discovery can resume from the staged manifest;
- resolution can retry a failed source without duplicating evidence;
- classification reuses the same inbox item;
- candidate uniqueness remains anchored by `(inbox_id, candidate_index)`;
- promotion must be safe to re-check before writing;
- completed sources are not reopened unless explicitly requested.

## Source intent

Source intent is useful but remains an ingestion-layer concern in v1.1 rather than a new normalized schema dimension.

Resolver/Classification may store fields such as `primary_content_type`, `secondary_content_type`, or `content_form` in `recipe_inbox.structured_data` using values such as recipe, multi_recipe, technique_demo, ingredient_explainer, learning_content, or nonrecipe.

This lets the system distinguish what a source primarily does from which recipe candidates can be extracted. The SAMUKICHI technique-first case demonstrated that a source can teach a technique while still yielding a recipe candidate. A future source-to-concept teaches/demonstrates relationship remains a separate modeling decision.

## Pilot stop conditions

The Aaron & Claire pilot should pause for review rather than continue blindly if:

- the same resolver failure repeats across three consecutive sources;
- provenance is assigned incorrectly;
- rerunning a source creates duplicate inbox/evidence/candidate state;
- promotion writes to the wrong existing recipe;
- a new schema requirement appears, including a repeated need for a structural base/component dimension;
- agent decisions repeatedly require taxonomy exceptions;
- a systematic QA failure is found.

A stop condition pauses downstream promotion. It does not require discarding already verified source evidence.

## Aaron & Claire pilot specification

Initial cohort:

- target **10-15 videos**;
- creator: Aaron & Claire;
- use the existing creator/channel review grouping where available;
- include the previously validated Ssamjang video as a control case if useful, but distinguish previously known results from new pilot evidence;
- prefer a heterogeneous cohort: single-recipe videos, multi-recipe compilations, creator-page-backed videos, and at least one source that stresses resolver fallback.

Review policy:

- newly discovered creator content remains `explicit_review`;
- no channel-wide auto-promotion.

For each source record:

- resolution status;
- evidence roles used;
- candidate count;
- validation outcome;
- dedupe outcome;
- preference outcome;
- human/specialist escalation required or not;
- final disposition.

Pilot evaluation should answer:

- which steps are sufficiently mechanical to delegate safely;
- where strong reasoning is actually required;
- how often human review is needed;
- whether repeated creator processing warrants a normalized Creator entity;
- whether creator grouping via existing source/content-collection semantics is sufficient;
- whether the Promotion Executor can remain fully deterministic;
- whether a larger channel crawl is justified.

## Post-pilot audit result — 2026-10-12

**Verdict: PASS for guarded autonomy.**

The bounded Aaron & Claire pilot completed all clean reviewable dispositions. New-discovery outcomes were 19 promoted, 4 duplicate, and 2 intentional holds; the previously known Ssamjang control contributed 3 additional promoted candidates.

Database invariant checks after the pilot found:

- 0 duplicate pilot inbox source identities;
- 0 duplicate `(inbox_id, candidate_index)` keys;
- 0 promoted candidates without a promoted recipe;
- 0 promoted candidates without a recipe-source link;
- 0 partial sources without `resolution_error`;
- 0 `possible_duplicate` candidates promoted;
- 0 `validation_status = needs_review` candidates promoted;
- 0 duplicate dispositions without a matched recipe.

Observed role readiness:

- **Discovery:** suitable for autonomous execution inside approved scope.
- **Resolver:** suitable for autonomous acquisition behind the narrow Resolver Service boundary; partial/failure states must remain explicit.
- **Classification:** suitable for autonomous candidate production using a strong reasoning model, but not canonical recipe writes.
- **QA / Review:** suitable for strong-model autonomous review of routine cases, with mandatory escalation for ambiguity, controlled taxonomy changes, concept-model novelty, and other consequential semantic changes.
- **Promotion Executor:** suitable for deterministic autonomous execution after an allowed/approved disposition, implemented as a transactional executor rather than open-ended reasoning.

The pilot also validated that richer creator-page evidence can materially change identity/classification decisions: e.g. Firecrawl resolution corrected the Gochujang Pt.2 details and identified the Jjajangmyeon source specifically as a Jaengban Jjajang variant.

## Success criteria for Agent Contract v1.1

The contract is considered validated when the pilot demonstrates:

- no provenance-role violations;
- no invented recipe facts;
- no duplicate recipe identities caused by reruns;
- every promoted/enriched recipe is traceable to evidence and an approved candidate disposition;
- ambiguous cases are escalated rather than guessed;
- non-recipe content can still resolve to zero candidates;
- partial sources remain visibly partial;
- deterministic promotion reproduces the approved QA outcome;
- agent boundaries prove useful enough to implement as separate workers/services.

The goal is not zero human review.

The goal is to move routine work to agents while reserving human/senior-model attention for decisions where judgment actually matters.

## Ownership

Until autonomous agents are implemented:

- this specialist workstream owns the domain contract and Resolver/Promotion implementation specification;
- the current chat may continue to simulate/orchestrate the roles for targeted validation;
- Project OS/Core owns cross-project agent runtime/orchestration architecture;
- Recipe Intelligence owns the domain-specific rules described here.

Agent Contract v1.1 is now the implementation specification for the first guarded ingestion-agent workflow. The next implementation step is to define the concrete Resolver Service v1 interface and deterministic Promotion Executor contract without changing the validated role boundaries.
