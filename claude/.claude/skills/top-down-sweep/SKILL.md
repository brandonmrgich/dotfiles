---
name: "[HomebrewSkill] top-down-sweep"
description: "Activates on '/top-down-sweep', 'top-down sweep from <path>', 'audit docs from <path>', or 'sweep docs'. Use when the user asks for a breadth-first documentation audit from a named root doc (README.md, ARCHITECTURE.md, BRIDGES.md, or similar canonical doc)."
triggers:
  - /top-down-sweep
  - "top-down sweep"
  - "audit docs from"
  - "sweep docs from"
---

# Top-Down Sweep

A named protocol for keeping the most-read docs current. Dual to bottom-up code cleanup: cleanup notices drift while doing other work; top-down sweep starts from the canonical account and pulls drift toward the surface.

Top-level docs (READMEs, ARCHITECTURE.md, BRIDGES.md) are the ones people trust most and read first — drift there is most expensive. Walking from the top guarantees we catch things in the order they matter.

---

## Step 1 — Pick the root

If the user provides a root doc path, use it. Otherwise ask one focused question:
"Which doc is the root of this sweep? (e.g., `README.md`, `docs/ARCHITECTURE.md`)"

Name the sweep explicitly: "TOP_DOWN_SWEEP from `<path>`".

## Step 2 — Read the root in full

No skimming. The whole document, including front-matter and link targets noted but not yet followed.

## Step 3 — Truth-test every factual claim

For each claim in the root doc:

- **Files / paths**: do they exist? Use Read or Bash `ls`.
- **APIs, functions, types, schemas**: grep for the identifier. Spot-read where it's defined.
- **"X does Y" behavioral claims**: grep + spot-read enough to confirm.
- **Front-matter `covers:` paths**: do they all exist?

A claim is verified only when the code confirms it. Trust nothing the doc says about itself.

## Step 4 — Apply truth rules

**The code is the source of truth.** When doc and code disagree, the doc is wrong.

- **Harmful drift → fix immediately.** Nonexistent APIs, dead paths, wrong identifiers — repair in the sweep, don't flag.
- **Honest hedging keeps a doc load-bearing.** When code hasn't caught up to intent:
  - `PLANNED` — intended, not built.
  - `UNCERTAIN` — not sure how this will land yet.
  - Explicit "current state (<date>):" followed by what actually happens today.
- **Bump `last-verified:`** on docs that pass verification clean. ISO date.
- **Prose vs identifier distinction.** Prose names lean human-form ("Music Portfolio"); module/package/URL tokens stay as identifiers (`MusicPortfolio`).

## Step 5 — Walk links breadth-first

Survey width before depth. Don't rabbit-hole into the first subsystem.

For each linked doc:
- If obviously fresh (edited today, claims self-evidently current) → prune; don't re-verify.
- If small drift (<~10 min to fix) → fix in the sweep.
- If substantial drift (>~20 min to fix) → flag as `[next sweep from here]` and continue. Don't let one sweep metastasize.

## Step 6 — Output summary

At the end, write a summary to `<project>/.claude/sweeps/<root-slug>-<date>.md` (create dir if needed). Console gets a 1-3 line status:

```
TOP_DOWN_SWEEP from <path> complete.
Updated: 4 docs · Flagged: 2 · Pruned: 3
Summary: <path-to-sweep-summary>
```

The summary file contains:
- Root doc + date
- Per-doc: status (verified / updated / flagged / pruned) + what changed or what's flagged
- List of follow-up sweeps queued

---

## Integration

- Bumps `last-verified:` on anchored docs. Same field the `doc-freshness` skill watches.
- When a sweep finds a doc whose `covers:` paths have moved or been deleted, update `covers:` to match reality.
- When a sweep produces large remediation work, propose creating a plan via the essay → plan flow rather than fixing inline.

## What you must never do

- Trust a doc's claim about itself without grep/Read confirmation.
- Use `last-verified:` to mean "today I read this" — only "today I verified the claims hold."
- Let a single sweep grow past ~30 minutes without flagging more for next time.
- Modify code during a sweep. Sweeps fix docs; code drift goes on a flagged list for a separate change.
