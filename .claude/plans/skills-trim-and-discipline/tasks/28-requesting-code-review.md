# Task 28 — Create requesting-code-review skill

**Phase:** 6 (Ritual skills)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Add a `[HomebrewSkill] requesting-code-review` skill: a checklist for
what to include when asking for review (or when requesting via the
`code-reviewer` sub-agent).

## Context

Per essay #8 §"Gap 3", the receiving half landed in Task 27. Requesting
is the lower-priority half — but pairs with the existing pr-review-toolkit's
`code-reviewer` agent and the auto-reviewer activation pattern.

## Files

**Created:**
- `~/dotfiles/claude/.claude/skills/requesting-code-review/SKILL.md`

## Steps

1. RED — pressure-test: ask sub-agent to "request review on this PR"
   without skill; observe what context it gathers.
2. GREEN — write skill body:
   - Frontmatter: triggers like "request review", "code review my
     changes", "ready for review".
   - Body:
     - **Checklist before requesting** —
       - Diff is reviewable (no whitespace noise, no unrelated changes).
       - Description states intent, scope, and tradeoffs.
       - Test plan is concrete (steps, not "verify it works").
       - Areas of concern explicitly flagged ("I'm uncertain about X").
       - Self-review pass complete.
     - **Cross-ref** — `pr-review-toolkit:code-reviewer` agent for
       auto-review; sibling `receiving-code-review` for response.
   - Target body: <500 words.
3. REFACTOR — iterate.
4. Stow + verify.
5. Commit + PR.

## Acceptance criteria

- [ ] Skill exists; checklist has ≥5 items.
- [ ] Cross-references to existing review agents and sibling skill.
- [ ] PR description includes RED→GREEN→REFACTOR trace.

## Validation

- Activation: "ready for review"; activates.
- Behavioral: dispatch agent on a PR-prep scenario WITH skill; observe
  whether it surfaces the checklist before requesting.

## Commit / PR

- Commit message:
  ```
  feat(skill): add requesting-code-review ritual skill

  Pre-request checklist: reviewable diff, intent stated, test plan
  concrete, concerns flagged, self-review complete. Cross-refs the
  pr-review-toolkit code-reviewer agent.

  Pressure-tested per references/skill-pressure-testing.md.

  Refs: essay skill-system-vs-superpowers.md §Gap 3

  Plan: skills-trim-and-discipline
  Task: 28
  ```
- PR target: `main`.
