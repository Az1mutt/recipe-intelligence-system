# Codex Task — Recipe Intelligence Database Baseline

## Required Repository Inputs

This task has two authoritative repository source files:

1. `docs/task-inputs/database-baseline/RECIPE_INTELLIGENCE_CURRENT_SCHEMA_SQL.sql`
2. `docs/task-inputs/database-baseline/RECIPE_INTELLIGENCE_READ_ONLY_TECHNICAL_HANDOFF.md`

If either repository source file is unavailable or unreadable, stop without changing the repository and report the missing input.

Use the SQL repository source file as the sole source for the current-state bootstrap SQL.  
Use the technical handoff as the sole source for remote migration evidence, live-state facts, RLS documentation, seed status, dependencies, and known unknowns.

Do not reconstruct security-sensitive SQL from memory or from migration names.

---

## Repository

Expected repository:

`Az1mutt/recipe-intelligence-system`

Execution environment:

This task is intended to run in Codex Cloud from the repository environment and source branch selected by the user. Codex Cloud may present the checked-out source commit on an isolated local branch named `work`, with no configured Git remote, no `origin/HEAD`, and no remote-tracking references. That is expected platform behavior and is not a prerequisite failure.

The user has selected repository `Az1mutt/recipe-intelligence-system` and source branch `docs/database-baseline` in the Codex Cloud composer. The platform-provided isolated `work` branch is the dedicated working branch for this run and satisfies the branching intent of `AGENTS.md`. Do not attempt to fetch, add a remote, switch branches, rename `work`, or contact GitHub from the terminal.

Before editing:

1. Confirm that the working tree is clean.
2. Confirm that root `AGENTS.md` exists and read it completely.
3. Confirm that both authoritative repository inputs listed above exist and are readable.
4. Confirm that this task prompt is present at `docs/tasks/CODEX_RECIPE_INTELLIGENCE_DATABASE_BASELINE_PROMPT.md`.
5. Record the current `HEAD` SHA for the final report.

Proceed when those repository-content checks pass. Absence of a Git remote, remote-tracking references, an authoritative default-branch reference, or a locally named `docs/database-baseline` branch must not stop the task in Codex Cloud.

Stop without changes only if the working tree is dirty before editing, `AGENTS.md` is missing, either authoritative input is missing or unreadable, or the checked-out contents materially contradict this task's verified starting state.

---

## Objective

Add a truthful, reproducible, documentation-first baseline of the database currently running in the Supabase project `Recipes_decision_system`, without connecting to or modifying that live project.

The result must:

- preserve the exact catalog-derived current schema snapshot,
- preserve the four exact remote migration records as historical evidence,
- document the current architecture and access model,
- explicitly distinguish the live remote database from the bootstrap of a new environment,
- document that no production seeds are approved,
- prevent the baseline or historical migrations from being treated as active migrations for the existing remote project,
- avoid initializing Supabase CLI or creating an active migration stream in this task.

This is a repository and documentation task only.

---

## Mandatory Baseline Strategy

Implement exactly this strategy:

### 1. Immutable post-migration bootstrap snapshot

Store one complete current-state SQL snapshot under `database/bootstrap/`.

It represents the live database state after the four confirmed remote migrations.

It is intended only to bootstrap a brand-new, empty Supabase environment.

It is not an active migration and must never be applied to the existing live project.

### 2. Remote migration evidence kept outside the active migration path

Store the four confirmed remote migrations under `database/remote-history/`.

These files are historical evidence of SQL already applied remotely.

They are not steps to run after the bootstrap because their effects are already included in the bootstrap snapshot.

They must not be placed under `supabase/migrations/`, a root `migrations/` directory, or any location presented as automatically executable.

### 3. No active Supabase CLI setup in this task

Do not create:

- `supabase/config.toml`
- `supabase/migrations/`
- `supabase/seed.sql`
- project linkage files
- migration-repair commands
- remote database configuration

Do not run:

- `supabase link`
- `supabase db pull`
- `supabase db push`
- `supabase migration repair`
- `supabase db reset`
- any command that connects to the live Supabase project

### 4. Explicit environment distinction

Documentation must state:

#### Existing live remote project

Do not run:

- the bootstrap SQL,
- any historical migration file,
- schema creation SQL,
- seed SQL,
- migration-repair commands.

The live project is already at the documented state.

#### Brand-new Supabase environment

Apply the current-state bootstrap exactly once to a new, empty Supabase-provisioned database that already provides:

- `auth.users`
- `auth.uid()`
- roles `anon` and `authenticated`
- schemas `auth` and `extensions`

The bootstrap creates or verifies the required `uuid-ossp` extension and then creates the project-owned schema objects.

No seed step currently follows because no production seed values are confirmed.

#### Future changes

Future database changes must be represented as new forward-only migrations created after this baseline cutover.

The choice and initialization of the future active migration toolchain is explicitly outside this task.

---

## Verified Repository Starting State

Treat the following as the inspected repository state unless the checked-out Codex Cloud source commit proves otherwise:

- `README.md` is blank or effectively empty.
- `database/` exists only through `.gitkeep`.
- `docs/` exists only through `.gitkeep`.
- `backend/`, `frontend/`, and `assets/` are placeholders only.
- no tracked SQL exists,
- no Supabase CLI structure exists,
- no migrations or seeds exist,
- no `.gitignore` exists,
- no secrets were found in the inspected snapshot.

If the checked-out source commit differs, adapt only where necessary and report the difference. Do not overwrite valid newer documentation without reconciling it.

---

## Files to Create or Update

Create or update exactly the following logical artifacts. Reuse the existing `database/`, `docs/`, and `README.md` locations.

### 1. `.gitignore`

Create a minimal repository-level `.gitignore` that protects common secrets and generated files.

It must include at least:

```gitignore
.env
.env.*
!.env.example

*.pem
*.key
*.p12
*.pfx

supabase/.temp/

node_modules/
dist/
build/

.venv/
__pycache__/
*.py[cod]

.DS_Store
Thumbs.db
```

Do not create `.env.example` in this task.

### 2. `database/bootstrap/2026-08-03_current_schema.sql`

Copy the complete contents of the repository source file:

`docs/task-inputs/database-baseline/RECIPE_INTELLIGENCE_CURRENT_SCHEMA_SQL.sql`

The copied SQL must be byte-for-byte identical after normalizing only a final trailing newline.

Do not rewrite, simplify, reformat, reorder, or regenerate this SQL.

This file is the immutable current-state bootstrap snapshot.

### 3. `database/remote-history/20260803093134_secure_recipe_public_view_access.sql`

Create a file containing:

- a short SQL comment header stating that it is historical remote evidence and must not be executed against the existing remote project or replayed after the bootstrap,
- the exact stored SQL body from the matching section of the technical handoff.

Do not change the SQL statements.

### 4. `database/remote-history/20260803100626_implement_single_owner_reader_access_v1.sql`

Use the same rules:

- safety comment header,
- exact stored remote SQL body,
- no rewriting or simplification.

### 5. `database/remote-history/20260803100743_deny_direct_client_access_to_access_registry.sql`

Use the same rules.

### 6. `database/remote-history/20260803103515_add_missing_foreign_key_indexes.sql`

Use the same rules.

Do not remove the twelve indexes merely because a performance advisor may classify them as unused while tables are empty.

### 7. `database/remote-history/README.md`

Document:

- that the four files are exact stored statements from `supabase_migrations.schema_migrations`,
- that they were already applied to the live project,
- that they are preserved as evidence rather than active migrations,
- that the bootstrap snapshot already contains their resulting state,
- that they must not be applied after the bootstrap,
- that they must never be placed into an active migration path without a separately reviewed migration-reconciliation plan.

Include a table with timestamp, migration name, purpose, and current repository path.

### 8. `database/seeds/README.md`

Document explicitly:

```text
No production seed values confirmed.
```

Also state:

- all ten lookup tables were empty at the snapshot time,
- proposal and example values from project discussions are not approved production seeds,
- no executable seed SQL is created in this task,
- future production seeds must be idempotent,
- future lookup inserts must avoid hardcoded foreign UUID dependencies,
- future matching must respect the case-insensitive unique indexes,
- example or test recipes must remain separate from production lookup seeds.

Do not create `seed.sql`.

Do not convert the example values from the handoff into inserts.

### 9. `database/README.md`

Create the main database entry point.

It must contain:

- artifact map,
- the mandatory baseline strategy,
- a prominent warning for the existing live project,
- brand-new environment bootstrap instructions,
- required Supabase dependencies,
- seed status,
- future migration policy,
- links to the detailed documentation.

Include a clearly marked command example for a brand-new environment only:

```bash
psql "$NEW_SUPABASE_DATABASE_URL" \
  --set ON_ERROR_STOP=1 \
  --file database/bootstrap/2026-08-03_current_schema.sql
```

The surrounding text must state that:

- `NEW_SUPABASE_DATABASE_URL` is supplied at runtime and never committed,
- the command is only for a new, empty Supabase environment,
- it must not target `Recipes_decision_system`,
- the command was not executed during this task.

Do not provide a real URL or credential.

### 10. `docs/database-architecture.md`

Document the current database architecture using only the supplied technical handoff and SQL.

Include:

- PostgreSQL 17.6 and Supabase context,
- 15 public tables,
- lookup tables,
- primary tables,
- bridge tables,
- `private.recipe_access_members`,
- `public.recipe_public_view`,
- foreign-key behavior,
- all twelve FK indexes,
- case-insensitive lookup-name indexes,
- known schema limitations.

Add a Mermaid ER diagram covering:

- all 15 public tables,
- `private.recipe_access_members`,
- the relation to `auth.users`,
- bridge-table relationships.

Do not draw `recipes.added_by_id` as a foreign key. Annotate that it currently has no confirmed FK.

Clearly state that:

- `recipe_inbox` is a future AI import staging area,
- it is not currently the manual recipe-entry path,
- all public tables were empty at the snapshot time,
- no user-defined triggers exist,
- `updated_at` is not automatically refreshed.

### 11. `docs/database-access-model.md`

Document the exact v1 authorization model:

- `anon`: no access,
- unassigned authenticated user: no access,
- active `reader`: read only,
- single active `owner`: read and write,
- all 15 public tables have RLS enabled,
- `FORCE ROW LEVEL SECURITY` is false,
- each public table has SELECT, INSERT, UPDATE, DELETE policies,
- total public-table policy count: 60,
- `private.recipe_access_members` has the restrictive `no direct client access` policy,
- helper functions are `SECURITY DEFINER`, `STABLE`, with empty `search_path`,
- `authenticated` has function execute permissions,
- `anon` and `PUBLIC` do not,
- authenticated table grants are constrained by RLS,
- the view is `security_invoker=true` and grants SELECT only to `authenticated`,
- the unique partial index allows at most one active owner.

Explain the distinction between SQL grants and effective access through RLS.

Do not simplify the helper functions or propose a different security model.

### 12. `docs/database-baseline-and-migrations.md`

Document:

- why the original initial-schema SQL is unavailable,
- why the bootstrap is a current-state reconstruction rather than invented history,
- the exact baseline cutover date,
- the four confirmed remote migrations,
- the mandatory strategy chosen in this task,
- the existing-live-project prohibition,
- the new-environment bootstrap sequence,
- why historical files are not active migrations,
- why no Supabase CLI structure is initialized,
- how future forward-only migrations should begin after the baseline,
- what must be reviewed before any future migration-history reconciliation.

Add a prominent warning block:

```text
Never run the bootstrap or the historical migration files against the existing Recipes_decision_system Supabase project.
```

State explicitly that this task does not alter or repair `supabase_migrations.schema_migrations`.

### 13. `docs/database-current-state.md`

Create a dated implementation checkpoint for `2026-08-03`.

Include:

#### Implemented

- 15 public tables,
- one private access registry,
- two private helper functions,
- RLS and access policies,
- secure view,
- FK constraints,
- twelve FK indexes,
- effective requested-role grants,
- required extension and dependencies.

#### Current data/platform state

- project status reported as active and healthy in the handoff,
- region `eu-central-1`,
- PostgreSQL 17.6,
- zero Auth users,
- zero Storage buckets,
- zero Edge Functions,
- all public tables empty,
- no confirmed production seeds.

#### Known limitations / backlog, not implemented

- first Auth user and owner assignment,
- automatic `updated_at`,
- conversion of application timestamps to `timestamptz`,
- validation constraints for times, servings, difficulty, inbox status and confidence,
- FK or alternative model for `recipes.added_by_id`,
- multi-user authorship and personal statuses,
- ingredient and step model,
- pantry and inventory,
- component and batch cooking,
- frontend,
- AI import agents.

Do not present these backlog items as implemented.

### 14. `README.md`

Replace the blank README with a concise project overview.

It must:

- use the project name `Recipe Intelligence System`,
- describe the current implementation as a Supabase/PostgreSQL database foundation,
- state that frontend and AI capabilities are planned, not implemented,
- summarize the database baseline and security model,
- link to:
  - `database/README.md`
  - `docs/database-architecture.md`
  - `docs/database-access-model.md`
  - `docs/database-baseline-and-migrations.md`
  - `docs/database-current-state.md`
- include a clear current-status section,
- include a short repository structure section,
- avoid claiming that sample data, production seeds, Auth users, frontend, backend API, or AI ingestion are complete.

Do not create additional frontend or backend files.

### 15. Placeholder cleanup

After real files are added:

- remove `database/.gitkeep` if it exists,
- remove `docs/.gitkeep` if it exists.

Do not remove:

- `backend/.gitkeep`
- `frontend/.gitkeep`
- `assets/.gitkeep`

Do not alter unrelated files.

---

## Implementation Requirements

1. Treat the attached current-schema SQL as an immutable source artifact.
2. Treat the four migration bodies in the handoff as exact remote evidence.
3. Preserve PostgreSQL object names exactly.
4. Preserve the `private` schema and security model exactly.
5. Preserve `security_invoker=true`.
6. Preserve all 60 public-table policies and the one restrictive private policy.
7. Preserve the twelve named FK indexes.
8. Preserve the `uuid-ossp` dependency and schema-qualified UUID function.
9. Do not add a foreign key to `recipes.added_by_id`.
10. Do not add triggers or new validation constraints.
11. Do not insert users, access members, lookup values, or recipes.
12. Do not normalize or rename tables, policies, indexes, functions, constraints, or columns.
13. Do not create pantry, ingredient, step, frontend, backend, or AI implementation.
14. Use clear English documentation and commit text.
15. Keep the change as one coherent database-baseline commit unless a technical limitation requires otherwise.

---

## Safety Constraints

Do not:

- connect to Supabase,
- use any project credential,
- execute SQL against any remote database,
- run migrations,
- initialize or link Supabase CLI,
- modify the live `Recipes_decision_system` project,
- create or edit Auth users,
- add an owner or reader,
- expose secrets,
- commit `.env` files,
- create a service-role key,
- invent missing historical SQL,
- treat proposal-only lookup values as approved seeds,
- put bootstrap or history SQL into an active migration path,
- modify RLS logic,
- remove indexes reported as unused,
- push directly to the default branch,
- merge the pull request.

If a source conflict is found between the SQL repository source file and the technical handoff:

1. stop the affected implementation,
2. do not guess,
3. report the exact conflict with file and section references.

---

## Validation

Perform only local, static repository validation.

### 1. Source integrity

Verify that:

`database/bootstrap/2026-08-03_current_schema.sql`

matches the repository SQL source file exactly after normalizing only the final trailing newline.

Report both SHA-256 hashes.

### 2. Baseline object checks

Using deterministic local text analysis, confirm the bootstrap includes:

- 15 `CREATE TABLE public...` definitions,
- 1 `CREATE TABLE private.recipe_access_members`,
- 2 private helper functions,
- 1 `public.recipe_public_view`,
- 16 RLS enable statements,
- 60 public-table policies,
- 1 restrictive private policy,
- all 12 required FK index names,
- `security_invoker = true`,
- the required grants and revokes.

Do not execute the SQL.

### 3. Remote-history checks

Verify that:

- all four expected migration files exist,
- each contains the correct timestamp and migration name,
- each SQL body matches its source block in the technical handoff,
- none is located under an active migration directory.

### 4. Seed checks

Verify that:

- no executable seed SQL was created,
- documentation says no production seeds are confirmed,
- proposal values were not converted into inserts.

### 5. Safety checks

Verify that:

- no `supabase/` directory was created,
- no `.env` or credential file is tracked,
- no connection string, service-role key, JWT secret, private key, password, or access token appears in the diff,
- no real Supabase project URL appears in new files,
- no command in documentation could reasonably be mistaken as safe for the existing live project without an adjacent warning.

Redact values if a suspicious match is found.

### 6. Repository checks

Run:

```bash
git diff --check
git status --short
```

Also verify Markdown links point to existing repository files.

Do not run SQL or remote integration tests.

### 7. Validation limitations

In the final report, explicitly state:

- SQL was statically inspected only,
- no database connection was made,
- no bootstrap was executed,
- no migration was executed,
- no remote project was changed.

---

## Acceptance Criteria

The task is complete only when:

- the exact current-state SQL is preserved as a bootstrap snapshot,
- all 15 public tables are represented,
- the private access registry is represented,
- both helper functions are represented,
- RLS, grants, the secure view, and all policies are represented,
- all 12 FK indexes are represented,
- all four confirmed remote migrations are stored as historical evidence,
- documentation clearly states that the bootstrap already includes those migrations' effects,
- documentation clearly separates the existing remote project from a new environment,
- no active migration path or Supabase CLI linkage is created,
- no production seed values are invented,
- README reflects the real current implementation,
- no secrets are committed,
- only relevant repository files are changed,
- one logical commit is created,
- a draft pull request is created,
- the pull request is not merged.

---

## Deliverables

Expected repository result:

```text
.gitignore
README.md

database/
├── README.md
├── bootstrap/
│   └── 2026-08-03_current_schema.sql
├── remote-history/
│   ├── README.md
│   ├── 20260803093134_secure_recipe_public_view_access.sql
│   ├── 20260803100626_implement_single_owner_reader_access_v1.sql
│   ├── 20260803100743_deny_direct_client_access_to_access_registry.sql
│   └── 20260803103515_add_missing_foreign_key_indexes.sql
└── seeds/
    └── README.md

docs/
├── database-architecture.md
├── database-access-model.md
├── database-baseline-and-migrations.md
└── database-current-state.md
```

The existing placeholder directories `backend/`, `frontend/`, and `assets/` must remain unchanged.

---

## Suggested Commit

Use one commit:

```text
Add reproducible Supabase database baseline
```

---

## Pull Request

After the repository changes and validations are complete, use the Codex Cloud pull-request integration available to the task to create a draft pull request targeting `main`. The lack of a configured Git remote in the terminal is expected and must not block this platform action.

Title:

```text
Add reproducible Supabase database baseline
```

The pull request body must summarize:

- the chosen bootstrap-snapshot strategy,
- the distinction between live remote and new environment,
- the four historical remote migration files,
- the lack of approved production seeds,
- documentation created,
- static validations performed,
- explicit confirmation that no Supabase connection or SQL execution occurred.

Do not merge the pull request.

---

## Final Report

Return:

1. confirmed Codex Cloud repository-content prerequisites and intended target branch `main`,
2. execution branch or isolated work-checkout name,
3. resulting commit SHA,
4. draft PR URL and number,
5. complete changed-file list,
6. SHA-256 comparison for the source and copied bootstrap SQL,
7. baseline object-count validation,
8. remote-history validation,
9. secret-scan result,
10. Markdown-link validation,
11. any differences found from the expected starting repository,
12. any source ambiguity or limitation,
13. explicit confirmation that:
    - no Supabase connection was made,
    - no SQL was executed,
    - no migration was run,
    - no live database object or data was changed,
    - no pull request was merged.
