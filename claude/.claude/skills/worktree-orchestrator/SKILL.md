---
name: "[HomebrewSkill] worktree-orchestrator"
description: "Manages git worktrees for concurrent agent work on long-running plans. Activates when a user wants to start, resume, list, or merge work from a plan-executor plan in isolation from the main working tree. Trigger phrases: 'start a worktree for', 'create a worktree', 'list active worktrees', 'merge the worktree for', 'switch to worktree', 'prepare worktree merge', 'clean up worktree'. Also activates when plan-executor is starting a non-trivial plan (>5 tasks) and no worktree exists for it yet. Manages creation, the registry at ~/.claude/worktree-registry.json, conflict detection, merge preparation (NEVER auto-merge), and post-merge cleanup."
triggers:
  - "start a worktree"
  - "create a worktree"
  - "list active worktrees"
  - "merge the worktree"
  - "prepare worktree merge"
  - "clean up worktree"
---

# worktree-orchestrator

Manages git worktrees for concurrent agent work on long-running plans. One worktree per plan. Registry at `~/.claude/worktree-registry.json`. Never auto-merges.

---

## Operating principles

1. **One plan = one worktree.** Enforced via registry. Refuse to create a second worktree for an active plan.
2. **No auto-merge.** Prepare the merge, summarize, present to the human. Human runs the actual merge command.
3. **No destructive operations.** Never `--force`, never interactive rebase, never delete branches without explicit confirmation.
4. **Worktrees are for plan-executed work.** Quick fixes and ad-hoc edits happen in the main working tree. Don't create a worktree for a 5-minute task.
5. **Registry is source of truth.** All worktrees created or acknowledged are recorded at `~/.claude/worktree-registry.json`.

---

## Registry format

```json
{
    "worktrees": [
        {
            "repo": "<repo-name>",
            "repo_path": "/absolute/path/to/repo",
            "plan": "<plan-name>",
            "worktree_path": "/absolute/path/to/<repo-name>-worktrees/<plan-name>",
            "branch": "agent/<plan-name>",
            "created": "<ISO 8601>",
            "status": "active"
        }
    ]
}
```

Status values: `active | merged | abandoned`. When registry doesn't exist, create it with an empty `worktrees` array.

---

## Workflows

### Start a new worktree for a plan

1. Verify plan exists at `.claude/plans/<plan-name>/MasterPlan.md`. If not, refuse.
2. Read registry. Reject if an `active` entry already exists for this (repo, plan) pair.
3. Compute paths:
   - Repo root via `git rev-parse --show-toplevel`
   - Repo name from basename of repo root
   - Worktree path: `<dirname-of-repo>/<repo-name>-worktrees/<plan-name>/`
   - Branch: `agent/<plan-name>`
4. Confirm with user before creating.
5. Run `git worktree add <worktree-path> -b <branch>`.
6. Update registry, status `active`.
7. Print absolute worktree path and `cd` hint. Remind: "Open Claude Code in that directory to begin plan execution."

### Resume / list

Read registry, list active worktrees. If user named a plan, return the worktree path and `cd` hint.

### List worktrees

Print table: `Plan | Repo | Branch | Status | Created`

### Prepare merge

1. Verify plan worktree is registered and active.
2. Verify working tree is clean (`git status --porcelain` empty). Refuse if not.
3. Read `.claude/plan-states/<plan-name>.json`. Warn if plan not marked completed, but allow user override.
4. Show commits: `git log <main-branch>..HEAD --oneline`
5. Show diff stat: `git diff --stat <main>..HEAD`
6. Print the merge command for the human:
   ```
   git checkout <main-branch>
   git merge --no-ff agent/<plan-name>
   ```
7. Print: "I'm not running this. After you've merged, run `worktree-orchestrator: cleanup <plan-name>` to remove the worktree."
8. **NEVER run the merge.**

### Cleanup after merge

1. Verify branch is merged: `git branch --merged <main>` includes `agent/<plan-name>`. Refuse if not.
2. Confirm with user.
3. `git worktree remove <worktree-path>` then `git branch -d agent/<plan-name>`.
4. Update registry: status `merged`, add `merged_at` timestamp. Keep entry for history.

### Abandon a worktree

1. Double-confirm (two prompts; second asks user to type the plan name).
2. `git worktree remove --force <worktree-path>` then `git branch -D agent/<plan-name>`.
3. Update registry: status `abandoned`, add `abandoned_at`.

---

## Conflict detection

Before starting a plan worktree, check registry for other active worktrees in the same repo. Read each active plan's MasterPlan.md to identify file scope overlap. If >30% file overlap with the new plan's scope, warn the user before creating. Best-effort heuristic only — plans can drift from stated scope.

---

## Integration with plan-executor

When plan-executor is about to start a non-trivial plan (>5 tasks), suggest: "This plan is non-trivial. Consider running it in a worktree for isolation — `worktree-orchestrator` can create one." Do not block plan-executor if user declines.

---

## Integration with zoom-in/zoom-out

When zoom-out produces a plan scaffold (`.claude/zoom-plan-<slug>.md`) and the user promotes it to a full plan, suggest: "This plan is ready for execution. `worktree-orchestrator` can create an isolated worktree for it."

---

## Diagnostic commands

- `git worktree list` — actual worktrees on disk
- `cat ~/.claude/worktree-registry.json` — registry state
- Reconcile drift: if registry says `active` but worktree directory is gone, mark `abandoned` and ask user what happened.

---

## What you must never do

- Auto-merge to any branch
- Force-push
- Interactive rebase
- Delete branches without explicit user confirmation (double confirmation for unmerged work)
- Operate on branches this skill didn't create
- Skip registry updates — every worktree change must be reflected
- Create a worktree when one already exists for the same (repo, plan) pair with status `active`
