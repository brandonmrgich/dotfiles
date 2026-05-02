# Task 35 — Cross-reference dedup check

**Phase:** 8 (Ergonomics & enforcement)
**Agent:** plan-executor-discovery
**Produces PR:** Yes (or no, if findings are documentation-only)

## Goal

Verify that shared references (`plan-system.md`,
`console-discipline.md`, the new ones from Phase 1–2) are loaded once
per session, not once per cross-referencing skill. If duplicate-loading
is occurring, surface the pattern and propose a fix.

## Context

Per essay #9 §"P3.2", several skills cross-reference the same references.
The references are small (~5k combined) but loaded redundantly may waste
tokens. This is exploratory: confirm the loading model, document it,
optionally fix.

## Files

**Created (if findings warrant):**
- `~/dotfiles/claude/.claude/references/loading-model.md` (notes on how
  Claude loads references and what dedup behavior looks like)

## Steps

1. Investigate Claude's reference-loading semantics:
   - When a SKILL.md says "see `references/X.md`", does Claude
     auto-load? Or does it Read-tool the file when context demands?
   - Hypothesis from the plan-executor design: refs are loaded
     on-demand via Read tool, not auto-inlined. Verify.
2. Empirical test: open a session, trigger plan-executor (cites
   plan-system.md and console-discipline.md), inspect what gets loaded.
3. Compare to a skill citing the same references — confirm second
   activation does not double-load.
4. Document findings in `references/loading-model.md` (or add as a
   section to an existing reference if it fits).
5. If duplicate-loading is observed, propose a fix as a follow-up
   task (likely involves rewriting "see also" prose to be Read-tool
   triggered, not auto-inlined).
6. Commit + PR (or report-only if no fix needed).

## Acceptance criteria

- [ ] Loading model documented or confirmed.
- [ ] Empirical observation captured.
- [ ] Recommendation: no-action (model is correct) or follow-up task.

## Validation

- The documentation can be reproduced by another agent reading the
  notes and the references.

## Commit / PR

- If documentation-only:
  ```
  docs(claude): document skill-reference loading model

  Verifies that shared references load on-demand via Read tool, not
  redundantly per cross-referencing skill. Notes captured in
  references/loading-model.md.

  Refs: essay skill-system-token-efficiency-audit.md §P3.2

  Plan: skills-trim-and-discipline
  Task: 35
  ```
- PR target: `main`. If no PR (no findings), produce a note in the
  Phase 8 audit report instead.
