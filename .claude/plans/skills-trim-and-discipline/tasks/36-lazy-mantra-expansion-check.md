# Task 36 — Lazy mantra expansion check

**Phase:** 8 (Ergonomics & enforcement)
**Agent:** plan-executor-discovery
**Produces PR:** Yes (or no, if findings are documentation-only)

## Goal

Verify mantras (`~/.claude/mantras/*.md`) are not double-loaded. The
CLAUDE.md "Design doctrines" section embeds abbreviated mantras
(~1.7k bytes); the full mantra files are 5.6k + 4.3k = 9.9k. The
abbreviated form is the right mainline. Verify nothing pulls the full
files implicitly.

## Context

Per essay #9 §"P3.3", confirm mantras aren't double-loaded. If any
skill references mantras by full path
(`~/.claude/mantras/<title>.md`), that's a potential double-load source.

## Files

**Possibly affected:**
- Any skill or reference that cites a mantra by full path → repoint to
  the CLAUDE.md inline section.

## Steps

1. Grep all SKILL.md and reference files for `mantras/`-rooted paths.
2. For each hit, evaluate: is the citation pointing at the full mantra
   file, or at the CLAUDE.md inline section?
3. If full-file citation exists: assess whether the citing context
   needs the full mantra (rare) or the abbreviated form (common). If
   abbreviated suffices, repoint to CLAUDE.md.
4. Document the loading model in a brief reference note (or add to
   `references/loading-model.md` from Task 35 if that landed).
5. Stow + verify.
6. Commit + PR (or report-only).

## Acceptance criteria

- [ ] Mantra-citation audit complete.
- [ ] Any over-pointing (full file when abbreviated suffices) repointed.
- [ ] Loading model documented.

## Validation

- Open a session where a mantra-citing skill activates; confirm the
  full mantra file is not auto-loaded unless explicitly Read.

## Commit / PR

- If repointing happened:
  ```
  refactor(claude): repoint mantra citations to CLAUDE.md inline form

  Where citations pointed at full mantra files, but the abbreviated
  CLAUDE.md form was sufficient, repointed to avoid double-loading.

  Refs: essay skill-system-token-efficiency-audit.md §P3.3

  Plan: skills-trim-and-discipline
  Task: 36
  ```
- PR target: `main`. Or report-only as Task 35.
