# Database architecture

## Platform and scope

The live Recipe Intelligence System runs on Supabase/PostgreSQL. As of **2026-09-10**, the live project has **33 public tables**, one private access-registry table, two private authorization helpers, and `public.recipe_public_view`. All 33 public tables have RLS enabled.

The product is a **recipe intelligence system**, not a canonical recipe-text store. `recipes` contains recipe identity and classification. Provenance is modeled through `sources` and `recipe_sources`; ingestion evidence is kept separately; detailed ingredient quantities and step-by-step instructions are intentionally not first-class recipe tables at this stage.

## Table groups

### Core recipe and taxonomy layer

Lookup/classification tables:

- `cuisine`
- `protein`
- `main_ingredient`
- `side_dish`
- `preparation_type`
- `prep_method`
- `meal_usage`
- `recipe_status`
- `dish_type`
- `source_types`
- `tags`

Core entities and bridges:

- `recipes`
- `sources`
- `recipe_sources`
- `recipe_tags`
- `recipe_inbox`

`recipes` currently stores name, description, lookup references, optional prep/cook time, optional servings, difficulty, timestamps, and `added_by_id`. The optional time/serving fields are enrichment rather than required recipe identity and must not be invented when source evidence does not support them.

### Culinary knowledge graph

- `culinary_concepts`
- `culinary_relationships`
- `culinary_relationship_sources`
- `recipe_concepts`
- `recipe_usage_roles`

The graph supports concepts such as ingredients, stocks, sauces, components, techniques, seasonings, condiments, preparations, dough/batter concepts, and categories. Relationships include `DERIVED_FROM`, `REQUIRES`, `VARIANT_OF`, `USES_TECHNIQUE`, `MEMBER_OF`, `COMMONLY_USED_FOR`, and `RELATED_TO`.

Specific ingredients that are useful for retrieval but do not belong in coarse recipe taxonomy are modeled here. For example, a recipe can keep `protein = Bravčové mäso` and `main_ingredient = Gnocchi` while also linking the ingredient concept `Italian Sausage`.

### Learning and curation layer

- `learning_topics`
- `content_collections`
- `learning_topic_concepts`
- `learning_topic_cuisines`
- `learning_topic_recipes`
- `content_collection_sources`
- `content_collection_concepts`
- `content_collection_topics`

This layer groups concepts, cuisines, recipes, and source material for structured learning and creator/channel review without polluting recipe tags with provenance.

### Personal preference layer

- `preference_profiles`
- `food_preferences`

Preferences affect prioritization and recommendation behavior without deleting objectively valid recipes. A recipe can therefore remain in the catalogue while being deprioritized or suppressed for a specific profile.

### Ingestion contract v1

- `recipe_inbox_evidence`
- `recipe_candidates`

Together with `recipe_inbox`, these tables separate acquisition from interpretation and promotion. One inbox source may yield zero, one, or many candidates.

The operational path is:

```text
source
-> recipe_inbox
-> resolver chain
-> recipe_inbox_evidence
-> recipe_candidates
-> validation
-> dedupe
-> preference evaluation
-> review policy
-> promote / merge / reject
-> recipes + sources + bridges + intelligence links
```

See [ingestion contract v1](ingestion-contract-v1.md) for state semantics and resolver behavior.

## Taxonomy semantics

### `protein`

`protein` represents the dominant meat/fish/tofu/cheese-style protein category. When the species/type is known, keep the concrete category such as `Bravčové mäso` rather than replacing it with a preparation form such as ground meat. The field may legitimately be `NULL` when no meaningful protein category applies.

### `main_ingredient`

`main_ingredient` is the practical pantry/menu-planning dimension: it should help answer questions such as "I have chickpeas/gnocchi/mushrooms; what can I cook?" It is not required to duplicate the protein field.

### Specific ingredients and forms

Concrete or reusable ingredient concepts such as `Mleté mäso`, `Italian Sausage`, or future `Guanciale` belong in `culinary_concepts` / `recipe_concepts` when they are useful for ingredient-driven retrieval. Recipe tags remain properties of the dish, not an ingredient catalogue.

## Provenance model

A recipe can have multiple sources. A shared source is also the grouping mechanism for multiple recipes extracted from the same video or article. For example, five recipes extracted from one compilation video all link to that same source; no provenance-specific recipe tag is required.

Creator identity is currently stored textually in `sources.author`. A normalized Creator entity is intentionally deferred until repeated creator/channel-scale processing proves that the extra model is useful.

## Access and security

- All 33 public tables have RLS enabled.
- `private.recipe_access_members` is the private access registry.
- `private.has_recipe_access()` and `private.is_recipe_owner()` are the authorization helpers.
- `public.recipe_public_view` uses invoker security and is the secure read surface.
- Member read / owner write policy is used across intelligence, curation, preference, evidence, and candidate layers.
- The Supabase Security Advisor reported **0 lints** on 2026-09-10.

See [database access model](database-access-model.md) for authorization details.

## Live architecture counts — 2026-09-10

- 33 public tables
- 246 recipes
- 142 sources
- 191 inbox items
- 14 recipe candidates
- 17 evidence rows
- 52 culinary concepts
- 24 culinary relationships
- 18 recipe-to-concept links
- 6 learning topics
- 13 content collections
- 1 preference profile / 2 food preferences

These counts are a dated verification snapshot, not schema constants.

## Historical baseline warning

`database/bootstrap/2026-08-03_current_schema.sql` is an immutable historical 15-table baseline. The live project has advanced materially beyond it. It must **not** be treated as the current schema and must never be replayed against the existing Supabase project.

A reproducible current migration/bootstrap path is still technical debt; see [baseline and migration policy](database-baseline-and-migrations.md).
