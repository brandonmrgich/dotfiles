---
name: "[HomebrewSkill] worktree-orchestrator"
class: workflow
description: "Use when the user says 'start a worktree for', 'create a worktree', 'list active worktrees', 'merge the worktree for', 'switch to worktree', 'prepare worktree merge', or 'clean up worktree'. Also activates when plan-executor is starting a non-trivial plan (>5 tasks) and no worktree exists for it yet. Covers concurrent agent work on long-running plans, the registry at ~/.claude/worktree-registry.json, conflict detection, merge preparation (NEVER auto-merge), and post-merge cleanup."
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

1. **One plan = one worktree.** Registry-enforced. Refuse a second worktree for an active plan.
2. **No auto-merge.** Prepare, summarize, present. Human runs the merge.
3. **No destructive ops.** Never `--force`, never interactive rebase, never delete branches without explicit confirmation.
4. **Worktrees are for plan-executed work.** Quick fixes happen in main tree. Don't worktree a 5-minute task.
5. **Registry is source of truth.** Every worktree change is recorded.

---

## Registry format

```json
{
  "worktrees": [
    {
      "repo": "<repo-name>",
      "repo_path": "/abs/path/to/repo",
      "plan": "<plan-name>",
      "worktree_path": "/abs/path/to/<repo-name>-worktrees/<plan-name>",
      "branch": "agent/<plan-name>",
      "created": "<ISO 8601>",
      "status": "active"
    }
  ]
}
```

Status: `active | merged | abandoned`. Create with empty `worktrees` array if absent.

---

## Workflows

### Start a new worktree

1. Verify `.claude/plans/<plan-name>/MasterPlan.md` exists; refuse if not.
2. Reject if registry has an `active` entry for this (repo, plan).
3. Compute paths: repo root via `git rev-parse --show-toplevel`; worktree at `<dirname-of-repo>/<repo-name>-worktrees/<plan-name>/`; branch `agent/<plan-name>`.
4. Confirm with user.
5. `git worktree add <worktree-path> -b <branch>`.
6. Update registry to `active`.
7. Print absolute path + `cd` hint: "Open Claude Code there to begin plan execution."

### Resume / list

Read registry, list active worktrees. If user named a plan, return its path + `cd` hint.

### List worktrees

Print: `Plan | Repo | Branch | Status | Created`

### Prepare merge

1. Verify worktree is registered + active.
2. Verify clean tree (`git status --porcelain` empty); refuse if not.
3. Read `.claude/plan-states/<plan-name>.json`. Warn if not completed; allow override.
4. Show `git log <main>..HEAD --oneline` and `git diff --stat <main>..HEAD`.
5. Print the merge command for the human:
   ```
   git checkout <main>
   git merge --no-ff agent/<plan-name>
   ```
6. Print: "I'm not running this. After merging, run `worktree-orchestrator: cleanup <plan-name>`."
7. **NEVER run the merge.**

### Cleanup after merge

1. Verify branch merged: `git branch --merged <main>` includes `agent/<plan-name>`. Refuse if not.
2. Confirm with user.
3. `git worktree remove <worktree-path>` then `git branch -d agent/<plan-name>`.
4. Registry: status `merged`, add `merged_at`. Keep entry for history.

### Abandon

1. Double-confirm (second prompt asks user to type the plan name).
2. `git worktree remove --force <worktree-path>` then `git branch -D agent/<plan-name>`.
3. Registry: status `abandoned`, add `abandoned_at`.

---

## Conflict detection

Before starting, check registry for other active worktrees in the same repo. Read each plan's MasterPlan to identify file-scope overlap. If >30% overlap, warn before creating. Best-effort heuristic — plans drift.

---

## Integration

- **plan-executor.** When a plan has >5 tasks, suggest: "Consider running it in a worktree — `worktree-orchestrator` can create one." Don't block if declined.
- **zoom-in/zoom-out.** When zoom-out promotes a scaffold (`.claude/zoom-plan-<slug>.md`) to a plan, suggest creating an isolated worktree.

---

## Diagnostics

- `git worktree list` — actual worktrees on disk
- `cat ~/.claude/worktree-registry.json` — registry state
- Drift: registry says `active` but directory gone → mark `abandoned`, ask user.

---

## What you must never do

- Auto-merge to any branch
- Force-push or interactive rebase
- Delete branches without explicit confirmation (double-confirm unmerged)
- Operate on branches this skill didn't create
- Skip registry updates
- Create a second active worktree for the same (repo, plan)
