# Plan System Reference

Single source of truth for filesystem layout, gitignore rules, multi-plan conventions,
and worktree interaction. Skills and agents cite this; they do not restate it.

---

## Layout

```
<project-root>/
  .claude/
    plans/
      <plan-name>/
        MasterPlan.md          ← plan inputs (user-authored or orchestrator-generated)
        tasks/
          00-discovery.md
          01-foo.md
          ...
        audits/
          00-discovery-audit.md
          ...
    plan-states/
      <plan-name>.json         ← runtime state (orchestrator-maintained)
      <plan-name>.log          ← append-only event log
    plan-completion-report.md  ← written at plan completion; offered for cleanup
    settings.local.json        ← machine-local overrides; never commit
```

Plan name derives from the plan directory name:
`.claude/plans/admin-form-overhaul/` → plan name `admin-form-overhaul`
→ state file `.claude/plan-states/admin-form-overhaul.json`

---

## Gitignore rules

| Path | Rule | Rationale |
|---|---|---|
| `.claude/plan-states/` | Always ignore | Runtime state; machine-local; not reproducible from source |
| `.claude/plan-completion-report.md` | Always ignore | Transient artifact; outcome lives in git history |
| `.claude/settings.local.json` | Always ignore | Machine-local overrides; secrets risk |
| `.claude/plans/` | Dotfiles: always ignore. Project repos: track. | Dotfiles has no plans to run; project plans are source input |

Old paths (pre-multi-plan) no longer used:
- `.claude/plan-state.json` → replaced by `.claude/plan-states/<name>.json`
- `.claude/plan-executor.log` → replaced by `.claude/plan-states/<name>.log`
- `.claude/plan-artifacts/` → no longer in use

---

## Multi-plan support

Each active plan has its own state file under `.claude/plan-states/`. Plans are
independent — multiple can be active simultaneously in the same project. The plan
name (derived from directory name) is the key.

When resuming without a plan name: list all non-completed JSON files in
`.claude/plan-states/` and ask the user which to resume.

---

## Worktree interaction

- Plan dirs (`.claude/plans/<name>/`) live in the main repo, not in worktrees.
  Worktrees share the same `.git` and can read them.
- State files live at `.claude/plan-states/<name>.json` in the worktree's working tree
  (same structure, isolated per worktree).
- Worktree branch naming: `agent/<plan-name>`.
- Worktree path: `<dirname-of-repo>/<repo-name>-worktrees/<plan-name>/`.
- Registry: `~/.claude/worktree-registry.json` — source of truth for active worktrees.
  Always ignored (machine-local).

---

## Project vs dotfiles context

**Dotfiles repo** (`~/dotfiles`): ignore both `.claude/plans/` and `.claude/plan-states/`.
No plans are executed from the dotfiles repo itself.

**Single-project repo**: track `.claude/plans/` (plan inputs are part of project history).
Ignore `.claude/plan-states/`.

**Monorepo**: same as single-project at the root. Per-package `.gitignore` only for
package-specific artifacts.
