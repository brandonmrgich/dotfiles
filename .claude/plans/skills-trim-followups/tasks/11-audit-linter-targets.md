# Task 11 — Audit linter target values

**Phase:** 4 (Extension and recalibration)
**Agent:** plan-executor-discovery
**Produces PR:** No (audit report only)

## Goal

Audit the per-class budget values embedded in `~/.claude/tools/skill-budget-lint.py`. Where did they come from? Are they justified? Which need recalibration based on actual skill content?

User-flagged at Phase 1 audit: "these values seem arbitrary, how were they chosen?"

## Context

Parent plan Task 34 (essay #9 §P3.1) introduced the linter and class budgets. The budgets currently are:

| Class | Description | Body | Total |
|---|---|---|---|
| specialist | ≤1024 | ≤6000 | ≤8000 |
| workflow | ≤500 | ≤4000 | ≤5000 |
| capture | ≤500 | ≤4000 | ≤5000 |
| policy | ≤400 | ≤3500 | ≤4500 |
| meta | ≤700 | ≤5000 | ≤6000 |
| ritual | ≤500 | ≤4000 | ≤5000 |
| discipline | ≤700 | ≤4000 | ≤5000 |

Phase 1 surfaced two budget-vs-content tensions:
- **plan-executor body** trimmed to 6,497 B; workflow strict 4,000 B unreachable.
- **Multiple ritual descriptions** authored to ≤1024 char (parent description-format spec) but FAIL the 500-char ritual budget.

These are budget mismatches, not content failures. This task identifies which budgets are wrong vs which content is wrong.

## Files

**Read-only:**
- `~/.claude/tools/skill-budget-lint.py` (source of budgets)
- `~/.claude/essays/skill-system-token-efficiency-audit.md` §P3.1 (origin of budgets)
- All 28 SKILL.md files (per-skill content; informs whether budget matches reality)

**Created:**
- `audits/11-linter-targets-audit.md`

## Steps

1. **Trace origin.** Read essay #9 §P3.1 to find the explicit rationale (or absence thereof) for each class budget. Cite the essay's reasoning verbatim.

2. **Per-class measurement vs budget.** For each of the 7 classes, compute:
   - Member skills (e.g., specialist = nextjs, ddex, web-audio, etc.)
   - Median description char count, body byte count.
   - Distribution: how many are within band, in WARN tier, FAILing.
   - Tightest (smallest) and loosest (largest) member.

3. **Identify mismatches.** Three patterns:
   - **Budget too tight** — the class has multiple compliant skills failing on a budget they were authored to meet. Most common in description budgets if Phase 3 description format spec authored to ≤1024 but linter enforces 500.
   - **Budget about right** — most members in band; outliers are genuinely over-content.
   - **Budget too loose** — most members well under budget; budget could tighten.

4. **Recommend recalibrations.** Per class, propose:
   - Keep / tighten / loosen.
   - For loosen: by how much, with rationale (cite the median + max).
   - Note: ritual + discipline classes may need separate description budgets reflecting their compliance with the parent description-format spec (≤1024 chars).

5. **Recommend new classes (if any).** plan-executor's density suggests a "complex-orchestrator" budget class (≤6,500 B body). Audit whether any other skills justify joining this class.

6. **Write `audits/11-linter-targets-audit.md`:**
   - Origin trace per class (citing essay #9).
   - Per-class measurement table.
   - Recommended recalibrations + rationale.
   - Recommended new classes (if any).

7. Commit.

## Acceptance criteria

- Audit report written.
- All 7 current classes audited.
- Recommended recalibrations stated with rationale.
- Complex-orchestrator class addressed (yes/no recommendation).

## Commit / PR

- Commit message:
  ```
  docs(plan): audit per-class budget targets in skill-budget-lint

  Per-class origin trace, measurement vs budget, recommendations for
  recalibration. plan-executor + complex-orchestrator class addressed.
  Phase-1 audit flagged class budgets as feeling arbitrary; this audit
  surfaces which are calibrated vs which need adjustment.

  Refs: parent plan skills-trim-and-discipline §"Phase-8 follow-ups";
        skills-trim-followups Task 06 audit.

  Plan: skills-trim-followups
  Task: 11
  ```
- No PR — closeout PR aggregates.
