# Seed status

The live Supabase project now contains approved production lookup/taxonomy values. This replaces the original 2026-08-03 state in which all lookup tables were empty.

## Current live policy

Lookup vocabularies evolve deliberately as real recipe data exposes missing values. Examples include cuisine, protein, main ingredient, preparation type, meal usage, dish type, tags, and source types. New values should be added only when they represent a stable reusable category rather than one-off provenance or arbitrary recipe text.

Important modeling rules:

- `protein` is a coarse dominant protein category; keep the known species/type when available.
- `main_ingredient` is a practical pantry/menu-planning dimension.
- specific ingredient detail such as `Italian Sausage`, `Mleté mäso`, or future `Guanciale` belongs in culinary concepts when useful for retrieval rather than expanding tags indiscriminately.
- tags describe dish properties, not creator/source provenance.

## Repository status

There is currently **no complete executable seed package in this repository that reproduces the live lookup state**. The historical 2026-08-03 bootstrap remains unseeded by design and must not be retroactively rewritten to imply later seed values existed at that cutover.

When a reproducible current environment is needed, create an idempotent current seed package alongside a reviewed current migration/bootstrap path. Lookup inserts should avoid hardcoded foreign UUID dependencies and respect case-insensitive name uniqueness. Example/test recipes must remain separate from production lookup seeds.
