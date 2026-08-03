# Seed status

**No production seed values confirmed.**

All ten lookup tables were empty at the 2026-08-03 snapshot time. Proposal and example values from project discussions are not approved production seeds and have not been converted into inserts. No executable seed SQL is created by this baseline.

Future production seeds must be idempotent. Lookup inserts must avoid hardcoded foreign UUID dependencies, and matching must respect the case-insensitive unique name indexes. Example or test recipes must remain separate from production lookup seeds.
