# AGENTS.md

## Repository Purpose

This repository contains the Recipe Intelligence System, a personal data product built around PostgreSQL and Supabase, with planned frontend and AI capabilities.

## Instruction Refresh

Before any task that will write to GitHub, read the current `AGENTS.md` from the repository default branch. Do not rely on an older chat copy of these rules when the repository version is available.

## Token and Context Efficiency

Optimize for useful verified work per token. Do not trade away correctness, safety, or required freshness.

- Reuse verified durable state/evidence when still sufficient; do not re-check the same stable fact by default.
- Re-verify only when freshness matters, evidence conflicts, state is stale/unknown, the action is high-risk, implementation may have changed, or Igor asks.
- Avoid duplicate documentation; update the authoritative artifact instead of creating near-copies.
- Prefer concise deltas, exact next actions, and links/references over repeating full history.
- Retrieve narrowly and avoid repeated full-file reads or broad scans when a known range/result is enough.
- Stop research once evidence is sufficient; add more only when it materially improves confidence or coverage.
- Prefer deterministic reusable operations, cached/structured artifacts, and existing Skills where they safely reduce repeated LLM work.

If extra retrieval, verification, or documentation will not materially change the answer, reduce meaningful risk, or create reusable value, skip it.

## Temporal context awareness

When reusing older conversation context, Project State, notes, tool output, or prior plans, account for elapsed time instead of treating every past statement as current.

- Treat time-bound or ephemeral state as potentially stale: today's meal, current pantry/fridge contents, open food or drink, current plans, in-progress tasks, mood, weather, temporary availability, live service status, and similar "now" facts.
- Compare timestamps and relative wording such as `today`, `tomorrow`, `current`, and `now`. Do not silently carry a temporary state forward just because it appears in context.
- Durable facts and decisions may be reused until superseded. Ephemeral facts should be refreshed, qualified as last-known, or re-confirmed when currentness materially affects correctness.
- Prefer wording such as `last known on <date>` when useful rather than presenting stale state as present reality.
- Do not create granular memory, logging, or documentation solely to implement this rule. This is primarily an interpretation rule, not a requirement to store every transient event.

This policy applies across chats, agents, Project State reading, research, planning, and operations.

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
