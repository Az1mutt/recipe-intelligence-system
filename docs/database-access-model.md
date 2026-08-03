# Database access model

## Version 1 authorization

Effective client access is:

| Principal | Effective access |
|---|---|
| `anon` | None |
| Authenticated but unassigned | None |
| Active `reader` | Read only |
| Single active `owner` | Read and write |

All 15 public tables have RLS enabled and `FORCE ROW LEVEL SECURITY` is false. Each has SELECT, INSERT, UPDATE, and DELETE policies: 60 public-table policies total. Reads call `private.has_recipe_access()`; writes call `private.is_recipe_owner()`. The partial unique index `recipe_access_one_active_owner_idx` permits at most one active owner.

`private.recipe_access_members` also has RLS enabled and a restrictive `no direct client access` policy whose `USING` and `WITH CHECK` are false. Direct privileges are revoked for client roles.

## Helpers, grants, and view

Both helpers are SQL, `STABLE`, `SECURITY DEFINER`, and use an empty `search_path`. `authenticated` has function `EXECUTE`; `anon` and `PUBLIC` do not. The authenticated role has SELECT, INSERT, UPDATE, and DELETE table grants, but those grants only make an operation eligible: RLS still determines effective row access. Thus an unassigned authenticated user receives no rows and cannot write, while readers cannot pass owner write policies.

`public.recipe_public_view` has `security_invoker=true`, so underlying RLS applies as the caller. Only `authenticated` receives SELECT on the view; `anon` and `PUBLIC` do not.

SQL grants and RLS are complementary: a grant permits PostgreSQL to consider an operation, while an applicable RLS policy must separately allow its rows. Neither layer alone describes effective client access. The private registry is administered outside direct client access; this document does not propose a different security model.
