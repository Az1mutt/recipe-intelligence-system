# Database access model

## Version 1 authorization

Effective client access is:

| Principal | Effective access |
|---|---|
| `anon` | None |
| Authenticated but unassigned | None |
| Active `reader` | Read only |
| Single active `owner` | Read and write |

As verified on **2026-09-10**, all **33 public tables** have RLS enabled and `FORCE ROW LEVEL SECURITY` is false. Each public table has SELECT, INSERT, UPDATE, and DELETE policies: **132 public-table policies total**. Reads call `private.has_recipe_access()`; writes call `private.is_recipe_owner()`.

`private.recipe_access_members` has RLS enabled and one restrictive `no direct client access` policy. Direct client privileges remain revoked. The partial unique owner constraint permits at most one active owner.

## Helpers, grants, and view

Both authorization helpers are SQL, `STABLE`, `SECURITY DEFINER`, and use an empty `search_path`. `authenticated` can execute the helpers; `anon` and `PUBLIC` do not receive effective application access through them.

Table grants and RLS are complementary: a grant only makes an operation eligible, while the applicable RLS policy separately determines whether rows are visible or writable. An unassigned authenticated user therefore receives no effective recipe access, while readers cannot pass owner write policies.

`public.recipe_public_view` is configured with `security_invoker=true`, so underlying RLS applies as the caller. It remains the secure read surface for authenticated recipe access; anonymous access is not part of the model.

## Coverage of newer intelligence tables

The same member-read / owner-write authorization pattern now covers the post-baseline architecture as well, including:

- culinary knowledge graph tables
- learning and content-collection tables
- personal preference tables
- `recipe_inbox_evidence`
- `recipe_candidates`

This means the ingestion and intelligence layers did not introduce a parallel or weaker client-access model.

## Verification

The Supabase Security Advisor reported **0 security lints** on 2026-09-10.

The private registry is still intended to be administered outside direct client access. This document describes the current model; it does not propose multi-owner or public/anonymous access.
