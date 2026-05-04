# Task 00 — Discovery & pre-followup baseline

**Phase:** 0 (Setup)
**Agent:** plan-executor-discovery
**Produces PR:** No (state-setup; rolls into setup PR)

## Goal

Capture the pre-followup state: linter output, per-over-budget-skill body byte counts, current commit on main. Subsequent tasks compare against this baseline to verify yield.

## Context

The parent plan (`skills-trim-and-discipline`, v3.0) finished with 12 OK / 4 WARN / 12 FAIL on `~/.claude/tools/skill-budget-lint.py`. This task captures that state as the pre-followup baseline so post-followup re-runs can show clear FAIL→OK transitions.

## Files

**Created:**
- `.claude/plans/skills-trim-followups/audits/00-baseline.md`

## Steps

1. Confirm working tree clean: `git -C ~/dotfiles status --short` returns empty.
2. Confirm on `main` and at v3.0 reachable: `git -C ~/dotfiles describe --tags HEAD` shows v3.0 or a descendant.
3. Create execution branch: `git -C ~/dotfiles checkout -b claude/skills-trim-followups`.
4. Run baseline:
   ```bash
   python3 ~/.claude/tools/skill-budget-lint.py > /tmp/lint-baseline.txt
   ```
5. Capture per-target body byte counts (the 5 prose-prune targets):
   ```bash
   for s in ddex-standards nextjs-app-router royalty-splits-music turborepo-patterns plan-executor; do
     wc -c ~/.claude/skills/$s/SKILL.md
   done
   ```
6. Write `audits/00-baseline.md` with:
   - Linter output (OK/WARN/FAIL counts + per-skill table).
   - Per-target body byte count.
   - Pre-followup HEAD SHA.
   - Reference to parent-plan v3.0 tag commit.
7. No commit on its own — the audit file rolls into the setup PR commit (along with MasterPlan.md and task files added by the setup PR).

## Acceptance criteria

- [ ] On branch `claude/skills-trim-followups`.
- [ ] `audits/00-baseline.md` written.
- [ ] Pre-followup linter snapshot captured (12/4/12 expected).
- [ ] No code-bearing files modified.

## Validation

- Linter runs without error.
- Baseline numbers match the v3.0 audit (audit-37) within ±50 bytes (small drift from any post-merge content additions).

## Commit / PR

- No standalone commit — Task 00 outputs roll into the setup PR commit (which adds the gitignore exemption + MasterPlan + task files + this baseline audit).
