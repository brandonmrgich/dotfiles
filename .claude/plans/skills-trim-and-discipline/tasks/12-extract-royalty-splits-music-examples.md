# Task 12 — Extract royalty-splits-music examples

**Phase:** 2 (Heavy SKILL.md trims)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Move TypeScript types and bulk-replace example out of
`royalty-splits-music/SKILL.md` into sibling `examples/`.

Targets ~1k bytes saved per activation.

## Files

**Affected:**
- `~/dotfiles/claude/.claude/skills/royalty-splits-music/SKILL.md`

**Created:**
- `~/dotfiles/claude/.claude/skills/royalty-splits-music/examples/types.example.ts`

(Bulk-replace inline if short; moves only if >20 lines.)

## Steps

1. Identify the TypeScript type block(s) and any bulk-replace example.
2. Create `examples/` directory.
3. Write each as a standalone file with header comment.
4. Replace each block in SKILL.md with a pointer.
5. Stow + verify.
6. Commit + PR.

## Acceptance criteria

- [ ] `royalty-splits-music/SKILL.md` byte size in the range 8,000–9,000.
- [ ] Example file(s) present as symlinks.
- [ ] No content lost.

## Validation

- Activate ("show me the RoyaltySplit type"); body points to example.

## Commit / PR

- Commit message:
  ```
  refactor(skill): extract royalty-splits-music TS types to examples/

  Move TS type definitions and bulk-replace example from SKILL.md.
  Saves ~1k bytes per activation.

  Refs: essay skill-system-token-efficiency-audit.md §P1.2

  Plan: skills-trim-and-discipline
  Task: 12
  ```
- PR target: `main`.
