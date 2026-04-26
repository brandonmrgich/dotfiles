---
title: Migrate music-platform-monorepo to new plan execution system
created: 2026-04-26
status: open
tags: [migration, plan-executor, music-platform-monorepo]
project: music-platform-monorepo
---

# Idea: Migrate music-platform-monorepo .claude/ to new plan layout

## Motivation

User-wide skills (multi-plan state paths, worktree-orchestrator, doc-freshness, zoom integration) shipped in v1.9. The music-platform-monorepo project still uses the legacy single-file plan-state layout. Migration brings the project in sync.

No changelog migration needed — changelogs were never built in that repo (superseded by doc-freshness before creation).

## Sketch

Run from `music-platform-monorepo` root:

1. Inventory: `ls .claude/`, check `.gitignore` for plan refs
2. Create new directory: `mkdir -p .claude/plan-states`
3. Move existing state and log files (if present):
   ```bash
   mv .claude/plan-state.json .claude/plan-states/admin-form-overhaul.json
   mv .claude/plan-executor.log .claude/plan-states/admin-form-overhaul.log
   ```
4. Update `.gitignore`:
   - Remove: `.claude/plan-state.json`, `.claude/plan-executor.log`
   - Add: `.claude/plan-states/`, `.claude/plans/`, `.claude/plan-completion-report.md`
5. Update project `CLAUDE.md`:
   - Plan-state path → `.claude/plan-states/<plan-name>.json`
   - Add a "Worktrees" section pointing at `worktree-orchestrator`
   - Do NOT add a Changelogs section
6. Commit: `chore(claude): migrate plan state to plan-states/ layout`

## Open questions

- Another agent is doing work in this repo per the user's note. Wait until that work merges before starting this.
- Is `admin-form-overhaul` plan still active or completed? If active, don't migrate mid-flight.

## Promotion criteria

- Blocking agent's work merges
- Self-contained migration — could be a small (trivial) plan run in interactive mode
