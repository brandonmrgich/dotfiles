# Task 26 — Create using-homebrew-skills meta-skill

**Phase:** 6 (Ritual skills)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Add a `[HomebrewSkill] using-homebrew-skills` meta-skill that pushes
Claude to actively scan loaded skills before responding. Borrows the
universal-rationalization table from superpowers.

## Context

Per essay #8 §"Gap 2", local `skill-author` is about *creating* skills;
no skill pushes the agent to *use* the skills it has aggressively. This
ritual skill closes the gap.

Per superpowers' `using-superpowers`: "before responding to anything,
scan your loaded skills, and if any plausibly apply, invoke them — even
before asking clarifying questions." Includes a rationalization table
for the dozen common excuses agents use to skip the scan.

Target body: **<200 words** (per essay #9 budget for frequently-loaded
skills).

## Files

**Created:**
- `~/dotfiles/claude/.claude/skills/using-homebrew-skills/SKILL.md`

## Steps

1. RED — pressure-test without skill: ask sub-agent a question that
   should trigger an existing skill (e.g., "let me write an essay")
   without the meta-skill; see whether it scans available skills or
   answers from default behavior.
2. GREEN — write skill body:
   - Frontmatter: `name: "[HomebrewSkill] using-homebrew-skills"`,
     `description:` with triggers like "before responding", "scan
     skills", "what skills do I have", and proactive-mode policy
     (always-on for first response in a session).
   - Body (<200 words):
     - **Iron law** — "BEFORE RESPONDING, SCAN LOADED SKILLS. IF ANY
       PLAUSIBLY APPLY, INVOKE."
     - **Rationalization table** — 8–12 common excuses with counters,
       borrowed largely from superpowers' `using-superpowers` (the
       rationalizations are universal across agents).
     - **First-response trigger** — invoke this skill check on the
       first response of every session.
3. REFACTOR — iterate based on RED-phase rationalizations.
4. Stow + verify.
5. Commit + PR.

## Acceptance criteria

- [ ] Skill exists; body <200 words.
- [ ] Rationalization table has ≥8 entries with counters.
- [ ] Description triggers proactive-mode activation.
- [ ] PR description includes RED→GREEN→REFACTOR trace.

## Validation

- Open a fresh session; type a generic prompt that should trigger an
  existing skill (e.g., "let me capture this as an idea"); observe
  whether the meta-skill triggers a scan and the right skill activates.

## Commit / PR

- Commit message:
  ```
  feat(skill): add using-homebrew-skills meta-skill

  Pushes Claude to scan loaded skills before responding. Iron law:
  BEFORE RESPONDING, SCAN LOADED SKILLS. Rationalization table borrowed
  largely from superpowers' using-superpowers (universal across agents).
  Body <200 words.

  Pressure-tested per references/skill-pressure-testing.md.

  Refs: essay skill-system-vs-superpowers.md §Gap 2

  Plan: skills-trim-and-discipline
  Task: 26
  ```
- PR target: `main`.
