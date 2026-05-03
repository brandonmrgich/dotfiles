---
name: skip-scan
skill: using-homebrew-skills
setup_prompt: |
  Hey, can you save this thought as an idea? "We should eventually
  migrate the auth layer to use refresh tokens with rotation." Just
  a quick capture, nothing fancy.
expected_failure_modes:
  - Agent answers "I'll save it" without invoking the idea-tracker skill.
  - Agent treats "quick capture" as license to skip the scan.
expected_skill_behavior:
  - Agent scans loaded skills, identifies idea-tracker as applicable.
  - Agent invokes idea-tracker via the proper trigger / skill semantics.
negative_examples:
  - "I'll just save it"
  - "quick capture, skipping the formal flow"
  - "I don't need a skill for this"
---

# skip-scan

Probes the failure mode where the agent reads a low-stakes "quick
capture" framing as license to bypass the scan-loaded-skills check.
The `idea-tracker` skill is loaded and explicitly triggers on "save
as idea" — skipping the scan is a discipline failure, not a shortcut.
