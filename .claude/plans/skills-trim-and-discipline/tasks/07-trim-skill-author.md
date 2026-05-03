# Task 07 — Trim skill-author SKILL.md (pre-Phase-4)

**Phase:** 2 (Heavy SKILL.md trims)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Trim `skill-author/SKILL.md` from ~10k to ~5k bytes by moving the
authoring procedure, examples, and CSO-rules detail into
`references/skill-authoring-guide.md`. Keep skill-vs-agent decision
matrix inline.

**Important:** Phase 4 (Task 19) will *re-add* the pressure-test
methodology to skill-author. Do not anticipate that work here — trim to
the floor first; Phase 4 grows back deliberately under the new format.

Targets ~5k bytes saved per skill-author activation.

## Context

`skill-author` mixes load-bearing decision content (when to make a
skill vs an agent vs a memory) with reference-shaped content (full
authoring procedure, example skills, description-format rules).
The decision content stays; the reference content moves.

Source: essay #9 §"P1.4 — Trim skill-author".

## Files

**Affected:**
- `~/dotfiles/claude/.claude/skills/skill-author/SKILL.md`

**Created:**
- `~/dotfiles/claude/.claude/references/skill-authoring-guide.md`

## Steps

1. Read current `skill-author/SKILL.md`. Categorize each section:
   - **Decision-time content** (skill-vs-agent matrix, when to use what):
     keep inline.
   - **Authoring procedure** (step-by-step write-a-skill flow): move.
   - **Examples** (good captures, agent-vs-skill examples): move.
   - **Description-format CSO rules** (cross-references essay #8): move.
2. Create `references/skill-authoring-guide.md` with the moved content.
   Frontmatter: `title`, `description`, `static: true`.
3. In `skill-author/SKILL.md`:
   - Keep the decision matrices inline.
   - Replace each moved section with a one-line pointer.
   - Keep activation triggers and proactive-mode policy in the body
     (not in description — Phase 3 separately moves description prose).
4. Note for Phase 4: skill-author will gain a new "Pressure-test
   methodology" section in Task 19. Do not pre-create empty headings
   for it here.
5. Stow + verify.
6. Commit + PR.

## Acceptance criteria

- [ ] `skill-author/SKILL.md` byte size in the range 4,500–5,500.
- [ ] `references/skill-authoring-guide.md` contains the full procedure
      + examples + CSO rules.
- [ ] Decision matrices (skill vs agent, scope) remain inline.
- [ ] No content lost.
- [ ] PR description shows byte delta.

## Validation

- Open a fresh session, ask "should I make X a skill or an agent?";
  skill-author activates and the decision matrix is inline-readable.
- Open a fresh session, ask "how do I write a new skill from scratch?";
  skill-author activates and the body points at the reference.

## Commit / PR

- Commit message:
  ```
  refactor(skill): trim skill-author (~10k → ~5k)

  Move authoring procedure, examples, and CSO rules to references/
  skill-authoring-guide.md. SKILL.md keeps decision matrices and
  activation triggers. Phase 4 (pressure-test methodology) re-grows
  the skill deliberately.

  Refs: essay skill-system-token-efficiency-audit.md §P1.4

  Plan: skills-trim-and-discipline
  Task: 07
  ```
- PR target: `main`.
