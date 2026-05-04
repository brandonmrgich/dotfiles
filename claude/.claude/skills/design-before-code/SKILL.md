---
name: "[HomebrewSkill] design-before-code"
class: discipline
description: "Use when about to implement a feature, fix, or change without first stating goal + alternatives + trade-offs. Activates on phrases like 'let me just build it', 'I'll start coding', 'skip the planning', 'this is simple', 'should be quick', 'this is straightforward', 'no need to overthink'. Enforces iron-law: NO CODE BEFORE DESIGN. EVEN ON SIMPLE TASKS. 5-step procedure: state goal, diverge (2-3 approaches), converge (pick + tradeoffs), capture (graduate to essay or idea), implement. Do NOT trigger for typo fixes, comment-only changes, dependency bumps, or applying a previously-decided design."
---

# design-before-code

## Iron law

**NO CODE BEFORE DESIGN. EVEN ON SIMPLE TASKS.**

Implementation that precedes design is a guess wearing a uniform. The
shortest path from request to working code passes through a stated
goal, two or three considered alternatives, and one chosen trade-off —
not around them.

## Procedure

1. **State the goal in one sentence.** What outcome counts as success?
   If the sentence is hard to write, the request is ambiguous — that
   is the first finding, not a reason to skip ahead.
2. **Diverge: list 2–3 approaches.** Name each, with its rough shape
   and obvious trade-off (cost, complexity, failure mode, coupling).
   Two is the minimum; one approach is not a choice.
3. **Converge: pick one with stated trade-offs.** "X over Y because
   Z" — the *because* is the load-bearing word.
4. **Capture the decision.** Non-trivial decision affecting future
   artifacts → graduate to `essay`. Pre-plan stash, not yet
   actionable → `idea-tracker`. Small and local → stay in chat, but
   the trade-off was still stated.
5. **Implement.** Now the code has somewhere to land.

## "Simple task" rationalization counters

- *"This is simple — should be quick. Let me just build it."* — The
  perception of simplicity is the failure mode. "Simple" requests
  hide the same trade-offs as complex ones (sync vs async, retry
  policy, secret storage, error visibility); skipping design defers
  the choice to the first incident. Skill applies *especially* when
  the task feels small.
- *"Skip the planning, the requirements are clear."* — Clear
  requirements leave the *how* underdetermined. Diverge exposes at
  least one alternative the obvious approach was hiding. If both
  converge on the same answer, the step cost a sentence.
- *"Designing this out would be over-engineering."* — Over-engineering
  is building unused machinery, not naming alternatives. A two-line
  trade-off is the minimum honesty the next reader needs. Skipping
  it relocates the effort to whoever debugs the unstated choice.
- *"I'll start coding and refactor if it's wrong."* — Refactoring
  recovers shape, not intent. A wrong choice made implicitly will
  reproduce itself because the trade-off was never named.

## Cross-references

- `essay` — non-trivial decisions graduate here; the capture step
  persists across sessions.
- `idea-tracker` — pre-plan stash when the converge step produces a
  decision but implementation is deferred.
- Sibling `test-driven-development` — RED-before-GREEN is the same
  discipline at the test boundary; design-before-code is its upstream
  form at the requirements boundary.
- Sibling `verification-before-completion` — design states what
  success looks like; verification proves it. The skills bracket the
  implementation cycle.

## When NOT to use

- Typo fixes, comment-only changes.
- Dependency version bumps with no behavior change.
- Pure documentation edits.
- Applying a previously-decided design (the design step already ran).
