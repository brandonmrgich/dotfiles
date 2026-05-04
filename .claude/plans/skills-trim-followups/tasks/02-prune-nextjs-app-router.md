# Task 02 — Prose-prune nextjs-app-router body

**Phase:** 1 (Prose pruning)
**Agent:** plan-executor-implementer
**Produces PR:** No

## Goal

Trim `nextjs-app-router/SKILL.md` body to ≤6,000 B (specialist budget). Pre-followup: 7,668 B body — 1,668 B over. (Phase 2 task-13 audit measured 8,541 B body proper; same skill, lint reads body differently. Use linter as authoritative.)

## Context

Nextjs-app-router carries dense framework content: server vs client components, four caching layers, hydration patterns, middleware. Phase 2 of the parent plan extracted code blocks to `patterns/`; remaining body is prose-explanation + decision tables. Trim verbose prose.

## Files

**Affected:**
- `~/dotfiles/claude/.claude/skills/nextjs-app-router/SKILL.md`

## Steps

1. Identify trim candidates:
   - Decision tree explaining server-vs-client component choice (likely fold to a 4-row table).
   - Four caching layers section — keep the table; trim the surrounding prose.
   - Hydration patterns section — already references `patterns/hydration.example.tsx`; further trim the prose.
   - "Common pitfalls" list — keep the list; tighten each bullet.
   - Footer prose / cross-refs — usually trimmable.
2. **Preserve:**
   - Cache-layer names (Request Memoization, Data Cache, Full Route Cache, Router Cache).
   - All directive names (`use client`, `use server`, `client:*`).
   - File-name pattern keywords (`layout.tsx`, `page.tsx`, etc.).
   - Pointer to `patterns/`.
   - "Do NOT trigger for Pages Router" guard.
3. Run linter; verify FAIL → OK or WARN.
4. Smoke-test: "how do I revalidate after a server action?" — skill activates.
5. Commit.

## Acceptance criteria

- [ ] Body ≤6,600 B.
- [ ] Cache-layer names preserved.
- [ ] Directive keyword pool preserved.
- [ ] Patterns/ pointer intact.
- [ ] Linter shows nextjs moved from FAIL.

## Commit / PR

- Commit message:
  ```
  refactor(skill): prose-prune nextjs-app-router body to budget

  Tighten decision-tree and caching-layer prose; preserve cache-layer
  names, directive keywords, patterns/ pointer. Body NNNN -> MMMM B.

  Refs: parent plan skills-trim-and-discipline §"Phase-8 follow-ups #1"

  Plan: skills-trim-followups
  Task: 02
  ```
