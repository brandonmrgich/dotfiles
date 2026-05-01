# Task 29 — Create finishing-a-branch skill

**Phase:** 6 (Ritual skills)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Add a `[HomebrewSkill] finishing-a-branch` skill: a closeout checklist
for ad-hoc feature branches that aren't plan-driven. Defers to
`plan-executor` Phase 4 when a plan is active.

## Context

Per essay #8 §"Gap 4", `plan-executor` Phase 4/5 covers closeout for
plan-driven work. Ad-hoc feature branches have no equivalent ritual.
This skill closes that gap.

Cross-references: `plan-executor` (defer to Phase 4 when active),
`worktree-orchestrator` (worktree cleanup), `github` (push/PR mechanics),
`verification-before-completion` (don't claim done without evidence).

## Files

**Created:**
- `~/dotfiles/claude/.claude/skills/finishing-a-branch/SKILL.md`

## Steps

1. RED — pressure-test: ask sub-agent "I think we're done with this
   branch — what's left?" without the skill; observe what it checks.
2. GREEN — write skill body:
   - Frontmatter: triggers like "finishing a branch", "ready to merge",
     "close out this work", "what's left before merging".
   - Body:
     - **Pre-flight check** — "is a plan active? if yes, defer to
       `plan-executor` Phase 4. else, run this skill."
     - **Checklist** —
       - Full test run passes (cite output).
       - Diff is clean (no debug code, no unrelated changes).
       - Commits are logical (squash candidates flagged).
       - All TODOs in changed code addressed or filed.
       - Sidecars updated for any non-trivial file touched (per
         `~/.claude/CLAUDE.md` sidecar conventions).
       - Stow OK if dotfiles touched.
       - Tag bump considered if auto-tag-on-main repo (cite `github` skill).
     - **Cross-refs** — `plan-executor`, `worktree-orchestrator`,
       `github`, `verification-before-completion`.
   - Target body: <500 words.
3. REFACTOR — iterate.
4. Stow + verify.
5. Commit + PR.

## Acceptance criteria

- [ ] Skill exists; pre-flight defer-to-plan-executor present.
- [ ] Checklist has ≥6 items.
- [ ] Cross-references to relevant skills present.
- [ ] PR description includes RED→GREEN→REFACTOR trace.

## Validation

- Activation: "ready to merge"; activates.
- Behavioral: WITH skill, dispatch on a scenario where a plan is active;
  confirm it defers to `plan-executor`. Without plan, confirm checklist
  fires.

## Commit / PR

- Commit message:
  ```
  feat(skill): add finishing-a-branch closeout ritual

  Closeout checklist for ad-hoc feature branches. Defers to
  plan-executor Phase 4 when a plan is active. Cross-refs github,
  worktree-orchestrator, verification-before-completion.

  Pressure-tested per references/skill-pressure-testing.md.

  Refs: essay skill-system-vs-superpowers.md §Gap 4

  Plan: skills-trim-and-discipline
  Task: 29
  ```
- PR target: `main`.
