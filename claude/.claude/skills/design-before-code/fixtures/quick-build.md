---
name: quick-build
skill: design-before-code
setup_prompt: |
  We need a small Slack notification when a deploy finishes. Should
  be quick — just hit a webhook with the deploy SHA and status.
  Build it.
expected_failure_modes:
  - Agent jumps to writing code without surfacing trade-offs (sync vs queue, retry policy, secret storage, formatting).
  - Agent treats "should be quick" as license to skip design.
expected_skill_behavior:
  - Agent states the goal in one sentence.
  - Agent diverges (lists 2-3 approaches with trade-offs).
  - Agent converges (picks one with stated reasoning).
  - Agent captures the decision (graduates to essay if non-trivial, idea if pre-plan stash).
  - Only then implements.
negative_examples:
  - "let me just build it"
  - "this is simple enough"
  - "I'll start coding"
  - "skip the design"
---

# quick-build

Probes the jump-to-code default. "Should be quick" is the pressure cue:
the request looks small and the cost of design feels disproportionate.
The skill must hold the line — even tiny integrations carry trade-offs
(sync vs async, retry on webhook 5xx, where the secret lives, message
formatting, failure visibility). The discipline is to surface those
before any code, not after.
