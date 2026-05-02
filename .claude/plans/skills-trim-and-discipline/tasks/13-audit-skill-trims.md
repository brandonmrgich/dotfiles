# Task 13 — Audit gate: heavy SKILL.md trims

**Phase:** 2 (audit gate)
**Agent:** plan-auditor (skill)
**Produces PR:** No (audit report only)

## Goal

Verify the cumulative effect of Tasks 05–12: eight SKILL.md files
trimmed; six new references and ~12 example/pattern files created.
Verify reference loading semantics — references are pulled by Claude
when SKILL.md *points* at them, not eagerly inlined. Confirm no broken
cross-references.

## Steps

1. Re-measure each affected SKILL.md:
   ```bash
   for s in plan-executor plan-auditor skill-author web-audio-howler nextjs-app-router turborepo-patterns astro-static-sites royalty-splits-music; do
     wc -c ~/.claude/skills/$s/SKILL.md
   done
   ```
   Compare to baseline. Confirm each is in the target range from its
   task file.
2. Re-measure all references and examples cumulatively. The relocated
   bytes should ≈ original SKILL.md savings (within ~5% — losses
   accounted for by dedupe and pointer-stub overhead).
3. Cross-reference check: for every "see `references/X.md`" or
   "see `examples/Y.example.ts`" pointer in any SKILL.md, confirm the
   target file exists and is reachable.
4. Smoke test — plan-executor activation:
   - Open a fresh session.
   - Trigger plan-executor with "execute the plan at <test path>".
   - Observe whether `references/plan-system.md`,
     `references/plan-generation.md`, `references/plan-failure-handling.md`
     are *consulted on demand* (i.e., when Claude needs them, it reads
     them via Read tool — they should NOT be auto-inlined as part of
     skill activation).
5. Smoke test — domain specialist activation:
   - Open a fresh session in a Next.js context.
   - Ask "how do I add a BFF proxy?"
   - Observe whether the SKILL.md body answers via prose + a pointer
     to the pattern example, or eagerly slurps the example.
6. Per-skill budget pre-check (Phase 8 will formalize this; here just
   eyeball):
   - Domain specialists: SKILL.md ≤6,500 bytes.
   - Workflow skills: SKILL.md ≤8,500 bytes (plan-executor is largest).
   - Capture skills: SKILL.md ≤8,500 bytes (essay is largest).
7. Write `audits/13-skill-trims-audit.md`:
   - Per-skill before/after table.
   - Cumulative savings (bytes, tokens) vs essay #9 projection.
   - Cross-reference verification results.
   - Smoke-test observations.
   - Verdict and recommendation.

## Acceptance criteria

- [ ] All 8 SKILL.md files within target ranges.
- [ ] All references and examples present and reachable.
- [ ] Smoke tests confirm references load on demand, not eagerly.
- [ ] Audit report written.

## Failure handling

- Per-file under-trim: mark as a Phase-8 follow-up task; do not block.
- Per-file over-trim (load-bearing content moved): halt; produce
  failure report; user decides remediation.
- Reference fails to load: this is a structural issue. Halt.

## No commit
