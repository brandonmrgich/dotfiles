# Task 03 — Prose-prune royalty-splits-music body

**Phase:** 1 (Prose pruning)
**Agent:** plan-executor-implementer
**Produces PR:** No

## Goal

Trim `royalty-splits-music/SKILL.md` body to ≤6,000 B. Pre-followup: 7,225 B body — 1,225 B over.

## Context

Royalty splits is split-bucket-heavy domain content. Phase 2 already extracted TS types to `examples/types.example.ts`. Remaining body explains MASTER vs PUBLISHING, sum-to-100, sound-recording vs musical-work, neighboring rights, donation flows. Trim prose; preserve concepts.

## Files

**Affected:**
- `~/dotfiles/claude/.claude/skills/royalty-splits-music/SKILL.md`

## Steps

1. Identify trim candidates:
   - MASTER vs PUBLISHING bucket explanation (often a paragraph that could be a 2-row table).
   - Sound-recording vs musical-work split (similar — table-able).
   - Donation flow ASCII diagram or prose — assess whether the diagram earns its bytes; if it's reference-shaped, link to a future docs page or trim.
   - Cross-refs section — typically tightenable.
2. **Preserve:**
   - All split-type keywords (RoyaltySplit, MASTER, PUBLISHING, sum-to-100).
   - Recording-vs-release scope XOR mention.
   - Neighboring rights / equitable remuneration concepts.
   - Pointer to `examples/types.example.ts`.
   - "Do NOT trigger" guards.
3. Run linter; verify FAIL → OK/WARN.
4. Smoke-test: "model a royalty split" — activates.
5. Commit.

## Acceptance criteria

- [ ] Body ≤6,600 B.
- [ ] Bucket keywords preserved.
- [ ] Examples pointer intact.
- [ ] Linter shows royalty-splits moved from FAIL.

## Commit / PR

- Commit message:
  ```
  refactor(skill): prose-prune royalty-splits-music body to budget

  Tighten MASTER/PUBLISHING explanation prose; preserve bucket keywords
  and recording-vs-release scope XOR. Body NNNN -> MMMM B.

  Refs: parent plan skills-trim-and-discipline §"Phase-8 follow-ups #3"

  Plan: skills-trim-followups
  Task: 03
  ```
