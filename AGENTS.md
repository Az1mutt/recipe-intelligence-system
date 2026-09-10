# AGENTS.md

## Repository Purpose

This repository contains the Recipe Intelligence System, a personal data product built around PostgreSQL and Supabase, with planned frontend and AI capabilities.

## Instruction Refresh

Before any task that will write to GitHub, read the current `AGENTS.md` from the repository default branch. Do not rely on an older chat copy of these rules when the repository version is available.

## Working Rules

- Read the existing repository documentation before making changes.
- Treat the current implementation as the source of truth.
- Never describe planned functionality as already implemented.
- Prefer small, focused changes.
- Preserve existing architectural decisions unless explicitly asked to revise them.
- Do not add secrets, credentials, API keys, private URLs, or personal data.
- Do not delete files unless explicitly requested or clearly required by an already approved change.
- Use clear English commit messages.
- For documentation changes, keep README concise and place detailed information under docs/.

## Git Workflow

Use a risk-based workflow. A branch is a safety tool, not a mandatory ceremony.

### Routine Sync Lane — direct to `main` allowed

A change may be committed directly to the default branch when it is a small, deterministic, easily reversible synchronization of already verified reality, for example:

- updating this workstream's owned `.project/...yaml` state after a meaningful verified milestone;
- updating status/current-state/roadmap documentation to match already verified implementation;
- correcting small documentation errors, broken links, wording, or metadata;
- other low-risk documentation-only synchronization that does not change system behavior.

Routine Sync Lane must not be used for code behavior changes, database schema/migrations, RLS/security changes, Supabase configuration, new integrations, dependency changes, destructive operations, major architecture decisions, or ambiguous changes.

### Change / Review Lane — branch + PR required

Use a dedicated branch and pull request for changes with meaningful implementation or review risk, including:

- application or ingestion code changes;
- SQL schema changes and migrations;
- RLS, permissions, security, credentials handling, or external integrations;
- dependency/tooling changes;
- major architectural or data-model decisions;
- deletes/renames or broad refactors;
- any change whose correctness or scope is uncertain.

Keep unrelated changes out of the branch. Run applicable checks before merge.

### Branch lifecycle ownership

If you create a branch, you own its lifecycle.

- If Igor has already approved the intended change, do not ask for a second approval merely to merge the resulting PR.
- After applicable checks pass and the implemented scope still matches the approved change, merge the PR as part of completing the task.
- Prefer squash merge unless the repository/task has a reason to preserve individual commits.
- Delete the merged branch when the available GitHub tooling supports branch deletion.
- If branch deletion is unavailable, explicitly report the leftover merged branch instead of silently leaving cleanup to Igor.
- Do not merge if checks fail, the scope materially changed, or new consequential risk appeared; surface that instead.
- Use draft PRs only for genuinely unfinished work, not by default.

## Project State Rules

For multi-workstream Project OS usage, write only the state file assigned to this workstream. Do not overwrite a root project rollup owned by Project OS/Core.

Meaningful verified milestones should synchronize the owned Project State as part of milestone closure. Ordinary discussion, brainstorming, and failed experiments that do not change verified reality do not require a state write.

## Project Status Rules

Clearly distinguish between:

- implemented,
- in progress,
- planned,
- backlog.

Never present future architecture as completed functionality.
