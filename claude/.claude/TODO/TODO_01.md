> **STATUS (2026-04-26):** Partially superseded. See master plan at
> `~/dotfiles/.claude/plans/skills-worktree-overhaul/MasterPlan.md`.
>
> **Changelog work is CANCELLED** — the changelog mechanism (Phase 1
> "Changelog appending" section, Phase 2 steps 4–5, Phase 2 step 7
> "Changelogs" section) was superseded by the doc-freshness front-matter
> approach (see TODO_03, now executed). Do not implement any changelog steps.
>
> **Completed by this plan:**
> - Phase 1: plan-executor updated (multi-plan state paths, removed changelog,
>   added multi-plan awareness)
> - Phase 3: worktree-orchestrator skill created
> - Phase 4: zoom-in/zoom-out integration added
>
> **Still outstanding (not in this plan):**
> - Phase 2: music-platform-monorepo project structure migration
>   (.claude/plan-states/ dir, .gitignore update, CLAUDE.md update for that repo)
> - Phase 5 commit: belongs in music-platform-monorepo, not here

I'm restructuring how plans, plan state, changelogs, and worktrees are
organized. This is a multi-skill update plus a project migration plus a
new user-wide skill. Execute in phases. Stop and ask at each phase
boundary.

## Context — read first

Read these to understand the current state:

1. `~/.claude/skills/plan-executor/SKILL.md`
2. `~/.claude/skills/plan-auditor/SKILL.md`
3. `~/.claude/skills/plan-executor-discovery/SKILL.md`
4. `~/.claude/skills/plan-executor-implementer/SKILL.md`
5. `~/.claude/skills/plan-executor-tester/SKILL.md`
6. `~/.claude/skills/plan-executor-documenter/SKILL.md`
7. The current project `.claude/` directory layout (`tree .claude`)
8. The current `.gitignore` (Claude-related lines)
9. The project `CLAUDE.md`

Also surface:

10. **Do I have a "zoom-in" or "zoom-out" skill installed user-wide?**
    Look in `~/.claude/skills/` for any skill with those names or
    related concepts (focus narrowing, scope expansion, planning
    triggers). If yes, read it — its behavior intersects with this
    redesign. Print its current trigger conditions before proceeding.

After reading, print a summary of what you found and stop. Do not
proceed to Phase 1 until I confirm.

## Decisions already made (do not re-litigate)

- **Plan state location:** `.claude/plan-states/<plan-name>.json` and
  `.claude/plan-states/<plan-name>.log` — gitignored. One file per plan.
- **Plans directory:** `.claude/plans/<plan-name>/` — tracked. Each plan
  has its own folder with MasterPlan.md and tasks/.
- **Changelogs:** `.claude/changelogs/<YYYY-MM>.md` — tracked. Monthly
  rotation. Skill appends to current month's file, creating it if
  needed.
- **Worktree location:** sibling of the repo at
  `<parent>/<repo-name>-worktrees/<plan-name>/`. So for this repo:
  `~/Development/music-platform-monorepo-worktrees/<plan-name>/`.
- **One plan = one worktree.** Invariant. Enforced by skill.
- **Worktrees are for plan-executed work only.** Manual/exploratory
  work happens in the main repo working tree.
- **Worktree registry:** `~/.claude/worktree-registry.json` — single
  source of truth for which plans are active in which worktrees,
  across all repos.
- **Plan state is per-worktree.** Each worktree has its own
  `.claude/plan-states/`. The registry prevents two worktrees from
  working on the same plan.
- **No auto-merge.** The skill prepares merges; the human approves.
- **No force-push, no interactive rebase, no destructive history ops.**

## Phase 1 — Update existing skills

Update these user-wide skills to use the new state and changelog paths:

### plan-executor

Find every reference to:

- `.claude/plan-state.json` → change to `.claude/plan-states/<plan-name>.json`
- `.claude/plan-executor.log` → change to `.claude/plan-states/<plan-name>.log`
- `.claude/changelog.md` → change to `.claude/changelogs/<YYYY-MM>.md`,
  with the skill computing current YYYY-MM at write time and creating
  the file if it doesn't exist

Add to the skill body, in a new "Multi-plan awareness" section:

```
## Multi-plan awareness

Multiple plans may exist in the same project simultaneously. Each plan
has its own state file at `.claude/plan-states/<plan-name>.json`. The
plan name is derived from the plan directory name (e.g.,
`.claude/plans/admin-form-overhaul/` → state at
`.claude/plan-states/admin-form-overhaul.json`).

When asked to "resume the plan" without a name, list all active plan
states (any non-completed JSON in `.claude/plan-states/`) and ask the
user which to resume. Never assume.

When starting a new plan, refuse if a worktree-registry entry exists
indicating the plan is already active in another worktree (see the
worktree-orchestrator skill). The user must explicitly close or move
the other instance first.
```

Also add a "Changelog appending" section:

```
## Appending to the changelog

After any successful task completion, append one line to the current
month's changelog file. The path is `.claude/changelogs/<YYYY-MM>.md`
where YYYY-MM is the current ISO year-month at write time.

If the file doesn't exist, create it with this header:

```

# Changelog — <YYYY-MM>

Format: `<ISO date> | <files changed (or "plan: <name>")> | <what changed>`

```

Then append the entry. Don't backfill missing months — only write to
current.

A new changelog month does NOT trigger any rotation logic; the skill
just writes to the right file based on date.
```

### plan-auditor

Same path updates as plan-executor (state file at new path, log file
at new path).

### plan-executor-discovery, -implementer, -tester, -documenter

Same path updates. These are sub-skills dispatched by plan-executor;
they need to know where to read state and where to write logs.

After updating each file, print a brief diff summary showing what
changed (line numbers + before/after). Stop and wait for approval
before moving to Phase 2.

## Phase 2 — Migrate this project's existing structure

### Current state to migrate

The project currently has:

- `.claude/plan-state.json` — single state file, tied to admin-form-overhaul
- `.claude/plan-executor.log` — single log file
- `.claude/changelog.md` — flat changelog
- `.claude/plans/admin-form-overhaul/` — plan and tasks (assumed in
  current location after earlier reorganization)

### Target state

- `.claude/plan-states/admin-form-overhaul.json` (gitignored)
- `.claude/plan-states/admin-form-overhaul.log` (gitignored)
- `.claude/plans/admin-form-overhaul/` (unchanged, still tracked)
- `.claude/changelogs/<YYYY-MM>.md` for each month present in the
  current flat changelog (tracked)
- The flat `.claude/changelog.md` deleted after migration

### Steps

1. Create `.claude/plan-states/` directory.
2. Move `.claude/plan-state.json` → `.claude/plan-states/admin-form-overhaul.json`.
   Use `git mv` if it's tracked; otherwise just `mv`.
3. Move `.claude/plan-executor.log` → `.claude/plan-states/admin-form-overhaul.log`.
4. Read `.claude/changelog.md`. Parse entries (format:
   `<date> | <files> | <what>`). Group by ISO year-month. Write each
   group to `.claude/changelogs/<YYYY-MM>.md` with the standard header.
5. Delete `.claude/changelog.md`.
6. Update `.gitignore`:
    - REMOVE: `.claude/plan-state.json`, `.claude/plan-executor.log`
    - ADD: `.claude/plan-states/`
    - VERIFY tracked (NOT in gitignore): `.claude/plans/`,
      `.claude/changelogs/`, `.claude/skills/`
7. Update project `CLAUDE.md`:
    - Find the "Active execution plans" section. Update path references
      to `.claude/plan-states/<plan-name>.json` for state.
    - Add a "Changelogs" section pointing at `.claude/changelogs/` and
      explaining the monthly rotation: agents write to
      `<YYYY-MM>.md` (current month), older months are read-only history.
    - Update the "After any edit" rule to write to the current month's
      changelog file.
    - Add a "Worktrees" section: brief mention that long-running plans
      should be executed in a worktree per the `worktree-orchestrator`
      skill, with worktrees living at
      `~/Development/music-platform-monorepo-worktrees/<plan-name>/`.

After all migration steps, print:

- `tree .claude` showing new structure
- `cat .gitignore | grep -E 'claude|plan'`
- `git status` showing what's staged for commit

Stop and wait for approval before Phase 3.

## Phase 3 — Create the worktree-orchestrator skill

Create user-wide at `~/.claude/skills/worktree-orchestrator/SKILL.md`.

Frontmatter:

```yaml
---
name: worktree-orchestrator
description: Manages git worktrees for concurrent agent work on long-running plans. Activates when a user wants to start, resume, list, or merge work from a plan-executor plan that should run in isolation from the main repo working tree. Triggers on phrases like "start a worktree for", "create a worktree", "list active worktrees", "merge the worktree for", "switch to worktree", "what's running in worktrees", "prepare worktree merge", "clean up worktree". Also activates automatically when the plan-executor skill is about to start a new plan in a repo where another plan-executor session is already active in a different worktree, or when the zoom-in/zoom-out skill (if installed) decides a focused exploration should be promoted into a full plan that needs isolation. Manages worktree creation, the registry at ~/.claude/worktree-registry.json, conflict detection between worktrees, merge preparation (NEVER auto-merge), and cleanup after approved merges. Never force-pushes, never deletes branches without explicit user approval, never operates on branches it didn't create. Knows the convention: worktrees live as siblings of the repo at <parent>/<repo-name>-worktrees/<plan-name>/, branches follow agent/<plan-name> naming, and one plan = one worktree.
---
```

Skill body:

````markdown
# Worktree Orchestrator

You manage git worktrees for plans that need to run in isolation from
the main repo. Concurrent plan execution requires worktrees because
two agents in the same working tree clobber each other's files.

## Operating principles

1. **One plan = one worktree.** Enforced via the registry. Refuse to
   create a second worktree for an active plan.
2. **No auto-merge.** Prepare the merge, summarize, present to the
   human. The human runs the actual merge command.
3. **No destructive operations.** Never `--force`, never interactive
   rebase, never delete branches without explicit confirmation.
4. **Worktrees are for plan-executed work.** Quick fixes, exploratory
   edits, and ad-hoc work happen in the main working tree. Don't
   create a worktree for a 5-minute task.
5. **Registry is source of truth.** All worktrees you create or
   acknowledge are recorded at `~/.claude/worktree-registry.json`.

## Registry format

`~/.claude/worktree-registry.json`:

```json
{
    "worktrees": [
        {
            "repo": "music-platform-monorepo",
            "repo_path": "/Users/<u>/Development/music-platform-monorepo",
            "plan": "admin-form-overhaul",
            "worktree_path": "/Users/<u>/Development/music-platform-monorepo-worktrees/admin-form-overhaul",
            "branch": "agent/admin-form-overhaul",
            "created": "2026-04-25T14:32:00Z",
            "status": "active"
        }
    ]
}
```

Status values: `active` | `merged` | `abandoned`.

When the registry doesn't exist, create it with an empty worktrees
array.

## Workflows

### Start a new worktree for a plan

Inputs: plan name (e.g., `stream-player-redesign`).

1. Verify the plan exists at `.claude/plans/<plan-name>/MasterPlan.md`
   in the current repo. If not, refuse and tell the user to create
   the plan first.
2. Read the registry. Reject if a worktree for this (repo, plan)
   already exists with status `active`.
3. Compute paths:
    - Repo path = current `git rev-parse --show-toplevel`
    - Repo name = basename of repo path
    - Worktree parent = sibling of repo: `<dirname of repo>/<repo-name>-worktrees/`
    - Worktree path = `<worktree-parent>/<plan-name>/`
    - Branch = `agent/<plan-name>`
4. Confirm with the user:
    - "I'll create a worktree at `<worktree-path>` on branch
      `<branch>`. Proceed? (y/n)"
5. Run `git worktree add <worktree-path> -b <branch>` from the main
   repo.
6. Update the registry with a new entry, status `active`.
7. Print the absolute path to the worktree and a one-line cd hint:
   `cd <worktree-path>`
8. Remind the user: "Open Claude Code in that directory to begin
   plan execution."

### Resume work in an existing worktree

Inputs: plan name, OR list available active worktrees.

1. Read registry. List all active worktrees (filter by repo if asked).
2. If user named a plan, return the worktree path. If not, ask which.
3. Print the cd hint.

### List worktrees

Read registry, print a table:

| Plan | Repo | Branch | Status | Created |

Filter by `--repo <name>` or `--status active` if asked.

### Prepare merge

Inputs: plan name.

1. Verify the plan's worktree is registered and active.
2. cd into the worktree.
3. Verify the working tree is clean (`git status --porcelain` empty).
   If not, refuse.
4. Verify the plan-state shows phase 5 cleanup completed (read
   `.claude/plan-states/<plan>.json`). If not, warn and ask if user
   wants to merge anyway.
5. Run `git log <main-branch>..HEAD --oneline` to show the commits
   that will be merged.
6. Generate a merge summary:
    - Plan name
    - Branch name
    - Commit count
    - Files touched (`git diff --stat <main>..HEAD`)
    - Tests passed/failed (read from plan-state if recorded)
7. Print the suggested merge command for the human:
````

git checkout <main-branch>
git merge --no-ff agent/<plan-name>

```
8. Print: "I'm not running this. After you've reviewed and merged,
   run `worktree-orchestrator: cleanup <plan-name>` to remove the
   worktree."

NEVER run the merge automatically.

### Cleanup after merge

Inputs: plan name.

1. Verify the branch is merged into the main branch
   (`git branch --merged <main>` includes `agent/<plan-name>`).
   If not, refuse.
2. Confirm with user:
   - "Remove worktree at `<path>` and delete branch
     `agent/<plan-name>`? (y/n)"
3. On confirmation:
   - `git worktree remove <worktree-path>`
   - `git branch -d agent/<plan-name>` (note: lowercase -d, refuses
     if not merged — extra safety)
4. Update registry: set status to `merged`, add `merged_at` timestamp.
   Don't delete the entry — keep history.

### Abandon a worktree

Inputs: plan name. For when work is being abandoned (not merged).

1. Confirm with user — twice. "This will delete uncommitted work and
   the branch. Are you sure? (yes/no)" Then "Type the plan name to
   confirm: <plan-name>"
2. On confirmation:
   - `git worktree remove --force <worktree-path>` (force is OK here
     because user explicitly confirmed twice)
   - `git branch -D agent/<plan-name>`
3. Update registry: status to `abandoned`, add `abandoned_at`.

## Detecting conflicts

Before starting a plan, check the registry for active worktrees in the
same repo. Read each active plan's MasterPlan.md to identify which
files/directories the plan touches. If overlap with the new plan's
scope > 30% of files, warn the user before creating the worktree.

This is best-effort heuristic, not a guarantee. Plans can drift from
their stated scope.

## Integration with other skills

- **plan-executor:** When asked to start a new plan, if no worktree
  exists for it AND the plan is non-trivial (>5 tasks or estimated
  >2 days), suggest creating a worktree first via this skill.
- **zoom-in/zoom-out (if installed):** When zoom-out promotes a focused
  exploration into a full plan, suggest creating a worktree to execute it.
  See "Integration with zoom-in/zoom-out" below.

## Integration with zoom-in/zoom-out (if installed)

If a zoom-in or zoom-out skill is installed user-wide, consult it to
understand its triggers and outputs. The integration goal:

- When zoom-out concludes "this exploration should become a full plan,"
  this skill is the natural next step. The hand-off is: zoom-out
  produces a plan scaffold under `.claude/plans/<plan-name>/`, then
  worktree-orchestrator creates the worktree to execute it.

When this skill is loaded, ALSO check for the zoom-in/zoom-out skill in
the user's installed skills. If it exists, add a one-line note to your
output when starting a new worktree: "If this came from a zoom-out
session, the plan scaffold should already be in place — verify before
proceeding."

If the zoom-in/zoom-out skill does NOT exist, ignore this section.

## What you must never do

- Auto-merge to main or any default branch
- Force-push (`--force` on push)
- Run interactive rebase
- Delete branches without explicit user confirmation (twice for
  unmerged work)
- Operate on branches you didn't create (e.g., merge `feat/something`
  the user made themselves)
- Skip the registry update — every worktree change must be reflected
- Create a worktree when one already exists for the same (repo, plan)
  pair with status `active`

## Diagnostic commands

If something looks wrong:

- `git worktree list` shows actual worktrees on disk
- `cat ~/.claude/worktree-registry.json` shows what we think is active
- Reconcile drift: if registry says active but worktree directory
  is gone, mark `abandoned` and ask the user what happened

## Example session

User: "I'm starting the stream-player-redesign plan."

Skill: "I'll create a worktree at
`~/Development/music-platform-monorepo-worktrees/stream-player-redesign`
on branch `agent/stream-player-redesign`. Proceed? (y/n)"

User: "y"

Skill: [runs `git worktree add`, updates registry]
"Done. To begin work:
  cd ~/Development/music-platform-monorepo-worktrees/stream-player-redesign
Then open Claude Code in that directory and resume the plan."
```

After creating the file, print the first 15 lines so I can verify
the frontmatter triggers.

## Phase 4 — Update zoom-in/zoom-out skill (if it exists)

Only execute this phase if Phase 0 found a zoom-in or zoom-out skill.

If it exists:

1. Read the skill's current trigger conditions and body.
2. Identify where in its workflow it decides "this is now a plan,
   not just exploration." Likely in zoom-out.
3. Add a section to the skill: "Plan promotion handoff." When zoom-out
   produces a full plan, the skill should:
    - Generate the plan scaffold under `.claude/plans/<plan-name>/`
      with MasterPlan.md and tasks/ directory
    - Suggest the worktree-orchestrator skill for execution: "This plan
      is ready for execution in a worktree. The
      `worktree-orchestrator` skill can create one for you."
    - Do NOT auto-create the worktree — let the user confirm and
      trigger it explicitly.
4. Print the diff for me to approve.

If it doesn't exist, skip this phase silently and tell me at the end:
"No zoom-in/zoom-out skill found; integration is in place if/when one
is installed."

## Phase 5 — Final verification + commit

Print:

1. `tree .claude` showing final project structure
2. The final `.gitignore` Claude-related lines
3. The new project `CLAUDE.md` (full file, since it changed
   substantially)
4. List of every skill file modified with a one-line summary of changes
5. The first 15 lines of the new worktree-orchestrator skill

Make ONE commit:

```
git add -A
git commit -m "refactor(claude): multi-plan state, dated changelogs, worktree orchestration

- Plan state moves from .claude/plan-state.json to
  .claude/plan-states/<plan-name>.json (gitignored)
- Plan logs move to .claude/plan-states/<plan-name>.log (gitignored)
- Changelogs rotate monthly under .claude/changelogs/<YYYY-MM>.md
  (tracked); old flat .claude/changelog.md migrated and removed
- Project CLAUDE.md updated with new paths and worktree pattern
- Updated user-wide skills: plan-executor, plan-auditor, and the four
  plan-executor-* sub-skills
- Added user-wide worktree-orchestrator skill for concurrent plans
- Updated zoom-in/zoom-out skill (if present) to hand off to
  worktree-orchestrator"
```

## Stop conditions

Stop and ask if:

- Phase 0 inventory shows a zoom-in/zoom-out skill with content I
  should know about — surface its current behavior in detail before
  Phase 1
- The current `.claude/plan-state.json` shows the admin form overhaul
  plan as in-progress — flag this and ask whether to migrate state
  mid-flight
- The current changelog has malformed entries that don't fit the
  format — print them and ask how to handle
- Any path collision: a file already exists at a target location
  before migration moves to it
- The repo has uncommitted changes when migration starts — refuse and
  tell me to commit or stash first
