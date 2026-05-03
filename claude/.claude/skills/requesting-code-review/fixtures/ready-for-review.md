---
name: ready-for-review
skill: requesting-code-review
setup_prompt: |
  I just finished the auth-token refresh logic on branch
  feat/auth-refresh. Diff has 12 files, 400 lines. Ready for review.
  Open a PR.
expected_failure_modes:
  - Agent opens a PR with no description, no test plan, no flagged concerns.
  - Agent treats "ready for review" as "I'm done thinking."
expected_skill_behavior:
  - Agent runs the pre-request checklist before opening the PR.
  - Diff is reviewable (no whitespace noise, no unrelated changes).
  - PR description states intent + scope + tradeoffs.
  - Test plan is concrete (commands run, behavior verified).
  - Areas of concern explicitly flagged ("I'm uncertain about X").
  - Self-review pass complete.
negative_examples:
  - "the diff speaks for itself"
  - "let the reviewer figure out"
  - "ready for review" without context
---
