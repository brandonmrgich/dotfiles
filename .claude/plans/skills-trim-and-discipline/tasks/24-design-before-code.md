# Task 24 — Create design-before-code skill

**Phase:** 5 (Discipline skills)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Add a `[HomebrewSkill] design-before-code` skill enforcing mandatory
design discussion before implementation, even on "simple" tasks.
Activates on jump-to-code rationalizations.

## Context

Per essay #8 §"Gap 1", adapt superpowers' `brainstorming`. Local naming:
`design-before-code` (since `essay` already covers the brainstorm
artifact and the *enforcement* needs a distinct name).

The skill graduates into the existing `essay` and `idea-tracker` skills:
when design discussion produces a non-trivial decision, route to
`essay`. Pre-plan stash routes to `idea-tracker`.

## Files

**Created:**
- `~/dotfiles/claude/.claude/skills/design-before-code/SKILL.md`

## Steps

1. RED — ask sub-agent "let me just build feature X — should be quick";
   observe whether it jumps to implementation or pauses for design.
2. GREEN — write skill body:
   - Frontmatter: triggers including "let me just build it",
     "I'll start coding", "skip the planning", "this is simple",
     "should be quick".
   - Body:
     - **Iron law** — "NO CODE BEFORE DESIGN. EVEN ON SIMPLE TASKS."
     - **Procedure** — (1) state the goal in one sentence;
       (2) divergence: list 2–3 approaches; (3) convergence: pick one
       with stated tradeoffs; (4) capture: graduate to essay (if
       non-trivial) or idea (if pre-plan); (5) only then implement.
     - **"Simple task" rationalization counters** — list common
       deferral excuses with counters.
     - **Cross-refs** — `essay` for capture, `idea-tracker` for
       pre-plan stash.
   - Target body: <500 words.
3. REFACTOR — iterate.
4. Stow + verify.
5. Commit + PR.

## Acceptance criteria

- [ ] Skill exists; frontmatter compliant.
- [ ] Iron law present; procedure has 5 explicit steps.
- [ ] Rationalization counters captured.
- [ ] Cross-refs to essay and idea-tracker present.
- [ ] PR description includes RED→GREEN→REFACTOR trace.

## Validation

- Activation: "let me just build X"; skill activates.
- Behavioral: dispatch sub-agent on a "simple" task WITH skill; observe
  divergence/convergence step before code.

## Commit / PR

- Commit message:
  ```
  feat(skill): add design-before-code discipline skill

  Counters jump-to-code default. Iron law: NO CODE BEFORE DESIGN.
  Procedure: state goal, diverge, converge, capture (graduate to essay
  or idea), implement. Rationalization counters for "simple task"
  excuses.

  Pressure-tested per references/skill-pressure-testing.md.

  Refs: essay skill-system-vs-superpowers.md §Gap 1

  Plan: skills-trim-and-discipline
  Task: 24
  ```
- PR target: `main`.
