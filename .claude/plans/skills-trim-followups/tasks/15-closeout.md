# Task 15 — Closeout: parent essays updated; this plan resolved; closeout PR

**Phase:** 3 (Cleanup + closeout) — but runs LAST, after Phase 4
**Agent:** plan-executor-documenter
**Produces PR:** Yes (closeout PR — user-merged)

## Goal

Close the follow-ups plan. Update parent essays' "Measured outcome" sections with followup deltas. Mark this plan resolved. Open the closeout PR. Orchestrator places v3.2 tag on the closeout commit before user-merge.

## Pre-flight: raise deferred items

**Before any closeout work**, read `.claude/plan-states/skills-trim-followups.json` → `deferred_items[]`. For each item, surface to the user with the listed `options_when_raised`. Do NOT proceed with closeout until each deferred item has an explicit user decision recorded. The user's chosen option for each item must be reflected in:
- The closeout commit body (which option was chosen + brief rationale).
- Essay #9's "Followup outcome" section (CLOSED / WAIVED / DEFERRED-TO-FUTURE-PLAN).
- The parent plan's carry-forward update if the deferred item was originally a parent-plan carry-forward.

Known deferred items as of plan extension (2026-05-04):
- **phase-2-red-dispatches** (Tasks 07, 08): RED dispatches for 8 discipline+ritual skills. Skipped due to structural blocker. User-confirmed defer; must raise here.

## Files

**Affected:**
- `~/dotfiles/claude/.claude/essays/skill-system-token-efficiency-audit.md` — append "Followup outcome (v3.1-v3.2)" section
- `~/dotfiles/claude/.claude/essays/skill-system-vs-superpowers.md` — append followup note
- `~/dotfiles/.claude/plans/skills-trim-followups/MasterPlan.md` — `status: completed`

## Steps

1. **Update essay #9** (`skill-system-token-efficiency-audit.md`):
   - Append `## Followup outcome (v3.1-v3.2)` section. Required content:
     1. Headline — one-bold-sentence summary (e.g., "8 of 8 carry-forward items closed; lint result moved from 12/4/12 (OK/WARN/FAIL) to N/M/K").
     2. Per-followup-item ledger — for each of the 8 items in parent §"Phase-8 follow-ups", state CLOSED / PARTIAL / WAIVED with the closing commit / audit reference.
     3. Updated lint result — final OK/WARN/FAIL counts post-followup.
     4. Cumulative always-loaded delta from v3.0 → v3.2 (likely small; the followup is mostly body-budget compliance, not always-loaded reduction).

2. **Update essay #8** (`skill-system-vs-superpowers.md`):
   - Append `## Followup note (v3.1-v3.2)` section. Brief: "Phase-8 follow-ups closed in `skills-trim-followups` plan (v3.1-v3.2). Gap 8 (token budget) now CLOSED — all over-budget skills brought into compliance. Empirical RED dispatches captured for 8 discipline+ritual skills (closing the hypothetical-RED carry-forward from v3.0)."

3. **Update this plan's MasterPlan.md frontmatter:** `status: completed`.

4. **Stow simulate clean** (essays don't move; symlinks already exist).

5. **Commit** (closeout commit). Use:
   ```
   docs(claude): mark skills-trim-followups plan complete

   Closes 8 carry-forward items from skills-trim-and-discipline (v3.0):
   - Items 1-5 (prose-pruning) closed in commits NNNN-NNNN.
   - Item 6 (cold-session smoke) closed in commit NNNN (or noted skipped).
   - Item 7 (RED dispatches) closed in audit NNNN.
   - Item 8 (YAML quoting sweep) closed in commit NNNN (or noted no-op).

   Parent essays updated with "Followup outcome" sections. This plan
   marked status: completed.

   Refs: ~/dotfiles/.claude/plans/skills-trim-followups/MasterPlan.md

   Plan: skills-trim-followups
   Task: 11
   ```

6. **Open closeout PR** via `gh pr create --base main --head claude/skills-trim-followups`. Title:
   `feat(claude): skills-trim-followups — closeout`

   Body sections:
   - Summary (3-5 sentences).
   - Per-followup-item closure ledger (matching the essay #9 update).
   - Updated lint result (post-followup OK/WARN/FAIL).
   - Phase ledger (Phase 1 yields, Phase 2 RED captures, Phase 3 cleanup).
   - Test plan (stow OK; activation regression sweep results; lint summary).
   - Notes for user — this PR closes the followup. Merge bumps v3.2 (MINOR).
   - Post-merge actions — `gh release create v3.2 --notes-from-tag` (after user runs).

7. **Do NOT merge the PR.**

8. **Do NOT push v3.2 yet.** Orchestrator places v3.2 on the closeout commit AFTER this task returns successfully, BEFORE user merges.

## Acceptance criteria

- Essay #9 has "Followup outcome (v3.1-v3.2)" section with per-item ledger.
- Essay #8 has "Followup note (v3.1-v3.2)" section.
- This plan's MasterPlan frontmatter `status: completed`.
- Closeout commit on `claude/skills-trim-followups`.
- Closeout PR opened against `main`; not merged.
- v3.2 tag NOT pushed by you.

## Commit / PR

See Steps 5-8 above.
