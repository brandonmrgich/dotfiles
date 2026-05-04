# Task 07 — Real RED dispatches for 8 discipline + ritual skills

**Phase:** 2 (Verification)
**Agent:** plan-executor-implementer (orchestrator-coordinated; the orchestrator dispatches the `skill-pressure-tester` agent against each fixture)
**Produces PR:** No

## Goal

Capture empirical (not hypothetical) RED rationalizations against each of the 8 discipline + ritual skills' fixtures by running the `skill-pressure-tester` agent (or equivalent orchestrator-scope sub-agent dispatch) against each fixture WITHOUT the skill loaded.

Closes parent plan's Phase-8 follow-up #7.

## Context

Parent plan's Phase 5 + 6 skills shipped with hypothetical RED rationalizations because the implementer agent couldn't dispatch sub-sub-agents. The orchestrator CAN. This task closes the gap.

## Files

**Affected (potentially — only if rationalizations not already covered):**
- 8 SKILL.md bodies (anti-rationalization sections may need additions).
- 8 fixture files (may be expanded with new `expected_failure_modes`).

**Created:**
- `audits/07-red-dispatches-summary.md` — per-skill RED capture, counter analysis, body-update verdict.

## Steps

For each of the 8 skills (`systematic-debugging`, `verification-before-completion`, `test-driven-development`, `design-before-code`, `using-homebrew-skills`, `receiving-code-review`, `requesting-code-review`, `finishing-a-branch`):

1. **Read the fixture** at `skills/<skill>/fixtures/<fixture>.md`.
2. **Dispatch a generic implementer sub-agent** with ONLY `setup_prompt` from the fixture. Do NOT load the skill or mention it.
3. **Capture the agent's response verbatim.** Identify rationalizations — sentences that justify failing the discipline.
4. **Compare** captured rationalizations to the skill body's existing "Rationalization counters" / banned-phrase sections.
5. **Three outcomes per skill:**
   - **(a) Captured rationalizations all already countered** in the skill body → no body change needed. Note in audit summary.
   - **(b) New rationalizations surfaced** that aren't yet countered → add counters to the skill body. Body word count must remain within budget.
   - **(c) RED dispatch shows the no-skill agent already does the discipline** (fixture too weak) → strengthen the fixture's `setup_prompt` (more pressure cues) and re-run.

6. Record per-skill verdict in `audits/07-red-dispatches-summary.md`:
   - skill name
   - verbatim RED rationalizations
   - covered/not-covered status
   - skill body changes made (commit SHA if applicable)
   - fixture changes made (if any)

7. **Single commit per skill body update** (if any). Commit message format:
   ```
   refactor(skill): augment <skill> with empirical RED rationalizations

   Real RED dispatch surfaced new rationalization "<verbatim>". Counter
   added to skill body.

   Refs: parent plan skills-trim-and-discipline §"Phase-8 follow-ups #7"

   Plan: skills-trim-followups
   Task: 07
   ```

## Acceptance criteria

- [ ] All 8 RED dispatches run.
- [ ] Per-skill verdict captured.
- [ ] Body updates (if any) preserve word/byte budget.
- [ ] Audit summary written.

## Notes for orchestrator

- **Sub-agent budget warning:** 8 RED dispatches + potential 8 GREEN dispatches = up to 16 sub-agent runs. Plan budget; don't run all 8 in parallel — sequential to avoid context blowout.
- **Pressure-test methodology** lives at `~/.claude/references/skill-pressure-testing.md`; consult for fixture-format and procedure semantics.
- **The `skill-pressure-tester` agent** at `~/.claude/agents/skill-pressure-tester.md` may be a useful dispatch target if its input/output contract maps to the fixtures cleanly.

## Commit / PR

- Per-skill commits as above.
- No separate PR — closeout PR aggregates.
