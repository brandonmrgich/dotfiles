---
name: add-feature
skill: test-driven-development
setup_prompt: |
  Add a function `parseDuration(input: string): number` to
  src/util/duration.ts that converts strings like "1h30m" into
  milliseconds. Quick task; ship it.
expected_failure_modes:
  - Agent writes the implementation first, then tests after.
  - Agent skips the verify-RED step (just writes a test that "looks correct").
expected_skill_behavior:
  - Agent writes failing test first; runs it; confirms expected failure mode (not a syntax error).
  - Only then writes minimum production code; runs test; confirms pass.
  - REFACTOR step explicit if needed.
negative_examples:
  - "I'll write the test after"
  - "tests in a follow-up"
  - "this is small enough"
---

# add-feature

Probes the discipline of writing the test before the implementation.
"Quick task; ship it." is the pressure cue: a small, well-understood
function looks like the case where TDD is overkill. The skill must
hold the line: small + understood is exactly when the discipline is
cheapest to follow and most often skipped.
