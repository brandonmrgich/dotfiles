# Task 00 — Discovery & baseline measurements

**Phase:** 0 (Discovery)
**Agent:** plan-executor-discovery
**Produces PR:** No (state-setup task)

## Goal

Establish the before-measurements that every subsequent audit gate compares
against. Verify the working tree is clean, branch off `main` correctly, and
build the cross-reference graph used to detect collateral effects when
trimming SKILL.md files.

## Context

The two source essays (`skill-system-token-efficiency-audit.md`,
`skill-system-vs-superpowers.md`) include estimates. Estimates are not truth.
This task captures hard `wc -c` numbers so subsequent audits can report
**actual** delta vs essay projection. Without a baseline, "we saved 40%"
becomes uncheckable.

## Files

**Affected:** none (read-only)
**Created:**
- `.claude/plans/skills-trim-and-discipline/audits/00-baseline.md`

## Steps

1. Confirm working tree is clean:
   `git -C ~/dotfiles status --short` returns empty.
2. Confirm on `main` and up-to-date:
   `git -C ~/dotfiles rev-parse --abbrev-ref HEAD` is `main`;
   `git -C ~/dotfiles fetch --quiet && git -C ~/dotfiles status -sb` shows no divergence.
3. Create the feature branch (do NOT push yet):
   `git -C ~/dotfiles checkout -b claude/skills-trim-and-discipline`.
4. Run baseline measurements:
   ```bash
   for f in ~/.claude/CLAUDE.md ~/.claude/skills/*/SKILL.md ~/.claude/references/*.md ~/.claude/agents/*.md ~/.claude/mantras/*.md ~/.claude/environment/*.md; do
     wc -c "$f"
   done
   ```
5. For each SKILL.md, extract `description:` field char count via Python/yaml
   (manual fallback if frontmatter spans multiple lines). Record per-skill.
6. Build cross-reference graph: grep every SKILL.md and CLAUDE.md for
   `~/.claude/`-rooted paths and backtick-wrapped skill names. Filter false
   positives from code fences. Record adjacency list.
7. Compute always-loaded baseline: CLAUDE.md bytes + sum(all 20 SKILL.md
   description bytes). Convert to estimated tokens (÷4).
8. Write `audits/00-baseline.md` with: per-file table, per-skill description
   table, cross-ref graph, always-loaded baseline, projection-table source
   (cite essay #9 §"Compound savings projection") for each scenario
   (A–F).
9. Commit the audit baseline on the execution branch
   (`claude/skills-trim-and-discipline`). The plan dir is tracked per
   the gitignore exemption from the setup PR, so the audit file is
   durable in git. Subsequent tasks read it from disk and reference it
   by file path; the commit acts as the Phase 1 starting checkpoint.

## Acceptance criteria

- [ ] Working tree clean before any change.
- [ ] On branch `claude/skills-trim-and-discipline`.
- [ ] Baseline file written and contains: 20 per-skill rows + per-file rows
      for references/agents/mantras/environment + always-loaded total.
- [ ] Cross-reference graph captured (pre-trim shape).
- [ ] No code-bearing files modified.

## Validation

- `wc -c` runs without errors against every target.
- Description char counts agree with essay #9 Appendix A within ±5% (drift
  beyond that signals an extraction bug; investigate before continuing).
- Cross-ref graph matches essay #9's "Cross-reference graph" section
  qualitatively.

## Commit / PR

- Commit message:
  ```
  chore(plan): baseline measurements for skills-trim-and-discipline

  Captures pre-Phase-1 wc -c measurements over CLAUDE.md, all 20
  SKILL.md files, references, agents, mantras, and environment files.
  Per-skill description char counts. Cross-reference graph. Always-loaded
  baseline (CLAUDE.md + descriptions). Reference for all subsequent
  phase audit gates.

  Plan: skills-trim-and-discipline
  Task: 00
  ```
- No PR (single-branch execution; commits aggregate into the umbrella PR
  at Phase 9 / Task 38).
