# Task 10 — Extract turborepo-patterns examples

**Phase:** 2 (Heavy SKILL.md trims)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Move the full `turbo.json` example, the Vercel `ignoreCommand` script,
and the CI pseudo-yaml block out of `turborepo-patterns/SKILL.md` into
sibling `examples/`.

Targets ~2.5k bytes saved per activation.

## Files

**Affected:**
- `~/dotfiles/claude/.claude/skills/turborepo-patterns/SKILL.md`

**Created:**
- `~/dotfiles/claude/.claude/skills/turborepo-patterns/examples/turbo.json.example`
- `~/dotfiles/claude/.claude/skills/turborepo-patterns/examples/vercel-ignore.sh`

(CI pseudo-yaml inline if short; full block moves only if >20 lines.)

## Steps

1. Identify the three blocks in SKILL.md.
2. Create `examples/` directory.
3. Write each as a standalone file with header comment indicating
   purpose.
4. Replace each block in SKILL.md with a pointer.
5. Stow + verify.
6. Commit + PR.

## Acceptance criteria

- [ ] `turborepo-patterns/SKILL.md` byte size in the range 6,000–7,000.
- [ ] Example files present as symlinks.
- [ ] No content lost.

## Validation

- Activate ("how do I configure turbo.json for X?"); body points to example.

## Commit / PR

- Commit message:
  ```
  refactor(skill): extract turborepo-patterns examples to examples/

  Move turbo.json and vercel-ignore.sh from SKILL.md to examples/.
  Saves ~2.5k bytes per activation.

  Refs: essay skill-system-token-efficiency-audit.md §P1.2

  Plan: skills-trim-and-discipline
  Task: 10
  ```
- PR target: `main`.
