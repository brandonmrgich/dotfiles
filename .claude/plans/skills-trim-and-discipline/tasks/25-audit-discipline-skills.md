# Task 25 — Audit gate: discipline skills

**Phase:** 5 (audit gate)
**Agent:** plan-auditor (skill)
**Produces PR:** No

## Goal

Verify the four discipline skills (Tasks 21–24) are present, compliant,
and pressure-tested. Re-measure the always-loaded baseline (descriptions
have grown by 4 new skills).

## Steps

1. Verify presence:
   - `~/.claude/skills/systematic-debugging/SKILL.md`
   - `~/.claude/skills/verification-before-completion/SKILL.md`
   - `~/.claude/skills/test-driven-development/SKILL.md`
   - `~/.claude/skills/design-before-code/SKILL.md`
   All four exist as symlinks; frontmatter compliant; descriptions ≤1024
   chars.
2. Verify pressure-test traces in each PR description (RED→GREEN→REFACTOR).
3. Re-measure description bytes total: 4 new skills add ~1k–2k bytes
   (4 × ~300–500 chars each). The cumulative always-loaded delta
   from baseline should still be net negative — original cuts (~14k)
   minus new descriptions (~1.5k) ≈ 12.5k saved.
4. Activation regression test: run all 4 new skills' canonical triggers
   AND a sample of the existing 20 — ensure no over-eager activation
   (e.g., `design-before-code` triggering on neutral "let me think"
   prompts).
5. Behavioral verification: for one of the four (pick `systematic-debugging`
   — the most easily testable), dispatch a sub-agent on a debugging
   scenario WITH and WITHOUT the skill. Compare. Document the delta.
6. Per-class budget pre-check: discipline skills should be ≤4,000 bytes
   total each (they're <500 word skills).
7. Write `audits/25-discipline-skills-audit.md`:
   - Presence + compliance table.
   - Cumulative description bytes (always-loaded delta vs Task 18).
   - Activation regression results.
   - Behavioral A/B observation for one skill.
   - Verdict + recommendation for Phase 6.

## Acceptance criteria

- [ ] Four skills present, compliant, pressure-tested.
- [ ] Net always-loaded savings still positive vs Task 00 baseline.
- [ ] No activation regressions.
- [ ] Audit report written.

## Failure handling

- A skill present but fails activation: re-trigger; if still failing,
  the description doesn't match. Patch task.
- A skill triggers on neutral prompts: description over-broad. Patch task.
- Cumulative savings turned negative: investigate; likely descriptions
  too long.

## No commit
