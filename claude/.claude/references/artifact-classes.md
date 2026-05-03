---
title: Artifact classes and front-matter
description: Full six-class table, anchor-chain diagram, three-purposes breakdown, and per-class schema rationale. Referenced from ~/.claude/CLAUDE.md.
static: true
---

# Artifact classes and front-matter

Six artifact classes share the same YAML front-matter mechanism but answer different questions and live in different locations. Don't conflate them.

> **Rationale for this taxonomy lives in `~/.claude/essays/cross-claude-mantras-and-skills-integration.md`.** Read before proposing structural changes — that essay records why six classes (not five), why mantras separated from essays, and why the anchor chain is shaped the way it is.

| Class | Lives at | Front-matter | Purpose |
|---|---|---|---|
| **Memory** | `~/.claude/memory/` | `name`, `description`, `type`, `originSessionId` | Operational rules to recall during work (auto-memory retrieval by `description:` match) |
| **Mantra** (doctrine) | `~/.claude/mantras/` | `title`, `status`, `adopted`, `origin` | Universal principles internalized via CLAUDE.md reference; never retrieved, always embodied |
| **Idea** | `~/.claude/ideas/` | `title`, `created`, `status`, `tags`, `project?` | Pre-plan stash for future directions; managed by `idea-tracker` skill; matures into an essay or plan |
| **Essay** | `~/.claude/essays/` or `<repo>/.claude/essays/` | `title`, `status`, `created`, `last-active`, `tags`, `anchors` | Decision artifacts with lifecycle (open → resolved → superseded) and forward/back anchors |
| **Plan** | `<repo>/.claude/plans/<name>/MasterPlan.md` | `plan`, `status`, `from-essay`, `affects-docs`, `created` | Execution unit; back-references its essay, declares forward what docs it will touch |
| **Doc** | `<repo>/docs/...` | `title`, `covers`, `last-verified`, `from-plan` | Current-state code description; tracked for staleness via `covers:` + `last-verified:` |

Plus commit footers (`Plan:`, `Task:`) — provenance metadata in commits, not front-matter. See `~/.claude/skills/github/SKILL.md` for syntax.

## The anchor chain

```
idea → essay → plan → doc → code
     (matures) (spawns) (guides) (documents)
              ↑
          mantra (informs)
```

Linear, one-way, acyclic. Children point to parents (via `from-essay:`, `from-plan:`); parents declare children forward only when needed for verification (via `anchors.produced` on essays, `affects-docs:` on plans). Ideas precede essays — most ideas mature into either an essay (when they need design discussion) or directly into a plan (when scope is already clear); the originating idea is archived with a pointer to the plan/essay it became. Memories sit aside — operational rules, not part of the design history chain.

## Three front-matter *purposes* across these classes

| Purpose | Fields | Question answered |
|---|---|---|
| **Retrieval / lifecycle** | `description`, `tags`, `status`, `last-active` | How is this artifact found and what state is it in? |
| **Provenance** | `from-essay`, `from-plan`, `affects-docs`, `anchors`, commit footers | Where did this come from / what did it produce? |
| **Staleness** | `covers`, `last-verified` | Is this doc still true about the code? |

Apply *make state honest*: don't add fields an artifact doesn't need. A mantra doesn't have `anchors`, an essay doesn't have `covers:`, a plan doesn't have `last-verified:`. The schema for each class is exactly what that class needs — no more.

See `~/.claude/references/plan-system.md` for the canonical filesystem layout and gitignore rules.
