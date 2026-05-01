# Task 32 — Anchor-chain nudges in plan-executor and essay

**Phase:** 7 (Existing-skill upgrades)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Add soft warnings to `plan-executor` Phase 0 (initialize) and `essay`
Resolve mode when the anchor chain (`idea → essay → plan → doc → code`)
is broken or absent.

## Context

Per essay #8 §"Gap 10", the anchor chain is documented but not enforced.
No skill checks "you're starting a plan — is there an essay it's
`from-essay:`'d to?" or "you're producing a doc — does it have
`from-plan:` or `covers:` set?".

This task adds *nudges*, not blocks. Anchor chains can have legitimate
gaps (a plan that arose without a prior essay because scope was clear).
The nudge surfaces the gap so the user can confirm intent.

## Files

**Affected:**
- `~/dotfiles/claude/.claude/skills/plan-executor/SKILL.md`
- `~/dotfiles/claude/.claude/skills/essay/SKILL.md`

## Steps

1. In `plan-executor` Phase 0:
   - Read the master plan's frontmatter.
   - If `from-essay:` is missing or empty, surface a soft warning:
     "No essay anchored to this plan. Intentional? (Y to continue,
     N to revisit and add `from-essay:`.)"
   - If `affects-docs:` is missing or empty AND the plan is non-trivial
     (>5 tasks), surface: "No `affects-docs:` declared. If this plan
     touches doc-bearing code paths, declare them now for downstream
     verification."
   - Both nudges; neither blocks.
2. In `essay` Resolve mode:
   - When marking an essay `status: resolved`, check `anchors.produced`
     is populated.
   - If empty, surface: "Essay being resolved without anchored
     produced artifacts. Confirm: was this essay informational only,
     or did it produce a plan/doc that should be linked?"
3. Stow + verify.
4. Commit + PR.

## Acceptance criteria

- [ ] `plan-executor` Phase 0 surfaces both nudges when applicable.
- [ ] `essay` Resolve mode surfaces the nudge.
- [ ] Neither nudge blocks; both can be acknowledged.
- [ ] PR description includes example outputs of each nudge.

## Validation

- Run plan-executor against a master plan with no `from-essay:`;
  observe the nudge.
- Run essay Resolve on an essay with empty `anchors.produced`;
  observe the nudge.
- Run both against fully-anchored cases; observe no nudge fires.

## Commit / PR

- Commit message:
  ```
  feat(skills): anchor-chain nudges in plan-executor and essay

  Soft warnings (not blocks) when from-essay/affects-docs/anchors.produced
  are missing. Surfaces anchor-chain gaps without enforcing them.

  Refs: essay skill-system-vs-superpowers.md §Gap 10

  Plan: skills-trim-and-discipline
  Task: 32
  ```
- PR target: `main`.
