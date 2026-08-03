-- Historical remote migration evidence: 20260803103515 add_missing_foreign_key_indexes.
-- Already applied remotely; do not execute against the existing remote project.
-- Do not replay after the current-state bootstrap.

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
