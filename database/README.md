# Database baseline

> **Existing live project warning:** `Recipes_decision_system` is already at this documented state. Never run the bootstrap, historical migrations, schema creation SQL, seed SQL, or migration-repair commands against it.

## Artifact map and strategy

- `bootstrap/2026-08-03_current_schema.sql` is an immutable post-migration current-state snapshot, used exactly once only to bootstrap a brand-new empty Supabase environment.
- `remote-history/` preserves four migrations already applied remotely. They are evidence outside any active migration path; their effects are already in the bootstrap and they must not be replayed afterward.
- `seeds/README.md` records that no production seeds are approved. There is no executable seed step.

No Supabase CLI configuration, linkage, or active migration stream is initialized by this baseline.

## Brand-new Supabase environment only

The empty Supabase-provisioned database must already provide `auth.users`, `auth.uid()`, roles `anon` and `authenticated`, and schemas `auth` and `extensions`. The bootstrap creates or verifies `uuid-ossp` in `extensions`, then creates project-owned objects. PostgreSQL 17.6 is the documented target; `plpgsql` is needed only if separately replaying the historical `DO` block, which is not part of bootstrap.

Supply `NEW_SUPABASE_DATABASE_URL` only at runtime and never commit it. This command is only for a new, empty environment, must not target `Recipes_decision_system`, and was not executed during this task:

```bash
psql "$NEW_SUPABASE_DATABASE_URL" \
  --set ON_ERROR_STOP=1 \
  --file database/bootstrap/2026-08-03_current_schema.sql
```

Apply the bootstrap exactly once. No seed step follows because no production seed values are confirmed.

## Future changes

Create new, forward-only migrations after the 2026-08-03 baseline cutover. Selecting and initializing the future active migration toolchain is outside this baseline task. Historical reconciliation requires separate review before changing remote migration records or moving evidence into any active path.

See [architecture](../docs/database-architecture.md), [access model](../docs/database-access-model.md), [baseline policy](../docs/database-baseline-and-migrations.md), [current state](../docs/database-current-state.md), [remote evidence](remote-history/README.md), and [seed status](seeds/README.md).
