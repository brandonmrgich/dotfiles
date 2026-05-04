# Task 04 — Prose-prune turborepo-patterns body

**Phase:** 1 (Prose pruning)
**Agent:** plan-executor-implementer
**Produces PR:** No

## Goal

Trim `turborepo-patterns/SKILL.md` body to ≤6,000 B. Pre-followup: 7,116 B body — 1,116 B over.

## Context

Turborepo body has pipeline-task explanation, four-tier caching model, common pitfalls, globalEnv ✅/❌ candidate lists. Phase 2 extracted full turbo.json + vercel-ignore + bin-vs-task to `examples/`. Remaining: tighten prose around tables.

## Files

**Affected:**
- `~/dotfiles/claude/.claude/skills/turborepo-patterns/SKILL.md`

## Steps

1. Identify trim candidates:
   - Pipeline-task fields explanation (likely a table; trim surrounding prose).
   - Caching-model paragraphs — fold to a "Cache layers" table if not already.
   - GlobalEnv ✅/❌ candidate lists — already compact; minimal trim possible.
   - Common pitfalls list — keep; tighten each bullet.
   - Vercel `ignoreCommand` brief — already references the example file; trim further.
2. **Preserve:**
   - All command names (turbo run/build/dev/lint/typecheck/prune/gen).
   - Flag names (--filter, --affected, --scope).
   - turbo.json field names (pipeline, dependsOn, outputs, cache, persistent, env, globalEnv).
   - Pointer to `examples/`.
3. Run linter; verify FAIL → OK/WARN.
4. Smoke-test: "configure turbo.json for X" — activates.
5. Commit.

## Acceptance criteria

- [ ] Body ≤6,600 B.
- [ ] Command + flag keywords preserved.
- [ ] turbo.json field names preserved.
- [ ] Examples pointer intact.
- [ ] Linter shows turborepo moved from FAIL.

## Commit / PR

- Commit message:
  ```
  refactor(skill): prose-prune turborepo-patterns body to budget

  Fold pipeline-task and caching-model prose around their tables;
  preserve command names, flag names, turbo.json field names, examples
  pointer. Body NNNN -> MMMM B.

  Refs: parent plan skills-trim-and-discipline §"Phase-8 follow-ups #2"

  Plan: skills-trim-followups
  Task: 04
  ```
