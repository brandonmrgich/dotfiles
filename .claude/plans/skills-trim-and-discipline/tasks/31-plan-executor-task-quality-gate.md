# Task 31 — Plan-executor task-quality gate

**Phase:** 7 (Existing-skill upgrades)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Add a Phase-1 task-quality validation step to `plan-executor`. Update
`plan-executor-implementer` agent definition so it rejects under-specified
tasks back to the orchestrator instead of improvising.

## Context

Per essay #8 §"Gap 5", superpowers' `writing-plans` enforces extreme
rigor (2–5 minute tasks, complete code in tasks, zero-context engineer
assumption, no placeholder language, exact commit messages). Local
`plan-executor` delegates task-content quality to whatever generated
the tasks; vague tasks produce gap-filling guesses.

This task adds a quality gate without rewriting the plan format —
imposing rejection from the dispatched side is the lighter-weight fix.

## Files

**Affected:**
- `~/dotfiles/claude/.claude/skills/plan-executor/SKILL.md`
- `~/dotfiles/claude/.claude/agents/plan-executor-implementer.md`
- `~/dotfiles/claude/.claude/agents/plan-executor-tester.md`
- `~/dotfiles/claude/.claude/agents/plan-executor-documenter.md`
- `~/dotfiles/claude/.claude/agents/plan-executor-discovery.md`

## Steps

1. In `plan-executor/SKILL.md` Phase 1 (validation), add a
   "task-quality gate" subsection:
   - Each task file must have: explicit goal, files affected/created,
     concrete steps (no "figure out X"), acceptance criteria.
   - Tasks lacking these get marked "needs-elaboration" and either
     surfaced to user or sent through plan generation again.
2. In each `plan-executor-*.md` agent definition, add a "Reject
   under-specified tasks" section:
   - When dispatched, validate the task file before doing work.
   - Rejection criteria: missing acceptance criteria, missing files
     section, "TBD"/"figure out"/"as appropriate" placeholders.
   - On rejection, return a structured response to the orchestrator
     (verdict: REJECTED, reason: <which check failed>, suggested
     elaboration: <what's needed>).
3. Update `plan-executor` Phase 2 (dispatch) to handle REJECTED
   responses: surface to user before retrying.
4. Steal the rationalization table from superpowers' `writing-plans`
   and embed it in `references/plan-generation.md` (created in Task 05).
5. Stow + verify.
6. Commit + PR.

## Acceptance criteria

- [ ] `plan-executor` Phase 1 has explicit task-quality gate.
- [ ] All four sub-agents reject under-specified tasks.
- [ ] Rejection response format documented.
- [ ] Rationalization table added to `plan-generation.md`.

## Validation

- Construct a deliberately vague task ("implement the thing"). Dispatch
  via plan-executor. Confirm sub-agent returns REJECTED, not improvised
  output.
- Confirm well-specified task still dispatches and completes normally.

## Commit / PR

- Commit message:
  ```
  feat(plan-executor): add task-quality gate; sub-agents reject vague tasks

  Phase 1 validation gates each task on goal+files+steps+acceptance.
  Sub-agents return REJECTED on under-specified inputs instead of
  improvising. Rationalization table embedded in plan-generation
  reference.

  Refs: essay skill-system-vs-superpowers.md §Gap 5

  Plan: skills-trim-and-discipline
  Task: 31
  ```
- PR target: `main`.
