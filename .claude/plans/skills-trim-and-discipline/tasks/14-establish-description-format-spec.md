# Task 14 — Establish description-format spec

**Phase:** 3 (Description format conventions)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Write the canonical spec for SKILL.md `description:` fields. Future
description rewrites (Tasks 15–17) and all new skills (Phases 5–6) ship
in this format. Spec lives at `references/description-format.md` and is
cited from `skill-author/SKILL.md`.

## Context

Both source essays converge on the same description-format issue:
- Essay #8 §"Gap 7" — descriptions are the only signal Claude uses to
  decide skill loading; pre-summarized workflow narration causes silent
  skips (per superpowers' `writing-skills` doctrine).
- Essay #9 §"Hotspot 4" — eight descriptions exceed 1024 chars; eagerly
  loaded; ~1500 tokens cuttable per session.

This task does not rewrite descriptions — it establishes the rules so
the rewriting tasks have a target.

Source: essay #8 §"Gap 7", essay #9 §"P2.1–P2.3", and superpowers'
`writing-skills` skill (cited in essay #8).

## Files

**Affected:**
- `~/dotfiles/claude/.claude/skills/skill-author/SKILL.md` — add citation pointer

**Created:**
- `~/dotfiles/claude/.claude/references/description-format.md`

## Steps

1. Write `references/description-format.md` with sections:
   - **Purpose** — descriptions are the activation signal; bad
     descriptions cause silent skips.
   - **Rules** —
     - Max 1024 characters.
     - Third person.
     - Open with "Use when…" or "Activates when…".
     - Triggers ONLY (no workflow summaries, no concept explanations).
     - Keyword density preserved (activation recall depends on it);
       compress *prose*, not *keywords*.
     - Avoid synonym chains ("client:load, client:idle, …" →
       "client:* directives").
   - **Anti-patterns** with examples drawn from current SKILL.md descriptions
     (e.g., "Orchestrate sequential…" → workflow summary, not trigger).
   - **Migration recipe** — for each skill: extract triggers, prepend
     "Use when…", drop summary clauses, verify char count.
   - **Worked examples** — 2–3 before/after rewrites.
2. In `skill-author/SKILL.md`, add a one-line pointer:
   "Description format: `references/description-format.md`."
3. Stow + verify.
4. Commit + PR.

## Acceptance criteria

- [ ] `references/description-format.md` exists with all sections.
- [ ] Worked examples are concrete (real local skills).
- [ ] `skill-author` cites the reference.
- [ ] PR description summarizes the rules and links the reference.

## Validation

- An agent reading only `skill-author/SKILL.md` and the reference can
  produce a compliant description without further context.

## Commit / PR

- Commit message:
  ```
  docs(claude): canonicalize SKILL.md description format

  Establish the rules for SKILL.md `description:` fields: <=1024 chars,
  third person, "Use when..." prefix, triggers-only, keyword pool
  preserved. Cited from skill-author. Drives the description rewrites
  in tasks 15-17 and all new skills in phases 5-6.

  Refs: essays skill-system-vs-superpowers.md §Gap 7 and
        skill-system-token-efficiency-audit.md §Hotspot 4

  Plan: skills-trim-and-discipline
  Task: 14
  ```
- PR target: `main`.
