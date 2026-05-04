---
name: "[HomebrewSkill] test-driven-development"
class: discipline
description: "Use when adding a feature, fixing a bug with a known reproduction, refactoring with behavior-preserving intent, or changing observable production behavior. Activates on phrases like 'add this function', 'implement X', 'fix this bug', 'let me write the implementation', 'I'll add tests after'. Enforces iron-law: NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST. Full cycle RED -> verify-RED -> GREEN -> verify-GREEN -> REFACTOR. Pre-test production code must be deleted and re-derived test-first. Do NOT trigger for typo fixes, comment-only changes, dependency bumps, or pure documentation."
---

# test-driven-development

## Iron law

**NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.**

A test that has not been observed to fail is not a test — it is a
hope. Production code written before its test is unmoored: nothing
proves the test would have caught its absence.

## The cycle

1. **RED** — write a failing test that names the behavior you want.
   One behavior per test; minimal assertions.
2. **verify-RED** — run the test. Confirm the failure message is the
   *expected* one: missing implementation, wrong return value, etc.
   A syntax error, import error, or wrong-assertion failure does not
   count as RED. If the failure mode is wrong, fix the test until it
   fails *correctly*.
3. **GREEN** — write the minimum production code that makes the test
   pass. No bonus features, no speculative branches.
4. **verify-GREEN** — run the test. Confirm pass. Run the broader
   test suite if cheap; confirm no regressions.
5. **REFACTOR** — clean both the test and the production code while
   the suite stays green. Stop when the shape is honest; do not
   polish indefinitely.

## Pre-test code deletion clause

If you have already written production code without its test:

- **Delete** the production code.
- Write the test (step 1).
- Verify it fails for the right reason (step 2).
- Re-derive the production code (step 3).

There is no "tests-after" amnesty. Tests written against existing
code reverse-engineer the implementation; they cannot catch the bugs
the implementation already encodes. The deletion is the discipline.

## Rationalization counters

- *"I'll write the test after — quicker to iterate against the
  implementation."* — Iterating against the implementation is the
  failure mode. The test exists to constrain the implementation, not
  describe it after the fact. If the test is downstream of the code,
  it will mirror the code's bugs.
- *"This change is small enough that a test would slow me down."* —
  Small + understood is exactly when the discipline is cheapest to
  follow. The cost of skipping is not measured today; it is measured
  the next time someone touches this code without context.
- *"I'll add tests in a follow-up commit."* — Follow-up commits do
  not happen reliably, and a test added later cannot prove RED — the
  code already passes. A follow-up test is a description, not a
  constraint.

## Cross-references

- `plan-executor-tester` agent — plan-scoped test authoring runs
  this same cycle inside the orchestrator's dispatch model.
- Sibling skill `verification-before-completion` — GREEN's
  verify-step is the same evidence discipline: cite the test
  output, do not claim "should pass".
- Sibling skill `systematic-debugging` — the FIX phase ends in a
  RED-then-GREEN flip on the captured reproduction; this skill is
  how that flip is performed.

## When NOT to use

- Typo fixes, comment-only changes.
- Dependency version bumps with no behavior change.
- Pure documentation edits.
- Generated-code regeneration (the generator is what's tested).
