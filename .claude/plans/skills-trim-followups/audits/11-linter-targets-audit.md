# Audit Report — Task 11: Per-class budget targets in skill-budget-lint

**Auditor:** Plan Compliance Auditor (orchestrator, discovery sub-agent)
**Date:** 2026-05-04
**Branch / Commit:** `claude/skills-trim-followups` @ `667a858` (post Task 10 deferral)
**Source under audit:** `~/.claude/tools/skill-budget-lint.py`
**Origin essay:** `~/.claude/essays/skill-system-token-efficiency-audit.md` §P3.1

User-flag at Phase-1 audit boundary: **"these values seem arbitrary, how were they chosen?"** This audit answers the flag, measures every class against its budget, and recommends concrete recalibrations for Task 12.

---

## Section 1 — Origin trace

### What essay #9 §P3.1 actually says

Essay §P3.1 ("Establish per-class budgets and lint them") in full:

> **P3.1 — Establish per-class budgets and lint them.**
> Add a CI/pre-commit script that fails when a SKILL.md exceeds
> its class budget:
>
> | Class | Description | Body | Total |
> |---|---|---|---|
> | Domain specialist | ≤1,024 chars | ≤6,000 bytes | ≤8,000 |
> | Workflow / discipline | ≤500 chars | ≤4,000 bytes | ≤5,000 |
> | Capture / knowledge | ≤500 chars | ≤4,000 bytes | ≤5,000 |
> | Policy / catalog | ≤400 chars | ≤3,500 bytes | ≤4,500 |
> | Meta (skill-author, etc.) | ≤700 chars | ≤5,000 bytes | ≤6,000 |
>
> Soft enforcement first (warning), hard after one cleanup pass.

That is the entire derivation in the essay. No per-class measurement,
no member skill enumeration, no anchor from "skill X is N bytes,
therefore the class budget is M". The numbers are **stated, not
justified**. The only adjacent rationale is essay §"Hotspot 4"'s
mention of "superpowers' 1024-char target" for descriptions — i.e.
the specialist desc=1024 is anchored to an external standard, but
the other four numbers in that row (and all 12 numbers in the other
rows) carry no derivation.

**The user's flag is essentially correct: the values are arbitrary.**
They are reasonable-looking estimates that happened to roughly fit
the 20 skills in scope at essay-authoring time. That suffices for
"soft enforcement first" (the essay's own caveat) but does not
survive the +8-skill addition Phases 5+6 made to the system.

### The 5→7 class drift

Essay #9 names **5 classes**. The linter implements **7 classes**.
The drift is undocumented in the essay; it happened during/after
the parent plan's Phase-5/6 (when 4 discipline + 4 ritual skills
were added).

| Class | Essay #9 | Linter | Notes |
|---|---|---|---|
| specialist | yes (≤1024 / ≤6000 / ≤8000) | yes (same) | Anchored to superpowers' 1024 desc target |
| workflow | bundled with discipline (≤500 / ≤4000 / ≤5000) | yes (≤500 / ≤4000 / ≤5000) | Split apart |
| discipline | bundled with workflow (same numbers) | yes (≤700 / ≤4000 / ≤5000) | Desc budget retrofit to 700 — no documented basis |
| capture | bundled with knowledge (≤500 / ≤4000 / ≤5000) | yes (≤500 / ≤4000 / ≤5000) | "knowledge" alias dropped |
| policy | yes (≤400 / ≤3500 / ≤4500) | yes (same) | Zero current members |
| meta | yes (≤700 / ≤5000 / ≤6000) | yes (same) | One member (skill-author) |
| ritual | **NOT IN ESSAY** | yes (≤500 / ≤4000 / ≤5000) | Class added wholesale; no documented basis |

The two undocumented additions (`ritual` introduced; `discipline`
desc retrofit from 500→700) directly cause 4 of the 8 current
FAILs (4 ritual skills FAIL on `desc>500`). This is a **mis-
calibration artifact**, not a content problem — Phase 3 of the
parent plan authored those descriptions to the ≤1024 spec, but the
linter enforces 500.

---

## Section 2 — Per-class measurement

Running the current linter (post-Phase-1) yields:
**OK=15  WARN=5  FAIL=8  UNKNOWN=0  (total=28)**.

Class totals: specialist=8, workflow=8, capture=3, policy=0,
meta=1, ritual=4, discipline=4.

### 2.1 specialist (N=8) — budget desc=1024 / body=6000 / total=8000

| Skill | Desc | Body | Total | Verdict |
|---|---|---|---|---|
| astro-static-sites | 893 | 5,525 | 6,418 | OK |
| ddex-standards | 967 | 6,199 | 7,166 | WARN (body) |
| github | 451 | 6,214 | 6,665 | WARN (body) |
| gitignore | 420 | 4,928 | 5,348 | OK |
| nextjs-app-router | 994 | 5,984 | 6,978 | OK |
| royalty-splits-music | 870 | 5,527 | 6,397 | OK |
| turborepo-patterns | 713 | 5,789 | 6,502 | OK |
| web-audio-howler | 915 | 5,601 | 6,516 | OK |

- Desc: median 892, min 420, max 994. All ≤ 1024.
- Body: median 5,755, min 4,928, max 6,214. 0 over budget; 2 in WARN band.
- Total: median 6,510, min 5,348, max 7,166. All ≤ 8,000.
- **Outliers:** github (very short desc 451 — ROUTER-style), gitignore (short body 4,928 — could compress further but no need).

### 2.2 workflow (N=8) — budget desc=500 / body=4000 / total=5000

| Skill | Desc | Body | Total | Verdict |
|---|---|---|---|---|
| doc-freshness | 332 | 3,978 | 4,310 | OK |
| plan-auditor | 505 | 5,823 | 6,328 | FAIL (desc, body, total) |
| plan-executor | 432 | 6,497 | 6,929 | FAIL (body, total) |
| session-ready | 337 | 4,947 | 5,284 | FAIL (body, total) |
| top-down-sweep | 257 | 3,628 | 3,885 | OK |
| worktree-orchestrator | 485 | 5,019 | 5,504 | FAIL (body, total) |
| zoom-in | 221 | 2,564 | 2,785 | OK |
| zoom-out | 126 | 1,728 | 1,854 | OK |

- Desc: median 335, min 126, max 505. 1 over (plan-auditor by 5).
- Body: median 4,463, min 1,728, max 6,497. **4 over the 4,000 budget.**
- Total: median 4,629, min 1,854, max 6,929. 4 over the 5,000 budget.
- **Bimodal distribution:** four light slash-command-style workflows
  (zoom-out 1,728 → top-down-sweep 3,628 → doc-freshness 3,978 →
  zoom-in 2,564) sit well under budget; four heavy orchestrators
  (session-ready 4,947, worktree-orchestrator 5,019, plan-auditor
  5,823, plan-executor 6,497) are all over by 24%–62%.
- **The 4,000 B body budget fits the light cluster; it does not fit
  the orchestrator cluster.** The class is heterogeneous.

### 2.3 capture (N=3) — budget desc=500 / body=4000 / total=5000

| Skill | Desc | Body | Total | Verdict |
|---|---|---|---|---|
| environment-map | 1 | 1,677 | 1,678 | OK |
| essay | 508 | 8,365 | 8,873 | FAIL (desc, body, total) |
| idea-tracker | 341 | 4,356 | 4,697 | WARN (body) |

- Desc: 1, 341, 508. essay 8 chars over.
- Body: 1,677, 4,356, 8,365. essay is **2.1× the budget** — a real over, not a mis-calibration. idea-tracker is in the WARN band.
- **environment-map's desc=1 is anomalous** — its real description is multi-line YAML that the simple parser truncates; the description is actually present and works. (Out of scope for this audit; does not affect calibration.)
- Sample size N=3 is too small to recalibrate — but essay is a real 2× over and either needs trimming (Task 13) or reclassification.

### 2.4 policy (N=0) — budget desc=400 / body=3500 / total=4500

**Zero current members.** This class is reserved in the linter but
never used. No member assignments were made during the parent plan
or this followup. Carries the most aggressive budgets of any class.

### 2.5 meta (N=1) — budget desc=700 / body=5000 / total=6000

| Skill | Desc | Body | Total | Verdict |
|---|---|---|---|---|
| skill-author | 760 | 5,012 | 5,772 | WARN (desc, body) |

- Single member, both desc (760 vs 700) and body (5,012 vs 5,000) just over.
- **N=1; cannot calibrate.** Either accept the WARN as ambient noise from a tight budget on a single artifact, or loosen to desc=800 / body=5500 to give skill-author OK headroom.

### 2.6 ritual (N=4) — budget desc=500 / body=4000 / total=5000

| Skill | Desc | Body | Total | Verdict |
|---|---|---|---|---|
| finishing-a-branch | 623 | 3,033 | 3,656 | FAIL (desc) |
| receiving-code-review | 605 | 3,330 | 3,935 | FAIL (desc) |
| requesting-code-review | 619 | 3,058 | 3,677 | FAIL (desc) |
| using-homebrew-skills | 535 | 2,181 | 2,716 | WARN (desc) |

- Desc: median 614, min 535, max 623. **All 4 over the 500 budget; all 4 well under the Phase-3 description-format spec's ≤1024.**
- Body: median 3,047, min 2,181, max 3,330. All comfortably under 4,000.
- Total: median 3,667, all under 5,000.
- **This is a textbook mis-calibrated-tight pattern.** The descriptions were authored to ≤1024 (Phase 3 of parent plan); the linter enforces ≤500 from a different, undocumented basis. Bodies and totals are fine.

### 2.7 discipline (N=4) — budget desc=700 / body=4000 / total=5000

| Skill | Desc | Body | Total | Verdict |
|---|---|---|---|---|
| design-before-code | 598 | 3,020 | 3,618 | OK |
| systematic-debugging | 631 | 3,051 | 3,682 | OK |
| test-driven-development | 589 | 3,049 | 3,638 | OK |
| verification-before-completion | 547 | 2,891 | 3,438 | OK |

- Desc: median 593, min 547, max 631. All ≤ 700.
- Body: median 3,035, min 2,891, max 3,051. All comfortably under 4,000 (~76% utilization).
- Total: all under 5,000.
- **All 4 OK.** Calibrated tight on desc (max 631 vs budget 700, ~10% headroom); calibrated loose on body. Could tighten body to 3,500 without forcing trim, but no benefit unless we want to discourage future bloat.

---

## Section 3 — Per-class pattern verdict

| Class | Pattern | One-line summary |
|---|---|---|
| specialist | **calibrated** | 0/8 over body; 2/8 in WARN band; matches superpowers' 1024 desc anchor. Keep as-is. |
| workflow | **split** | Bimodal: 4 slash-commands (1.7–4.3k bodies) + 4 orchestrators (4.9–6.5k bodies). Single budget cannot fit both. |
| capture | **mis-calibrated tight on essay only / N too small overall** | env-map and idea-tracker fit; essay is a 2× over (genuine, not mis-calibration). Don't recalibrate; trim or reclass essay. |
| policy | **empty** | Zero members. Either remove from linter or document as reserved. |
| meta | **N=1; cannot calibrate** | skill-author is 8 chars / 12 bytes over both desc and body limits. Keep WARN, or loosen 100/500. |
| ritual | **mis-calibrated tight (desc)** | All 4 over 500-char desc despite Phase-3 authoring to ≤1024. Body+total fine. Loosen desc. |
| discipline | **calibrated** | All 4 OK. Slight desc headroom (~10%); slight body headroom (~24%). Keep as-is. |

---

## Section 4 — Recalibration recommendations

### specialist — KEEP AS-IS
- Budget: desc=1024 / body=6000 / total=8000.
- Rationale: 0 over body; 2 in WARN band (ddex-standards 6,199; github 6,214) which is healthy headroom signaling. Desc anchor traces to superpowers; body/total empirically fit the cluster.

### workflow — SPLIT
- New `workflow` budget: desc=500 / body=4000 / total=5000 (unchanged).
- New `complex-orchestrator` class budget: **desc=500 / body=6500 / total=7500**.
- Members reassigned to complex-orchestrator: **`plan-executor`, `plan-auditor`** (the two heaviest, both currently FAIL).
- Members staying as workflow: `doc-freshness`, `top-down-sweep`, `zoom-in`, `zoom-out`, `session-ready`, `worktree-orchestrator`.
- Body=6500 anchor: Task 05 spec's empirically-derived "relaxed target ≤6,500 B" for plan-executor; landed at 6,497 B. plan-auditor at 5,823 B fits comfortably.
- session-ready (4,947) and worktree-orchestrator (5,019) **stay as workflow and become Task 13 targets** — they are over the 4,000 body but only by ~24%; prose-pruning is the right answer, not class promotion.

### capture — KEEP BUDGET; RESOLVE essay SEPARATELY
- Budget: desc=500 / body=4000 / total=5000 (unchanged).
- Rationale: N=3 is too small to recalibrate. env-map and idea-tracker fit; essay is a real 2× over.
- **essay action (Task 13):** trim body to ~5,000 B (one prose-pruning pass; same pattern as Phase 1) OR reclassify to specialist (essay describes a specialist-density tool: capture / lifecycle / supersede / anchors). Recommend **trim** — essay is a capture/knowledge artifact by intent; reclassifying just to dodge a budget would be papering over.

### policy — REMOVE FROM LINTER (or comment as reserved)
- Zero members; cluttering the BUDGETS dict.
- Recommend: delete the row. If a future class genuinely needs ≤400 / ≤3,500 / ≤4,500 budgets, re-add at that time.
- Alternative (lower-friction): leave the row but add an inline comment `# policy: reserved; no current members as of plan skills-trim-followups Task 11`.

### meta — LOOSEN to desc=800 / body=5500 / total=6500
- Rationale: N=1; can't truly calibrate. skill-author at 760/5,012/5,772 is barely over both desc and body. The current budget produces persistent WARN noise on the only member without signaling any actionable trim work. Loosening to desc=800 / body=5500 / total=6500 gives ~5% headroom in each direction.
- Alternative (purist): leave at 700/5000/6000 and trim skill-author's description by ~60 chars and body by ~12 B — an absurdly small trim for the budget signal it would silence. Loosening is cheaper.

### ritual — LOOSEN desc to 700 (or 1024)
- Rationale: All 4 ritual descriptions were authored to the Phase-3 description-format spec's ≤1024 cap. Linter's 500 cap is undocumented and produces 4 FAILs that are calibration artifacts, not content problems.
- **Recommend desc=700**: matches the discipline class's desc budget (rituals and disciplines are sibling shapes — both teach iron-laws and rationalization tables); covers all 4 current ritual descriptions (max 623); preserves a tighter signal than 1024.
- **Alternative desc=1024**: matches the Phase-3 spec exactly; matches specialist; produces the loosest possible budget. Only worth picking if a future ritual genuinely needs the headroom — current data does not suggest it.
- Body=4000 / total=5000 unchanged (all 4 fit comfortably).

### discipline — KEEP AS-IS
- Budget: desc=700 / body=4000 / total=5000 (unchanged).
- Rationale: all 4 OK with healthy headroom; tightening body to 3,500 would gain ~500 B per skill of "don't bloat" signal but the current class is already disciplined. Don't add friction without cause.

### complex-orchestrator (NEW) — desc=500 / body=6500 / total=7500
- Members: `plan-executor`, `plan-auditor`.
- Body=6500 derived from Task 05 spec's empirical anchor (plan-executor's relaxed body target).
- desc=500 inherits from workflow; both members already comply.
- **Future expansion candidates** (NOT promoted now): `worktree-orchestrator` (body=5,019 — ambient workflow density, can prose-prune); any future plan-system orchestrator that exceeds 5k.

### Summary table — recommended new BUDGETS dict

```python
BUDGETS = {
    "specialist":           (1024, 6000, 8000),  # unchanged
    "workflow":             ( 500, 4000, 5000),  # unchanged
    "complex-orchestrator": ( 500, 6500, 7500),  # NEW
    "capture":              ( 500, 4000, 5000),  # unchanged
    "meta":                 ( 800, 5500, 6500),  # loosened from 700/5000/6000
    "ritual":               ( 700, 4000, 5000),  # desc loosened from 500
    "discipline":           ( 700, 4000, 5000),  # unchanged
    # "policy" removed (zero members; re-add when needed)
}
```

### Projected linter result after recalibration alone (no body trims)

Recalibration alone (Task 12) without any trim work (Task 13) flips:

| Skill | Pre-recal | Post-recal | Why |
|---|---|---|---|
| plan-executor | FAIL | OK | Reclassed to complex-orchestrator (body 6,497 ≤ 6,500) |
| plan-auditor | FAIL | OK | Reclassed; desc 505 needs trim by 5 chars OR fold into class budget desc=500 (already fits the class line — recheck) — actually FAIL desc remains; see note |
| skill-author | WARN | OK | Meta loosened |
| finishing-a-branch | FAIL | OK | Ritual desc loosened |
| receiving-code-review | FAIL | OK | Ritual desc loosened |
| requesting-code-review | FAIL | OK | Ritual desc loosened |
| using-homebrew-skills | WARN | OK | Ritual desc loosened |
| ddex-standards | WARN | WARN | Specialist body unchanged at 6,199 (within WARN band) |
| github | WARN | WARN | Same |
| idea-tracker | WARN | WARN | Body 4,356 unchanged |

Note on **plan-auditor desc=505 vs new complex-orchestrator desc=500**: still 5 chars over; trivial nominal trim or accept WARN in the new class. Recommend trim 5 chars at Task 12 (one-line edit in skill description).

Remaining FAILs after recalibration (Task 13 targets):
- `essay` (desc 508, body 8,365 — body is a real 2× over)
- `session-ready` (body 4,947, total 5,284 — moderate trim or class promotion case)
- `worktree-orchestrator` (body 5,019, total 5,504 — moderate trim)

Projected final state after Task 12 alone: **OK ~22 / WARN 3 / FAIL 3** (vs current 15/5/8). Task 13 brings the 3 remaining FAILs to OK.

---

## Section 5 — Required action for Task 12

Task 12 (apply linter recalibrations) must:

1. **Edit `~/.claude/tools/skill-budget-lint.py` BUDGETS dict** to the table at end of Section 4. Specifically:
   - ADD `"complex-orchestrator": (500, 6500, 7500)`.
   - CHANGE `"meta"` to `(800, 5500, 6500)`.
   - CHANGE `"ritual"` to `(700, 4000, 5000)`.
   - REMOVE `"policy"` row (or comment as reserved — pick one).

2. **Reclassify two SKILL.md files** (frontmatter `class:` field):
   - `~/.claude/skills/plan-executor/SKILL.md`: `class: workflow` → `class: complex-orchestrator`.
   - `~/.claude/skills/plan-auditor/SKILL.md`: `class: workflow` → `class: complex-orchestrator`.

3. **Trim plan-auditor description by 5 chars** (505 → ≤500) to clear the desc FAIL under the new class. Single-line edit; preserve all keywords.

4. **Re-run linter; capture the new pass/fail counts** in commit body. Expected: ~22 OK / 3 WARN / 3 FAIL.

5. **Update essay #9 §P3.1** (or add a §P3.1.1 note) recording:
   - The class taxonomy now has 7 active classes (8 total minus policy if removed).
   - The recalibration rationale (this audit document path).
   - The remaining 3 FAILs are queued for Task 13 prose-pruning.

6. **Stow re-apply** if any new files; this task is config + frontmatter edits only — `stow -d ~/dotfiles -t ~ claude` is a no-op but should be confirmed clean.

7. **Commit footer**: `Plan: skills-trim-followups`, `Task: 12`.

Task 13 then handles the 3 remaining FAILs via prose-pruning:
- `essay` body trim (~3,000 B target — biggest job in Task 13).
- `session-ready` body trim (~1,000 B target).
- `worktree-orchestrator` body trim (~1,000 B target).

---

## Audit verdict

**Origin trace:** essay #9 §P3.1 lists the budget table verbatim and provides **no per-class derivation, no measurement basis, no anchor for body/total numbers**. Only the specialist desc=1024 has external anchoring (superpowers). The user's flag ("these values seem arbitrary") is correct: the budget table is essentially an estimate authored at the time, never recalibrated when 8 new skills (4 discipline + 4 ritual) were added in Phases 5+6 of the parent plan. The linter even drifted from 5 to 7 classes without doc trail.

**Calibration verdicts:** 2 calibrated (specialist, discipline), 1 split (workflow), 1 mis-tight (ritual desc), 1 needs N>1 to judge (meta), 1 needs essay-trim-or-reclass (capture), 1 empty (policy).

**complex-orchestrator class: YES.** Members: plan-executor, plan-auditor. Budget: desc=500 / body=6500 / total=7500. Anchored to Task 05 spec's empirical 6,500 B target.

**Ritual desc budget too tight: YES.** All 4 descriptions authored to Phase-3 spec ≤1024; linter enforces 500. Loosen to 700 (matches discipline; covers all 4 current members; preserves tightness vs 1024).

Recommendations are concrete numbers; Task 12 has a deterministic apply procedure.
