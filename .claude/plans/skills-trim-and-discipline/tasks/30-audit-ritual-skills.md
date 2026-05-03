# Task 30 — Audit gate: ritual skills

**Phase:** 6 (audit gate)
**Agent:** plan-auditor (skill)
**Produces PR:** No

## Goal

Verify the four ritual skills (Tasks 26–29) are present, compliant, and
correctly cross-referenced with existing skills. Re-measure baseline
(4 more skill descriptions added).

## Steps

1. Verify presence of all 4 skills.
2. Cross-reference verification:
   - `using-homebrew-skills` does not duplicate `skill-author`'s
     scope (one is *use*, the other is *create*).
   - `receiving-code-review` cross-refs `github` and
     `requesting-code-review`.
   - `finishing-a-branch` defers to `plan-executor` and cross-refs
     `verification-before-completion` (from Phase 5).
3. Per-skill compliance: descriptions ≤1024 chars,
   `[HomebrewSkill]` prefix, "Use when…" or equivalent.
4. Re-measure cumulative description bytes. After Phase 5+6, 8 new
   descriptions add ~3k–4k bytes. Net always-loaded delta from baseline
   should still be ~10–11k saved.
5. Activation regression: trigger each new skill via canonical phrases;
   confirm no over-activation of older skills.
6. Special check on `using-homebrew-skills`: verify the proactive-mode
   policy doesn't conflict with existing proactive skills (`skill-author`,
   `essay`).
7. Write `audits/30-ritual-skills-audit.md`:
   - Presence + compliance table.
   - Cross-reference verification table.
   - Cumulative description bytes vs baseline.
   - Verdict + recommendation for Phase 7.

## Acceptance criteria

- [ ] Four skills present, compliant, cross-referenced.
- [ ] Net always-loaded savings still positive (~10–11k vs baseline).
- [ ] No proactive-mode conflicts.
- [ ] Audit report written.

## No commit
