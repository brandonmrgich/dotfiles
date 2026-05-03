# Task 22 — Create verification-before-completion skill

**Phase:** 5 (Discipline skills)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Add a `[HomebrewSkill] verification-before-completion` skill enforcing
fresh-evidence requirements before any "done" claim. Counters the
fake-completion default.

## Context

Per essay #8 §"Gap 1", adapt superpowers' `verification-before-completion`.
The skill formalizes: any "complete" claim must cite fresh evidence
(test output, diff inspection, behavioral verification) — not memory
of having done the work. Hedging language is forbidden.

Cross-references: `plan-auditor` (plan-scoped verification),
`doc-freshness` (doc-scoped verification), this skill is the general
case.

## Files

**Created:**
- `~/dotfiles/claude/.claude/skills/verification-before-completion/SKILL.md`

## Steps

1. RED — pressure-test without the skill: ask a sub-agent to "implement
   feature X then declare it done." Capture how it claims completion
   (likely from memory, no fresh evidence).
2. GREEN — write skill body:
   - Frontmatter: standard.
   - Body sections:
     - **Iron law** — "DO NOT CLAIM DONE WITHOUT FRESH EVIDENCE."
     - **Required evidence** — for code: test output + diff cite; for
       docs: re-read + last-verified bump cite; for plans: audit verdict.
     - **Banned phrases** — list of hedges to refuse ("I think it's
       working", "should be done", "done — let me know if anything's
       broken").
     - **Cross-refs** — `plan-auditor`, `doc-freshness`,
       `systematic-debugging` (sibling).
   - Target body: <500 words.
3. REFACTOR — re-run pressure scenario; iterate.
4. Stow + verify.
5. Commit + PR.

## Acceptance criteria

- [ ] Skill exists; frontmatter compliant.
- [ ] Iron law and banned-phrase list present.
- [ ] PR description includes RED→GREEN→REFACTOR trace.

## Validation

- Activation: trigger via "I'm done with that task"; skill activates.
- Behavioral: dispatch a sub-agent on a "implement and declare done"
  scenario WITH the skill; observe whether it cites fresh evidence
  rather than memory.

## Commit / PR

- Commit message:
  ```
  feat(skill): add verification-before-completion discipline skill

  Counters fake-completion default. Iron law: DO NOT CLAIM DONE WITHOUT
  FRESH EVIDENCE. Per-artifact evidence requirements; banned-phrase list.
  Cross-refs plan-auditor, doc-freshness, systematic-debugging.

  Pressure-tested per references/skill-pressure-testing.md.

  Refs: essay skill-system-vs-superpowers.md §Gap 1

  Plan: skills-trim-and-discipline
  Task: 22
  ```
- PR target: `main`.
