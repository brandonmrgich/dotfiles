---
title: Skill pressure-testing methodology
description: TDD cycle for new skills — RED (capture rationalizations without skill), GREEN (write minimum skill), REFACTOR (re-run, counter new rationalizations). Scenario fixture format. When to apply.
static: true
---

# Skill pressure-testing methodology

A skill is only as strong as the behavior it actually produces under
pressure. Before a discipline-pressure skill ships, run it against a
**scenario fixture** that probes the failure mode the skill claims to
prevent. Capture the rationalizations the model emits when the skill
is absent; let those rationalizations drive the skill body's anti-cheat
language.

This is TDD for skills: **RED → GREEN → REFACTOR**.

---

## Cycle

### RED — fail without the skill

1. Pick the scenario fixture (or write one — see "Scenario fixture format").
2. Dispatch a sub-agent against `setup_prompt` **without loading the
   skill** (no Skill invocation, no inclusion in the agent's preamble).
3. Capture the agent's response verbatim. Look for:
   - Failure to perform the discipline (skipped step, shortcut, etc.).
   - **Rationalizations** — the prose justifying the shortcut. Quote
     them verbatim; they are the raw material for GREEN.
4. Confirm at least one rationalization matches a `expected_failure_modes`
   entry in the fixture. If no failure occurs, the fixture is too weak —
   strengthen `setup_prompt` (add time pressure, fake-confidence cues,
   "just this once" framing) and rerun.

### GREEN — write the minimum skill

1. Author the skill body with two ingredients:
   - **Procedure** — the discipline the skill enforces, stated as steps.
   - **Anti-rationalization counters** — for each captured rationalization,
     a sentence in the body that names the rationalization and rebuts it
     ("If you find yourself thinking 'just this once', stop. The skill
     applies *especially* under time pressure.").
2. Re-dispatch the same fixture **with the skill loaded**. Confirm the
   agent now performs the discipline and the rationalization does not
   appear (or appears followed by self-correction).

### REFACTOR — re-run; counter the new rationalizations

1. Run 2–3 variant fixtures (same failure mode, different cover stories).
2. New rationalizations will surface — the model is creative. Add
   counters for each.
3. Stop when a fresh fixture produces no new rationalizations OR three
   iterations have not improved coverage. The skill is "ready to merge"
   when its anti-rationalization section covers the captured library.

---

## Scenario fixture format

A fixture is a markdown file with YAML frontmatter, stored under the
skill's directory at `skills/<skill>/fixtures/<name>.md`.

```yaml
---
name: <kebab-case-fixture-name>
skill: <skill-being-tested>
setup_prompt: |
  <Multi-line prompt that puts the agent in the failure-prone
   situation. Include time pressure, ambiguity, or "obvious shortcut"
   framing if the discipline is meant to resist those.>
expected_failure_modes:
  - <One-sentence description of a failure the no-skill agent should exhibit.>
  - <Another.>
expected_skill_behavior:
  - <One-sentence description of the with-skill agent's correct action.>
  - <Another.>
negative_examples:
  - <Phrase that, if it appears in the with-skill output, indicates the
     skill failed to overcome the rationalization.>
---

# <name>

<Optional prose context — what the fixture is probing, why this scenario
 is realistic, references to the discipline being enforced.>
```

**Fixture sizing.** Keep `setup_prompt` under ~200 words. Long prompts
dilute the pressure signal; short, sharp scenarios produce cleaner
rationalizations.

---

## Procedure (running a fixture)

1. **RED dispatch.** Use the Task tool with a generic implementer
   subagent_type. Pass only `setup_prompt` as the agent prompt. Do
   **not** mention the skill. Record the full response.
2. **Extract rationalizations.** Read the response; copy verbatim any
   sentences that justify the failure. These go into the skill's
   anti-rationalization section in GREEN.
3. **GREEN dispatch.** Re-dispatch with the skill loaded (Skill tool
   invocation in the orchestrator's preamble, or explicit "use the X
   skill" instruction in the agent prompt). Record the response.
4. **Compare.** Verdict is one of:
   - **PASS** — discipline performed; no rationalization from the
     captured library; no `negative_examples` strings present.
   - **CONDITIONAL PASS** — discipline performed but with a new
     rationalization not yet in the library. Add it, re-author the
     skill counter, re-run.
   - **FAIL** — discipline not performed, or a `negative_examples`
     string present. Skill body is insufficient; iterate GREEN.

---

## Captured rationalization library (seed)

Universal rationalizations the model emits when shortcutting a
discipline. Treat as a starting set; extend per-skill from RED runs.

- **"This is a simple case — the formal procedure is overkill."** Skill
  applies regardless of perceived simplicity.
- **"The user clearly wants this done quickly."** Speed is not the
  skill's tradeoff; correctness is.
- **"I'll just write a quick fix and verify after."** Verify-after is
  the failure mode the skill exists to prevent.
- **"I don't need to invoke the skill for a one-off task."** Skill
  invocation is the trigger, not a reward for complexity.
- **"The previous step already handled this — I can skip ahead."**
  Step-skipping is the highest-frequency failure; skill steps are
  ordered for a reason.

---

## When to use

- **Required:** every new discipline-pressure skill (Phase 5 skills:
  systematic-debugging, verification-before-completion, TDD,
  design-before-code; future similar additions).
- **Recommended:** ritual skills (Phase 6) if they encode pressure
  language ("don't skip code review", "always finish the branch
  before…").
- **Exempt:** specialist skills (`nextjs-app-router`,
  `royalty-splits-music`, `ddex-standards`, etc.). Specialists are
  domain-knowledge skills; their failure mode is "wrong answer", not
  "shortcut under pressure", and unit-style validation suits them
  better than a fixture.

---

## Cross-references

- `~/.claude/agents/skill-pressure-tester.md` — agent that runs the
  RED/GREEN dispatch automatically and reports a verdict.
- `~/.claude/skills/skill-author/SKILL.md` — cites this reference;
  pressure-testing is the verification step in skill authoring.
- `~/.claude/essays/skill-system-vs-superpowers.md` §Gap 6 — rationale
  for the methodology and its origin in superpowers' `writing-skills`.
