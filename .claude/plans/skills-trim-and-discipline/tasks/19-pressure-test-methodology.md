# Task 19 — Pressure-test methodology in skill-author

**Phase:** 4 (Pressure-test methodology)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Formalize a TDD-for-skills cycle. Discipline skills landing in Phase 5
will be pressure-tested before merge using this methodology.

Per user direction (clarifying answer #2), this lands **before** the
discipline skills, reversing essay #8's stated order. Reason: new skills
must be testable when they ship, not retrofitted later.

## Context

Per essay #8 §"Gap 6", superpowers' `writing-skills` defines
RED → GREEN → REFACTOR for skills:

1. RED — run a pressure scenario with a sub-agent **without** the skill;
   document the failure rationalizations verbatim.
2. GREEN — write the minimum skill that fixes the observed failures.
3. REFACTOR — re-run scenarios; identify new rationalizations; counter
   them in the skill body.

The local `skill-author` skill currently has decision matrices and
authoring procedure but no verification step. This task adds it.

## Files

**Affected:**
- `~/dotfiles/claude/.claude/skills/skill-author/SKILL.md`

**Created:**
- `~/dotfiles/claude/.claude/references/skill-pressure-testing.md`
- `~/dotfiles/claude/.claude/agents/skill-pressure-tester.md` (optional;
  decide based on whether the methodology runs better as procedure
  inline or as a callable agent)

## Steps

1. Write `references/skill-pressure-testing.md` with:
   - **Cycle** — RED → GREEN → REFACTOR.
   - **Scenario fixture format** — a YAML or markdown fixture defining:
     `name`, `setup_prompt`, `expected_failure_modes`,
     `expected_skill_behavior`, `negative_examples`.
   - **Procedure** — how to dispatch a sub-agent without the skill,
     capture rationalizations, then dispatch with the skill, compare.
   - **Captured rationalization library** — seeded with 3–5 universal
     ones from superpowers' `using-superpowers` (e.g., "I don't need
     to invoke a skill for a simple task").
   - **When to use** — every new discipline-pressure skill must run
     this cycle; specialist skills are exempt.
2. Decide: agent or inline?
   - Agent (`agents/skill-pressure-tester.md`) — preferred if Phase 5
     wants programmatic testing (orchestrator dispatches the agent on
     a fixture, agent reports verdict).
   - Inline procedure — simpler if pressure-testing is a manual exercise
     by the implementer agent.
   - Recommendation: **create the agent**; it lets Phase 5 tasks include
     a deterministic pressure-test step.
3. If agent: write `agents/skill-pressure-tester.md` with frontmatter
   (`name`, `description`), purpose, input format (skill path +
   fixture path), output format (verdict + rationalization deltas).
4. In `skill-author/SKILL.md`, add a "Pressure-test before merge"
   section pointing at the reference and (if created) the agent. Keep
   it terse — references hold the detail.
5. Stow + verify all new files.
6. Commit + PR.

## Acceptance criteria

- [ ] `references/skill-pressure-testing.md` exists with all sections.
- [ ] If agent path chosen: `agents/skill-pressure-tester.md` registered
      and reachable.
- [ ] `skill-author/SKILL.md` cites the reference (and agent, if applicable).
- [ ] Scenario fixture format is documented and runnable on a control
      fixture (Task 20 verifies).
- [ ] PR description includes a worked example: a fixture + a brief
      RED→GREEN→REFACTOR walkthrough on a hypothetical
      "always-respond-in-haiku" skill.

## Validation

- Reading just the new reference, an agent could pressure-test a skill
  end-to-end without external context.

## Commit / PR

- Commit message:
  ```
  feat(claude): add pressure-test methodology for new skills

  Formalize RED -> GREEN -> REFACTOR for skills. New discipline-pressure
  skills (phase 5) must run this before merge. References file holds the
  cycle and fixture format; skill-pressure-tester agent (if created)
  runs scenarios programmatically.

  Refs: essay skill-system-vs-superpowers.md §Gap 6

  Plan: skills-trim-and-discipline
  Task: 19
  ```
- PR target: `main`.
