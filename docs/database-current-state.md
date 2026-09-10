# Database current state — 2026-09-10

## Live platform

The live Supabase project is the authoritative implementation. The repository's 2026-08-03 bootstrap is a historical baseline only and no longer represents the full live schema.

Verified live state on **2026-09-10**:

- 33 public tables, all with RLS enabled
- one private access-registry table: `private.recipe_access_members`
- two private authorization helpers: `private.has_recipe_access()` and `private.is_recipe_owner()`
- secure read view: `public.recipe_public_view`
- 246 recipes
- 142 sources
- 191 `recipe_inbox` rows
- 14 `recipe_candidates`
- 17 `recipe_inbox_evidence` rows
- 52 culinary concepts
- 24 culinary relationships
- 18 recipe-to-concept links
- 6 learning topics
- 13 content collections
- 1 preference profile and 2 food preferences
- Supabase Security Advisor: 0 security lints

## Implemented architecture

### Recipe intelligence and taxonomy

Core recipe classification includes cuisine, protein, main ingredient, side dish, preparation type, prep method, meal usage, recipe status, dish type, tags, source types, sources, and recipe/source/tag bridges.

`recipes` intentionally stores recipe identity and intelligence rather than canonical ingredient quantities and steps.

### Culinary knowledge graph

Implemented tables:

- `culinary_concepts`
- `culinary_relationships`
- `culinary_relationship_sources`
- `recipe_concepts`
- `recipe_usage_roles`

This supports reusable ingredient/component/technique knowledge and ingredient-driven retrieval beyond the coarse recipe lookup fields.

### Learning and curation

Implemented tables:

- `learning_topics`
- `content_collections`
- `learning_topic_concepts`
- `learning_topic_cuisines`
- `learning_topic_recipes`
- `content_collection_sources`
- `content_collection_concepts`
- `content_collection_topics`

### Personal food preferences

Implemented:

- `preference_profiles`
- `food_preferences`

Preference logic can mark objectively valid recipes as match, adaptable, deprioritized, or suppressed for a profile rather than deleting them.

### Ingestion contract v1

Implemented:

- extended `recipe_inbox` workflow / resolution / review-policy fields
- `recipe_inbox_evidence`
- `recipe_candidates`
- evidence roles separating original source, creator reference, external reference, and manual context
- 0..N candidates per source
- objective validation, dedupe, preference evaluation, explicit-review / auto-after-validation policy, promotion and merge behavior

See [ingestion contract v1](ingestion-contract-v1.md).

## Validated ingestion milestone

The ingestion contract has passed both single-source and heterogeneous batch validation.

The six-source Hárok3 batch completed successfully and exercised:

- **exact duplicate enrichment** — Perfect Pot Roast enriched existing `Pot Roast`
- **meaningful variant preservation** — Japanese-Style Mapo Tofu remained distinct from Chinese Mapo Tofu
- **unique promotion** — two gnocchi recipes were promoted
- **non-recipe handling** — a cheesecake water-bath technique article produced zero recipe candidates
- **partial-source fallback** — Tasty YouTube resolution remained partial while a third-party page was stored only as `external_reference` evidence
- **merge without hallucinated detail** — `One-Pot Pasta Primavera` enriched existing `Pasta primavera` with source/properties but no unsupported time, servings, or ingredient details

This closes the `batch-ingestion-validation` phase. The technical workstream is ready for a **bounded creator/channel-scale ingestion pilot** with explicit review and no bulk auto-promotion.

## Current modeling decisions

- `protein` is the coarse dominant protein category. If a known meat species exists, keep it rather than replacing it with a preparation form.
- `main_ingredient` is the practical pantry/menu-planning dimension and may differ from protein.
- specific ingredients/forms useful for retrieval belong in `culinary_concepts` / `recipe_concepts`; examples already validated include `Mleté mäso` and `Italian Sausage`
- recipe tags describe properties of dishes; provenance and creator grouping do not belong in tags
- multiple recipes from one video/article are grouped by their shared source relation
- creator identity currently lives in `sources.author`; normalized Creator modeling remains intentionally undecided until creator-scale use proves the need
- prep time, cook time, servings, and similar fields are optional evidence-backed enrichment

## Next technical gate

Run a bounded creator/channel-scale pilot, with Caitlin Shoemaker / From My Bowl as the natural first candidate. Preserve source grouping and creator identity, stage a manageable cohort, process it through the same resolver/evidence/candidate/validation/dedupe/preference/review pipeline, and evaluate whether creator normalization or new operational tooling is justified.

## Known technical debt / backlog

- The 2026-08-03 bootstrap and historical migration evidence do not reproduce the current 33-table live schema; a current forward-only migration/bootstrap strategy is still needed.
- A standalone backend/API and automated resolver service are not yet packaged.
- Frontend/review UI is not implemented.
- Pantry/inventory is planned to reference `culinary_concepts` rather than create a disconnected ingredient vocabulary.
- Remaining social inbox items, unresolved Facebook history, and Hárok5 import/dedupe remain backlog.
- Normalized Creator modeling is deferred pending creator/channel-scale evidence.
