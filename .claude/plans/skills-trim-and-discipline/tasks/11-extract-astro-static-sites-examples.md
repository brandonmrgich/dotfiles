# Task 11 — Extract astro-static-sites examples

**Phase:** 2 (Heavy SKILL.md trims)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Move content-collections example and View Transitions example out of
`astro-static-sites/SKILL.md` into sibling `examples/`.

Targets ~1.5k bytes saved per activation.

## Files

**Affected:**
- `~/dotfiles/claude/.claude/skills/astro-static-sites/SKILL.md`

**Created:**
- `~/dotfiles/claude/.claude/skills/astro-static-sites/examples/content-collections.example.ts`
- `~/dotfiles/claude/.claude/skills/astro-static-sites/examples/view-transitions.example.astro`

## Steps

1. Identify the two example blocks in SKILL.md.
2. Create `examples/` directory.
3. Write each as a standalone file with header comment.
4. Replace each block in SKILL.md with a pointer.
5. Stow + verify.
6. Commit + PR.

## Acceptance criteria

- [ ] `astro-static-sites/SKILL.md` byte size in the range 5,500–6,500.
- [ ] Two example files present as symlinks.
- [ ] No content lost.

## Validation

- Activate ("how do I use content collections in Astro?"); body points to example.

## Commit / PR

- Commit message:
  ```
  refactor(skill): extract astro-static-sites examples to examples/

  Move content-collections and view-transitions blocks from SKILL.md.
  Saves ~1.5k bytes per activation.

  Refs: essay skill-system-token-efficiency-audit.md §P1.2

  Plan: skills-trim-and-discipline
  Task: 11
  ```
- PR target: `main`.
