# Task 34 — Per-class budget enforcement script

**Phase:** 8 (Ergonomics & enforcement)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Add a pre-commit-hook script that fails when a SKILL.md (or its
description) exceeds its per-class budget. Soft enforcement first
(warning only); convert to hard enforcement after one cleanup pass.

## Context

Per essay #9 §"P3.1", budgets per class:

| Class | Description | Body | Total |
|---|---|---|---|
| Domain specialist | ≤1,024 chars | ≤6,000 bytes | ≤8,000 |
| Workflow / discipline | ≤500 chars | ≤4,000 bytes | ≤5,000 |
| Capture / knowledge | ≤500 chars | ≤4,000 bytes | ≤5,000 |
| Policy / catalog | ≤400 chars | ≤3,500 bytes | ≤4,500 |
| Meta (skill-author, etc.) | ≤700 chars | ≤5,000 bytes | ≤6,000 |

The script must:
- Classify each SKILL.md into a class (heuristic on description keywords
  or explicit class tag in frontmatter).
- Measure description chars + body bytes.
- Compare to per-class budget.
- Output WARN or FAIL.
- Exit non-zero on FAIL when run as a pre-commit hook.

## Files

**Created:**
- `~/dotfiles/claude/.claude/tools/skill-budget-lint.sh` (or `.py` —
  Python may be cleaner for YAML parsing).

**Possibly affected:**
- `~/dotfiles/.git/hooks/pre-commit` (if dotfiles uses pre-commit hooks)
  OR a Husky/lint-staged config OR a separate script the user runs
  manually before commit.

## Steps

1. Decide implementation language: bash (limited YAML parsing) vs Python.
   Python recommended for safe YAML frontmatter handling.
2. Decide class tagging mechanism:
   - **Frontmatter tag** (preferred) — add `class: workflow|specialist|...`
     to each SKILL.md frontmatter.
   - **Heuristic** — derive from skill name or description content.
   - Default: add the explicit tag; the script reads it.
3. If tag-based: in this PR, add `class:` to all 24 (20 + 4 new from
   Phase 5/6) SKILL.md frontmatters. This is a frontmatter-only change,
   no body edits.
4. Write the lint script:
   - Walk `~/.claude/skills/*/SKILL.md`.
   - Parse frontmatter; read `class:`, `description:`, body.
   - Compare to class budget table.
   - Print WARN-level violations on stderr; FAIL on >budget+10%.
   - Exit code: 0 if all WARN-or-better, non-zero if any FAIL.
5. Decide enforcement mode for this PR: **WARN-only**. Hard FAIL is
   activated in a follow-up after one cleanup pass.
6. If a pre-commit hook exists, wire the script in (warn-only).
   Otherwise document how to run it manually
   (`bash ~/.claude/tools/skill-budget-lint.sh`).
7. Stow + verify.
8. Commit + PR.

## Acceptance criteria

- [ ] Lint script present and executable.
- [ ] All 24 SKILL.md frontmatters have `class:` tag (if tag mechanism
      chosen).
- [ ] Running the script produces the per-skill compliance table.
- [ ] WARN-mode by default; FAIL is opt-in via env var.
- [ ] PR description shows the script's first run output.

## Validation

- Run the script. All current skills should be at-or-near budget after
  Phase 1–3 trims; flag any over-budget for a follow-up patch.
- Deliberately bloat one description; re-run; confirm WARN/FAIL fires.

## Commit / PR

- Commit message:
  ```
  feat(claude): add per-class skill budget linter (warn-only)

  skill-budget-lint script measures description chars + body bytes per
  SKILL.md against per-class budgets. WARN-only by default; FAIL opt-in.
  Each SKILL.md frontmatter now carries an explicit class: tag.

  Refs: essay skill-system-token-efficiency-audit.md §P3.1

  Plan: skills-trim-and-discipline
  Task: 34
  ```
- PR target: `main`.
