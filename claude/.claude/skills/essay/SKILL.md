---
name: "[HomebrewSkill] essay"
description: "Captures and maintains essay-format records of design discussions, decisions, and reasoning. Activates on phrases like 'essay this', 'capture as an essay', 'save as an essay', 'open the X essay', 'continue the X essay', 'update the X essay', 'find essays about Y', 'what essays touch Z', 'resolve the X essay', 'supersede X with Y', 'list my essays'. Also activates implicitly — but only proactively offers — when a conversation has clearly produced a non-trivial decision with rationale that wasn't obvious upfront, AND that decision is likely to produce or affect artifacts (plans, docs, code), AND no essay on the topic already exists. Knows two storage locations: user-wide ~/.claude/essays/ and project-local <repo>/.claude/essays/. Picks based on whether the essay's anchors point at a specific repo. Knows essays are compressed logs of decisions — not verbatim transcripts. Knows the status taxonomy: open, resolved, superseded, archived. Integrates with the anchoring system: essays produce artifacts (plans, docs); artifacts cite essays via from-essay: front-matter."
---

# Essay Skill

Captures the reasoning behind design decisions in a durable form. Essays sit between
chat history (ephemeral) and docs (describe current state) — they record *why* things
are the way they are.

---

## What an essay is

A compressed log of decisions and rationale. Essays preserve the *train of thought*,
not verbatim conversation.

A good essay entry captures:
- **What was being decided** (one sentence)
- **Options considered** (terse — 1 line each, with key tradeoff)
- **Decision** (one sentence)
- **Rationale** (1–3 sentences — the *why*)
- **Anchors** (artifacts produced or affected)

A good essay entry does NOT capture:
- Verbatim conversation
- Side discussions that didn't lead to decisions
- Rejected brainstorming (unless rejection itself is the lesson)
- Implementation detail (that lives in plans/docs)

---

## Storage

- **User-wide:** `~/.claude/essays/<slug>.md` (default)
- **Project-local:** `<repo>/.claude/essays/<slug>.md` (rare exception)

**Default is user-wide.** Essays capture reasoning — reasoning is portable. The essay
lives in `~/.claude/essays/` regardless of which project prompted the thinking.

The plan or doc produced by an essay is what attaches to the project. When an essay
produces a plan, the plan goes in `<repo>/.claude/plans/<plan-name>/` and its
MasterPlan.md carries `from-essay: <essay-slug>` in its front-matter. This is how the
essay-to-project connection is made — through the artifact, not the essay's location.

**Exception — project-local essays:** only when the essay describes reasoning that is
genuinely specific to one repo's internals and would be meaningless outside it (e.g.,
a migration decision tied to a specific schema). When in doubt, default user-wide and ask.

The slug is kebab-case derived from the essay title.

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
  produced:
    - <path to plan, doc, or code area>
  references:
    - <other essay slug>
  superseded-by: <essay slug>  # only when status is superseded
---
```

---

## Operating modes

### Snapshot mode

Triggers: "essay this", "capture as an essay", "save this conversation as an essay"

1. Identify the decisions made in the conversation (filter for actual decisions, not info exchange)
2. Determine routing: user-wide or project-local based on anchors
3. Propose a slug and front-matter
4. Draft the essay body in compressed-log format
5. Show the draft to the user
6. After approval, write the file

The essay is "frozen" after snapshot. Further conversation does not auto-update it.

### Living mode

Triggers: "open the X essay", "continue the X essay"

1. Locate and read the essay (search `~/.claude/essays/` first, then project-local)
2. Treat it as conversation context
3. The user explicitly says "update the essay" to write changes
4. If after snapshot the conversation produces NEW decisions, prompt:
   "This conversation produced new decisions since the essay was snapshotted. Want me to update it?"

### Update mode

Triggers: "update the X essay"

1. Read existing essay
2. Identify NEW decisions or refinements since last update
3. Append a new dated section (don't rewrite history)
4. Update `last-active`
5. Update `anchors.produced` if new artifacts were created
6. Show diff, confirm, write

### Resolve mode

Triggers: "resolve the X essay"

1. Read essay
2. Confirm all `anchors.produced` exist (the artifacts were actually created)
3. Set `status: resolved`
4. Optionally add a "Resolution" section summarizing final outcomes
5. Write

Resolved is NOT immutable — can be reopened or superseded.

### Supersede mode

Triggers: "supersede X with Y"

1. If Y doesn't exist, create it via snapshot mode first
2. Update X's front-matter: `status: superseded`, `superseded-by: <Y-slug>`
3. Add a one-line note at the top of X: "Superseded by [Y title] (<date>)"

### Query mode

Triggers: "find essays about Y", "what essays touch Z", "list my essays"

1. Search across `~/.claude/essays/` and any project-local `<repo>/.claude/essays/` in scope
2. Match by tags, content, or anchors
3. Return as a table: `| Title | Status | Last active | Anchors | Tags |`

### Archive mode

Triggers: explicit "archive the X essay" OR "show me old essays" with periodic cleanup

1. List essays older than 6 months (by `last-active`)
2. For each, ask if it should be archived
3. On confirmation: move to `archive/`, update `status: archived`

---

## Implicit triggering

When a conversation might warrant an essay, ALL of these must be true to proactively offer:

1. The conversation reached at least one decision (not just Q&A)
2. The decision has rationale that wasn't obvious upfront
3. The decision is likely to produce or affect artifacts
4. No essay on this topic already exists (or the existing one is meaningfully extended)

When all four hold, at the end of your normal response, add:

```
---
**Essay capture suggestion:** This conversation produced a decision about [topic] with
non-obvious rationale. Want me to capture this as an essay? It would be [user-wide /
project-local] and anchor to [artifacts]. Estimated content: [brief summary].
```

If user declines or ignores, do NOT re-prompt.

DO NOT offer an essay when:
- Conversation was Q&A only
- Decision was trivial / obvious
- Conversation was task execution (running migrations, debugging)
- Already essayed and not meaningfully extended

---

## Integration with anchoring

**Essay → plan → project** is the canonical flow:

1. Reasoning lives in the essay (user-wide, portable)
2. When the essay produces a plan, the plan goes in `<repo>/.claude/plans/<plan-name>/`
3. The plan's MasterPlan.md carries `from-essay: <essay-slug>` in front-matter
4. The essay's `anchors.produced` lists the plan path
5. This is how essays attach to projects — through the plan artifact, not the essay's location

When an essay produces a doc directly (rare):
1. The doc gets `from-essay: <essay-slug>` in its front-matter
2. The essay's `anchors.produced` lists the doc path

When essays reference each other:
1. The newer essay's `anchors.references` lists the older essay slug
2. The older essay does NOT need updating (one-way to avoid cascades)

### The `ready-for-plan` tag

When an essay's design decisions have settled but no plan or code yet exists, add `ready-for-plan` to its front-matter `tags`. This marks the essay as a planning candidate without bending the status taxonomy — `resolved` requires artifacts produced, and the plan is not yet produced, so the essay's `status` stays `open` while the tag carries the readiness signal.

Discovery: query mode matches the tag. `find essays tagged ready-for-plan` (or any phrasing about the planning queue, planning candidates, queued essays, essays awaiting a plan) surfaces every tagged essay across `~/.claude/essays/` and any in-scope project-local essay tree.

When a plan is actually created from the essay:
1. Remove `ready-for-plan` from `tags`.
2. Add the plan path to the essay's `anchors.produced`.
3. Consider whether `status` should advance to `resolved`.

Plan creation from a tagged essay is always a deliberate, separate invocation — never auto-create plans from tagged essays.

---

## Writing principles

- **Compress.** A 90-minute conversation with three decisions is ~150 lines, not 9000.
- **Train of thought matters.** Capture *why options were rejected*, not just what was chosen.
- **Anchors first.** Draft the anchors before drafting the body. This grounds the essay.
- **Reasoning > narration.** "We chose X because Y, accepting tradeoff Z" beats narrative.

---

## What you must never do

- Auto-write essays without user confirmation
- Capture verbatim chat as essay content
- Update an essay without showing the diff
- Re-prompt after a user has declined an essay capture
- Create both a user-wide and project-local essay for the same topic
- Modify an essay's `created` date
