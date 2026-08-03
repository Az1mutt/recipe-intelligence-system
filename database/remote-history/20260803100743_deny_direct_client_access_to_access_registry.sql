-- Historical remote migration evidence: 20260803100743 deny_direct_client_access_to_access_registry.
-- Already applied remotely; do not execute against the existing remote project.
-- Do not replay after the current-state bootstrap.

create policy "no direct client access"
on private.recipe_access_members
as restrictive
for all
to authenticated
using (false)
with check (false);
