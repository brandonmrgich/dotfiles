# Task 17 — Rewrite domain-specialist descriptions

**Phase:** 3 (Description format conventions)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Trim the 8 domain-specialist descriptions to ≤1024 chars while preserving
the keyword pool. Compress synonym chains, drop parenthetical asides,
strip pre-summarized workflow text. Specialists already lead with
keyword lists (good); this task tightens them.

## Context

Per essay #9 §"Hotspot 4", these are the worst per-char offenders:
- `nextjs-app-router` (~1865 chars)
- `ddex-standards` (~1543)
- `web-audio-howler` (~1357)
- `astro-static-sites` (~1278)
- `royalty-splits-music` (~1210)
- `turborepo-patterns` (~1100)
- `github` (~451 — already acceptable; do NOT regress)
- `gitignore` (~360 — already acceptable; do NOT regress)

For the six over-target skills, target ≤1024 chars. For the two already
acceptable (`github`, `gitignore`), verify they meet the new spec
(triggers-only, "Use when…" or equivalent). If they do, leave them
alone — non-regression is the goal.

## Files

- `~/dotfiles/claude/.claude/skills/nextjs-app-router/SKILL.md`
- `~/dotfiles/claude/.claude/skills/ddex-standards/SKILL.md`
- `~/dotfiles/claude/.claude/skills/web-audio-howler/SKILL.md`
- `~/dotfiles/claude/.claude/skills/astro-static-sites/SKILL.md`
- `~/dotfiles/claude/.claude/skills/royalty-splits-music/SKILL.md`
- `~/dotfiles/claude/.claude/skills/turborepo-patterns/SKILL.md`
- `~/dotfiles/claude/.claude/skills/github/SKILL.md` (verify only)
- `~/dotfiles/claude/.claude/skills/gitignore/SKILL.md` (verify only)

## Steps

For each over-target specialist:
1. Identify cuttable patterns:
   - Parenthetical asides ("(Digital Data Exchange)",
     "(the cross-browser audio library)").
   - Synonym chains — collapse via wildcards or canonical terms.
   - Workflow narration — drop entirely (specialists shouldn't have it
     at all, but some do).
2. Preserve all unique keywords. **Test**: a Linguistic search for any
   keyword in the original description should still find a hit (or its
   wildcard pattern) in the new one.
3. Verify ≤1024 chars.
4. For `github` and `gitignore`: read description, verify spec
   compliance, do not rewrite if already compliant.
5. Commit as one PR.

## Acceptance criteria

- [ ] 6 over-target specialists trimmed to ≤1024 chars.
- [ ] Keyword pool preserved across all 8.
- [ ] PR description shows before/after char counts.

## Validation

- Activate each via canonical trigger keywords (e.g., "DDEX ERN message",
  "Howler MediaSession", "client:load directive"). Each must still fire.
- For each, also test a *previously-keyword* phrase that may have been
  collapsed: confirm the wildcard or canonical term still triggers.

## Commit / PR

- Commit message:
  ```
  refactor(claude): trim specialist descriptions to <=1024 chars

  Compress synonym chains and parenthetical asides in 6 specialists
  (nextjs-app-router, ddex-standards, web-audio-howler, astro-static-sites,
  royalty-splits-music, turborepo-patterns). Keyword pool preserved.
  github and gitignore verified spec-compliant; not touched.

  Refs: essays skill-system-vs-superpowers.md §Gap 7 / Appendix A and
        skill-system-token-efficiency-audit.md §Hotspot 4

  Plan: skills-trim-and-discipline
  Task: 17
  ```
- PR target: `main`.
