# Task 09 — Extract nextjs-app-router patterns

**Phase:** 2 (Heavy SKILL.md trims)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Move three large code patterns out of
`nextjs-app-router/SKILL.md` into sibling
`skills/nextjs-app-router/patterns/*.example.{ts,tsx}` files:

- BFF (backend-for-frontend) proxy pattern
- Hydration patterns (skipHydration / persisted Zustand)
- Theme-via-cookie SSR pattern

Targets ~3k bytes saved per activation.

## Context

Same rationale as Task 08 — code blocks are useful at implementation
time; they pay always-on tax during routine activations. SKILL.md keeps
prose, decision tables, and short snippets; full modules move.

Source: essay #9 §"P1.2 — Domain-specialist code-block extraction".

## Files

**Affected:**
- `~/dotfiles/claude/.claude/skills/nextjs-app-router/SKILL.md`

**Created:**
- `~/dotfiles/claude/.claude/skills/nextjs-app-router/patterns/bff-proxy.example.ts`
- `~/dotfiles/claude/.claude/skills/nextjs-app-router/patterns/hydration.example.tsx`
- `~/dotfiles/claude/.claude/skills/nextjs-app-router/patterns/theme-cookie.example.ts`

## Steps

1. Identify the three patterns in SKILL.md.
2. Create `patterns/` directory under the skill dir.
3. Write each as a standalone `.example.{ts,tsx}` file with a header
   comment.
4. Replace each block in SKILL.md with a pointer.
5. Keep short illustrative snippets inline.
6. Stow + verify.
7. Commit + PR.

## Acceptance criteria

- [ ] `nextjs-app-router/SKILL.md` byte size in the range 6,500–7,500
      (down from ~10k).
- [ ] Three pattern files present as symlinks.
- [ ] No content lost.

## Validation

- Activate ("how do I add a BFF proxy?"); body points to pattern file.

## Commit / PR

- Commit message:
  ```
  refactor(skill): extract nextjs-app-router patterns to patterns/

  Move BFF proxy, hydration, and theme-cookie code blocks from SKILL.md
  to patterns/*.example.{ts,tsx}. Saves ~3k bytes per activation.

  Refs: essay skill-system-token-efficiency-audit.md §P1.2

  Plan: skills-trim-and-discipline
  Task: 09
  ```
- PR target: `main`.
