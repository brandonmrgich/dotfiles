# Task 18 — Audit gate: descriptions + cold-session re-measurement

**Phase:** 3 (audit gate)
**Agent:** plan-auditor (skill)
**Produces PR:** No

## Goal

Verify the cumulative effect of Tasks 14–17: all 20 descriptions
spec-compliant; eagerly-loaded description bytes dropped by ~5–6k;
cold-session token cost dropped meaningfully. Pre-check per-class
budget compliance (Phase 8 will formalize the linter).

This is the second-most-important audit gate after Task 04 — it tests
the activation-recall hypothesis. If trimming descriptions caused any
regression in skill activation, this is where it surfaces.

## Steps

1. Re-measure all 20 description char counts. Record before/after.
2. Cumulative description-bytes delta: should be ~5,000–6,500 bytes
   below baseline (from Task 00).
3. Cold-session smoke test:
   - Open a fresh session at `~/dotfiles`.
   - Do nothing — observe initial context utilization.
   - Compare to the cold-session snapshot from Task 04 audit.
   - Cumulative delta from baseline should be ~12,000–17,000 bytes
     (CLAUDE.md trims + description trims combined).
4. Activation regression test — run each of these and confirm the
   expected skill activates:
   - "let me write an essay about X" → `essay`
   - "save this as an idea" → `idea-tracker`
   - "execute the plan at X" → `plan-executor`
   - "run a top-down sweep" → `top-down-sweep`
   - "is this doc stale?" → `doc-freshness`
   - "narrow focus to task X" → `zoom-in`
   - "I need to ssh into m1-macbook" → `environment-map`
   - "write me a Howler audio engine" → `web-audio-howler`
   - "configure turbo.json for this monorepo" → `turborepo-patterns`
   - "set up an Astro content collection" → `astro-static-sites`
   - "model this DDEX ERN message" → `ddex-standards`
   - "create a server action with revalidatePath" → `nextjs-app-router`
   - "split sheet for this collaboration" → `royalty-splits-music`
   - "audit this gitignore" → `gitignore`
5. Per-class budget pre-check (informational; Phase 8 enforces):
   - Description bytes per skill ≤1024.
   - SKILL.md body bytes per class:
     - Specialists: ≤6,500 (post Phase-2 trim).
     - Workflow: ≤8,500.
     - Capture: ≤8,500.
     - Policy/catalog: ≤7,000 (`github`, `gitignore`).
6. Write `audits/18-descriptions-and-cold-session-audit.md`:
   - Per-skill description before/after.
   - Cumulative description bytes saved.
   - Cumulative always-loaded bytes saved (CLAUDE.md + descriptions).
   - Cold-session smoke observations.
   - Activation regression results (table: skill → expected → actual).
   - Budget pre-check (any over-budget skills flagged).
   - Verdict + recommendation.

## Acceptance criteria

- [ ] All 20 descriptions ≤1024 chars.
- [ ] No skill failed an activation test.
- [ ] Cumulative always-loaded saved bytes within ±25% of essay #9
      projection (~14k bytes / 3,500 tokens combined for Phase 1+3).
- [ ] Audit report written.

## Failure handling

- One activation regression: triage. If the keyword was over-trimmed,
  fix in a quick patch task and re-test.
- Multiple regressions: halt. The description spec or rewrite may need
  recalibration.
- Projection miss >25%: investigate before proceeding to Phase 4 — the
  measurement model may be off.

## No commit
