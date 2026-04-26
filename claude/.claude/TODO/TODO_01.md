# Phase 2 — music-platform-monorepo .claude/ structure migration

The user-wide skills have already been updated (multi-plan state paths,
worktree-orchestrator, doc-freshness, zoom integration). This task migrates
the project-local `.claude/` structure in `music-platform-monorepo` to match.

**Run this from the music-platform-monorepo root.**

## Context

The plan-executor skill now expects:
- State at `.claude/plan-states/<plan-name>.json` (gitignored)
- Logs at `.claude/plan-states/<plan-name>.log` (gitignored)

The repo currently has the legacy single-file layout. This migration brings
it in sync. No changelog migration is needed — changelogs were never built
in this repo (superseded by doc-freshness before creation).

## Steps

1. Check what exists:
   ```bash
   ls .claude/
   cat .gitignore | grep -E 'claude|plan'
   ```

2. Create the new directory:
   ```bash
   mkdir -p .claude/plan-states
   ```

3. Move existing state and log files (if present):
   ```bash
   # Only if these exist — check first
   mv .claude/plan-state.json .claude/plan-states/admin-form-overhaul.json
   mv .claude/plan-executor.log .claude/plan-states/admin-form-overhaul.log
   ```

4. Update `.gitignore`:
   - REMOVE lines: `.claude/plan-state.json`, `.claude/plan-executor.log`
   - ADD line: `.claude/plan-states/`
   - VERIFY these are NOT gitignored (should be tracked): `.claude/plans/`, `.claude/skills/`

5. Update project `CLAUDE.md`:
   - Find any "Active execution plans" or plan-state path references → update
     to `.claude/plan-states/<plan-name>.json`
   - Add a "Worktrees" section: "Long-running plans run in a git worktree at
     `~/Development/music-platform-monorepo-worktrees/<plan-name>/` via the
     `worktree-orchestrator` skill."
   - Do NOT add a Changelogs section — use `doc-freshness` front-matter instead

6. Verify and commit:
   ```bash
   tree .claude
   cat .gitignore | grep -E 'claude|plan'
   git status
   git add .gitignore CLAUDE.md
   git commit -m "chore(claude): migrate plan state to plan-states/ layout"
   ```

## Stop conditions

Stop and ask if:
- `.claude/plan-state.json` shows an admin-form-overhaul plan currently
  in-progress — don't migrate mid-flight without confirming
- The `.gitignore` already has `.claude/plan-states/` — nothing to do
- `CLAUDE.md` doesn't have plan-state path references — skip step 5 path update
