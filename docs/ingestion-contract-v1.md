# Ingestion contract v1

## Purpose

Recipe Intelligence System must not depend on one brittle way of reading external content. Ingestion is evidence-driven: the system only classifies or promotes information that was actually resolved from source content, creator references, trustworthy external references, or explicit manual context.

Acquisition, understanding, and promotion are separate concerns.

## End-to-end flow

```text
source URL / video / article
-> recipe_inbox
-> resolver chain
-> recipe_inbox_evidence
-> recipe_candidates (0..N)
-> objective validation
-> dedupe
-> personal preference evaluation
-> review policy
-> promote / merge / reject
-> recipes + sources + bridges + knowledge/learning links
```

## Three independent state axes

Do not conflate these states:

1. `recipe_inbox.status` — ingestion workflow state.
2. `recipe_inbox.content_resolution_status` — how much of the original source was actually resolved.
3. `recipes.status_id` — the user's relationship to a recipe, such as wanting to try it or having tried it.

A source can therefore be workflow `completed` while remaining content-resolution `partial` if the resolver exhausted legitimate options and preserved the limitation explicitly.

## `recipe_inbox`

Important v1 fields include:

- `source_ref`
- `raw_input`
- `extracted_text`
- `structured_data`
- `ai_suggestion`
- `confidence_score`
- `status`
- `content_resolution_status`
- `review_policy`
- `resolution_error`

Workflow `status` values:

- `new`
- `processing`
- `ready_for_review`
- `approved`
- `rejected`
- `irrelevant`
- `duplicate`
- `failed`
- `completed`
- `blocked`

Content-resolution values:

- `pending`
- `metadata_only`
- `partial`
- `resolved`
- `failed_access`
- `failed_processing`

Review policy values:

- `explicit_review`
- `auto_after_validation`
- `hold`

## Evidence and provenance

`recipe_inbox_evidence` records what the resolver actually obtained. Evidence must not contain invented source content.

Evidence roles:

- `source_content` — material obtained from the original source.
- `creator_reference` — a creator-owned page or reference that supports the recipe/source identity.
- `external_reference` — a third-party reference used to classify or verify a recipe idea when the original source is unavailable or incomplete.
- `manual_context` — explicit user/manual context.

Evidence types include metadata, description, captions, transcript, audio transcript, keyframe text, webpage text, manual note, and other.

An `external_reference` may support classification, dedupe, or enrichment, but it must never be represented as the original creator/source.

## Resolver strategy

### YouTube

Preferred order:

1. canonicalize URL / video ID
2. resolve metadata
3. resolve description and creator-owned pages
4. captions / transcript when available and necessary
5. audio only when legitimately accessible and necessary
6. keyframes / vision when necessary
7. assemble evidence
8. extract candidates
9. use external verification/fallback when needed
10. validate, dedupe, apply preferences, review, and promote/merge

Expensive resolver steps should short-circuit when simpler evidence is sufficient.

Direct YouTube access is not assumed to be reliable. A source-access failure is a resolver condition, not permission to invent content.

## Candidate model

`recipe_candidates` allows one intake source to yield zero, one, or many recipe candidates.

Important states:

Candidate workflow:
- `extracted`
- `needs_review`
- `approved`
- `rejected`
- `duplicate`
- `promoted`
- `failed`

Validation:
- `pending`
- `passed`
- `needs_review`
- `failed`

Dedupe:
- `unchecked`
- `unique`
- `possible_duplicate`
- `exact_duplicate`
- `merge_candidate`

Personal preference:
- `not_evaluated`
- `match`
- `adaptable`
- `deprioritized`
- `suppressed`

A duplicate candidate may enrich an existing recipe with a new source, tags, concepts, or reliable metadata rather than producing another recipe row.

## Review policy

### Direct explicit user submission

For a direct instruction such as "add this video", use `auto_after_validation` when appropriate. The user has already approved the intake intent, so a redundant second approval should not be required after validation. Dedupe and safety/data-quality gates still apply.

### Discovery, channel, playlist, and legacy backlog

Use `explicit_review`. Broad discovery is not permission to promote every candidate automatically.

### Hold

Use `hold` for intentionally parked items.

## Dedupe principles

- Exact or semantic duplicates should enrich the existing recipe rather than create a second identity.
- Meaningful named or culinary variants may remain separate recipes.
- A preparation detail such as "one-pot" does not automatically create a new recipe identity.
- Shared source provenance belongs in `recipe_sources`, not provenance-specific recipe tags.

## Taxonomy rules established during validation

- `protein` keeps a known meat/protein species/category, e.g. `Bravčové mäso`.
- Ground form does not replace a known species; `Mleté mäso` can be a culinary concept.
- `main_ingredient` is the practical pantry/menu-planning dimension.
- Specific reusable ingredients such as `Italian Sausage` or future `Guanciale` belong in culinary concepts when useful for retrieval.
- Tags describe properties of the dish, not source provenance or an unrestricted ingredient vocabulary.
- Prep time, cook time, servings, and similar fields are optional enrichment and are populated only when evidence supports them.

## Validated acceptance cases

### Resolved multi-recipe YouTube source

Aaron & Claire's "3 New Ways to Enjoy SSAMJANG, Korean Dipping Sauce!" resolved through metadata/description plus a creator-owned page. It produced three candidates and all three passed validation/dedupe and were promoted under `auto_after_validation`.

### Partial YouTube with creator-reference fallback

Caitlin Shoemaker's "5 Cozy Vegan Weeknight Dinners" could not be fully read directly from YouTube. Indexed metadata/description plus five creator-owned From My Bowl pages recovered five candidates. The workflow completed while `content_resolution_status` correctly remained `partial`; all five candidates were explicitly reviewed and promoted.

### Heterogeneous six-source batch — 2026-09-10

The batch validated multiple failure modes and outcomes:

- Perfect Pot Roast: exact duplicate; existing `Pot Roast` enriched instead of duplicated.
- Japanese-Style Mapo Tofu: meaningful Japanese variant retained separately from existing Chinese Mapo Tofu.
- Creamy Spinach and Mushroom Gnocchi: unique recipe promoted.
- Creamy Sausage Gnocchi: unique recipe promoted; `Italian Sausage` modeled as a specific ingredient concept.
- Cheesecake water-bath article: correctly classified as non-recipe technique content and produced zero recipe candidates.
- Tasty "One-Pot Vegetarian Meals": source remained partial; one `One-Pot Pasta Primavera` candidate was recovered via `external_reference`, then safely merged into existing `Pasta primavera` without inventing unsupported times, servings, or ingredients.

This closes the isolated/batch-ingestion validation gate. The next technical proof point is a bounded creator/channel-scale pilot with explicit review and no bulk auto-promotion.
