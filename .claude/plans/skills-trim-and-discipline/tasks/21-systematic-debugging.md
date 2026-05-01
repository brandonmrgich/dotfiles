# Task 21 — Create systematic-debugging skill

**Phase:** 5 (Discipline skills)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Add a `[HomebrewSkill] systematic-debugging` skill enforcing a 4-phase
root-cause methodology. Activate on debugging contexts and prevent
plausible-fix-without-investigation.

## Context

Per essay #8 §"Gap 1", superpowers' `systematic-debugging` is
adapted as the local equivalent. Iron-law language: "NO FIXES WITHOUT
ROOT CAUSE INVESTIGATION FIRST." Halt-and-question-architecture clause
after 3 failed attempts.

Cross-references: `make_state_honest` mantra is adjacent (state
diagnostics share its lens). `verification-before-completion` is the
sibling skill landing in Task 22.

## Files

**Created:**
- `~/dotfiles/claude/.claude/skills/systematic-debugging/SKILL.md`

## Steps

1. Pressure-test FIRST — RED phase per the methodology from Task 19:
   - Dispatch a sub-agent without this skill on a hypothetical bug
     (e.g., "users are sometimes seeing stale data; fix it").
   - Capture the rationalizations the agent uses to skip investigation
     ("the cache TTL is probably wrong; let me bump it").
   - Document verbatim in the PR description.
2. GREEN — write the skill body:
   - Frontmatter: `name: "[HomebrewSkill] systematic-debugging"`,
     `description:` per the format spec, ≤1024 chars, "Use when
     debugging, investigating bugs, or chasing failures…".
   - Body sections:
     - **Iron law** — bold, top of body.
     - **4-phase methodology** — REPRODUCE → ISOLATE → DIAGNOSE → FIX.
     - **Rationalization counters** — verbatim list from RED-phase
       capture, each with a counter.
     - **3-strikes clause** — after 3 failed attempts, halt and
       question architecture.
     - **Cross-refs** — mantra `make_state_honest`,
       sibling skill `verification-before-completion`.
   - Target body: <500 words.
3. REFACTOR — re-run pressure scenario; observe what new
   rationalizations appear (if any); add counters.
4. Stow + verify symlink.
5. Commit + PR.

## Acceptance criteria

- [ ] `~/.claude/skills/systematic-debugging/SKILL.md` symlink exists.
- [ ] Frontmatter compliant: `[HomebrewSkill]` prefix, description
      ≤1024 chars, "Use when…" prefix.
- [ ] Body <500 words; iron-law language present.
- [ ] Rationalization counters captured from real RED-phase output.
- [ ] PR description includes the RED→GREEN→REFACTOR trace.

## Validation

- Activation: type "I'm trying to debug a flaky test"; skill activates.
- Negative test: type "explain this function"; skill does NOT activate.
- Behavioral test: dispatch a sub-agent on a debugging scenario WITH
  the skill; observe whether it follows the 4-phase methodology
  before proposing a fix.

## Commit / PR

- Commit message:
  ```
  feat(skill): add systematic-debugging discipline skill

  Adapt superpowers' systematic-debugging methodology to local taxonomy.
  Iron law: NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST. 4-phase
  procedure (REPRODUCE -> ISOLATE -> DIAGNOSE -> FIX) with 3-strikes
  architecture-question clause.

  Pressure-tested per references/skill-pressure-testing.md (RED -> GREEN
  -> REFACTOR trace in PR description).

  Refs: essay skill-system-vs-superpowers.md §Gap 1

  Plan: skills-trim-and-discipline
  Task: 21
  ```
- PR target: `main`.
