---
name: "[HomebrewSkill] essay"
class: capture
description: "Activates when the user says \"essay this\", \"capture as an essay\", \"save as an essay\", \"open / continue / update the X essay\", \"find essays about Y\", \"what essays touch Z\", \"resolve the X essay\", \"supersede X with Y\", or \"list my essays\". Also activates implicitly when a conversation has produced a non-trivial decision with non-obvious rationale that will affect artifacts (plans, docs, code) and no essay on the topic exists yet — the skill offers capture rather than acting."
---

# Essay Skill

Captures *why* behind design decisions — between chat (ephemeral) and docs (current state). A compressed log of *train of thought*, not verbatim chat.

**Capture:** decision (1 sentence), options considered (1 line + tradeoff each), rationale (1–3 sentences), anchors (artifacts produced/affected).

**Don't capture:** verbatim chat, side discussions, rejected brainstorming (unless rejection is the lesson), implementation detail (lives in plans/docs).

---

## Storage

- **User-wide (default):** `~/.claude/essays/<slug>.md` — reasoning is portable.
- **Project-local (rare):** `<repo>/.claude/essays/<slug>.md` — only when reasoning is meaningless outside the repo.

Slug: kebab-case from title. Project linkage flows through the produced artifact (see Anchoring), not location.

---

## Front-matter schema

```yaml
---
title: <essay title>
status: open | resolved | superseded | archived
created: <ISO date>
last-active: <ISO date>
tags: [tag1, tag2]
anchors:
  produced: [<path to plan/doc/code>]
  references: [<other essay slug>]
  superseded-by: <essay slug>  # only when status: superseded
---
```

---

## Operating modes

| Mode | Trigger | Action |
|---|---|---|
| Snapshot | "essay this", "capture as an essay" | Identify decisions; route user-wide/project-local; propose slug + front-matter; draft; show; on approval, write. Frozen after. |
| Living | "open / continue the X essay" | Locate; treat as context. Write only on explicit "update". If new decisions emerge, prompt. |
| Update | "update the X essay" | Identify NEW decisions; append dated section (don't rewrite); bump `last-active`; update `anchors.produced` if needed; show diff; write. |
| Resolve | "resolve the X essay" | Confirm `anchors.produced` exist. **Anchor-chain nudge:** if missing/`[]`, soft-warn (don't block): *"Resolving without `anchors.produced`. Informational, or should a plan/doc be linked?"* Set `status: resolved`. Not immutable. |
| Supersede | "supersede X with Y" | Snapshot Y first if absent. Set X `status: superseded`, `superseded-by: <Y-slug>`; prepend "Superseded by [Y] (<date>)". |
| Query | "find essays about Y", "list my essays" | Search `~/.claude/essays/` + in-scope `<repo>/.claude/essays/`. Match tags/content/anchors. Return `\| Title \| Status \| Last active \| Anchors \| Tags \|`. |
| Archive | "archive the X essay" | List essays older than 6 months by `last-active`; ask per essay; on confirm move to `archive/`, set `status: archived`. |

---

## Implicit triggering

Proactively offer ONLY when ALL hold: (1) decision reached (not Q&A), (2) rationale wasn't obvious, (3) decision will produce/affect artifacts, (4) no existing essay covers it.

Append: "Decision about [topic] with non-obvious rationale. Capture as essay? [user-wide / project-local], anchors: [artifacts]."

If declined or ignored, do NOT re-prompt. Don't offer for Q&A, trivial decisions, task execution, or already-essayed topics.

---

## Anchoring

Canonical chain: **essay → plan → project**. Plan goes in `<repo>/.claude/plans/<plan-name>/`; its MasterPlan carries `from-essay: <slug>`; essay's `anchors.produced` lists the plan. Doc-direct (rare): doc gets `from-essay:`; essay's `anchors.produced` lists the doc.

Cross-essay: newer's `anchors.references` lists older slug. Older does NOT update (one-way, no cascades).

### `ready-for-plan` tag

When design has settled but no plan/code exists, add `ready-for-plan` to `tags`. Marks a planning candidate without bending the taxonomy: `resolved` requires artifacts produced, so without a plan, `status` stays `open` and the tag carries readiness.

Query mode matches "essays tagged ready-for-plan" (and phrasings about planning queue / candidates / awaiting a plan).

On plan creation: remove the tag, add the plan to `anchors.produced`, consider advancing `status` to `resolved`. Always deliberate — never auto-create.

---

## Writing principles

- **Compress.** 90 minutes, 3 decisions = ~150 lines, not 9000.
- **Capture *why options were rejected***, not just the choice.
- **Anchors first.** Draft anchors before body.
- "Chose X because Y, accepting Z" beats narrative.

---

## What you must never do

- Auto-write without confirmation
- Capture verbatim chat
- Update without showing the diff
- Re-prompt after a decline
- Create both user-wide and project-local for the same topic
- Modify `created`
