---
title: Anchoring replaces changelogs
status: resolved
created: 2026-04-26
last-active: 2026-04-26
tags: [docs, anchoring, claude-config, design]
anchors:
  produced:
    - ~/.claude/skills/doc-freshness/
    - ~/.claude/skills/plan-executor/
    - ~/.claude/skills/plan-auditor/
    - ~/.claude/skills/plan-executor-documenter/
    - ~/.claude/references/plan-system.md
  references: []
---

# Anchoring replaces changelogs

## What was being decided

How to keep documentation accurate as code evolves — specifically whether to
continue with changelog files or replace them with something better.

## Problem with changelogs

The system had `.claude/changelogs/<YYYY-MM>.md` files listing what changed and when.
The problem: changelogs duplicate git log, require manual maintenance, grow unboundedly,
and don't tell you *which doc* is now stale — only that something changed.

## Options considered

| Option | Tradeoff |
|--------|----------|
| Date-segmented logs (current) | Unbounded growth; doesn't answer "is doc X stale?" directly |
| Domain-segmented logs (per-doc changelogs) | More targeted but still manual; doesn't leverage git |
| Front-matter anchoring | Locality (staleness signal lives in the doc); git-leveraged; no manual log |

## Decision

Replace changelogs entirely with front-matter anchoring. Each doc declares `covers`
(which code paths it describes) and `last-verified` (when it was last confirmed accurate).
Staleness check = `git log --since=<last-verified> -- <covers>`.

## Rationale

Anchoring is local — the staleness signal is in the doc itself, not in a separate file.
It leverages git as the authoritative change record rather than duplicating it. Static
docs (external standards) and speculative docs (roadmap) opt out via `static: true` /
`speculative: true` flags. `last-updated-from` is derived on demand from `git log -1`,
never stored.

## Schema decisions

- `covers`: list of code paths/globs the doc describes
- `last-verified`: ISO date; set manually or bumped by the doc-freshness skill
- `static: true`: external-standard reference, no staleness check needed
- `speculative: true`: roadmap/aspirational content, no staleness check needed
- `from-essay`: path to the essay that produced/motivated this doc
- `from-plan`: plan name that substantially updated this doc

## Commit footer convention

Plan-executor commits include `Plan: <plan-name>` and `Task: <task-id>` footers.
This makes plan attribution greppable from `git log` without a changelog file.

## Migration approach

Delete old changelog files — don't convert them. `git log` carries the historical
signal. Reset `last-verified` to the migration date for all docs.

## Artifacts produced

- `doc-freshness` skill: implements staleness checks, verification bumping, history tracing
- Updated `plan-executor`, `plan-auditor`, `plan-executor-documenter` skills to use
  commit footers and affects-docs verification instead of changelog writes
- `plan-system.md` reference: canonical filesystem layout including gitignore rules
- `console-discipline.md` reference: output rules for skills
