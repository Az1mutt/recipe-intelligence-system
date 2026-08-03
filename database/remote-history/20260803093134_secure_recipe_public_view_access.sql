-- Historical remote migration evidence: 20260803093134 secure_recipe_public_view_access.
-- Already applied remotely; do not execute against the existing remote project.
-- Do not replay after the current-state bootstrap.

alter view public.recipe_public_view
  set (security_invoker = true);

revoke all privileges
  on table public.recipe_public_view
  from public, anon, authenticated;

grant select
  on table public.recipe_public_view
  to authenticated;
