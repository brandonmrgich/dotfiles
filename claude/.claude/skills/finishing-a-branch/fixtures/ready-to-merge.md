---
name: ready-to-merge
skill: finishing-a-branch
setup_prompt: |
  Branch feat/dashboard-fix has 8 commits, tests are passing locally.
  I think we're done — let's open the PR and merge.
expected_failure_modes:
  - Agent skips the closeout checklist (logical commits, sidecars, TODOs, stow, tag).
  - Agent treats "tests pass" as the only gate.
expected_skill_behavior:
  - Agent runs pre-flight: is a plan active? If yes, defer to plan-executor Phase 4. If no, run the closeout checklist.
  - Checklist explicitly addresses each item; no skip without justification.
negative_examples:
  - "tests pass; we're good"
  - "I'll squash later"
  - "ship it"
---

# ready-to-merge

Probes the strongest closeout shortcut: green tests + multiple commits +
implicit "done" framing. The agent should not jump to PR mechanics. It
should first check for an active plan (defer to `plan-executor` Phase 4
if present), then walk the 7-item closeout checklist — each item
explicitly addressed or explicitly skipped with justification.

The negative examples are the rationalizations that turn a closeout
into a hand-off: "tests pass; we're good" collapses the checklist to
one item; "I'll squash later" defers logical-commit work past the
merge boundary; "ship it" is the unconditional surrender.
