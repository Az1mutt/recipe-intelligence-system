# Agent Contract v1

## Status

**Design contract, not yet an implemented autonomous service.**

This document defines how Recipe Intelligence ingestion work should be split between specialized agents once the workflow is automated. It is based on the already validated [Ingestion contract v1](ingestion-contract-v1.md).

The first proving ground for this contract is a bounded **Aaron & Claire creator-scale pilot**. During that pilot, the current technical specialist chat may temporarily act as orchestrator and senior reviewer while each step is executed according to the same boundaries future agents must follow.

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

The first creator-scale pilot keeps **explicit review** for newly discovered channel content. Passing this pilot is not permission for bulk auto-promotion.

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
- `main_ingredient` is a dominant defining non-protein ingredient when one is genuinely meaningful; it must not default to rice/noodles/pasta merely because they form the dish's starch base;
- `side_dish` is reserved for an actual accompaniment, not an integrated starch/noodle base;
- while the creator pilot is evaluating the missing base dimension, candidate JSON may use provisional `base_component` values such as `Ryža` or `Rezance`; agents must not assume this is already a stable schema field;
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
- approval/rejection disposition.

Not allowed without escalation:

- create a new cuisine/protein/main_ingredient/tag seed;
- redefine taxonomy semantics;
- create a new relationship type;
- introduce a normalized Creator entity;
- approve a meaningful identity split when evidence is genuinely ambiguous;
- promote a candidate during the creator pilot without explicit review outcome.

### 5. Promotion Executor

Purpose: apply an already-approved disposition deterministically.

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

## Controlled taxonomy vs open-ended concepts

Agent v1 distinguishes controlled lookup dimensions from the more extensible culinary knowledge layer.

Controlled dimensions include, at minimum:

- cuisine,
- protein,
- main ingredient,
- preparation type,
- meal usage,
- dish type,
- recipe status,
- tags.

A missing controlled value is an **escalation**, not permission to invent a new seed.

Culinary concepts are more extensible but still evidence-driven. During the first creator pilot, creation of a materially new ingredient concept should be surfaced in review so vocabulary quality can be observed before wider automation.

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
- cuisine/protein/main-ingredient interpretation;
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

## Success criteria for Agent Contract v1

The contract is considered validated only when the pilot demonstrates:

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

- this specialist workstream owns the contract;
- the current chat may simulate/orchestrate the roles during the pilot;
- Project OS/Core owns cross-project agent architecture;
- Recipe Intelligence owns the domain-specific rules described here.

Once the pilot is complete, this contract should be revised from observed failures and then used as the implementation specification for the first real ingestion-agent workflow.
