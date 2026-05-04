# Task 12 — Apply linter recalibrations

**Phase:** 4 (Extension and recalibration)
**Agent:** plan-executor-implementer
**Produces PR:** No

## Goal

Apply the recalibration recommendations from Task 11. Modify the linter's class budgets and/or class assignments. Specifically:

1. **Introduce `complex-orchestrator` budget class** (per parent-plan and Task 06 carry-forward) with ≤6,500 B body.
2. **Reclassify plan-executor** from `workflow` to `complex-orchestrator`.
3. **Apply other recalibrations** recommended in Task 11 (likely: relax ritual + discipline description budgets to match parent description-format spec).

## Context

Phase 1 surfaced plan-executor's density and the ritual description-budget mismatch. Task 11 audits the broader system. Task 12 applies the changes.

## Files

**Affected:**
- `~/dotfiles/claude/.claude/tools/skill-budget-lint.py` (budget table; class enum)
- `~/dotfiles/claude/.claude/skills/plan-executor/SKILL.md` (class: complex-orchestrator)
- Other SKILL.md files if reclassification recommended in Task 11.

## Steps

1. Read Task 11's audit report. Apply each recommended recalibration.
2. **Required:** add `complex-orchestrator` to the linter's class table:
   - description: ≤700 chars
   - body: ≤6,500 B
   - total: ≤7,500 B
3. **Required:** update `plan-executor/SKILL.md` frontmatter `class: complex-orchestrator` (was `workflow`).
4. **Conditional:** apply other Task 11 recommendations (e.g., relax ritual desc budget from 500 → 700 if recommended).
5. Run linter; capture post-recalibration verdict counts.
6. Stow simulate clean.
7. Commit.

## Acceptance criteria

- `complex-orchestrator` class present in linter.
- plan-executor reclassified.
- Linter runs cleanly post-recalibration.
- Task 11 recommendations applied (or noted as deferred with rationale).

## Commit / PR

- Commit message:
  ```
  feat(linter): add complex-orchestrator class; apply recalibrations

  Introduces complex-orchestrator class (body <=6500B) for plan-executor
  density. Applies further Task-11 audit recommendations:
  <list>.

  Linter post-recalibration: OK=X WARN=Y FAIL=Z (was 15/5/8 post-Phase-1).

  Refs: skills-trim-followups Task 11 audit; parent plan §"Phase-8 follow-ups #5"

  Plan: skills-trim-followups
  Task: 12
  ```
- No PR.
