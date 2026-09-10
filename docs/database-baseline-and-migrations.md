# Database baseline and migration policy

> **Never run the historical bootstrap or historical migration files against the existing `Recipes_decision_system` Supabase project.**

## Historical baseline boundary

The repository preserves an immutable database baseline cut at **2026-08-03**. At that point the reconstructable project-owned public schema contained 15 tables plus the private access model. The original initial-schema SQL was unavailable in remote migration history, so `database/bootstrap/2026-08-03_current_schema.sql` is a dependency-ordered reconstruction from PostgreSQL catalogs rather than invented creation history.

The four confirmed remote records preserved for that boundary are:

1. `20260803093134 secure_recipe_public_view_access`
2. `20260803100626 implement_single_owner_reader_access_v1`
3. `20260803100743 deny_direct_client_access_to_access_registry`
4. `20260803103515 add_missing_foreign_key_indexes`

Those files are historical evidence only. Their effects are already represented in the historical bootstrap and they must not be replayed after it.

## Live project has moved beyond the baseline

As of **2026-09-10**, the live project has **33 public tables**, approved lookup data, a culinary knowledge graph, learning/curation and personal-preference layers, and ingestion-contract tables for evidence and candidates. The old 15-table bootstrap therefore no longer represents the current application.

For the existing live project:

- do not run the 2026-08-03 bootstrap
- do not replay `remote-history/`
- do not run migration-repair commands merely to make historical records look current
- do not assume the current live schema can be rebuilt from repository SQL yet

Use the live database plus [current-state documentation](database-current-state.md) as the present source of truth.

## Reproducibility debt

A reviewed forward-only migration/bootstrap path for the **current** 33-table architecture is still required before provisioning another equivalent environment. It should capture all post-baseline schema, constraints, policies, lookup seeds, knowledge-graph objects, learning/curation objects, preference objects, and ingestion-contract objects.

Do not rewrite or mutate the 2026-08-03 baseline to achieve this. Instead, preserve that baseline as history and establish a new explicit current migration boundary.

## Future migration policy

Future schema changes should be forward-only and reviewed from a known current baseline. Before migration-history reconciliation, separately verify:

- live schema and constraints
- `supabase_migrations.schema_migrations`
- historical bootstrap boundary
- exact historical migration bodies
- currently approved seed state
- RLS/policy behavior
- safe treatment of already-applied effects

No migration-history repair should be performed casually or solely for cosmetic consistency.
