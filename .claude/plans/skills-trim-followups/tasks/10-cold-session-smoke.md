# Task 10 — Cold-session smoke test (manual user-run)

**Phase:** 3 (Cleanup + closeout)
**Agent:** USER (this is not an agent task)
**Produces PR:** No

## Goal

Empirically verify the cumulative skill-system token reduction from a fresh Claude Code session. Closes the deferred-5-times check from parent plan audits 04, 13, 18, 25, 30, 37.

## Context

Throughout the parent plan, every audit gate deferred this check because an in-flight auditor cannot launch a fresh top-level Claude session. This is the capstone empirical validation.

## Files

**Possibly affected:**
- `audits/10-cold-session-smoke.md` — record of the user's observation.

## Steps (user runs)

1. Open a fresh Claude Code session in `~/dotfiles` (or anywhere).
2. Type a generic question that should NOT trigger any skill (e.g., "what time is it?" or "summarize the last commit").
3. Observe the visible context-utilization indicator (statusline shows it).
4. Compare to subjective sense of pre-plan sessions. Or if a snapshot of pre-plan utilization exists from audit 04, compare quantitatively.
5. Optionally: test a few skill activations (`/zoom-in <task>`, `let me write an essay`, `model a DDEX ERN message`) — verify each still activates correctly.
6. Record observation in `audits/10-cold-session-smoke.md`:
   - Cold-session context utilization (rough %).
   - Comparison to pre-plan baseline (if any).
   - Activation smoke test results.
   - Verdict: PASS / FAIL / INCONCLUSIVE.

## Acceptance criteria

- [ ] Audit file written by user.
- [ ] Verdict recorded.
- [ ] Closes deferred-check carry-forward from parent plan audits.

## Notes

- This is a USER task. Orchestrator does not execute. Closeout (Task 11) waits for the user to land this audit file before opening the closeout PR.
- If user skips: that's acceptable. Closeout still runs; the deferred check stays deferred indefinitely. No regression risk to land the closeout without it.

## No commit (or single commit if user adds the audit file)

If user writes the audit file:
```
chore(plan): cold-session smoke test verdict

Audit per parent plan deferred check (audits 04/13/18/25/30/37). Verdict:
<PASS|FAIL|INCONCLUSIVE>.

Refs: parent plan skills-trim-and-discipline §"Phase-8 follow-ups #6"

Plan: skills-trim-followups
Task: 10
```
