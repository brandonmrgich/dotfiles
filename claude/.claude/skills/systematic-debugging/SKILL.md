---
name: "[HomebrewSkill] systematic-debugging"
class: discipline
description: "Use when debugging, investigating bugs, chasing failures, diagnosing intermittent issues, or chasing 'sometimes-broken' behavior. Activates on phrases like 'why is this failing', 'I'm trying to debug', 'flaky test', 'sometimes broken', 'intermittent', 'race condition', 'heisenbug', 'works on my machine', 'users are seeing X but I see Y'. Enforces a 4-phase root-cause methodology (REPRODUCE → ISOLATE → DIAGNOSE → FIX) with iron-law: NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST. Halts after 3 failed attempts to question architecture. Do NOT trigger for simple typo fixes, syntax errors, or compile errors with obvious cause."
---

# systematic-debugging

## Iron law

**NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.**

A fix before the cause is a guess wearing a patch. The methodology
below is non-negotiable, *especially* under time pressure — time
pressure generates this failure mode, it does not exempt you from it.

## The 4 phases

### 1. REPRODUCE

Make the bug happen on demand before touching code.

- Get an exact failing input/environment/sequence. If "some users",
  identify which users / browsers / sessions.
- Capture logs, request IDs, timestamps. Record the symptom verbatim.
- Confirm a passing case in the same environment — the contrast
  *is* the data.
- Cannot reproduce? Next phase is expand reproduction evidence, not
  guess at fixes.

### 2. ISOLATE

Narrow the failure surface.

- Bisect: which commit, deploy, feature flag, config change.
- Strip variables: smallest input / stack / user state that fails.
- Stable signal vs noise: correlated with one node, cache key,
  tenant, timezone?

### 3. DIAGNOSE

Explain *why* in terms of code, state, or contract.

- State the causal chain in one paragraph: input X enters Y, branches
  on Z (false because of W), violates invariant I.
- Tie to evidence from REPRODUCE/ISOLATE. No hand-waves.
- If two diagnoses fit equally, ISOLATE isn't done. Go back.

### 4. FIX

Now — and only now — change code.

- Target the cause named in DIAGNOSE, not the symptom.
- Confirm the fix kills the REPRODUCE case and breaks no adjacent
  invariant. See `verification-before-completion`.

## 3-strikes clause

If three fix attempts fail to resolve the bug, **stop**. The
architecture is the problem, not the patch. Document the three
failed attempts and surface the architecture question to the user
before a fourth attempt.

## Rationalization counters

Captured from RED-phase pressure tests. When you hear yourself
forming any of these, the iron law is being violated:

- *"In the interest of time, I'll patch now and investigate after."*
  The deadline does not change which fix actually holds. A wrong
  fix at T-30min is a worse demo than the original bug.
- *"The most likely cause is X — let me just bump/clear/disable it."*
  "Most likely" without REPRODUCE evidence is a guess. Guesses
  belong in DIAGNOSE, after data, not before code.
- *"Some see fresh, some see stale — obviously a cache issue."*
  "Obviously" is the rationalization. ISOLATE the discriminator
  before naming the layer.
- *"Quick fix now, root cause after."* The "after" never happens;
  the patch becomes load-bearing. Investigate first.

## Cross-references

- Mantra **make state honest** — many bugs are state-shape bugs.
  When DIAGNOSE keeps producing "shouldn't happen" branches, the
  shape is wrong, not the code path.
- Sibling skill **verification-before-completion** — the FIX phase
  is incomplete without fresh evidence.

## When NOT to use

- Typos, syntax errors, compile errors with obvious cause.
- One-line config flips when the cause is already named.
- Cosmetic changes with no behavioral component.
