# Database baseline and migration policy

> **Never run the bootstrap or the historical migration files against the existing Recipes_decision_system Supabase project.**

## Why this is a current-state baseline

The original initial-schema SQL is unavailable in remote migration history: the 15 public tables, their original indexes, and the earlier view predate the stored migrations. The bootstrap is therefore a dependency-ordered reconstruction from PostgreSQL catalogs, not invented creation history. The exact baseline cutover date is **2026-08-03**.

The four confirmed remote records are:

1. `20260803093134 secure_recipe_public_view_access`
2. `20260803100626 implement_single_owner_reader_access_v1`
3. `20260803100743 deny_direct_client_access_to_access_registry`
4. `20260803103515 add_missing_foreign_key_indexes`

## Mandatory strategy

The immutable snapshot in `database/bootstrap/` represents state after all four migrations. It is only for bootstrapping a brand-new, empty Supabase environment. Exact remote statements are kept separately in `database/remote-history/` as evidence already applied—not as steps following bootstrap, because their effects are already included.

For the existing live project, do not run bootstrap SQL, historical files, schema creation SQL, seed SQL, or migration-repair commands. It is already at the documented state.

For a new environment: provision Supabase dependencies (`auth.users`, `auth.uid()`, client roles, and `auth` and `extensions` schemas), apply the bootstrap exactly once, and do not seed because no production values are confirmed. See the guarded command in the [database guide](../database/README.md).

No `supabase/` structure or active CLI migration stream is initialized because choosing the future toolchain is outside this baseline. Future changes begin as new forward-only migrations after the cutover. Before any migration-history reconciliation, separately review the live migration table, bootstrap boundary, exact historical bodies, tool behavior, and safe handling of already-applied effects. This task does not alter or repair `supabase_migrations.schema_migrations`.
