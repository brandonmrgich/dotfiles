# Task 23 — Create test-driven-development skill

**Phase:** 5 (Discipline skills)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Add a `[HomebrewSkill] test-driven-development` skill enforcing
RED → verify-RED → GREEN → verify-GREEN → REFACTOR with iron-law
language. Pre-test code must be deleted.

## Context

Per essay #8 §"Gap 1", adapt superpowers' `test-driven-development`.
The local `plan-executor-tester` agent writes tests in plan contexts but
no skill enforces TDD discipline on regular work. This skill applies
broadly.

Cross-references: `plan-executor-tester` agent (delegate-to in plan
contexts).

## Files

**Created:**
- `~/dotfiles/claude/.claude/skills/test-driven-development/SKILL.md`

## Steps

1. RED — pressure-test without skill: ask sub-agent to "add a feature
   to module X." Observe whether it writes test or code first.
2. GREEN — write skill body:
   - Frontmatter: standard.
   - Body:
     - **Iron law** — "NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST."
     - **Cycle** — RED (write test), verify-RED (run; confirm failure
       message is the expected one — not a syntax error), GREEN
       (write minimum code), verify-GREEN (run; confirm pass),
       REFACTOR (clean both).
     - **Pre-test code deletion clause** — if test was written *after*
       any production code, delete the production code and start over.
     - **Cross-refs** — `plan-executor-tester` for plan-scoped work,
       `verification-before-completion` (sibling).
   - Target body: <500 words.
3. REFACTOR — iterate.
4. Stow + verify.
5. Commit + PR.

## Acceptance criteria

- [ ] Skill exists; frontmatter compliant.
- [ ] Iron law present; verify-step explicit.
- [ ] Pre-test code deletion clause present.
- [ ] PR description includes RED→GREEN→REFACTOR trace.

## Validation

- Activation: "let's add a feature to X"; skill activates.
- Behavioral: dispatch sub-agent WITH skill; observe test-first flow.

## Commit / PR

- Commit message:
  ```
  feat(skill): add test-driven-development discipline skill

  Iron law: NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST. Full cycle
  (RED -> verify-RED -> GREEN -> verify-GREEN -> REFACTOR) with the
  pre-test-code deletion clause.

  Pressure-tested per references/skill-pressure-testing.md.

  Refs: essay skill-system-vs-superpowers.md §Gap 1

  Plan: skills-trim-and-discipline
  Task: 23
  ```
- PR target: `main`.
