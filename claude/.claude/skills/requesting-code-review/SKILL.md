---
name: "[HomebrewSkill] requesting-code-review"
description: "Use when asking for code review, marking a PR ready for review, requesting feedback, or dispatching the code-reviewer sub-agent. Activates on phrases like 'request review', 'ready for review', 'PTAL', 'can you review', 'review my changes'. Enforces a 5-item pre-request checklist: reviewable diff, intent stated, test plan concrete, concerns flagged, self-review complete. Cross-references the pr-review-toolkit:code-reviewer agent for auto-review, and sibling receiving-code-review for response discipline. Do NOT trigger for draft-PR / WIP signals or for requests to a specific human reviewer outside the skill scope."
---

# requesting-code-review

## Norm

**REVIEW REQUEST = REVIEWABLE DIFF + STATED INTENT + CONCRETE TEST
PLAN + FLAGGED CONCERNS + SELF-REVIEW COMPLETE.**

A review request is a transfer of attention. The reviewer's time is
the scarcest resource in the loop. The norm is to make that transfer
worth taking — frame the work, stage the diff, name what's uncertain.
"Ready for review" without these is not a request; it is a hand-off
of unfinished thinking.

## Pre-request checklist

1. **Reviewable diff.** No whitespace-only lines. No unrelated
   changes (split into a separate PR). No commented-out code. No
   `console.log`, `dbg!`, or other debug artifacts. The diff Claude
   pushes should match what Claude wants reviewed.
2. **Intent stated.** PR description explains *why*, not just *what*.
   Trade-offs surfaced. Alternatives considered get one sentence
   each. The reviewer should not have to reverse-engineer the goal
   from the code.
3. **Concrete test plan.** Exact commands run, observed behavior,
   edge cases checked. "Verified locally" without specifics is a
   non-answer. Format: `ran X → observed Y → covers cases A, B, C`.
4. **Concerns flagged.** Explicitly say "I'm uncertain about X" or
   "I'd value review focus on Y." If nothing concerns you, write
   "I am confident in: A, B, C" — the assertion forces the check.
5. **Self-review complete.** Read your own diff end-to-end before
   requesting. Catch the embarrassing mistakes yourself; reviewer
   attention is not a substitute for your own.

## Rationalization counters

- *"The diff speaks for itself."* — speaks volumes about your
  respect for reviewer time. Add the description.
- *"Let the reviewer figure out what to look at."* — review is
  verification, not exploration. Frame the work; pick the cone.
- *"I'm not sure what to flag — let them decide."* — that
  uncertainty itself is what to flag. Name it; don't hide it.
- *"It's only a small change."* — small changes still need intent
  and a test plan. The checklist scales with the diff; it doesn't
  vanish below some threshold.

## Cross-references

- `pr-review-toolkit:code-reviewer` agent — the auto-review path.
  Same checklist applies before dispatching: the agent reviews
  better when the framing is present.
- Sibling `receiving-code-review` — response discipline once the
  review comes back. Both skills enforce that a review is a
  verification exchange, not a performance.
- `github` — PR mechanics: body templates, draft vs ready, label
  conventions, push policy.
- `verification-before-completion` — the "self-review complete"
  step is the same evidence discipline at the diff boundary.

## When NOT to use

- Draft PRs / WIP signals — the request hasn't been made yet.
- Requests to a specific human reviewer outside the skill scope
  (e.g. "ping Sarah on Slack about the auth PR") — no checklist
  fires; that is a notification, not a review request.
- Auto-merge bots and dependency-update PRs — the diff is the
  description; the checklist would be ceremony.
