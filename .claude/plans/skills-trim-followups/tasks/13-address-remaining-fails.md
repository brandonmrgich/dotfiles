# Task 13 — Address remaining FAILs

**Phase:** 4 (Extension and recalibration)
**Agent:** plan-executor-implementer
**Produces PR:** No

## Goal

After Task 12 recalibrations, prose-prune any skills still genuinely over a *reasonable* budget. Phase 1 left 7 skills FAIL out of scope; Tasks 11+12 may convert several of those to OK/WARN via recalibration. Whatever remains over-budget after recalibration: trim here.

Pre-Phase-4 FAILs (post-Phase-1 lint): essay, finishing-a-branch, plan-auditor, receiving-code-review, requesting-code-review, session-ready, worktree-orchestrator, plan-executor (last addressed via reclassification in Task 12).

## Context

Many of these FAILs are description-budget gaps that recalibration in Task 12 should resolve. The remaining ones are body-overage on skills that genuinely need trimming.

## Files

**Affected:** any SKILL.md still FAIL after Task 12 recalibration. Likely subset:
- essay (capture body 8,365 over 4,000 — genuinely over even a relaxed budget)
- session-ready (workflow body 4,947; potentially OK after recalibration)
- worktree-orchestrator (workflow body 5,019; potentially OK after recalibration)
- plan-auditor (workflow body 5,823 — over even if desc cap relaxed)

## Steps

1. Re-run linter post-Task-12. Identify skills still FAIL.
2. For each remaining FAIL, prose-prune body following Phase 1 pattern:
   - Identify trim candidates (verbose prose, foldable sub-sections, redundant explanations).
   - Preserve identifier keywords, decision tables, pitfalls lists, cross-refs.
   - Target: in band or WARN tier.
3. Per-skill commit using same convention as Phase 1 trims.
4. Re-run linter; report final OK/WARN/FAIL counts.

## Acceptance criteria

- Post-Task-13 linter shows substantial reduction in FAIL count.
- All trims preserve activation triggers (description keywords) and load-bearing content.
- Each trim has its own commit with `Plan: skills-trim-followups`, `Task: 13` footers (one task across multiple skills is OK; or split into per-skill tasks if cleaner).

## Notes for orchestrator

- This task is a "do whatever's left" mop-up. Scope depends on Task 12 outcomes.
- If Task 12 fully resolves all FAILs (e.g., recalibrations close all gaps), Task 13 is a no-op — note that and move on.
- If 1-2 skills are stubbornly over budget and the trim would lose load-bearing content, accept as known exception (similar to plan-executor in Phase 1) and document.

## Commit / PR

- Per-skill commits as above. No PR — closeout PR aggregates.
