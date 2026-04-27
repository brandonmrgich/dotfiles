---
title: Essay system for design decisions
status: resolved
created: 2026-04-26
last-active: 2026-04-26
tags: [claude-config, essays, design, anchoring]
anchors:
  produced:
    - ~/.claude/skills/essay/
    - ~/.claude/essays/
  references:
    - anchoring-replaces-changelogs
---

# Essay system for design decisions

## What was being decided

How to preserve the reasoning behind design decisions across sessions — chat history
is ephemeral, and the "why" gets lost between conversations.

## The gap essays fill

| Artifact | What it captures |
|----------|-----------------|
| Chat history | Everything, but ephemeral |
| Docs | Current state of the system |
| Plans | How to execute a change |
| **Essays** | **Why decisions were made** |

Essays sit between ephemeral chat and durable docs.

## Storage routing

- **User-wide** (`~/.claude/essays/`): cross-project reasoning, Claude config design,
  general architecture principles
- **Project-local** (`<repo>/.claude/essays/`): decisions anchored to specific repo
  artifacts (plans, docs, code)

Rule: project-local if any anchor points at a specific repo artifact.

## Status taxonomy

| Status | Meaning |
|--------|---------|
| `open` | Active thinking, decisions still being made |
| `resolved` | Decisions made, artifacts produced |
| `superseded` | Newer essay replaces this; carries `superseded-by:` |
| `archived` | Old, preserved but no longer relevant |

`resolved` is NOT immutable — can be reopened or superseded.

## Implicit triggering rules

Claude proactively offers an essay only when ALL hold:
1. Conversation reached at least one decision (not just Q&A)
2. Decision has rationale that wasn't obvious upfront
3. Decision is likely to produce or affect artifacts
4. No essay on this topic already exists (or this meaningfully extends it)

If user declines, do NOT re-prompt.

## Snapshot vs living modes

- **Snapshot**: capture and freeze. Further conversation doesn't auto-update.
- **Living**: "open the X essay" loads it as context; "update the essay" writes changes.

After a snapshot, new decisions trigger a prompt — not an auto-update.

## Integration with anchoring

Essays produce artifacts; artifacts cite essays via `from-essay:` front-matter.
This creates a bidirectional trace: doc → essay → reasoning.

Cross-essay references use `anchors.references` (one-way; older essay not updated).

## The "compressed log" principle

A 90-minute conversation with three decisions → ~150 lines, not 9000.
Capture: question, options (terse), decision, rationale, anchors.
Skip: verbatim chat, side discussions, rejected brainstorming (unless rejection is the lesson).
