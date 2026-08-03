# Remote migration history

These four files preserve the exact stored statements from `supabase_migrations.schema_migrations`, preceded only by safety comments. They were already applied to the live project and are evidence, not active migrations. The bootstrap snapshot already contains their resulting state, so these files must not be applied after it or against the existing project. Never place them into an active migration path without a separately reviewed migration-reconciliation plan.

| Timestamp | Migration | Purpose | Repository path |
|---|---|---|---|
| 20260803093134 | `secure_recipe_public_view_access` | Enforce invoker security and authenticated-only view access | `database/remote-history/20260803093134_secure_recipe_public_view_access.sql` |
| 20260803100626 | `implement_single_owner_reader_access_v1` | Add the private registry, helpers, grants, RLS, and owner/reader policies | `database/remote-history/20260803100626_implement_single_owner_reader_access_v1.sql` |
| 20260803100743 | `deny_direct_client_access_to_access_registry` | Add the restrictive private-table policy | `database/remote-history/20260803100743_deny_direct_client_access_to_access_registry.sql` |
| 20260803103515 | `add_missing_foreign_key_indexes` | Add twelve foreign-key indexes | `database/remote-history/20260803103515_add_missing_foreign_key_indexes.sql` |
