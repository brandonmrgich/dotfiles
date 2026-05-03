---
name: "[HomebrewSkill] receiving-code-review"
description: "Use when responding to PR review comments, addressing review feedback, working through reviewer questions, or applying review-suggested changes. Activates on phrases like 'addressing review comments', 'review feedback', 'PR comment', 'reviewer says', 'requested changes'. Enforces iron-law: DO NOT AGREE PERFORMATIVELY. EVALUATE BEFORE RESPONDING. 6-step protocol: READ -> UNDERSTAND -> VERIFY -> EVALUATE -> RESPOND -> IMPLEMENT. Bans phrases 'you're absolutely right', 'great catch', 'good point' when used without verification. Do NOT trigger for trivial style nits or already-decided team conventions."
---

# receiving-code-review

## Iron law

**DO NOT AGREE PERFORMATIVELY. EVALUATE BEFORE RESPONDING.**

Reflexive agreement with a reviewer is sycophancy in a tie. It looks
collaborative; it is corrosive. Every "you're absolutely right"
emitted before a verification step trains the reviewer that
confidence overrides correctness, and trains future readers that
the codebase agrees with whoever speaks last. The discipline is to
treat each review comment as a claim to be checked, not a verdict
to be applied.

## 6-step protocol

1. **READ** — read the comment in full, including any attached
   suggestion, code block, or thread context. Skimming the first
   sentence and inferring the rest is the most common cause of
   wrongly-applied feedback.
2. **UNDERSTAND** — restate the reviewer's claim in your own words.
   If you cannot, the comment is ambiguous; ask before acting.
3. **VERIFY** — check the technical claim against documentation,
   the codebase, or a quick test. Do not skip. "Sounds right" is
   not verification.
4. **EVALUATE** — three outcomes:
   (a) reviewer is correct → accept;
   (b) reviewer's reasoning is wrong but the suggestion is OK for a
   different reason → state the actual reason;
   (c) reviewer is wrong → push back with evidence.
5. **RESPOND** — write the reply with stated reasoning. No "you're
   absolutely right" without VERIFY having passed. The reply names
   what was checked and what was found.
6. **IMPLEMENT** — make the change (if accepted), and cite the
   verification in the commit or reply ("Verified: Sets do preserve
   insertion order; switching to Map for the keyed-lookup ergonomics
   anyway").

## Banned phrases (and counters)

These phrases signal the protocol was skipped. Each has a stated
counter — use the counter form once VERIFY has actually run.

- *"You're absolutely right"* — pre-VERIFY agreement. Replace with
  "I checked X, you're correct that Y."
- *"Great catch"* — performative; flatters the reviewer instead of
  engaging the claim. Replace with "Verified: <what>."
- *"Good point"* — same failure mode. Replace with "Confirmed by
  <evidence>; updating accordingly."
- *"I'll fix it"* without preceding verification — collapses
  EVALUATE and IMPLEMENT into a single capitulation. Replace with
  "Verified the claim against <source>; applying the change."

If the verification step contradicts the reviewer, name the
contradiction directly: "Checked the spec/MDN/docs — <reason>;
keeping the current code, happy to discuss."

## Cross-references

- `github` — PR mechanics (reply syntax, resolve-thread conventions,
  push/force-push policy after addressing review).
- Sibling `requesting-code-review` — the upstream form (Task 28);
  what to ask for so reviewers can give actionable feedback.
- `verification-before-completion` — the same discipline at the
  task-completion boundary; both refuse to declare a thing settled
  without fresh evidence.

## When NOT to use

- Trivial style nits the team has already decided (linter rules,
  formatter output) — apply and move on.
- Already-decided team conventions cited in a review comment —
  the verification ran when the convention was set.
- Pure typo fixes in review feedback (typo in a comment, missing
  newline) — the verification is the diff itself.
