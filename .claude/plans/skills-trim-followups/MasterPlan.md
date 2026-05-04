---
plan: skills-trim-followups
status: ready
from-essay:
  - ~/.claude/essays/skill-system-token-efficiency-audit.md
  - ~/.claude/essays/skill-system-vs-superpowers.md
from-plan: ~/dotfiles/.claude/plans/skills-trim-and-discipline/MasterPlan.md
affects-docs: []
created: 2026-05-03
---

# Master Plan: Skills Trim & Discipline — Follow-ups

## Objective

Close the 8 Phase-8 follow-ups from `skills-trim-and-discipline` (now
v3.0). Tightens the system without changing its shape: prose-prunes
5 over-budget skill bodies, runs real RED dispatches against the 8
discipline + ritual fixtures, captures the deferred cold-session smoke
test, and sweeps for YAML quoting drift.

Net effect: closes the parent plan's CONDITIONAL PASS verdicts, pushing
the lint result from 12 OK / 4 WARN / 12 FAIL toward all-OK across all
28 skills.

## Sequencing (and why)

| Phase | What | Why this order |
|---|---|---|
| 0 — Setup | Discovery + setup PR | Captures pre-followup baseline; tracks plan dir; setup PR merges before phase work begins |
| 1 — Prose pruning | 5 specialist body trims (ddex → nextjs → royalty-splits → turborepo → plan-executor) | Mechanical work; budget linter gates each. Sequenced by yield (largest first); independent — could parallelize but kept sequential per orchestrator principle |
| 2 — Verification | Real RED dispatches for 8 discipline+ritual skills | Iterates skill bodies if new rationalizations surface. Runs after Phase 1 so prose-pruning doesn't invalidate captured rationalizations |
| 3 — Cleanup | YAML quoting sweep; cold-session smoke (manual user run) | Closes parent-plan deferred checks |
| 4 — Extension and recalibration | Audit linter targets; introduce complex-orchestrator class; apply recalibrations; address remaining FAILs; Phase 4 audit gate | User-added at Phase-1-audit boundary: linter targets feel arbitrary, plan-executor body needs its own class, and 7 out-of-scope FAILs from Phase 1 should be addressed (recalibrate or trim). Runs last because Tasks 11-14 may modify skills already touched by Phases 1-3 |
| 9 (closeout) | Update parent essays' Measured outcome with followup deltas; mark this plan resolved; closeout PR | Capstone |

## Scope

### Files to modify

**Phase 1 — prose pruning:**
- `claude/.claude/skills/ddex-standards/SKILL.md` (~+3,062 B over body budget)
- `claude/.claude/skills/nextjs-app-router/SKILL.md` (~+2,041 B)
- `claude/.claude/skills/royalty-splits-music/SKILL.md` (~+1,104 B)
- `claude/.claude/skills/turborepo-patterns/SKILL.md` (~+1,024 B)
- `claude/.claude/skills/plan-executor/SKILL.md` (~+502 B)

**Phase 2 — RED dispatch (only if rationalizations surface):**
- 8 discipline + ritual SKILL.md files (potentially)
- `claude/.claude/skills/<each>/fixtures/<name>.md` (potentially expanded)

**Phase 3 — cleanup + closeout:**
- `claude/.claude/essays/skill-system-token-efficiency-audit.md` (append "Followup outcome" section)
- `claude/.claude/essays/skill-system-vs-superpowers.md` (append followup note)
- Project-local skill files (YAML sweep — may be no-op)

### Out of scope

- Parent plan re-audit. The parent plan (`skills-trim-and-discipline`)
  is `status: completed` at v3.0; this plan is incremental hardening,
  not redo.
- New skills. No additions to the always-loaded baseline.
- Reference restructuring. The references/ pattern is settled; no
  re-extraction.
- Project-level CLAUDE.md audits (parent plan's `out of scope` item;
  separate per-project work).

## Branching, PRs, and tagging

**Cadence: compact — 2 PRs, 2 tags.** User-confirmed.

- **Execution branch:** `claude/skills-trim-followups` off post-v3.0 main.
- **Setup PR:** lands the gitignore exemption + MasterPlan + task files
  (this commit). Merged → **v3.1** MINOR tag.
- **Phase work:** all phases (1, 2, 3) commit to the same execution
  branch after setup PR merges and branch ff-syncs with main. Phase
  boundary commits are NOT individually tagged — only the closeout
  commit gets a tag.
- **Closeout PR (Phase 3 / Task 11):** essay updates + plan-resolved
  + summary. Merged → **v3.2** MINOR tag.
- **No MAJOR tag** for this follow-up (incremental hardening, not a
  large restructure per `~/dotfiles/CLAUDE.md` §"Tagging and releases").

### Tag-bump summary

| Stage | Tag | PR |
|---|---|---|
| Setup PR merged | **v3.1** (MINOR) | Setup PR |
| Phase 1 (prose pruning, 5 commits) | (no tag; commits accumulate) | Closeout PR |
| Phase 2 (RED dispatches) | (no tag) | Closeout PR |
| Phase 3 (cleanup + closeout commit) | **v3.2** (MINOR) | Closeout PR |
| **Total** | **2 MINOR** | **2 PRs** |

### Audit gates

Tasks 06, 08 are audit gates (Phase 1 audit + Phase 2 audit). Each
produces a report under `audits/`. **Per protocol** (locked from the
parent plan's execution): orchestrator runs the audit; if PASS,
proceeds; if anything other than PASS, halts and asks the user.

The Phase-3 cleanup tasks have no audit gate; they're capstone work
that closes the plan.

## Constraints

- **Verify main state before any push** (locked from parent plan).
  Branch is reconciled with `origin/main` before tag/PR pushes.
- **Stow discipline** for any new files. None expected in this plan
  (all edits are to existing tracked files).
- **One commit per task** with `Plan: skills-trim-followups`,
  `Task: NN` footers.
- **Skill-budget-lint gates each prose-pruning task.** Run
  `~/.claude/tools/skill-budget-lint.py` before AND after each Phase 1
  task; verify FAIL→OK (or FAIL→WARN→OK) transition.
- **Body-content preservation.** Prose pruning means tightening
  prose, not removing decision content. Each Phase 1 task must
  identify what to trim (redundant prose, examples that earn fewer
  bytes than they cost, sub-sections that can be folded) WITHOUT
  removing pitfalls lists, decision tables, or unique domain
  knowledge.
- **No description rewrites.** Phase 3 of the parent plan settled
  descriptions; this plan does not touch them. All Phase 1 trims are
  body-only.

## Key decisions (do not re-litigate)

- **Compact 2-tag cadence.** User-confirmed; matches the smaller
  scope. v3.1 = setup, v3.2 = closeout.
- **Sequential prose pruning, ordered by yield.** ddex (3,062 B over)
  → nextjs (2,041 B) → royalty-splits (1,104 B) → turborepo
  (1,024 B) → plan-executor (502 B).
- **RED dispatches AFTER prose pruning.** Rationalizations captured
  against pre-pruning skill bodies could be invalidated if pruning
  changes the body's anti-rationalization section. Order is
  prose-then-RED.
- **Single cold-session smoke at end.** Closes 5 deferred checks
  (audits 04, 13, 18, 25, 30, 37 from parent plan) at once.

## Task index

| # | Phase | File | Summary | Agent | Tag/PR |
|---|---|---|---|---|---|
| 00 | 0 | tasks/00-discovery.md | Re-baseline; pre-followup linter snapshot | discovery | setup PR |
| 01 | 1 | tasks/01-prune-ddex-standards.md | Prose-prune ddex-standards body | implementer | (closeout) |
| 02 | 1 | tasks/02-prune-nextjs-app-router.md | Prose-prune nextjs-app-router body | implementer | (closeout) |
| 03 | 1 | tasks/03-prune-royalty-splits-music.md | Prose-prune royalty-splits-music body | implementer | (closeout) |
| 04 | 1 | tasks/04-prune-turborepo-patterns.md | Prose-prune turborepo-patterns body | implementer | (closeout) |
| 05 | 1 | tasks/05-prune-plan-executor.md | Prose-prune plan-executor body | implementer | (closeout) |
| 06 | 1 | tasks/06-audit-prose-pruning.md | Re-run linter; verify FAIL→OK; activation regression sweep | auditor | gate |
| 07 | 2 | tasks/07-red-dispatches.md | Real RED dispatches for 8 discipline+ritual skills | implementer | (closeout) |
| 08 | 2 | tasks/08-audit-red-dispatches.md | Verify rationalization deltas captured; iterate skill bodies if needed | auditor | gate |
| 09 | 3 | tasks/09-yaml-quoting-sweep.md | Grep project-local skill dirs for unquoted descriptions w/ colons | discovery | (closeout) |
| 10 | 3 | tasks/10-cold-session-smoke.md | Manual user-run cold-session smoke; record observation | (user) | (closeout) |
| 11 | 4 | tasks/11-audit-linter-targets.md | Audit per-class budget origin/justification; recommend recalibrations | discovery | (closeout) |
| 12 | 4 | tasks/12-apply-linter-recalibrations.md | Introduce complex-orchestrator class; apply Task-11 recalibrations | implementer | (closeout) |
| 13 | 4 | tasks/13-address-remaining-fails.md | Prose-prune any skills still FAIL post-recalibration (essay, session-ready, worktree-orchestrator, plan-auditor likely) | implementer | (closeout) |
| 14 | 4 | tasks/14-audit-phase-4.md | Phase 4 audit gate: verify linter recalibrated + remaining FAILs addressed | auditor | gate |
| 15 | 3 | tasks/15-closeout.md | Update parent essays' Measured outcome with followup deltas; mark this plan resolved; closeout PR | documenter | closeout PR |

Tasks: `~/dotfiles/.claude/plans/skills-trim-followups/tasks/`
Audits: `~/dotfiles/.claude/plans/skills-trim-followups/audits/`

## Validation strategy

After each prose-pruning PR (Tasks 01–05):
1. Run `~/.claude/tools/skill-budget-lint.py`. The targeted skill should move from FAIL → OK or FAIL → WARN.
2. Smoke-test activation: trigger the skill via canonical phrase; confirm activation and behavior.
3. Verify body-content preservation: cross-check the pruned skill against its pre-pruning version; pitfalls lists, decision tables, unique domain knowledge must remain.

After Phase 1 audit (Task 06):
1. Re-run linter; report should show 12+5=17 OK (or close, depending on Phase 1 yield).
2. Activation regression sweep across all 5 trimmed specialists.
3. Note any FAIL skills still over budget; surface for user decision (continue or further trim).

After Phase 2 audit (Task 08):
1. Per-skill: did real RED dispatch surface NEW rationalizations beyond the hypothetical ones?
2. If yes: was the skill body updated? Verify body still ≤ word/byte budget.
3. If no: confirm hypothetical rationalizations were sufficient (a quiet PASS).

After closeout (Task 11):
1. Both source essays' "Measured outcome" updated with followup deltas (closing the 8 carry-forward items).
2. Closeout PR opened (not merged).
3. v3.2 tag prepared on closeout commit (orchestrator places before user-merge).

## Failure handling

Per parent-plan policy:
- **Prose pruning fails to hit budget:** mark as PARTIAL; surface to user; user decides whether to accept or push further.
- **RED dispatch surfaces rationalizations the skill can't counter:** halt; surface; user decides whether to iterate skill or accept.
- **Cold-session smoke shows regression:** halt; investigate; potentially revert prose-pruning.
- **Audit gate non-PASS:** halt and ask (locked protocol from parent plan).
