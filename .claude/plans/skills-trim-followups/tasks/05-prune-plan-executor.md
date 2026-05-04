# Task 05 — Prose-prune plan-executor body

**Phase:** 1 (Prose pruning)
**Agent:** plan-executor-implementer
**Produces PR:** No

## Goal

Trim `plan-executor/SKILL.md` body to ≤4,000 B (workflow budget). Pre-followup: 9,873 B body — 5,873 B over budget. Significant gap.

## Context

This is the largest workflow over-budget. Parent plan Phase 2 already trimmed plan-executor from 19k → 9.7k by extracting plan-generation, plan-system, plan-failure-handling references. Phase 7 added back ~1k for task-quality gate + anchor-chain nudges. Remaining body is dense: operating principles, phase outline, dispatch loop, return format, what-you-must-never-do list, how-the-user-invokes-you examples.

**Critical:** the workflow budget (≤4,000 B body) may be unrealistic for this skill. plan-executor is the heaviest orchestrator and inherently dense. **Acceptance for this task: ≤6,000 B body** (50% over budget, but materially smaller). If 4,000 isn't reachable without losing operating semantics, propose a "complex-orchestrator" budget class for Phase 8 of THIS plan to formally accept it.

## Files

**Affected:**
- `~/dotfiles/claude/.claude/skills/plan-executor/SKILL.md`

## Steps

1. Identify trim candidates:
   - Phase outlines — keep header lines, trim sub-bullets to single sentences.
   - "How the user invokes you" examples — trim from N examples to 2-3.
   - "What you must never do" list — keep list; tighten each bullet.
   - Failure-calibration prose around the existing table — should mostly point to `references/plan-failure-handling.md` already; trim.
   - Required sub-agent return format — already concise; verify can't trim further.
   - Anchor-chain nudges (added Phase 7) — keep, but tighten if verbose.
2. **Preserve:**
   - Operating principles (load-bearing for orchestrator behavior).
   - Phase 0/1/2/3/4/5 outline and phase numbers.
   - The Required sub-agent return format block.
   - Cross-refs to `references/plan-system.md`, `references/plan-generation.md`, `references/plan-failure-handling.md`.
   - Footer/cleanup procedure.
3. Run linter; verify FAIL → WARN or OK.
4. Smoke-test: dispatch plan-executor on a small fixture; confirm orchestration semantics intact.
5. Commit.

## Acceptance criteria

- [ ] Body ≤6,000 B (relaxed target acknowledging workflow budget gap).
- [ ] All operating principles preserved.
- [ ] Phase outline structure preserved.
- [ ] Required-return-format block intact.
- [ ] All references/ pointers preserved.
- [ ] Linter shows plan-executor moved from FAIL → WARN (or better).

## Commit / PR

- Commit message:
  ```
  refactor(skill): prose-prune plan-executor body

  Trim phase-outline sub-bullets and how-user-invokes examples; preserve
  operating principles, phase outline, required return format, references
  pointers. Body NNNN -> MMMM B (target <=6,000 B; workflow budget
  4,000 B is unrealistic for this orchestrator's density).

  Refs: parent plan skills-trim-and-discipline §"Phase-8 follow-ups #5"

  Plan: skills-trim-followups
  Task: 05
  ```
