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

---

## State file schema

The orchestrator persists per-plan execution state to
`.claude/plan-states/<plan-name>.json` so a new session can resume
exactly where the previous one stopped. The plan name derives from
the plan directory name (see § Layout above).

```json
{
    "master_plan_path": "apps/admin/docs/refactor/MasterPlan.md",
    "tasks_dir": "apps/admin/docs/refactor/tasks",
    "branch": "refactor/forms-v2",
    "started_at": "2026-04-25T18:30:00Z",
    "artifacts_generated_by_orchestrator": false,
    "cleanup_status": "not_offered",
    "tasks": [
        {
            "id": "00-discovery",
            "file": "00-discovery.md",
            "status": "complete",
            "subagent_type": "discovery",
            "started_at": "...",
            "completed_at": "...",
            "commit_sha": "abc1234",
            "summary": "Inventory complete. 7 forms found, 4 mutation hooks orphaned.",
            "audit_status": "not_run"
        },
        {
            "id": "01-form-state-machine",
            "file": "01-form-state-machine.md",
            "status": "in_progress",
            "subagent_type": "implementer",
            "started_at": "..."
        }
    ],
    "current_task_index": 1,
    "halt_reason": null
}
```

Field semantics:

- `master_plan_path`, `tasks_dir`, `branch` — what the plan
  operates on. Captured at Phase 0 init.
- `started_at` — ISO timestamp; first dispatch.
- `artifacts_generated_by_orchestrator` — `true` only when the
  orchestrator generated the plan/tasks itself in Mode B (see
  `~/.claude/references/plan-generation.md` § Step 6). Gates
  whether Phase 5 cleanup may remove the plan/tasks.
- `cleanup_status` — `not_offered | offered | done | declined`.
- `tasks[]` — one entry per task file, ordered by filename.
- `current_task_index` — zero-based index into `tasks[]`.
- `halt_reason` — populated when execution stops on non-trivial
  failure; null otherwise.

### Status taxonomies

Per-task `status`:

- `pending` — not yet dispatched.
- `in_progress` — dispatched, sub-agent has not returned.
- `complete` — sub-agent returned success, deliverables verified.
- `failed` — sub-agent returned failure or did not produce deliverables.
- `skipped` — user chose to skip this task explicitly.

Per-task `audit_status`:

- `not_run` — plan-auditor has not been invoked on this task.
- `pass` — auditor verdict PASS.
- `conditional_pass` — auditor verdict PASS with caveats.
- `fail` — auditor verdict FAIL.
- `escalated` — auditor refused to verdict; surfaced for user decision.

### Per-plan log

Alongside the JSON, the orchestrator maintains
`.claude/plan-states/<plan-name>.log` — append-only, one line per
significant event (dispatch, return, failure, audit, halt). The log
is debug-grade, not authoritative; the JSON state file is the source
of truth.
