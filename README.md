# Recipe Intelligence System

Recipe Intelligence System currently provides a Supabase/PostgreSQL database foundation for organizing recipes and their classifications. Frontend, backend API, and AI capabilities are planned and are not implemented.

## Current status

The implemented database baseline records 15 public tables, a private access registry, row-level security (RLS), a secure read view, and owner/reader authorization. It is a bootstrap snapshot for new environments plus historical evidence of four migrations already applied to the live project. There are no Auth users, sample data, or approved production seeds.

Start with the [database guide](database/README.md). Detailed references cover the [architecture](docs/database-architecture.md), [access model](docs/database-access-model.md), [baseline and migration policy](docs/database-baseline-and-migrations.md), and [dated current state](docs/database-current-state.md).

## Repository structure

- `database/bootstrap/`: immutable current-state bootstrap for a brand-new environment only.
- `database/remote-history/`: non-executable evidence of remote migrations already applied.
- `database/seeds/`: seed status and future requirements; no executable seed exists.
- `docs/`: detailed database documentation and task source material.
- `backend/`, `frontend/`, `assets/`: placeholders for planned work.
