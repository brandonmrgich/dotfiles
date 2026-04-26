---
title: GitHub Projects integration for plan-executor
created: 2026-04-26
status: open
tags: [tooling, plan-executor, kanban, gh-cli]
project: dotfiles
---

# Idea: GitHub Projects integration for plan-executor

## Motivation

The plan execution system tracks tasks per-project via state JSON files and the worktree registry. None of that surfaces visually as kanban — there's no "what's in flight, what's done, what's blocked" view across plans.

GitHub Projects V2 fits because:

- `gh` CLI already integrated and authenticated
- Free for personal use, no scale limits at solo level
- Native to the repos where work actually happens
- Can be linked to PRs/issues automatically (closes-keyword, etc.)
- Kanban primitives (Backlog / In Progress / Audit / In Review / Done / Halted) map cleanly onto plan-executor phases

## Sketch

Plan-executor (and worktree-orchestrator where appropriate) sync plan/task state into a GitHub Projects V2 board:

- Each plan = a Project board (or epic on a long-lived board — TBD)
- Each task = an Issue in the linked repo
- Issues move across columns as plan-executor advances phases:
  - Phase 0 init → `Backlog`
  - Phase 2 dispatch → `In Progress`
  - Phase 3 collect → `Done` if outcome is success
  - Phase 4 audit → epic to `Audit`; on `fail`, re-queue affected tasks to `In Progress`
  - Phase 5 PR handoff → epic to `In Review`, link PR to board
  - Phase 6 cleanup → epic to `Done`
  - Halt states → epic to `Halted`
- Audit verdicts surface as labels or comments

Configuration: add a `github_project` field to plan-state JSON (project ID, repo, board ID). Optional per-plan; falls back to no-sync if missing.

Failure mode: if `gh project` calls fail (auth, network), log and continue. Sync is best-effort — never blocks plan execution.

## Open questions

- Does `gh project` CLI expose enough primitives, or does this need GraphQL?
- One project board per plan, or shared long-lived board with epics?
- Sync gating: only for `complexity == non-trivial`? Otherwise spam risk across many small plans.
- Worktree-orchestrator integration: post Project URL into PR body alongside audit verdict?

## Promotion criteria

- After `plan-execution-overhaul` lands (provides the integration points)
- Reference Project V2 board manually set up on the dotfiles repo for testing
- Quick spike to confirm `gh project` capabilities before plan generation
- Confirm a more polished off-the-shelf option (Linear MCP, etc.) hasn't become the better choice in the meantime
