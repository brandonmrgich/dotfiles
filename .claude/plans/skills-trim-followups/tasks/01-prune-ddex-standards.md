# Task 01 — Prose-prune ddex-standards body

**Phase:** 1 (Prose pruning)
**Agent:** plan-executor-implementer
**Produces PR:** No (commits to execution branch; closeout PR aggregates)

## Goal

Trim `ddex-standards/SKILL.md` body to fit the specialist body budget (≤6,000 B). Pre-followup measurement: 6,936 B body / 8,043 B total — body 936 B over budget. (Audit-37 reported 9,562 B body using a slightly different measurement; reconcile during the task and use the linter's number as authoritative.)

## Context

Largest body-budget offender. Ddex-standards is reference-dense (DDEX standards, identifier list, royalty concept names). Prose can tighten without losing the keyword pool.

## Files

**Affected:**
- `~/dotfiles/claude/.claude/skills/ddex-standards/SKILL.md`

## Steps

1. Read current SKILL.md. Identify trim candidates:
   - Long-form prose explaining concepts that can be a 1-line "what it is" + cross-ref.
   - Repeated explanations (e.g., several variants of "MWN/MWL = musical-work-notification/letter").
   - Sub-sections that can fold (e.g., "P-Line vs C-Line" can be one line not three paragraphs).
   - Verbose examples in prose form (move to brief inline form or drop if not load-bearing).
2. **Preserve:**
   - All identifiers in the keyword pool (ISRC, ISWC, IPI, ISNI, GRid, DPID, HFA Song Code, P-Line, C-Line, MWN, MWL, IsCredited, etc.).
   - Pitfalls / "do not trigger for" guards.
   - Decision tables (if any).
   - Cross-references to other skills/references.
3. Trim aggressively. Target: body ≤6,000 B (in band) or ≤6,600 B (WARN tier acceptable).
4. Run `python3 ~/.claude/tools/skill-budget-lint.py | grep ddex` — verify FAIL → OK or WARN.
5. Smoke-test: trigger `ddex-standards` activation via "I need to model a DDEX ERN message" — confirm skill activates and body answers usefully.
6. Stow simulate clean.
7. Commit on execution branch.

## Acceptance criteria

- [ ] Body byte count post-trim ≤6,600 B (WARN tier or better).
- [ ] All keywords from pre-trim description's keyword pool still appear in the body (or are still in the description).
- [ ] Pitfalls list intact.
- [ ] Decision tables intact.
- [ ] Linter shows ddex moved from FAIL.

## Commit / PR

- Commit message:
  ```
  refactor(skill): prose-prune ddex-standards body to budget

  Trim long-form prose; preserve identifier keyword pool and
  pitfalls list. Body NNNN -> MMMM B (in band).

  Refs: parent plan skills-trim-and-discipline §"Phase-8 follow-ups #4"

  Plan: skills-trim-followups
  Task: 01
  ```
- No PR — closeout PR aggregates Phase 1+2+3 commits.
