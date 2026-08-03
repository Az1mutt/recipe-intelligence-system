# Recipe Intelligence System — Read-only Technical Handoff

**Project:** `Recipes_decision_system`  
**Platform:** Supabase / PostgreSQL 17.6  
**Region:** `eu-central-1`  
**Snapshot time:** 2026-08-03  
**Mode:** read-only inspection only  
**Secrets:** none included

This document separates the current live schema from remotely stored migration evidence. No Supabase objects or data were changed while preparing it.

# CURRENT_SCHEMA_SQL

The SQL below is a reproducible current-state reconstruction from PostgreSQL catalogs. It is not claimed to be the original SQL used to create the first 15 public tables.

The live default expression deparses as `uuid_generate_v4()`. Its resolved function is `extensions.uuid_generate_v4()`, owned by the installed `uuid-ossp` extension; the baseline uses the schema-qualified form for reproducibility.

All 15 public tables and `private.recipe_access_members` have RLS enabled. `FORCE ROW LEVEL SECURITY` is false on every table.

Function metadata:

- `private.has_recipe_access()`
  - owner: `postgres`
  - language: `sql`
  - volatility: `STABLE`
  - security: `SECURITY DEFINER`
  - `search_path`: empty
  - leakproof: false
  - parallel safety: unsafe
  - effective requested-role ACL: `authenticated = EXECUTE`; `anon = none`; `PUBLIC = none`
- `private.is_recipe_owner()`
  - owner: `postgres`
  - language: `sql`
  - volatility: `STABLE`
  - security: `SECURITY DEFINER`
  - `search_path`: empty
  - leakproof: false
  - parallel safety: unsafe
  - effective requested-role ACL: `authenticated = EXECUTE`; `anon = none`; `PUBLIC = none`

View metadata:

- `public.recipe_public_view`
  - owner: `postgres`
  - option: `security_invoker=true`
  - effective requested-role ACL: `authenticated = SELECT`; `anon = none`; `PUBLIC = none`

```sql
-- Recipe Intelligence System
-- CURRENT LIVE SCHEMA SNAPSHOT
-- Read-only reconstruction from PostgreSQL catalogs on 2026-08-03.
-- This is a current-state baseline, not proof of the original table-creation history.
-- Target platform: Supabase / PostgreSQL 17.6.

-- Required extension for UUID defaults.
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;

-- Supabase platform dependencies assumed to exist:
--   auth.users
--   auth.uid()
--   roles anon and authenticated
--   schemas public, auth and extensions

CREATE SCHEMA IF NOT EXISTS private;

CREATE TABLE public.cuisine (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    CONSTRAINT cuisine_pkey PRIMARY KEY (id)
);

ALTER TABLE public.cuisine OWNER TO postgres;

CREATE UNIQUE INDEX ux_cuisine_name_lower
    ON public.cuisine USING btree (lower(name));

CREATE TABLE public.protein (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    CONSTRAINT protein_pkey PRIMARY KEY (id)
);

ALTER TABLE public.protein OWNER TO postgres;

CREATE UNIQUE INDEX ux_protein_name_lower
    ON public.protein USING btree (lower(name));

CREATE TABLE public.main_ingredient (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    CONSTRAINT main_ingredient_pkey PRIMARY KEY (id)
);

ALTER TABLE public.main_ingredient OWNER TO postgres;

CREATE UNIQUE INDEX ux_main_ingredient_name_lower
    ON public.main_ingredient USING btree (lower(name));

CREATE TABLE public.side_dish (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    CONSTRAINT side_dish_pkey PRIMARY KEY (id)
);

ALTER TABLE public.side_dish OWNER TO postgres;

CREATE UNIQUE INDEX ux_side_dish_name_lower
    ON public.side_dish USING btree (lower(name));

CREATE TABLE public.preparation_type (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    CONSTRAINT preparation_type_pkey PRIMARY KEY (id)
);

ALTER TABLE public.preparation_type OWNER TO postgres;

CREATE UNIQUE INDEX ux_preparation_type_name_lower
    ON public.preparation_type USING btree (lower(name));

CREATE TABLE public.prep_method (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    CONSTRAINT prep_method_pkey PRIMARY KEY (id)
);

ALTER TABLE public.prep_method OWNER TO postgres;

CREATE UNIQUE INDEX ux_prep_method_name_lower
    ON public.prep_method USING btree (lower(name));

CREATE TABLE public.meal_usage (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    CONSTRAINT meal_usage_pkey PRIMARY KEY (id)
);

ALTER TABLE public.meal_usage OWNER TO postgres;

CREATE UNIQUE INDEX ux_meal_usage_name_lower
    ON public.meal_usage USING btree (lower(name));

CREATE TABLE public.recipe_status (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    CONSTRAINT recipe_status_pkey PRIMARY KEY (id)
);

ALTER TABLE public.recipe_status OWNER TO postgres;

CREATE UNIQUE INDEX ux_recipe_status_name_lower
    ON public.recipe_status USING btree (lower(name));

CREATE TABLE public.source_types (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    CONSTRAINT source_types_pkey PRIMARY KEY (id)
);

ALTER TABLE public.source_types OWNER TO postgres;

CREATE UNIQUE INDEX ux_source_types_name_lower
    ON public.source_types USING btree (lower(name));

CREATE TABLE public.tags (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    CONSTRAINT tags_pkey PRIMARY KEY (id),
    CONSTRAINT tags_name_key UNIQUE (name)
);

ALTER TABLE public.tags OWNER TO postgres;

CREATE UNIQUE INDEX ux_tags_name_lower
    ON public.tags USING btree (lower(name));

CREATE TABLE public.recipes (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    description text,
    status_id uuid,
    cuisine_id uuid,
    protein_id uuid,
    main_ingredient_id uuid,
    side_dish_id uuid,
    preparation_type_id uuid,
    prep_method_id uuid,
    meal_usage_id uuid,
    cook_time_minutes integer,
    prep_time_minutes integer,
    servings integer,
    difficulty text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    added_by_id uuid,
    CONSTRAINT recipes_pkey PRIMARY KEY (id),
    CONSTRAINT fk_status
        FOREIGN KEY (status_id)
        REFERENCES public.recipe_status(id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT recipes_cuisine_id_fkey
        FOREIGN KEY (cuisine_id)
        REFERENCES public.cuisine(id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT recipes_protein_id_fkey
        FOREIGN KEY (protein_id)
        REFERENCES public.protein(id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT recipes_main_ingredient_id_fkey
        FOREIGN KEY (main_ingredient_id)
        REFERENCES public.main_ingredient(id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT recipes_side_dish_id_fkey
        FOREIGN KEY (side_dish_id)
        REFERENCES public.side_dish(id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT recipes_preparation_type_id_fkey
        FOREIGN KEY (preparation_type_id)
        REFERENCES public.preparation_type(id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT recipes_prep_method_id_fkey
        FOREIGN KEY (prep_method_id)
        REFERENCES public.prep_method(id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT recipes_meal_usage_id_fkey
        FOREIGN KEY (meal_usage_id)
        REFERENCES public.meal_usage(id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

ALTER TABLE public.recipes OWNER TO postgres;

CREATE INDEX idx_recipes_status_id
    ON public.recipes USING btree (status_id);
CREATE INDEX idx_recipes_cuisine_id
    ON public.recipes USING btree (cuisine_id);
CREATE INDEX idx_recipes_protein_id
    ON public.recipes USING btree (protein_id);
CREATE INDEX idx_recipes_main_ingredient_id
    ON public.recipes USING btree (main_ingredient_id);
CREATE INDEX idx_recipes_side_dish_id
    ON public.recipes USING btree (side_dish_id);
CREATE INDEX idx_recipes_preparation_type_id
    ON public.recipes USING btree (preparation_type_id);
CREATE INDEX idx_recipes_prep_method_id
    ON public.recipes USING btree (prep_method_id);
CREATE INDEX idx_recipes_meal_usage_id
    ON public.recipes USING btree (meal_usage_id);

CREATE TABLE public.sources (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    source_type_id uuid,
    name text,
    url text,
    reference text,
    author text,
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT sources_pkey PRIMARY KEY (id),
    CONSTRAINT sources_source_type_id_fkey
        FOREIGN KEY (source_type_id)
        REFERENCES public.source_types(id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

ALTER TABLE public.sources OWNER TO postgres;

CREATE INDEX idx_sources_source_type_id
    ON public.sources USING btree (source_type_id);

CREATE TABLE public.recipe_inbox (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    source_type_id uuid,
    source_ref text,
    raw_input text,
    extracted_text text,
    structured_data jsonb,
    ai_suggestion jsonb,
    confidence_score numeric,
    status text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT recipe_inbox_pkey PRIMARY KEY (id),
    CONSTRAINT recipe_inbox_source_type_id_fkey
        FOREIGN KEY (source_type_id)
        REFERENCES public.source_types(id)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

ALTER TABLE public.recipe_inbox OWNER TO postgres;

CREATE INDEX idx_recipe_inbox_source_type_id
    ON public.recipe_inbox USING btree (source_type_id);

CREATE TABLE public.recipe_sources (
    recipe_id uuid NOT NULL,
    source_id uuid NOT NULL,
    CONSTRAINT recipe_sources_pkey PRIMARY KEY (recipe_id, source_id),
    CONSTRAINT recipe_sources_recipe_id_fkey
        FOREIGN KEY (recipe_id)
        REFERENCES public.recipes(id)
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT recipe_sources_source_id_fkey
        FOREIGN KEY (source_id)
        REFERENCES public.sources(id)
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

ALTER TABLE public.recipe_sources OWNER TO postgres;

CREATE INDEX idx_recipe_sources_source_id
    ON public.recipe_sources USING btree (source_id);

CREATE TABLE public.recipe_tags (
    recipe_id uuid NOT NULL,
    tag_id uuid NOT NULL,
    CONSTRAINT recipe_tags_pkey PRIMARY KEY (recipe_id, tag_id),
    CONSTRAINT recipe_tags_recipe_id_fkey
        FOREIGN KEY (recipe_id)
        REFERENCES public.recipes(id)
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT recipe_tags_tag_id_fkey
        FOREIGN KEY (tag_id)
        REFERENCES public.tags(id)
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

ALTER TABLE public.recipe_tags OWNER TO postgres;

CREATE INDEX idx_recipe_tags_tag_id
    ON public.recipe_tags USING btree (tag_id);

CREATE TABLE private.recipe_access_members (
    user_id uuid NOT NULL,
    access_role text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT recipe_access_members_pkey PRIMARY KEY (user_id),
    CONSTRAINT recipe_access_members_access_role_check
        CHECK (access_role = ANY (ARRAY['owner'::text, 'reader'::text])),
    CONSTRAINT recipe_access_members_user_id_fkey
        FOREIGN KEY (user_id)
        REFERENCES auth.users(id)
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

ALTER TABLE private.recipe_access_members OWNER TO postgres;

COMMENT ON TABLE private.recipe_access_members IS
    'Administrative allowlist for Recipe Intelligence System v1. Not exposed through the Data API.';

CREATE UNIQUE INDEX recipe_access_one_active_owner_idx
    ON private.recipe_access_members USING btree ((true))
    WHERE ((access_role = 'owner'::text) AND is_active);

CREATE OR REPLACE FUNCTION private.has_recipe_access()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO ''
AS $function$
  select (select auth.uid()) is not null
     and exists (
       select 1
       from private.recipe_access_members as member
       where member.user_id = (select auth.uid())
         and member.is_active
     );
$function$;

ALTER FUNCTION private.has_recipe_access() OWNER TO postgres;

CREATE OR REPLACE FUNCTION private.is_recipe_owner()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO ''
AS $function$
  select (select auth.uid()) is not null
     and exists (
       select 1
       from private.recipe_access_members as member
       where member.user_id = (select auth.uid())
         and member.access_role = 'owner'
         and member.is_active
     );
$function$;

ALTER FUNCTION private.is_recipe_owner() OWNER TO postgres;

CREATE OR REPLACE VIEW public.recipe_public_view
WITH (security_invoker = true)
AS
SELECT
    r.id,
    r.name,
    r.description,
    r.cook_time_minutes,
    r.prep_time_minutes,
    r.servings,
    r.difficulty,
    c.name AS cuisine,
    p.name AS protein,
    mi.name AS main_ingredient,
    sd.name AS side_dish,
    pt.name AS preparation_type,
    pm.name AS prep_method,
    ms.name AS meal_usage,
    rs.name AS status
FROM public.recipes AS r
LEFT JOIN public.cuisine AS c
    ON c.id = r.cuisine_id
LEFT JOIN public.protein AS p
    ON p.id = r.protein_id
LEFT JOIN public.main_ingredient AS mi
    ON mi.id = r.main_ingredient_id
LEFT JOIN public.side_dish AS sd
    ON sd.id = r.side_dish_id
LEFT JOIN public.preparation_type AS pt
    ON pt.id = r.preparation_type_id
LEFT JOIN public.prep_method AS pm
    ON pm.id = r.prep_method_id
LEFT JOIN public.meal_usage AS ms
    ON ms.id = r.meal_usage_id
LEFT JOIN public.recipe_status AS rs
    ON rs.id = r.status_id;

ALTER VIEW public.recipe_public_view OWNER TO postgres;

ALTER TABLE public.cuisine ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cuisine NO FORCE ROW LEVEL SECURITY;

ALTER TABLE public.main_ingredient ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.main_ingredient NO FORCE ROW LEVEL SECURITY;

ALTER TABLE public.meal_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_usage NO FORCE ROW LEVEL SECURITY;

ALTER TABLE public.prep_method ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prep_method NO FORCE ROW LEVEL SECURITY;

ALTER TABLE public.preparation_type ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.preparation_type NO FORCE ROW LEVEL SECURITY;

ALTER TABLE public.protein ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.protein NO FORCE ROW LEVEL SECURITY;

ALTER TABLE public.recipe_inbox ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipe_inbox NO FORCE ROW LEVEL SECURITY;

ALTER TABLE public.recipe_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipe_sources NO FORCE ROW LEVEL SECURITY;

ALTER TABLE public.recipe_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipe_status NO FORCE ROW LEVEL SECURITY;

ALTER TABLE public.recipe_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipe_tags NO FORCE ROW LEVEL SECURITY;

ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipes NO FORCE ROW LEVEL SECURITY;

ALTER TABLE public.side_dish ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.side_dish NO FORCE ROW LEVEL SECURITY;

ALTER TABLE public.source_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.source_types NO FORCE ROW LEVEL SECURITY;

ALTER TABLE public.sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sources NO FORCE ROW LEVEL SECURITY;

ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags NO FORCE ROW LEVEL SECURITY;

ALTER TABLE private.recipe_access_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE private.recipe_access_members NO FORCE ROW LEVEL SECURITY;

CREATE POLICY "recipe members can read"
ON public.cuisine
AS PERMISSIVE
FOR SELECT
TO authenticated
USING ((SELECT private.has_recipe_access()));

CREATE POLICY "recipe owner can insert"
ON public.cuisine
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can update"
ON public.cuisine
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING ((SELECT private.is_recipe_owner()))
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can delete"
ON public.cuisine
AS PERMISSIVE
FOR DELETE
TO authenticated
USING ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe members can read"
ON public.main_ingredient
AS PERMISSIVE
FOR SELECT
TO authenticated
USING ((SELECT private.has_recipe_access()));

CREATE POLICY "recipe owner can insert"
ON public.main_ingredient
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can update"
ON public.main_ingredient
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING ((SELECT private.is_recipe_owner()))
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can delete"
ON public.main_ingredient
AS PERMISSIVE
FOR DELETE
TO authenticated
USING ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe members can read"
ON public.meal_usage
AS PERMISSIVE
FOR SELECT
TO authenticated
USING ((SELECT private.has_recipe_access()));

CREATE POLICY "recipe owner can insert"
ON public.meal_usage
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can update"
ON public.meal_usage
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING ((SELECT private.is_recipe_owner()))
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can delete"
ON public.meal_usage
AS PERMISSIVE
FOR DELETE
TO authenticated
USING ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe members can read"
ON public.prep_method
AS PERMISSIVE
FOR SELECT
TO authenticated
USING ((SELECT private.has_recipe_access()));

CREATE POLICY "recipe owner can insert"
ON public.prep_method
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can update"
ON public.prep_method
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING ((SELECT private.is_recipe_owner()))
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can delete"
ON public.prep_method
AS PERMISSIVE
FOR DELETE
TO authenticated
USING ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe members can read"
ON public.preparation_type
AS PERMISSIVE
FOR SELECT
TO authenticated
USING ((SELECT private.has_recipe_access()));

CREATE POLICY "recipe owner can insert"
ON public.preparation_type
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can update"
ON public.preparation_type
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING ((SELECT private.is_recipe_owner()))
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can delete"
ON public.preparation_type
AS PERMISSIVE
FOR DELETE
TO authenticated
USING ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe members can read"
ON public.protein
AS PERMISSIVE
FOR SELECT
TO authenticated
USING ((SELECT private.has_recipe_access()));

CREATE POLICY "recipe owner can insert"
ON public.protein
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can update"
ON public.protein
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING ((SELECT private.is_recipe_owner()))
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can delete"
ON public.protein
AS PERMISSIVE
FOR DELETE
TO authenticated
USING ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe members can read"
ON public.recipe_inbox
AS PERMISSIVE
FOR SELECT
TO authenticated
USING ((SELECT private.has_recipe_access()));

CREATE POLICY "recipe owner can insert"
ON public.recipe_inbox
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can update"
ON public.recipe_inbox
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING ((SELECT private.is_recipe_owner()))
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can delete"
ON public.recipe_inbox
AS PERMISSIVE
FOR DELETE
TO authenticated
USING ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe members can read"
ON public.recipe_sources
AS PERMISSIVE
FOR SELECT
TO authenticated
USING ((SELECT private.has_recipe_access()));

CREATE POLICY "recipe owner can insert"
ON public.recipe_sources
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can update"
ON public.recipe_sources
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING ((SELECT private.is_recipe_owner()))
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can delete"
ON public.recipe_sources
AS PERMISSIVE
FOR DELETE
TO authenticated
USING ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe members can read"
ON public.recipe_status
AS PERMISSIVE
FOR SELECT
TO authenticated
USING ((SELECT private.has_recipe_access()));

CREATE POLICY "recipe owner can insert"
ON public.recipe_status
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can update"
ON public.recipe_status
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING ((SELECT private.is_recipe_owner()))
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can delete"
ON public.recipe_status
AS PERMISSIVE
FOR DELETE
TO authenticated
USING ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe members can read"
ON public.recipe_tags
AS PERMISSIVE
FOR SELECT
TO authenticated
USING ((SELECT private.has_recipe_access()));

CREATE POLICY "recipe owner can insert"
ON public.recipe_tags
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can update"
ON public.recipe_tags
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING ((SELECT private.is_recipe_owner()))
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can delete"
ON public.recipe_tags
AS PERMISSIVE
FOR DELETE
TO authenticated
USING ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe members can read"
ON public.recipes
AS PERMISSIVE
FOR SELECT
TO authenticated
USING ((SELECT private.has_recipe_access()));

CREATE POLICY "recipe owner can insert"
ON public.recipes
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can update"
ON public.recipes
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING ((SELECT private.is_recipe_owner()))
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can delete"
ON public.recipes
AS PERMISSIVE
FOR DELETE
TO authenticated
USING ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe members can read"
ON public.side_dish
AS PERMISSIVE
FOR SELECT
TO authenticated
USING ((SELECT private.has_recipe_access()));

CREATE POLICY "recipe owner can insert"
ON public.side_dish
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can update"
ON public.side_dish
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING ((SELECT private.is_recipe_owner()))
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can delete"
ON public.side_dish
AS PERMISSIVE
FOR DELETE
TO authenticated
USING ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe members can read"
ON public.source_types
AS PERMISSIVE
FOR SELECT
TO authenticated
USING ((SELECT private.has_recipe_access()));

CREATE POLICY "recipe owner can insert"
ON public.source_types
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can update"
ON public.source_types
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING ((SELECT private.is_recipe_owner()))
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can delete"
ON public.source_types
AS PERMISSIVE
FOR DELETE
TO authenticated
USING ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe members can read"
ON public.sources
AS PERMISSIVE
FOR SELECT
TO authenticated
USING ((SELECT private.has_recipe_access()));

CREATE POLICY "recipe owner can insert"
ON public.sources
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can update"
ON public.sources
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING ((SELECT private.is_recipe_owner()))
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can delete"
ON public.sources
AS PERMISSIVE
FOR DELETE
TO authenticated
USING ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe members can read"
ON public.tags
AS PERMISSIVE
FOR SELECT
TO authenticated
USING ((SELECT private.has_recipe_access()));

CREATE POLICY "recipe owner can insert"
ON public.tags
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can update"
ON public.tags
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING ((SELECT private.is_recipe_owner()))
WITH CHECK ((SELECT private.is_recipe_owner()));

CREATE POLICY "recipe owner can delete"
ON public.tags
AS PERMISSIVE
FOR DELETE
TO authenticated
USING ((SELECT private.is_recipe_owner()));

CREATE POLICY "no direct client access"
ON private.recipe_access_members
AS RESTRICTIVE
FOR ALL
TO authenticated
USING (false)
WITH CHECK (false);

-- ACL snapshot for requested roles: PUBLIC, anon, authenticated.
-- Current catalogs store effective privileges, not a complete historical log
-- of every REVOKE that may have occurred. These commands reproduce the current ACL.

REVOKE ALL ON SCHEMA private FROM PUBLIC, anon, authenticated;
GRANT USAGE ON SCHEMA private TO authenticated;

GRANT USAGE ON SCHEMA public TO PUBLIC, anon, authenticated;

REVOKE ALL PRIVILEGES ON FUNCTION private.has_recipe_access()
    FROM PUBLIC, anon;
REVOKE ALL PRIVILEGES ON FUNCTION private.is_recipe_owner()
    FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION private.has_recipe_access()
    TO authenticated;
GRANT EXECUTE ON FUNCTION private.is_recipe_owner()
    TO authenticated;

REVOKE ALL PRIVILEGES ON TABLE private.recipe_access_members
    FROM PUBLIC, anon, authenticated;

REVOKE ALL PRIVILEGES ON TABLE
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
FROM PUBLIC, anon, authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE
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
TO authenticated;

REVOKE ALL PRIVILEGES ON TABLE public.recipe_public_view
    FROM PUBLIC, anon, authenticated;
GRANT SELECT ON TABLE public.recipe_public_view
    TO authenticated;

-- No project-owned sequences exist in public or private.
-- Therefore there are no sequence GRANT/REVOKE statements for this baseline.
```

# REMOTE_MIGRATION_EVIDENCE

All four requested migration rows exist in `supabase_migrations.schema_migrations`, and their stored `statements` values were available. The SQL below is the stored remote evidence, not reconstructed history.

## `20260803093134 secure_recipe_public_view_access`

```sql
alter view public.recipe_public_view
  set (security_invoker = true);

revoke all privileges
  on table public.recipe_public_view
  from public, anon, authenticated;

grant select
  on table public.recipe_public_view
  to authenticated;
```

## `20260803100626 implement_single_owner_reader_access_v1`

```sql
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
```

## `20260803100743 deny_direct_client_access_to_access_registry`

```sql
create policy "no direct client access"
on private.recipe_access_members
as restrictive
for all
to authenticated
using (false)
with check (false);
```

## `20260803103515 add_missing_foreign_key_indexes`

```sql
create index if not exists idx_recipes_status_id
  on public.recipes (status_id);

create index if not exists idx_recipes_cuisine_id
  on public.recipes (cuisine_id);

create index if not exists idx_recipes_protein_id
  on public.recipes (protein_id);

create index if not exists idx_recipes_main_ingredient_id
  on public.recipes (main_ingredient_id);

create index if not exists idx_recipes_side_dish_id
  on public.recipes (side_dish_id);

create index if not exists idx_recipes_preparation_type_id
  on public.recipes (preparation_type_id);

create index if not exists idx_recipes_prep_method_id
  on public.recipes (prep_method_id);

create index if not exists idx_recipes_meal_usage_id
  on public.recipes (meal_usage_id);

create index if not exists idx_sources_source_type_id
  on public.sources (source_type_id);

create index if not exists idx_recipe_inbox_source_type_id
  on public.recipe_inbox (source_type_id);

create index if not exists idx_recipe_sources_source_id
  on public.recipe_sources (source_id);

create index if not exists idx_recipe_tags_tag_id
  on public.recipe_tags (tag_id);
```

# CONFIRMED_SEEDS

### Approved production values

`No production seed values confirmed.`

All ten lookup tables currently contain zero rows.

### Proposal-only values

No complete proposal set was found that was explicitly approved as the next production seed set.

### Examples mentioned in project materials

These are examples or discussion candidates only. They must not be converted into production seeds without a separate approval.

- `cuisine`: Slovenská, Talianska, Francúzska, Ázijská, Mexická, Maďarská, Indická
- `protein`: Kuracie, Hovädzie, Bravčové, Ryba, Vajce, Tofu, Bez mäsa
- `main_ingredient`: Šošovica, Tekvica, Mrkva, Zemiaky, Ryža
- `side_dish`: Ryža, Zemiaky, Cestoviny, Šalát, Pečivo
- `preparation_type`: Dusené, Pečené, Varené, Grilované, Wok, Sous vide, Slow cook
- `prep_method`: Marinovanie, Brine, Fermentácia, Nakladanie, Opekanie základu
- `meal_usage`: Jednorazové, Na viac dní, Meal prep, Vhodné zamraziť
- `recipe_status`: Chcem skúsiť, Varené, Obľúbené, Nikdy viac
- `source_types`: YouTube, Web, Kniha, Instagram, Vlastný recept, Rodinný recept
- `tags`: Comfort food, Rýchle, Zimné, Pikantné

Capitalization above follows the human-readable examples, not an approved normalization policy.


# UNKNOWN_OR_UNVERIFIED_ITEMS

1. **Original initial-schema SQL is unavailable in remote migration history.**  
   The first 15 public tables, their original indexes and `recipe_public_view` predate the four stored migrations. `CURRENT_SCHEMA_SQL` is therefore a catalog-derived current-state reconstruction, not invented historical migration evidence.

2. **Original object-creation chronology is unknown.**  
   Dependency-safe ordering in `CURRENT_SCHEMA_SQL` was chosen for reproducibility and is not asserted to be the original execution order.

3. **Historical REVOKE chronology is not fully inferable from current ACLs.**  
   PostgreSQL catalogs expose current privileges, not a complete history of every privilege removal. The ACL block reproduces the current effective state for `anon`, `authenticated` and `PUBLIC`. Exact REVOKE text is historical evidence only where present in the four stored migrations.

4. **`service_role`, object-owner and platform-admin ACLs are outside the requested ACL scope.**  
   They were not redacted into replacement values and were not modified. The current-state section focuses on `anon`, `authenticated` and `PUBLIC`.

5. **No project-owned sequences exist in `public` or `private`.**  
   UUID primary keys use `extensions.uuid_generate_v4()`, so there are no sequence grants or revokes to export.

6. **Required dependencies.**
   - Required extension: `uuid-ossp` version `1.1`, installed in schema `extensions`.
   - Required Supabase Auth objects: `auth.users`, `auth.uid()`.
   - PostgreSQL procedural language `plpgsql` is installed and is needed only to replay the stored `DO` block migration as written.
   - Also installed but not required by the current project schema: `pg_stat_statements 1.11`, `pgcrypto 1.3`, `supabase_vault 0.3.1`.

7. **No production seed values are confirmed.**  
   All named classifications in project materials are examples or discussion candidates until separately approved.

8. **No data-validation checks currently exist for** negative times, servings, difficulty, inbox status or confidence score. The only non-key CHECK in the current schema is `recipe_access_members_access_role_check`.

9. **`recipes.added_by_id` has no foreign key.**

10. **No user-defined triggers were found.**  
    In particular, `updated_at` is not automatically refreshed.

11. **All lookup tables were empty at snapshot time.**

12. **Secret redaction.**  
    No database password, JWT secret, connection string, project API key, access token or service-role key is included in this handoff.
