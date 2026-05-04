# Task 08 — Audit gate: Phase 2 RED dispatches

**Phase:** 2 (audit gate)
**Agent:** plan-auditor (orchestrator-run)
**Produces PR:** No

## Goal

Verify Task 07 captured real rationalizations for all 8 skills, that any body updates didn't break activation, and that the discipline+ritual skills now have empirical (not hypothetical) anti-rationalization coverage.

## Steps

1. Read `audits/07-red-dispatches-summary.md`. Verify all 8 skills covered.
2. For each skill where the body was updated:
   - Run the linter against that skill — verify within budget post-update.
   - Smoke-test activation via canonical trigger phrase.
   - Re-dispatch the GREEN test (with skill loaded) against the original fixture; confirm the agent now resists the captured rationalization.
3. For each skill where the body was unchanged:
   - Note in the audit that the hypothetical rationalizations from the parent plan are now empirically validated (or close enough; the captured RED rationalizations matched what the parent plan anticipated).
4. Aggregate: did any new rationalizations surface that NONE of the skills' bodies counter? If yes, that's a finding for the next iteration.
5. Write `audits/08-red-dispatches-audit.md`:
   - Per-skill verdict (BODY UPDATED / NO-CHANGE-NEEDED / FIXTURE-WEAK).
   - Cumulative body delta from Task 07 updates.
   - Universal rationalization library updates (if applicable).
   - Verdict: PASS / CONDITIONAL PASS / FAIL.

## Acceptance criteria

- [ ] All 8 skills audited.
- [ ] Body updates preserve budget.
- [ ] No activation regressions.
- [ ] Audit report written.

## Failure handling

- Skill body update breaks activation: revert that update; flag for Phase 3 user decision.
- A captured rationalization can't be countered without major skill restructuring: surface; user decides whether to accept (CONDITIONAL PASS) or queue redesign as a future plan.

## No commit
