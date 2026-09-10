# Database baseline

> **Historical baseline warning:** `database/bootstrap/2026-08-03_current_schema.sql` is an immutable 15-table snapshot from 2026-08-03. The live `Recipes_decision_system` project has advanced materially beyond it and currently has 33 public tables. Never run this bootstrap, the historical migrations, schema-creation SQL, seed SQL, or migration-repair commands against the existing live project.

## What this directory represents

- `bootstrap/2026-08-03_current_schema.sql` preserves the reconstructable database state at the 2026-08-03 cutover.
- `remote-history/` preserves migration evidence already applied before/at that historical baseline.
- `seeds/README.md` documents current seed policy/status. The live project now contains approved lookup values, but this repository does not yet maintain a complete executable current seed package.

The bootstrap remains useful as historical evidence and as a reference for the original access/security foundation. It is **not** the current live schema and is not sufficient to reproduce today's Recipe Intelligence System.

## Existing live Supabase project

For `Recipes_decision_system`, use the live database and current documentation as the source of truth. Do not replay the historical bootstrap or remote-history files.

Current references:

- [current live state](../docs/database-current-state.md)
- [database architecture](../docs/database-architecture.md)
- [ingestion contract v1](../docs/ingestion-contract-v1.md)
- [access model](../docs/database-access-model.md)
- [baseline and migration policy](../docs/database-baseline-and-migrations.md)

## New environments

Do **not** use the 2026-08-03 bootstrap as though it reproduced the current application. Before a new environment is needed, create a fresh, reviewed current-schema/migration path that includes all post-baseline architecture: knowledge graph, learning/curation, preference, ingestion evidence/candidates, current lookup seeds, RLS/policies, and other live changes.

Until that current migration/bootstrap path exists, the old bootstrap should be treated as historical evidence only.

## Future changes

Prefer forward-only, reviewed migrations from a known current baseline. Do not mutate historical migration evidence to make it appear that later live changes existed in 2026-08-03.
