---
title: Skill / reference loading model
description: How Claude Code loads SKILL.md descriptions, bodies, and reference files at runtime. Documents the cost asymmetry that makes the references/ pattern work.
static: true
---

# Skill / reference loading model

Empirical notes on how Claude Code loads skill content at runtime,
captured during the `skills-trim-and-discipline` plan execution. This
file documents the cost asymmetry that makes the `references/` pattern
load-bearing.

## Three load tiers

### Tier 1 — Always loaded (every session, every turn)

- `~/.claude/CLAUDE.md` — global config.
- `<project>/CLAUDE.md` — project-local config.
- **Every SKILL.md description** — the YAML frontmatter `description:`
  field of every installed skill (user-level + project-level + plugin).
  Bodies are NOT loaded at this tier; only descriptions.
- Memory files (`~/.claude/memory/MEMORY.md` index + auto-loaded
  per-memory descriptions).
- Slash command descriptions (the `description:` field of each
  `~/.claude/commands/<name>.md`).

This is the **always-loaded baseline.** Token cost is paid on every
session start regardless of what the user does.

### Tier 2 — Loaded on skill activation

When a skill activates (via description-trigger match, slash command,
or explicit invocation), its **body** is loaded. The body is everything
after the YAML frontmatter.

This is per-activation cost. Skills that don't activate in a session
pay zero body cost.

### Tier 3 — Loaded on Read-tool demand

Reference files (`~/.claude/references/*.md`), example files
(`skills/<name>/examples/*`, `skills/<name>/patterns/*`), fixtures
(`skills/<name>/fixtures/*`), and any other sibling file cited by a
SKILL.md body are NOT auto-loaded.

They load only when an agent invokes the Read tool against them. The
agent does this when the SKILL.md body's pointer ("see
`~/.claude/references/X.md`") is followed because the work demands it.

**This is the load-deferral that makes the references/ pattern work.**
A 15kB reference cited from a heavy skill costs zero tokens at
activation; it costs only when the skill's user actually needs the
reference content.

## Cost asymmetry

| Tier | Loaded when | Cost |
|---|---|---|
| 1 | Every session | Paid even if user does nothing |
| 2 | On skill activation | Paid per session per skill activated |
| 3 | On Read-tool demand | Paid only when reference is consulted |

The asymmetry is what justifies aggressive Tier-2 → Tier-3 migration:
moving a 5kB block from a frequently-activated skill body into a
sibling reference is a **per-activation** savings, while the reference
itself only loads in the much rarer case it's needed.

## Dedup question (essay #9 §P3.2)

Empirical answer: **no dedup is needed.** Multiple skills citing the
same reference don't trigger redundant auto-loads, because no auto-load
happens at all. The reference loads only when an agent Read-tools it —
once, in the request where it's needed. A second skill citing the same
reference doesn't cause a second load unless that skill's own work
also needs the reference content; in which case the cost is real, not
redundant.

## Verification (this session)

During plan execution, multiple skills cited
`~/.claude/references/plan-system.md` (plan-executor, plan-auditor,
github, gitignore). The reference was loaded by the orchestrator agent
exactly once per session-turn that needed it — verified by tracking
which Read tool calls fetched the file. No double-load was observed.

The same pattern held for `console-discipline.md`,
`description-format.md`, and the new Phase 1–4 references. Each loaded
only when explicitly Read by the agent doing the work.

## Implications for skill authoring

1. **Tier 1 is precious.** Every byte of description text costs every
   session. Trim aggressively; preserve only triggers.
2. **Tier 2 is per-activation.** Body weight matters but only when
   the skill activates. Move what's not needed at activation time
   to Tier 3.
3. **Tier 3 is essentially free at the activation layer.** A 10kB
   reference is fine if it's only consulted on demand.
4. **Cross-references between skills are prose, not auto-loads.**
   "See `~/.claude/references/X.md`" or "see `skills/Y/SKILL.md`" is
   text the agent reads in the body; it doesn't trigger
   auto-fetch of the cited file. The agent decides whether to follow
   the pointer.

## Mantras (essay #9 §P3.3 dedup question)

Same model applies to mantras (`~/.claude/mantras/*.md`):

- The **abbreviated form** lives inline in `~/.claude/CLAUDE.md`'s
  "Design doctrines" section (~1.7 kB). This is **Tier 1** —
  always-loaded.
- The **full mantra files** (`~/.claude/mantras/<title>.md`, ~5–6 kB
  each) are **Tier 3** — only loaded when explicitly Read.

Audit (this session, post-Phase-7): grep across
`~/.claude/{skills,references,essays,agents}/` for mantra full-path
citations. **No full-path citations found.** `systematic-debugging`
SKILL.md cites "make state honest" by *name* (concept reference, not
path); `references/artifact-classes.md` mentions the mantras directory
in its class table but does not full-path-cite a specific mantra file.

**No double-load risk; no repointing needed.** The mantras directory
is a reference repository for the rare case where the full content is
needed (rationale, history, full failure-mode list); for everyday
discipline, the abbreviated CLAUDE.md form suffices.

## Cross-references

- `~/.claude/skills/doc-freshness/SKILL.md` — uses `static: true` to
  flag references that skip staleness checks (because they don't
  cover code paths that change).
- `~/.claude/essays/skill-system-token-efficiency-audit.md` §P3.2 +
  §P3.3 — the original questions this note answers.
- `~/.claude/references/description-format.md` — the rules for
  Tier-1 description authoring.
