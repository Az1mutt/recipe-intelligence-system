# Recipe Intelligence System

Recipe Intelligence System is a personal recipe-intelligence data product built on Supabase/PostgreSQL. It stores dish classification, provenance, culinary concepts and relationships, learning/curation links, personal food preferences, and reviewed ingestion state for recipes discovered from web, video, and social sources.

The system is intentionally **not** a conventional full recipe database: `recipes` stores recipe identity and intelligence/classification, while source links preserve where the recipe came from. Canonical ingredient quantities and cooking steps are not modeled as first-class recipe tables at this stage.

## Current live status

Verified against the live Supabase project on **2026-09-10**:

- 33 public tables, all with RLS enabled
- 246 recipes and 142 sources
- 191 `recipe_inbox` items, 14 extracted candidates, and 17 evidence rows
- 52 culinary concepts and 24 culinary relationships
- 6 learning topics and 13 content collections
- personal preference modeling is active
- Supabase Security Advisor: 0 security lints

Ingestion contract v1 is implemented and has passed both single-source acceptance tests and a heterogeneous six-source batch covering direct recipe pages, exact-duplicate enrichment, meaningful variants, non-recipe content, partial YouTube resolution, external-reference fallback, and merge-to-existing-recipe behavior.

The operational flow is:

```text
source URL / video / article
-> recipe_inbox
-> resolver chain
-> recipe_inbox_evidence
-> recipe_candidates
-> objective validation
-> dedupe
-> personal preference evaluation
-> review policy
-> promotion / merge / rejection
-> recipes + sources + bridges + intelligence links
```

A standalone backend API, frontend, and autonomous bulk-ingestion service are still planned rather than implemented. Current ingestion is an operational workflow over the live database, not yet a packaged application service.

## Documentation

Start with:

- [Database architecture](docs/database-architecture.md)
- [Current live state](docs/database-current-state.md)
- [Ingestion contract v1](docs/ingestion-contract-v1.md)
- [Database access model](docs/database-access-model.md)
- [Historical baseline and migration policy](docs/database-baseline-and-migrations.md)

The 2026-08-03 SQL bootstrap under `database/bootstrap/` is an immutable **historical baseline**, not a representation of the current 33-table live schema. Do not replay it against the existing Supabase project.

## Repository structure

- `.project/`: Project OS state and workstream metadata.
- `database/bootstrap/`: immutable 2026-08-03 historical bootstrap for a brand-new empty environment only.
- `database/remote-history/`: evidence of remote migrations that predate the current live architecture.
- `database/seeds/`: seed policy/status; the live project now contains approved lookup values, but a current executable seed package is not yet maintained here.
- `docs/`: current architecture, access, ingestion, state, and historical-baseline documentation.
- `backend/`, `frontend/`, `assets/`: placeholders for future packaged application work.
