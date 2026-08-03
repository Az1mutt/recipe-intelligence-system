# Database architecture

## Platform and scope

The 2026-08-03 current-state snapshot describes a Supabase project on PostgreSQL 17.6. The project owns 15 tables in `public`, the `private.recipe_access_members` registry, two private authorization helpers, and `public.recipe_public_view`. All public tables were empty at snapshot time.

## Tables and relationships

Ten lookup tables are `cuisine`, `protein`, `main_ingredient`, `side_dish`, `preparation_type`, `prep_method`, `meal_usage`, `recipe_status`, `source_types`, and `tags`. Case-insensitive unique indexes on `lower(name)` protect their names (`tags` also retains its original case-sensitive unique constraint).

Primary tables are `recipes`, `sources`, and `recipe_inbox`; bridge tables are `recipe_sources` and `recipe_tags`. `recipe_inbox` is a **future AI import staging area**, not the current manual recipe-entry path. The private access registry references `auth.users` with `ON DELETE CASCADE` and permits at most one active owner.

Foreign keys use `NO ACTION` for update and delete unless noted: bridge references use `ON DELETE CASCADE`, as does the access registry's user reference. `recipes.added_by_id` has no confirmed foreign key and is intentionally shown as an unlinked attribute.

```mermaid
erDiagram
    AUTH_USERS ||--o| RECIPE_ACCESS_MEMBERS : "user_id (delete cascade)"
    RECIPE_STATUS ||--o{ RECIPES : status_id
    CUISINE ||--o{ RECIPES : cuisine_id
    PROTEIN ||--o{ RECIPES : protein_id
    MAIN_INGREDIENT ||--o{ RECIPES : main_ingredient_id
    SIDE_DISH ||--o{ RECIPES : side_dish_id
    PREPARATION_TYPE ||--o{ RECIPES : preparation_type_id
    PREP_METHOD ||--o{ RECIPES : prep_method_id
    MEAL_USAGE ||--o{ RECIPES : meal_usage_id
    SOURCE_TYPES ||--o{ SOURCES : source_type_id
    SOURCE_TYPES ||--o{ RECIPE_INBOX : source_type_id
    RECIPES ||--o{ RECIPE_SOURCES : recipe_id
    SOURCES ||--o{ RECIPE_SOURCES : source_id
    RECIPES ||--o{ RECIPE_TAGS : recipe_id
    TAGS ||--o{ RECIPE_TAGS : tag_id

    AUTH_USERS { uuid id PK }
    RECIPE_ACCESS_MEMBERS { uuid user_id PK string access_role boolean is_active }
    CUISINE { uuid id PK text name }
    PROTEIN { uuid id PK text name }
    MAIN_INGREDIENT { uuid id PK text name }
    SIDE_DISH { uuid id PK text name }
    PREPARATION_TYPE { uuid id PK text name }
    PREP_METHOD { uuid id PK text name }
    MEAL_USAGE { uuid id PK text name }
    RECIPE_STATUS { uuid id PK text name }
    SOURCE_TYPES { uuid id PK text name }
    TAGS { uuid id PK text name }
    RECIPES { uuid id PK uuid added_by_id "no confirmed FK" }
    SOURCES { uuid id PK uuid source_type_id FK }
    RECIPE_INBOX { uuid id PK uuid source_type_id FK }
    RECIPE_SOURCES { uuid recipe_id PK_FK uuid source_id PK_FK }
    RECIPE_TAGS { uuid recipe_id PK_FK uuid tag_id PK_FK }
```

## Views, indexes, and dependencies

`public.recipe_public_view` joins recipes to eight classification lookups and uses `security_invoker=true`. The twelve FK indexes are:

- `idx_recipes_status_id`, `idx_recipes_cuisine_id`, `idx_recipes_protein_id`, `idx_recipes_main_ingredient_id`
- `idx_recipes_side_dish_id`, `idx_recipes_preparation_type_id`, `idx_recipes_prep_method_id`, `idx_recipes_meal_usage_id`
- `idx_sources_source_type_id`, `idx_recipe_inbox_source_type_id`, `idx_recipe_sources_source_id`, `idx_recipe_tags_tag_id`

The schema requires Supabase Auth (`auth.users`, `auth.uid()`), roles `anon` and `authenticated`, schemas `auth` and `extensions`, and the `uuid-ossp` extension with `extensions.uuid_generate_v4()`.

## Known schema limitations

There are no user-defined triggers, so `updated_at` is not automatically refreshed. Application timestamps use `timestamp without time zone` except access-registry timestamps. No validation checks cover negative times, servings, difficulty, inbox status, or confidence. The ingredient/step model, pantry/inventory, component/batch cooking, multi-user authorship and personal statuses, frontend, and AI import agents are not implemented.
