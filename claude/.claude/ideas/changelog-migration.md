Prompt A — Anchoring Migration
Paste this into a Claude Code session opened inside ~/dotfiles (so the symlinked skill files resolve correctly).
I'm migrating from changelog-based change tracking to an anchoring-based
system. This affects two repos: ~/dotfiles (user-wide Claude config) and
music-platform-monorepo (project). Execute in phases, two repos, two
commits.

## Context — read first

1. Read these existing user-wide skills (edit them via the dotfiles
   repo path so changes are committable):
   - ~/dotfiles/claude/.claude/skills/plan-executor/SKILL.md
   - ~/dotfiles/claude/.claude/skills/plan-auditor/SKILL.md
   - ~/dotfiles/claude/.claude/skills/plan-executor-discovery/SKILL.md
   - ~/dotfiles/claude/.claude/skills/plan-executor-implementer/SKILL.md
   - ~/dotfiles/claude/.claude/skills/plan-executor-tester/SKILL.md
   - ~/dotfiles/claude/.claude/skills/plan-executor-documenter/SKILL.md

   If the path differs (e.g., the symlink target is at a different
   location), `readlink ~/.claude/skills/plan-executor/SKILL.md` to
   discover the real path. Edit the real path.

2. Read the project's current state (do NOT modify yet):
   - ~/Development/music-platform-monorepo/CLAUDE.md
   - ~/Development/music-platform-monorepo/.gitignore
   - List of files under ~/Development/music-platform-monorepo/docs/
   - List of files under ~/Development/music-platform-monorepo/.claude/plans/
   - Confirm whether ~/Development/music-platform-monorepo/.claude/changelogs/
     exists (created by the recent multi-plan migration)

3. Print summary of what you found. Stop. Wait for confirmation.

## Decisions already made (do not re-litigate)

- **Anchors replace changelogs entirely.** Changelog files are deleted,
  not converted. `git log` carries the historical signal.
- **Front-matter on every doc** declares `covers` (code paths) and
  `last-verified` (ISO date).
- **Sidecar taxonomy:** docs that don't describe code use the same
  front-matter system but with explicit flags. `static: true` for
  reference docs about external standards. `speculative: true` for
  roadmap-style content. Both opt out of staleness checks.
- **Plan front-matter:** plans declare `affects-docs` so the documenter
  sub-skill can verify those docs were touched on completion.
- **Commit footers:** plan-executor commits include
  `Plan: <plan-name>` and `Task: <task-id>` footers. This makes plan
  attribution greppable from `git log`.
- **`last-updated-from` is derived, not stored.** Read from
  `git log -1 <doc>` on demand.
- **doc-freshness is a NEW user-wide skill** that handles
  anchoring-aware reading and verification.
- **Project CLAUDE.md** removes the "After any edit, append to
  changelog" rule and adds an anchoring rule.
- **Both repos get one commit each.** Dotfiles first, then project.

## Phase 1 — Update user-wide skills in ~/dotfiles

Update the skills I listed in Context #1. Specific changes per skill:

### plan-executor

1. Find every reference to `.claude/changelog.md` or `.claude/changelogs/`
   and remove the changelog write/append behavior.

2. In its place, add a "Commit footer convention" section:

````
## Commit footer convention

Every commit made during plan execution MUST include footers identifying
the plan and the current task. Use git's standard footer format
(blank line before footers, then `Key: value`):

git commit -m "feat(scope): summary

Body text describing the change.

Plan: <plan-name>
Task: <task-id>"

This makes plan attribution greppable from `git log` and feeds the
doc-freshness skill's analysis. Tag every commit, including merge
commits.
````

3. Add an "Affects docs" section near where the plan-state.json schema
   is described:

````
## Plan front-matter and affects-docs

Plans declare which docs they expect to update via the `affects-docs`
field in MasterPlan.md front-matter:

---
plan: <name>
status: in-progress | completed | abandoned
affects-docs:
  - docs/05-admin.md
  - docs/04-backend.md
created: <ISO date>
---

The documenter sub-skill verifies these docs were touched (have new
commits with the plan footer) before plan completion.
````

4. Remove all references to changelog appending. Keep state file
   references (those are at `.claude/plan-states/<plan-name>.json` per
   the recent multi-plan migration).

### plan-executor-documenter

1. Remove changelog-writing instructions.

2. Add an "Anchoring verification" section as part of the Phase 5
   cleanup workflow:

````
## Anchoring verification (Phase 5 documenter responsibility)

Before marking the plan complete, verify the anchoring contract:

1. Read MasterPlan.md front-matter `affects-docs` list
2. For each listed doc, run:
   git log <plan-start-sha>..HEAD --grep="Plan: <plan-name>" -- <doc>
   If empty: the doc was NOT touched. FAIL the cleanup phase and
   report which docs need attention.
3. For each doc that WAS touched, bump its front-matter `last-verified`
   to today's date if not already set by the implementing tasks.
4. Report all anchor changes in the Phase 5 summary.
````

### plan-auditor

1. Remove changelog-related verification.

2. Add anchoring verification: when auditing a completed plan, the
   auditor reads `affects-docs`, confirms each was touched in commits
   bearing the plan footer, and confirms each has a `last-verified`
   newer than the plan's start date.

3. Audit reports include an "Anchor verification" section listing
   docs touched, docs not touched, and any front-matter inconsistencies.

### plan-executor-discovery, -implementer, -tester

1. Update commit instructions to use the footer format above.
2. Remove any changelog references.

After updating each file, print a brief diff summary (what lines
changed). Stop and wait for approval before Phase 2.

## Phase 2 — Create the doc-freshness skill in ~/dotfiles

Create:
~/dotfiles/claude/.claude/skills/doc-freshness/SKILL.md

````markdown
---
name: doc-freshness
description: Verifies and tracks staleness of documentation by comparing front-matter `last-verified` dates against git history of code paths declared in `covers`. Activates when an agent is about to read or rely on a doc, when an agent updates code that may invalidate a doc, when checking which docs need re-verification, or when explicitly asked about doc freshness. Triggers on phrases like "is this doc still accurate", "check doc freshness", "what docs are stale", "verify the X doc", "bump last-verified", "trace this doc's history", "which docs cover this code". Knows the front-matter schema: `covers` (code paths the doc describes), `last-verified` (ISO date), `static: true` (external-standard reference, opts out), `speculative: true` (roadmap, opts out), `from-essay` (essay that informed this doc). Also knows the commit-footer convention `Plan: <name>` / `Task: <id>` so it can attribute changes to plans. Never modifies docs without explicit confirmation; bumping `last-verified` is an explicit user-confirmed action.
---

# Doc Freshness Skill

Maintains the anchoring contract between docs and code. Replaces the
older changelog-based invalidation system.

## Front-matter schema

Every doc under docs/ should carry front-matter:

```yaml
---
title: <doc title>
covers:
  - <path or glob>
  - <path or glob>
last-verified: <ISO date YYYY-MM-DD>
---
```

Optional fields:

- `static: true` — doc describes an external standard, not internal
  code. Skip staleness checks.
- `speculative: true` — doc is roadmap/aspirational. Skip staleness
  checks.
- `from-essay: <path>` — doc's reasoning lives in an essay (the
  `essay` skill).
- `from-plan: <plan-name>` — doc was produced or substantially
  updated by a specific plan.

`last-updated-from` is NOT stored. Derive on demand:
git log -1 --format=%H -- <doc>

## Core operations

### 1. Check freshness on doc read

Before relying on a doc, run:

````
last_verified=$(yq -r '.last-verified' <doc>)
covers=$(yq '.covers[]' <doc>)
git log --since=$last_verified --oneline -- $covers
````

If output non-empty: doc may be stale. Surface to user:

"Doc <path> was last verified <date>. Since then, N commits have
touched its covered paths. Showing the most recent 5:
<commit list>
The doc may not reflect current code. Re-verify before relying on
it?"

If output empty: doc is fresh. Proceed silently.

If `static: true` or `speculative: true`: skip the check entirely.

### 2. Trace doc history

"What changed this doc, when, and which plan?"

````
git log --format='%h %ad %s' --date=short -- <doc>
````

To extract plan attribution from commit footers:

````
git log --format='%H' -- <doc> | while read sha; do
  git show --format='%H %ad %s%n%b' --date=short $sha | grep -E '^(Plan|Task):'
done
````

### 3. Bump last-verified

When the agent or user has confirmed a doc still accurately describes
its covered paths:

1. Read current front-matter
2. Update `last-verified: <today>` (ISO date)
3. Show diff
4. Confirm with user before writing

If the doc was just modified in the same session, the bump is implicit
in the commit (the new state is the verified state). Surface this:
"You just updated this doc. I'll bump last-verified to today."

### 4. List stale docs

"What docs are stale?"

For each doc under docs/ with non-static, non-speculative
front-matter:
- Compute days since last-verified
- Run the staleness check
- Report only docs with code changes since verification

Output as a table:
| Doc | Last verified | Days | Commits since | Plan attribution |

### 5. Suggest covers

When a new doc is created without front-matter, suggest `covers` based
on what the doc references:
- Look for code paths mentioned in headings or prose
- Match against the actual repo structure
- Propose front-matter; user approves before writing

## What you must never do

- Modify front-matter without explicit user confirmation
- Bump last-verified without verifying the doc actually matches code
  (or having the user confirm)
- Suggest auto-resolution of staleness — the human must decide whether
  a doc needs re-verification or not
- Treat `static: true` or `speculative: true` docs as failures when
  they don't have last-verified — they don't need it

## Integration with other skills

- **plan-executor / plan-executor-documenter:** the documenter calls
  this skill on plan completion to bump `last-verified` for all
  `affects-docs` listed in MasterPlan.md.
- **plan-auditor:** uses the trace operation to verify a plan's
  commits show up in expected docs' history.
- **essay (when present):** docs created from essays carry
  `from-essay: <path>` in front-matter; this skill can surface the
  essay when explaining a doc's reasoning.

## Example session

User: "I'm about to add a new admin route. Should I trust docs/05-admin.md?"

Skill: [reads front-matter, checks git log against covers]
"docs/05-admin.md was last verified 2026-04-12. Since then, 8 commits
have touched apps/admin/. The 3 most recent:
  abc123  2026-04-23  feat(admin): add SlideOver component (Plan: admin-form-overhaul)
  def456  2026-04-22  refactor(admin): consolidate ConfirmModal usage (Plan: admin-form-overhaul)
  ghi789  2026-04-20  fix(admin): unsaved changes guard (Plan: admin-form-overhaul)

These look like they're from the admin-form-overhaul plan, which
declared docs/05-admin.md in its affects-docs. Has the plan completed
phase 5 documenter step? If yes, last-verified should already be
bumped — checking again... [confirms]. The doc should be current."
````

After creating the file, print the first 15 lines so I can verify
frontmatter triggers.

## Phase 3 — Commit changes to ~/dotfiles

In ~/dotfiles, make ONE commit:

````
git -C ~/dotfiles add -A
git -C ~/dotfiles commit -m "feat(claude): replace changelogs with anchoring system

Replaces changelog-based change tracking with front-matter anchoring:

- plan-executor, plan-auditor, and the four plan-executor-* sub-skills
  no longer write to changelog files. Removed all changelog references.
- Plan-executor commits use Plan/Task footers for greppable attribution.
- Plan front-matter declares affects-docs; documenter verifies on
  completion.
- New doc-freshness skill: checks front-matter last-verified against
  git log of covers paths, surfaces stale docs, bumps verification
  dates with explicit confirmation.
- last-updated-from is derived from git log, not stored.
- Static reference docs and speculative roadmap docs opt out via
  static:true / speculative:true flags."
````

Print the commit SHA. Stop and wait for approval before Phase 4.

## Phase 4 — Migrate the music-platform-monorepo

Switch to the project:

````
cd ~/Development/music-platform-monorepo
````

### Step 4a — Verify clean working tree

If `git status --porcelain` is non-empty, refuse and ask user to commit
or stash first.

### Step 4b — Inventory docs and plans

For each .md file under docs/:
- Print path
- Suggest a `covers` list (best effort, based on file content and
  repo structure). The user will confirm.
- For known reference/standards docs, mark as `static: true`:
  - docs/reference/DDEX_Standards_Reference_Guide.md
  - docs/reference/DATA_STANDARDS.md
  - any other doc that describes external standards, not internal code
- For roadmap docs, mark as `speculative: true`:
  - docs/07-roadmap.md
  - any docs/09-* tooling-exceptions or similar

For each plan under .claude/plans/<name>/MasterPlan.md:
- Suggest `affects-docs` list based on what the plan modifies
- Note plan status from corresponding `.claude/plan-states/<name>.json`

Print the proposed front-matter for every doc and plan in a table:

| File | Type | Front-matter additions |
|------|------|------------------------|

Stop. Wait for me to approve, edit, or override before proceeding.

### Step 4c — Apply front-matter

For each approved doc:

If the doc has NO existing front-matter:
- Prepend YAML front-matter at line 1

If the doc HAS existing front-matter:
- Merge new fields, preserving any existing fields
- Set `last-verified: <today>` regardless of prior value (we're
  resetting at migration time)

For each plan's MasterPlan.md:
- Add front-matter with `plan: <name>`, `status: <from plan-states>`,
  `affects-docs: <approved list>`, `created: <plan creation date if
  determinable>`

### Step 4d — Delete the old changelog files

Per the recent multi-plan migration, `.claude/changelogs/<YYYY-MM>.md`
files exist. Delete them all:

````
git rm -r .claude/changelogs/
````

If `.claude/changelog.md` somehow still exists (older flat file),
delete it too.

### Step 4e — Update project CLAUDE.md

Find and remove the "After any edit" / changelog rule.

Add a new "## Anchoring" section with this content:

````markdown
## Anchoring

Docs declare what they cover and when they were last verified.
Anchoring replaces changelog-based change tracking.

### Doc front-matter

Every doc under `docs/` carries front-matter:

```yaml
---
title: <name>
covers:
  - <code path or glob>
last-verified: <ISO date>
---
```

Optional flags:
- `static: true` — describes external standards, opts out of staleness
- `speculative: true` — roadmap, opts out of staleness
- `from-essay: <path>` — doc's rationale lives in an essay
- `from-plan: <plan-name>` — doc was substantially produced by a plan

### Plan front-matter

Every plan's MasterPlan.md declares which docs it expects to update:

```yaml
---
plan: <name>
status: in-progress | completed | abandoned
affects-docs:
  - docs/...
created: <ISO date>
---
```

The documenter sub-skill verifies these docs were touched on plan
completion.

### Commit footers

Plan-executor commits include footers:

````
Plan: <plan-name>
Task: <task-id>
````

This makes plan attribution greppable from git log without a
changelog file.

### Tooling

The `doc-freshness` skill (user-wide) handles staleness detection,
verification bumping, and history tracing. Activate it when reading
a doc you'd cache, when updating code that may invalidate a doc,
or when explicitly asked about staleness.
````

Find the existing "## Never" section and remove the changelog-related
"Never" rules. Add (if not already present):

- "Never write changelog files; use anchoring + git log."

### Step 4f — Update .gitignore

Remove any references to `.claude/changelogs/` or `.claude/changelog.md`.
Verify `.claude/plans/` and `.claude/skills/` and `.claude/essays/`
(once that exists in Prompt B) are NOT gitignored.

### Step 4g — Verify

Print:
- `tree .claude` showing structure
- `tree docs` showing structure
- For each doc, the new front-matter (just front-matter, not the body)
- For each plan, the new front-matter
- The updated CLAUDE.md anchoring section
- `.gitignore` (Claude-related lines)

Stop. Wait for approval.

### Step 4h — Commit the project changes

````
git add -A
git commit -m "feat(docs): migrate from changelogs to anchoring system

- Add front-matter to all docs/ files declaring `covers` and
  `last-verified`. Reference docs (DDEX, DATA_STANDARDS) flagged
  static:true to opt out of staleness checks. Roadmap and tooling
  exceptions flagged speculative:true.
- Add front-matter to active plans declaring `affects-docs`.
- Delete .claude/changelogs/ — anchoring + git log replace this.
- Update CLAUDE.md: remove changelog rule, add Anchoring section
  describing the new pattern.
- Update .gitignore to remove changelog references."
````

Print the commit SHA.

## Stop conditions

Stop and ask if:
- The dotfiles symlink resolution is unclear — print what `readlink`
  shows for one skill and confirm before mass editing
- A doc has unusual existing front-matter that conflicts with the new
  schema — surface and ask
- Suggested `covers` for a doc isn't obvious — ask rather than guess
- A plan's `affects-docs` would be more than 5 entries — that suggests
  the plan is too broad; surface the concern
- Any uncommitted changes block migration — refuse and instruct
- Either commit fails or any phase produces unexpected output

Do not proceed past phase boundaries without confirmation.
