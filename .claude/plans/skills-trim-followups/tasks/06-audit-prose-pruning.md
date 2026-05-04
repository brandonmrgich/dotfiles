# Task 06 — Audit gate: Phase 1 prose pruning

**Phase:** 1 (audit gate)
**Agent:** plan-auditor (orchestrator-run per locked protocol)
**Produces PR:** No (audit report only)

## Goal

Verify all 5 Phase 1 trims hit budget; activation regressions absent; cumulative body delta material.

## Steps

1. Re-run linter:
   ```bash
   python3 ~/.claude/tools/skill-budget-lint.py
   ```
2. Capture per-skill OK/WARN/FAIL transition vs Task 00 baseline. Goal: 5 of 5 transitions out of FAIL (ideally to OK; WARN acceptable).
3. Activation regression sweep — for each of the 5 trimmed specialists, confirm canonical trigger phrase still activates.
4. Body-content preservation check — diff each trimmed SKILL.md against pre-trim. Confirm:
   - All keywords from pre-trim description's pool still appear in pre-trim or post-trim content.
   - Pitfalls / decision tables intact.
   - Cross-refs (references/, examples/, patterns/) intact.
5. Compute cumulative body bytes saved across the 5 trims. Compare to Phase 1 expectation (~7-9k B saved).
6. Write `audits/06-prose-pruning-audit.md`:
   - Per-skill before/after table.
   - FAIL→OK/WARN transitions.
   - Activation sweep results.
   - Cumulative body delta.
   - Verdict: PASS / CONDITIONAL PASS / FAIL.

## Acceptance criteria

- [ ] All 5 Phase 1 commits present.
- [ ] At least 4 of 5 skills moved out of FAIL.
- [ ] No activation regressions.
- [ ] Audit report written.

## Failure handling

- 0-3 FAIL→OK transitions: PARTIAL; surface to user; user decides whether to push another round of trim or accept.
- ≥1 activation regression: FAIL; surface; user decides whether to revert specific trim.
- Otherwise: PASS or CONDITIONAL PASS (explain conditions).

## No commit

Audit report written to `audits/`; no separate commit (rolls into closeout PR).
