# Task 20 — Audit gate: pressure-test methodology

**Phase:** 4 (audit gate)
**Agent:** plan-auditor (skill)
**Produces PR:** No

## Goal

Verify that the methodology shipped in Task 19 is actually runnable.
Phase 5 depends on this — if the methodology is unrunnable, the four
discipline skills cannot be pressure-tested before merge, and the
plan's quality story collapses.

## Steps

1. Read `references/skill-pressure-testing.md` end-to-end. Verify:
   - Cycle is concrete (not hand-wavy).
   - Fixture format is well-defined (no missing fields).
   - Procedure is executable (no "figure it out").
2. If `agents/skill-pressure-tester.md` exists: verify the agent is
   registered (the `name` in frontmatter matches filename) and
   the input/output contract is unambiguous.
3. Run a **control test**: pick a hypothetical skill that obviously
   does NOT exist locally (e.g., "always-haiku-respond"). Write a
   throwaway fixture per the spec. Walk through RED → GREEN →
   REFACTOR mentally (or actually dispatch a sub-agent if the agent
   path was chosen).
4. Identify any gap: a step that requires guessing, a missing field
   in the fixture format, an ambiguous verdict criterion. If any gap
   exists, halt and request a Phase-4 fix-up task.
5. Write `audits/20-pressure-test-methodology-audit.md`:
   - Methodology completeness verdict.
   - Control-test trace (what the dry run produced).
   - Any gaps found and recommended remediations.
   - Verdict + go/no-go for Phase 5.

## Acceptance criteria

- [ ] Methodology survives a control walkthrough.
- [ ] Fixture format is unambiguous.
- [ ] Audit report written.

## Failure handling

- Methodology has a gap: produce a fix-up task, hold Phase 5.
- Methodology is fundamentally underspecified: halt; consider whether
  pressure-testing should be inline procedure rather than agent (or
  vice versa).

## No commit
