# Database current state — 2026-08-03

## Implemented

- 15 public tables and one private access registry.
- Two private helper functions, RLS and access policies, and a secure invoker view.
- Foreign-key constraints and twelve supporting FK indexes.
- Effective requested-role grants for `PUBLIC`, `anon`, and `authenticated`.
- The `uuid-ossp` extension dependency plus Supabase Auth objects and roles.

## Current data and platform state

The handoff reports the project as active and healthy in `eu-central-1` on PostgreSQL 17.6. It reports zero Auth users, zero Storage buckets, and zero Edge Functions. All public tables—including all ten lookup tables—were empty, and no production seeds are confirmed.

## Known limitations and backlog — not implemented

- Create the first Auth user and assign the owner administratively.
- Automatically maintain `updated_at`.
- Convert application timestamps to `timestamptz`.
- Add validation for times, servings, difficulty, inbox status, and confidence.
- Add a foreign key or alternative model for `recipes.added_by_id`.
- Support multi-user authorship and personal statuses.
- Add ingredient and step models, pantry and inventory, and component and batch cooking.
- Build the frontend.
- Build AI import agents.

These items are backlog, not current functionality.
