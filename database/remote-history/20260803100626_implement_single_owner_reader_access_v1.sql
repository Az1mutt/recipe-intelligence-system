-- Historical remote migration evidence: 20260803100626 implement_single_owner_reader_access_v1.
-- Already applied remotely; do not execute against the existing remote project.
-- Do not replay after the current-state bootstrap.

create schema if not exists private;

revoke all on schema private from public, anon, authenticated;
grant usage on schema private to authenticated;

create table private.recipe_access_members (
  user_id uuid primary key references auth.users(id) on delete cascade,
  access_role text not null
    check (access_role in ('owner', 'reader')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table private.recipe_access_members is
  'Administrative allowlist for Recipe Intelligence System v1. Not exposed through the Data API.';

create unique index recipe_access_one_active_owner_idx
  on private.recipe_access_members ((true))
  where access_role = 'owner' and is_active;

alter table private.recipe_access_members enable row level security;

revoke all privileges on table private.recipe_access_members
  from public, anon, authenticated;

create or replace function private.has_recipe_access()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select (select auth.uid()) is not null
     and exists (
       select 1
       from private.recipe_access_members as member
       where member.user_id = (select auth.uid())
         and member.is_active
     );
$$;

create or replace function private.is_recipe_owner()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select (select auth.uid()) is not null
     and exists (
       select 1
       from private.recipe_access_members as member
       where member.user_id = (select auth.uid())
         and member.access_role = 'owner'
         and member.is_active
     );
$$;

revoke all on function private.has_recipe_access() from public, anon;
revoke all on function private.is_recipe_owner() from public, anon;
grant execute on function private.has_recipe_access() to authenticated;
grant execute on function private.is_recipe_owner() to authenticated;

revoke all privileges on all tables in schema public from public, anon, authenticated;

grant select, insert, update, delete on table
  public.cuisine,
  public.main_ingredient,
  public.meal_usage,
  public.prep_method,
  public.preparation_type,
  public.protein,
  public.recipe_inbox,
  public.recipe_sources,
  public.recipe_status,
  public.recipe_tags,
  public.recipes,
  public.side_dish,
  public.source_types,
  public.sources,
  public.tags
to authenticated;

grant select on table public.recipe_public_view to authenticated;

drop policy if exists "public read recipes" on public.recipes;

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'cuisine',
    'main_ingredient',
    'meal_usage',
    'prep_method',
    'preparation_type',
    'protein',
    'recipe_inbox',
    'recipe_sources',
    'recipe_status',
    'recipe_tags',
    'recipes',
    'side_dish',
    'source_types',
    'sources',
    'tags'
  ]
  loop
    execute format('alter table public.%I enable row level security', table_name);

    execute format(
      'create policy "recipe members can read" on public.%I
       for select to authenticated
       using ((select private.has_recipe_access()))',
      table_name
    );

    execute format(
      'create policy "recipe owner can insert" on public.%I
       for insert to authenticated
       with check ((select private.is_recipe_owner()))',
      table_name
    );

    execute format(
      'create policy "recipe owner can update" on public.%I
       for update to authenticated
       using ((select private.is_recipe_owner()))
       with check ((select private.is_recipe_owner()))',
      table_name
    );

    execute format(
      'create policy "recipe owner can delete" on public.%I
       for delete to authenticated
       using ((select private.is_recipe_owner()))',
      table_name
    );
  end loop;
end
$$;
