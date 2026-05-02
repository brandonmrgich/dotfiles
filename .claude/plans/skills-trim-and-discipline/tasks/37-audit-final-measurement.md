# Task 37 — Audit gate: full re-measurement

**Phase:** 8 (audit gate)
**Agent:** plan-auditor (skill)
**Produces PR:** No

## Goal

Final compound-savings re-measurement before closeout. Recompute essay
#9's full Compound-savings projection table with **real numbers**.
Compare to the projection. Document the actual outcome.

## Steps

1. Re-run all baseline measurements:
   ```bash
   for f in ~/.claude/CLAUDE.md ~/.claude/skills/*/SKILL.md ~/.claude/references/*.md ~/.claude/agents/*.md ~/.claude/mantras/*.md ~/.claude/environment/*.md; do
     wc -c "$f"
   done
   ```
2. Re-extract every description's char count.
3. Compute the always-loaded baseline: CLAUDE.md + sum(descriptions).
   Compare to Task 00 baseline.
4. Recompute Scenarios A–F from essay #9 §"Activation scenarios":
   - A — Cold session
   - B — Routine code (Next.js)
   - C — Music platform feature
   - D — Plan execution
   - E — Worst plausible compound
   - F — Doc audit
   For each, sum the bytes of all components per the essay's tables but
   using current values.
5. Compute % savings vs essay #9's Before column. Compare to projection
   (~40% average).
6. Smoke tests:
   - Cold-session token cost.
   - Plan-executor activation on a small fixture.
   - Doc-audit session.
   For each, observe context-utilization indicator and compare to
   pre-plan baseline.
7. Activation regression sweep: run all 24 skills' canonical triggers;
   confirm each activates correctly.
8. Per-class budget compliance: run `skill-budget-lint.sh` from Task 34;
   confirm any over-budget skills are flagged for follow-up.
9. Write `audits/37-final-measurement-audit.md`:
   - Per-file before/after table (full).
   - Always-loaded baseline before/after with % delta.
   - Scenario A–F with measured before/after and % saved.
   - Cold-session smoke observations.
   - Activation regression results.
   - Budget compliance summary.
   - Items that fell short of projection (with explanation).
   - Items that exceeded projection (and why).
   - Verdict + recommendation for closeout.

## Acceptance criteria

- [ ] All scenarios recomputed with real numbers.
- [ ] Average % savings within ±10% of essay #9 projection (40%).
- [ ] No activation regressions.
- [ ] Audit report written with full data.

## Failure handling

- Average savings <30%: investigate. Likely culprits: under-trimmed
  CLAUDE.md (Phase 1), under-trimmed plan-executor (Phase 2), or
  description bloat from new skills (Phases 5–6).
- Activation regression: triage; fix-up tasks before closeout.
- Budget violations: Phase 8 follow-up after closeout (do not block).

## No commit
