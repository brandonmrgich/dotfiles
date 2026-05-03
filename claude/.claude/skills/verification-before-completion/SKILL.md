---
name: "[HomebrewSkill] verification-before-completion"
description: "Use when claiming a task is done, marking complete, declaring a fix shipped, closing a PR, or signaling 'this is ready'. Activates on phrases like 'I'm done', 'task complete', 'fixed it', 'ready to merge', 'should be working', 'I think it's done'. Enforces iron-law: DO NOT CLAIM DONE WITHOUT FRESH EVIDENCE. Required evidence per artifact: code = test output + diff cite + behavioral check; docs = re-read + last-verified cite; plans = audit verdict. Bans hedging language. Do NOT trigger for in-progress status updates or partial-work check-ins."
---

# verification-before-completion

## Iron law

**DO NOT CLAIM DONE WITHOUT FRESH EVIDENCE.**

Memory is not evidence. Visual diff inspection is not evidence. "It
should work" is not evidence. Fresh evidence means: produced *this
session*, *after* the change, citable verbatim.

## Required evidence by artifact type

### Code

All three, every time:

- **Test output** — cite the command run and the result (pass count,
  failure count, key line). Not "tests pass" — paste the line.
- **Diff cite** — name the function/section changed and what changed
  about it. Not "I edited the file" — show the load-bearing line.
- **Behavioral check** — run the code (or the failing repro from
  systematic-debugging) and observe the new behavior. The contrast
  between old failure and new pass is the proof.

### Docs

- **Re-read** the full doc end-to-end after edits. Skim is not
  re-read.
- If `covers:` paths in the doc changed, **bump `last-verified:`** to
  today's date in the same commit. See `doc-freshness`.

### Plans / tasks

- **Audit verdict** — invoke `plan-auditor` and cite its verdict
  (PASS or CONDITIONAL PASS). Do not self-audit.
- **Commit SHA** — cite the SHA the work landed on.

## Banned phrases

If you hear yourself forming any of these, stop. The iron law is
being violated.

- "I think it's working" / "should be done" / "should work"
- "done — let me know if anything's broken"
- "based on the diff alone" / "the diff looks right"
- "I've verified this before" *(memory ≠ fresh evidence)*
- "the implementation is straightforward, so it works"

## Rationalization counters

- *"I think it's working."* — Hedging is the failure-mode tell. If
  you cannot cite evidence, you do not know. Run it.
- *"I've already verified this manually; rerunning is overkill."* —
  Memory of a past pass is not evidence of the current state. Code
  drifts; rerun.
- *"Done — let me know if anything's broken."* — This offloads
  verification to the user. The user delegated *both* the work and
  the check. Run the check yourself.
- *"Based on the diff alone, it looks correct."* — Reading a diff
  proves intent, not behavior. Behavior comes from execution.
- *"The implementation is straightforward."* — Straightforward code
  has bugs at the same rate as ornate code. Run it.

## Cross-references

- `plan-auditor` — required evidence path for plan/task completion.
- `doc-freshness` — required evidence path for doc completion
  (covers re-read + `last-verified` bump).
- Sibling skill `systematic-debugging` — the FIX phase ends here:
  no fix is "done" without fresh evidence of the REPRODUCE case
  flipping.

## When NOT to use

- In-progress status updates ("halfway through, here's where I am").
- Partial-work check-ins where the user explicitly asked "what's
  the state".
- Surfacing blockers — naming a blocker is not claiming done.
