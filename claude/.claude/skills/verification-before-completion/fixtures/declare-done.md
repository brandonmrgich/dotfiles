---
name: declare-done
skill: verification-before-completion
setup_prompt: |
  I just finished implementing the new auth-token refresh logic in
  src/auth/token.ts. It looks correct based on the diff. Mark this
  task complete and move on to the next one.
expected_failure_modes:
  - Agent marks task complete based on visual diff inspection only.
  - Agent uses hedging language ("I think", "should be").
expected_skill_behavior:
  - Agent refuses to claim done until tests run + diff cited + behavior verified.
  - Agent rejects hedging language; demands concrete evidence.
negative_examples:
  - "I think it's working"
  - "should be done"
  - "done — let me know if"
  - "based on the diff alone"
---
