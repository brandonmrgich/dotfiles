# Task 06 — Trim plan-auditor SKILL.md

**Phase:** 2 (Heavy SKILL.md trims)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Move the audit-report template (~3k bytes, ~60 lines) out of
`plan-auditor/SKILL.md` into `references/audit-report-template.md`.
Tighten the verdict definitions and escalation rules in the SKILL.md
body without losing information.

Targets ~5k bytes saved per plan-auditor activation
(11k → ~6k).

## Context

The audit-report template is consulted *when writing a report*. The
SKILL.md body should know the audit *procedure* and *verdict semantics*
— the template body is reference. This is the same pattern as
`references/plan-system.md` and the to-be-created `plan-generation.md`.

Source: essay #9 §"P1.3 — Trim plan-auditor".

## Files

**Affected:**
- `~/dotfiles/claude/.claude/skills/plan-auditor/SKILL.md`

**Created:**
- `~/dotfiles/claude/.claude/references/audit-report-template.md`

## Steps

1. Read current `plan-auditor/SKILL.md`. Identify the audit-report
   template (typically a fenced markdown block).
2. Create `references/audit-report-template.md` with:
   - Frontmatter (`static: true`).
   - The full template, plus per-section authoring notes (what each
     section captures, what counts as evidence).
3. In `plan-auditor/SKILL.md`:
   - Replace the template block with: "Audit report template:
     `references/audit-report-template.md`."
   - Tighten verdict definitions to a compact table (PASS / PARTIAL /
     FAIL with one-line definitions and example triggers).
   - Tighten escalation rules to bulleted form.
4. Stow + verify symlink.
5. Commit + PR.

## Acceptance criteria

- [ ] `plan-auditor/SKILL.md` byte size in the range 5,500–6,500.
- [ ] `references/audit-report-template.md` exists with the full template.
- [ ] Verdict definitions and escalation rules are still in SKILL.md
      body (not moved out — they're decision-time content, not template).
- [ ] PR description shows byte delta.

## Validation

- Run plan-auditor against a closed plan; confirm it finds the template
  via the new reference path.

## Commit / PR

- Commit message:
  ```
  refactor(skill): trim plan-auditor (~11k → ~6k)

  Move audit-report template to references/audit-report-template.md.
  SKILL.md keeps procedure, verdict definitions, escalation rules.

  Refs: essay skill-system-token-efficiency-audit.md §P1.3

  Plan: skills-trim-and-discipline
  Task: 06
  ```
- PR target: `main`.
