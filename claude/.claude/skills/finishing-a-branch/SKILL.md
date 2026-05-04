---
name: "[HomebrewSkill] finishing-a-branch"
class: ritual
description: "Use when finishing a feature branch, marking work ready to merge, closing out ad-hoc branch work, or asking 'what's left before merging'. Activates on phrases like 'ready to merge', 'finishing this branch', 'close out the work', 'what's left', 'wrapping up'. Pre-flight check: if a plan is active, defer to plan-executor Phase 4. Else runs a 7-item closeout checklist (tests, clean diff, logical commits, TODOs addressed, sidecars updated, stow synced, tag bump considered). Cross-refs plan-executor, worktree-orchestrator, github, verification-before-completion. Do NOT trigger for in-progress check-ins or draft branches."
---

# finishing-a-branch

## Norm

**FINISHED BRANCH = TESTS GREEN + CLEAN DIFF + LOGICAL COMMITS +
TODOs RESOLVED + SIDECARS UPDATED + STOW SYNCED + TAG CONSIDERED.**

Closeout transfers work from your machine to shared history. Walk
every item explicitly — skipping silently is the failure mode.
Address or justify each.

## Pre-flight: is a plan active?

Check `.claude/plan-states/` and session context. If a plan is
active, **stop** — defer to `plan-executor` Phase 4. Plan-driven
branches have their own closeout (audit gate, per-phase PR cadence,
state transitions); running this skill on top double-counts and
risks contradicting the plan's discipline.

Otherwise, continue.

## Closeout checklist

1. **Full test run passes.** Cite command and output. "Tests pass"
   is not evidence; `pnpm test → 142 pass, 0 fail` is.
2. **Diff is clean.** No debug code, no `console.log` / `dbg!`, no
   commented-out blocks, no unrelated changes. Split unrelated
   changes into a separate branch.
3. **Commits are logical.** Each commit tells a coherent story.
   Flag squash candidates. Fixup, "wip", and "address review"
   commits land squashed before merge.
4. **TODOs addressed or filed.** Every `TODO`/`FIXME`/`XXX` in
   changed code is resolved here or moved to a tracked idea
   (`idea-tracker`) or issue. No drift TODOs.
5. **Sidecars updated.** Per `CLAUDE.md` sidecar conventions, any
   non-trivial file touched gets its `.claude` sidecar reviewed
   and updated where intent or invariants changed.
6. **Stow OK.** If dotfiles touched: `cd ~/dotfiles && stow
   --simulate <package>` — must be clean. Verify the symlink for
   any added path.
7. **Tag bump considered.** If the repo auto-tags on main (per
   `github` skill), is the next tag prepared? MINOR for
   features/conventions; MAJOR for breaking/restructure. Document
   the decision — including "no tag this branch" with a reason.

## Rationalization counters

- *"Tests pass; we're good."* — tests are item 1 of 7. The other
  six fail silently; that's why the checklist exists.
- *"I'll squash later."* — later is post-merge, where logical
  commits become impossible. Squash now.
- *"Sidecars are optional."* — required for non-trivial files
  touched. "Skip with justification" ≠ "skip silently."
- *"Ship it."* — unconditional surrender. Walk the list.

## Cross-references

- `plan-executor` — Phase 4 closeout for plan-driven branches.
  Defer; do not run both.
- `worktree-orchestrator` — worktree-cleanup mechanics if the
  branch lives in a worktree.
- `github` — push / PR / tag / release mechanics; encodes the
  per-repo tag conventions in item 7.
- `verification-before-completion` — sibling discipline. "Done"
  requires evidence at the artifact boundary; this skill is
  evidence at the branch boundary.

## When NOT to use

- In-progress check-ins / draft branches — closeout hasn't
  arrived.
- Plan-driven branches — defer to `plan-executor` Phase 4.
- Bot / dependency-update branches — diff is the description.
