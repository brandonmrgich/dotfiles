# Task 16 — Rewrite capture/knowledge descriptions

**Phase:** 3 (Description format conventions)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Rewrite the `description:` field of the 4 capture/knowledge skills:
`essay`, `idea-tracker`, `environment-map`, `skill-author`. Per the
spec in `references/description-format.md`.

## Context

`essay` is the largest description in this group (~1100 chars; mixes
triggers with concept explanation). `skill-author` embeds proactive-mode
policy in its description (should live in body). `idea-tracker` mixes
trigger phrases with system replacement context.

## Files

- `~/dotfiles/claude/.claude/skills/essay/SKILL.md`
- `~/dotfiles/claude/.claude/skills/idea-tracker/SKILL.md`
- `~/dotfiles/claude/.claude/skills/environment-map/SKILL.md`
- `~/dotfiles/claude/.claude/skills/skill-author/SKILL.md`

## Steps

For each skill:
1. Extract trigger phrases.
2. Draft new description: triggers-only, ≤1024 chars.
3. Move proactive-mode/policy/concept content to body.
4. Char count verification.
5. Commit as one PR.

## Acceptance criteria

- [ ] All 4 descriptions ≤1024 chars.
- [ ] All 4 start with "Use when…" or equivalent.
- [ ] Proactive-mode policy and concept narration moved to body.
- [ ] PR description shows before/after.

## Validation

- Trigger each via canonical phrases; activations still fire.
- Pressure test: a "let me think about X" prompt should not falsely
  activate `essay` if the goal is task-driven (proactive-mode policy
  applies, but the description should trigger only on explicit phrases).

## Commit / PR

- Commit message:
  ```
  refactor(claude): rewrite capture-skill descriptions to triggers-only

  Apply references/description-format.md to essay, idea-tracker,
  environment-map, skill-author. Proactive-mode policy and concept
  prose moved to body.

  Refs: essays skill-system-vs-superpowers.md §Gap 7 / Appendix A and
        skill-system-token-efficiency-audit.md §Hotspot 4

  Plan: skills-trim-and-discipline
  Task: 16
  ```
- PR target: `main`.
