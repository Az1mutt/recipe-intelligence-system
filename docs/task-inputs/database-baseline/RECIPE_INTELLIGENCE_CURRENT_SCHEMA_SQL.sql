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
