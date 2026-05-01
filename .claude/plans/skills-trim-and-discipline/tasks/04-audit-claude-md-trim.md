# Task 04 — Audit gate: CLAUDE.md trim

**Phase:** 1 (audit gate)
**Agent:** plan-auditor (skill, not sub-agent)
**Produces PR:** No (audit report only)

## Goal

Verify the cumulative effect of Tasks 01–03: CLAUDE.md should have dropped
by ~9,000 bytes (~2,250 tokens) from baseline. Cold-session smoke test
should observe lower context utilization at fresh-session start.

## Context

This is the highest-stakes audit gate of the plan. CLAUDE.md is loaded
on every session — the savings here apply to every interaction, not
just skill activations. A failed gate here means the trim didn't deliver,
and Phase 2 (which depends on the references/ pattern being established)
is in question.

## Steps

1. Re-measure: `wc -c ~/.claude/CLAUDE.md`.
   Compare to baseline from Task 00. Compute delta.
2. Re-measure all three new references:
   `wc -c ~/.claude/references/{sidecar-conventions,artifact-classes}.md`.
   Confirm content is in references, not lost.
3. Cumulative check: (CLAUDE.md baseline) − (CLAUDE.md now) should be
   in the range **8,000–10,000 bytes**.
   - <8,000: under-trimmed; investigate which task fell short.
   - >10,000: possible over-trim (content lost, not relocated). Diff against
     Task 00 baseline. Verify reference files contain the expected sections.
4. Smoke test — cold session:
   - Open a fresh Claude Code session at `~/dotfiles`.
   - Ask a generic question that should not trigger any skill (e.g.,
     "what time is it?" or "summarize the last commit").
   - Capture the visible context-usage indicator (statusline shows it).
   - Compare to a known pre-trim session if available; document the
     observation.
5. Cross-reference check: grep all SKILL.md and reference files for any
   citation of CLAUDE.md sections that no longer exist inline (e.g.,
   `## Sidecar conventions` as an anchor). If found, update the citation
   to point at the new reference.
6. Write the audit report to
   `audits/04-claude-md-trim-audit.md`:
   - Verdict: PASS / PARTIAL / FAIL
   - Measured savings (bytes, estimated tokens)
   - Per-file delta table
   - Cold-session smoke observation
   - Cross-reference repair list (if any)
   - Recommendation: proceed to Phase 2 / halt / fix-and-recheck.

## Acceptance criteria

- [ ] CLAUDE.md byte delta within target range.
- [ ] All three references created and stowed.
- [ ] No broken citations across `~/.claude/`.
- [ ] Audit report written with explicit verdict.

## Failure handling

- PARTIAL: report what fell short; user decides whether to add a fix-up
  task before Phase 2 or proceed and fold the gap into Phase 8.
- FAIL: halt the plan. Most likely root cause is a lost section
  (over-trimmed) or stub too verbose (under-trimmed). Diff against
  baseline to identify, propose fix.

## No commit

Audit reports are written under `.claude/plans/.../audits/`, which is
gitignored. The verdict is the gating signal; the report is documentation.
