# Task 05 — Trim plan-executor SKILL.md

**Phase:** 2 (Heavy SKILL.md trims)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Move three reference-shaped chunks out of `plan-executor/SKILL.md`
(~19k → ~9k):

- **Plan/task generation procedure** (Mode B, ~4k bytes) → `references/plan-generation.md`
- **State-file JSON schema** (~1.5k bytes) → fold into existing `references/plan-system.md`
- **Failure-calibration table + audit checkpoint flow** (~2k bytes) → `references/plan-failure-handling.md`

Plus minor: dedupe commit-footer prose already covered in
`references/plan-system.md`.

Targets ~10k bytes saved on every plan-executor activation.

## Context

`plan-executor` is the heaviest skill (~5k tokens). Its
generation procedure is consulted only in Mode B (generate-then-execute);
the state-file schema is reference; the failure-calibration table is
consulted on failure, not every dispatch. SKILL.md should keep operating
principles, the phase outline, the dispatch loop, and the return format —
everything else moves.

Source: essay #9 §"Hotspot 2 — `plan-executor` body" and §"P1.1".

## Files

**Affected:**
- `~/dotfiles/claude/.claude/skills/plan-executor/SKILL.md`
- `~/dotfiles/claude/.claude/references/plan-system.md` (extend with state-file schema)

**Created:**
- `~/dotfiles/claude/.claude/references/plan-generation.md`
- `~/dotfiles/claude/.claude/references/plan-failure-handling.md`

## Steps

1. Read current `plan-executor/SKILL.md`. Identify the three sections to
   move (use heading anchors).
2. Create `references/plan-generation.md` with the Mode B procedure
   (Steps 1–6 of plan generation, task-file template, master-plan
   template). Frontmatter: `title`, `description`, `static: true`.
3. Extend `references/plan-system.md` with a `## State file schema`
   section: full JSON example with field comments. Increment the
   reference's `last-verified:` if it has one.
4. Create `references/plan-failure-handling.md` with the
   failure-calibration decision table (the 9-row matrix from PR #7) and
   the audit-checkpoint flow. Frontmatter as above.
5. In `plan-executor/SKILL.md`:
   - Replace the generation section with a one-paragraph pointer:
     "Mode B procedure (generate-then-execute) lives at
     `references/plan-generation.md`."
   - Replace the state-file schema with: "State file schema:
     `references/plan-system.md` §State file schema."
   - Replace the failure-calibration table with: "Failure handling:
     `references/plan-failure-handling.md`."
   - Verify operating principles, phase outline, dispatch loop, and
     return format remain inline.
6. Update any sub-agent definitions (`agents/plan-executor-*.md`) that
   cited the moved content. Repoint citations.
7. Stow + verify all three reference symlinks.
8. Commit + PR.

## Acceptance criteria

- [ ] `plan-executor/SKILL.md` byte size in the range 8,500–10,000.
- [ ] All three references exist and contain the relocated content.
- [ ] No content lost (sum the four files vs baseline; difference must
      be ≤500 bytes — the dedupe of commit-footer prose).
- [ ] Sub-agent files updated where needed.
- [ ] PR description shows before/after for plan-executor and the new
      references.

## Validation

- Trigger plan-executor in a fresh session with a Mode B intent
  ("generate a plan to do X"); confirm it consults
  `references/plan-generation.md` rather than failing for missing
  procedure.
- Trigger an explicit failure path and confirm failure-handling reference
  is reachable (no dangling pointer).

## Commit / PR

- Commit message:
  ```
  refactor(skill): trim plan-executor (~19k → ~9k)

  Move plan generation, state-file schema, and failure-handling table to
  references/. SKILL.md keeps operating principles, phase outline,
  dispatch loop, and return format.

  Refs: essay skill-system-token-efficiency-audit.md §Hotspot 2 / §P1.1

  Plan: skills-trim-and-discipline
  Task: 05
  ```
- PR target: `main`.
