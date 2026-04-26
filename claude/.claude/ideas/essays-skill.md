Prompt B — Essay Skill Creation
Run this after Prompt A is fully committed in both repos. Paste into a fresh Claude Code session opened inside ~/dotfiles.
Create an `essay` skill (user-wide) and seed the essays directory in
both ~/.claude/ and the music-platform-monorepo. Then capture the
recent anchoring + essays conversation as the seed essay.

This builds on the anchoring system created in the previous prompt.
Two repos: ~/dotfiles (skill) and music-platform-monorepo (project
essays directory). Two commits.

## Context — read first

1. Verify the previous anchoring migration is complete:
   - Check that ~/dotfiles/claude/.claude/skills/doc-freshness/SKILL.md
     exists
   - Check that the most recent commit in ~/dotfiles touches the
     plan-executor skills
   - Check that ~/Development/music-platform-monorepo/.claude/changelogs/
     does NOT exist (deleted by previous migration)
   - Check that some doc under
     ~/Development/music-platform-monorepo/docs/ has front-matter
     with `last-verified`

2. If any verification fails, stop and report. Do NOT proceed without
   the previous migration in place.

3. Read the recent conversation context describing what an essay
   should be. The user has provided this directly in the prompt;
   incorporate the principles below verbatim.

## Decisions already made

- **Skill name:** `essay` (singular)
- **Storage:** `~/.claude/essays/<slug>.md` (user-wide) and
  `<repo>/.claude/essays/<slug>.md` (project-local). Tracked in git.
- **Routing rule:** if essay anchors point at any artifact in a
  specific repo, project-local. Otherwise user-wide.
- **Essays are compressed logs of decisions** — train of thought, not
  verbatim transcript. Capture: question, options considered (terse),
  decision, rationale, anchors. Skip: verbatim chat, side discussions,
  rejected brainstorming.
- **Implicit triggering rules:** Claude only proactively offers an
  essay when ALL of these hold:
  1. Conversation reached at least one decision (not just info exchange)
  2. Decision has rationale that wasn't obvious upfront
  3. Decision is likely to produce or affect artifacts
  4. No essay on this topic exists, or the existing one is meaningfully
     extended by this conversation
- **Snapshot vs living mode:** both supported, with explicit triggers.
  After a snapshot, if conversation continues and produces NEW decisions,
  Claude prompts the user about updating the essay (does NOT auto-update).
- **Status taxonomy:**
  - `open` — active thinking, decisions still being made
  - `resolved` — decisions made, artifacts produced, no further changes
    expected. NOT immutable; can be reopened or superseded.
  - `superseded` — newer essay replaces this; carries `superseded-by:`
  - `archived` — old essay, preserved but no longer relevant
- **Cleanup:** periodic — when user asks, surface essays older than
  6 months and offer to archive. Not automatic.
- **Anchoring integration:** essays produce artifacts; artifacts cite
  essays via `from-essay:` front-matter. Cross-essay `references:`
  builds an idea graph.

## Phase 1 — Create the essay skill in ~/dotfiles

Create:
~/dotfiles/claude/.claude/skills/essay/SKILL.md

````markdown
---
name: essay
description: Captures and maintains essay-format records of design discussions, decisions, and reasoning. Activates on phrases like "essay this", "capture as an essay", "save as an essay", "open the X essay", "continue the X essay", "update the X essay", "find essays about Y", "what essays touch Z", "resolve the X essay", "supersede X with Y", "list my essays". Also activates implicitly — but only proactively offers — when a conversation has clearly produced a non-trivial decision with rationale that wasn't obvious upfront, AND that decision is likely to produce or affect artifacts (plans, docs, code), AND no essay on the topic already exists. Knows two storage locations: user-wide ~/.claude/essays/ and project-local <repo>/.claude/essays/. Picks based on whether the essay's anchors point at a specific repo. Knows essays are compressed logs of decisions — not verbatim transcripts. Knows the status taxonomy: open, resolved, superseded, archived. Integrates with the anchoring system: essays produce artifacts (plans, docs); artifacts cite essays via from-essay: front-matter.
---

# Essay Skill

Captures the reasoning behind design decisions in a durable form.
Essays sit between chat history (ephemeral) and docs (describe current
state) — they record *why* things are the way they are.

## What an essay is

A compressed log of decisions and rationale. Essays preserve the
*train of thought*, not verbatim conversation.

A good essay entry captures:
- **What was being decided** (one sentence)
- **Options considered** (terse — 1 line each, with key tradeoff)
- **Decision** (one sentence)
- **Rationale** (1-3 sentences — the *why*)
- **Anchors** (artifacts produced or affected)

A good essay entry does NOT capture:
- Verbatim conversation
- Side discussions that didn't lead to decisions
- Rejected brainstorming (unless rejection itself is the lesson)
- Implementation detail (that lives in plans/docs)

## Storage

- **User-wide:** `~/.claude/essays/<slug>.md`
- **Project-local:** `<repo>/.claude/essays/<slug>.md`

Routing rule: if the essay's anchors point at any artifact in a
specific repo (plans, docs, code), it's project-local. Otherwise it's
user-wide. When in doubt, ask the user.

The slug is kebab-case derived from the essay title.

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

## Operating modes

### Snapshot mode

Triggers: "essay this", "capture as an essay", "save this conversation
as an essay"

Action:
1. Identify the decisions made in the conversation (filter for
   actual decisions, not info exchange)
2. Determine routing: user-wide or project-local based on anchors
3. Propose a slug and front-matter
4. Draft the essay body in compressed-log format
5. Show the draft to the user
6. After approval, write the file

The essay is "frozen" after snapshot. Further conversation does not
auto-update it.

### Living mode

Triggers: "open the X essay", "continue the X essay"

Action:
1. Locate and read the essay (search ~/.claude/essays/ first, then
   project-local if in a repo)
2. Treat it as conversation context
3. As the conversation proceeds, work as normal
4. The user explicitly says "update the essay" to write changes
5. If after snapshot the conversation produces NEW decisions, prompt:
   "This conversation produced new decisions since the essay was
   snapshotted. Want me to update it?"

### Update mode

Triggers: "update the X essay"

Action:
1. Read existing essay
2. Identify NEW decisions or refinements since last update
3. Append a new dated section (don't rewrite history)
4. Update `last-active`
5. Update `anchors.produced` if new artifacts were created
6. Show diff, confirm, write

### Resolve mode

Triggers: "resolve the X essay"

Action:
1. Read essay
2. Confirm all anchors.produced exist (the artifacts were actually
   created)
3. Set `status: resolved`
4. Optionally add a "Resolution" section summarizing final outcomes
5. Write

Resolved is NOT immutable. The essay can be reopened or superseded
later.

### Supersede mode

Triggers: "supersede X with Y" (where X is old essay, Y is new one or
about to be created)

Action:
1. If Y doesn't exist, create it via snapshot mode first
2. Update X's front-matter: `status: superseded`,
   `superseded-by: <Y-slug>`
3. Add a one-line note at the top of X: "Superseded by [Y title]
   (<date>)"

### Query mode

Triggers: "find essays about Y", "what essays touch Z", "list my
essays"

Action:
1. Search across ~/.claude/essays/ and any project-local
   <repo>/.claude/essays/ in scope
2. Match by tags, content, or anchors
3. Return as a table:

| Title | Status | Last active | Anchors | Tags |

### Archive mode

Triggers: explicit "archive the X essay" OR "show me old essays" with
periodic cleanup

Action:
1. List essays older than 6 months (by last-active)
2. For each, ask if it should be archived
3. On confirmation: move to ~/.claude/essays/archive/ (or
   <repo>/.claude/essays/archive/), update status to archived

## Implicit triggering

When a conversation might warrant an essay, evaluate:

ALL of these must be true to proactively offer:

1. The conversation reached at least one decision (not just Q&A)
2. The decision has rationale that wasn't obvious upfront
3. The decision is likely to produce or affect artifacts
4. No essay on this topic already exists (or the existing one is
   meaningfully extended)

When all four hold, at the end of your normal response, add:

````
---
**Essay capture suggestion:** This conversation produced a decision
about [topic] with non-obvious rationale. Want me to capture this as
an essay? It would be [user-wide / project-local] and anchor to
[artifacts]. Estimated content: [brief summary].
````

If user declines or ignores, do NOT re-prompt. Wait for explicit ask.

DO NOT offer an essay when:
- Conversation was Q&A only
- Decision was trivial / obvious
- Conversation was task execution (running migrations, debugging)
- Already essayed and not meaningfully extended

## Integration with anchoring

When an essay produces a plan or doc:

1. The essay's `anchors.produced` is updated to include the new
   artifact's path
2. The artifact (plan or doc) gets `from-essay: <essay-path>` in its
   front-matter

This means: a future agent reading a doc can trace the doc to the
essay, and reading the essay can find the doc. Bidirectional.

When essays reference each other:

1. The newer essay's `anchors.references` lists the older essay slug
2. The older essay does NOT need updating (the reference is one-way
   to avoid update cascades)

## Writing principles

- **Compress.** A 90-minute conversation with three decisions is
  ~150 lines, not 9000.
- **Train of thought matters.** Capture *why options were rejected*,
  not just what was chosen.
- **Anchors first.** When proposing an essay, draft the anchors
  before drafting the body. This grounds the essay in concrete
  outputs.
- **Reasoning > narration.** "We chose X because Y, accepting tradeoff
  Z" beats "First we discussed X, then Y, then we decided X."

## What you must never do

- Auto-write essays without user confirmation
- Capture verbatim chat as essay content
- Update an essay without showing the diff
- Re-prompt after a user has declined an essay capture
- Create both a user-wide and project-local essay for the same topic
- Modify an essay's `created` date

## Example session

User: [discusses with Claude whether to use worktrees vs single-tree
       branches for concurrent agent work, decides on worktrees]

Claude (at end of normal response):
"---
**Essay capture suggestion:** This conversation produced a decision
about how to support concurrent Claude agents (worktrees vs branch
discipline). The reasoning explores three options and lands on
worktrees specifically because of the working-tree isolation problem.
Want me to capture this as an essay? User-wide, anchored to the
worktree-orchestrator skill we'll create next. Estimated content:
~80 lines."

User: "yes"

Claude:
[generates essay at ~/.claude/essays/concurrent-agents-via-worktrees.md
with front-matter, options table, decision, rationale, anchors]
"Draft below. Approve to write?

[full essay content]"
````

After creating the file, print the first 15 lines to verify
front-matter triggers.

## Phase 2 — Create essays directories

In ~/.claude/ (real directory, follow symlinks if needed):
````
mkdir -p ~/.claude/essays
mkdir -p ~/.claude/essays/archive
````

In ~/Development/music-platform-monorepo/.claude/:
````
mkdir -p ~/Development/music-platform-monorepo/.claude/essays
mkdir -p ~/Development/music-platform-monorepo/.claude/essays/archive
````

Add a small README.md in each project-local essays directory:

````markdown
# Project-local essays

Essays anchored to artifacts in this repo. See the `essay` skill for
details. Cross-project / general thinking lives in
~/.claude/essays/ instead.
````

(No README needed in the user-wide ~/.claude/essays/ — the skill
documents itself.)

## Phase 3 — Seed the first essay

The conversation that designed this anchoring + essays system is
itself essay-worthy. Capture it as the seed essay.

Determine routing: the essay touches BOTH user-wide concerns
(anchoring philosophy applies to any project) AND project-local
concerns (the music-platform migration). Split into two essays:

### Essay 1: ~/.claude/essays/anchoring-replaces-changelogs.md

Topic: Replacing changelogs with a front-matter-based anchoring
system. The general principle, not the specific migration.

Front-matter:
````yaml
---
title: Anchoring replaces changelogs
status: resolved
created: <today>
last-active: <today>
tags: [docs, anchoring, claude-config, design]
anchors:
  produced:
    - ~/.claude/skills/doc-freshness/
    - ~/.claude/skills/plan-executor/  # updated
    - ~/.claude/skills/plan-auditor/   # updated
    - ~/.claude/skills/plan-executor-documenter/  # updated
  references: []
---
````

Body covers:
- The problem changelogs were trying to solve (doc invalidation)
- Why changelogs are a poor fit (manual upkeep, duplicates git log)
- Three alternatives considered (date-segmented logs, domain-segmented
  logs, anchoring via front-matter)
- Why anchoring won (locality, precision, leverages git log)
- The schema decisions (covers, last-verified, static/speculative
  flags, last-updated-from derived not stored)
- Commit footer convention as the plan-attribution mechanism
- Migration approach: delete old changelogs, don't convert

Length target: ~120 lines.

### Essay 2: ~/Development/music-platform-monorepo/.claude/essays/essay-system.md

Topic: The essay system itself, including its integration with
anchoring.

Front-matter:
````yaml
---
title: Essay system for design decisions
status: resolved
created: <today>
last-active: <today>
tags: [claude-config, essays, design, anchoring]
anchors:
  produced:
    - ~/.claude/skills/essay/
    - ~/.claude/essays/
    - .claude/essays/
  references:
    - anchoring-replaces-changelogs
---
````

Body covers:
- The problem (chat history is ephemeral, design reasoning gets lost)
- What essays are vs docs vs plans vs chat
- Storage routing (user-wide vs project-local)
- The four statuses and what each means
- Implicit triggering rules (the four-condition test)
- Snapshot vs living modes
- Integration with anchoring (essays anchor to artifacts; artifacts
  cite essays)
- The "compressed log of decisions" principle

Length target: ~100 lines.

Wait — this essay is project-local but anchors to user-wide artifacts
(the essay skill itself). The routing rule says project-local if any
anchor points at a repo. Since the project-local essays directory was
created in this conversation, the essay belongs there. But the essay's
content is mostly user-wide. Surface this tension to the user and ask
where they want it. Default: project-local (matches the routing rule).

For both essays:
1. Draft the essay
2. Show full draft to user
3. After approval, write the file

## Phase 4 — Two commits

Commit to ~/dotfiles:

````
git -C ~/dotfiles add -A
git -C ~/dotfiles commit -m "feat(claude): add essay skill for design discussion capture

Essays sit between ephemeral chat and durable docs. They capture
the reasoning behind design decisions in compressed-log format.

- New essay skill: snapshot mode (capture conversation), living mode
  (continue across sessions), update mode, resolve mode, supersede
  mode, query mode, archive mode
- Storage: user-wide ~/.claude/essays/ for cross-project ideas,
  project-local <repo>/.claude/essays/ for project-specific design
- Status taxonomy: open, resolved, superseded, archived
- Implicit triggering only when conversation produced non-trivial
  decision with rationale and likely artifacts
- Integration with anchoring: essays produce artifacts; artifacts
  cite essays via from-essay: front-matter
- Created seed essay at ~/.claude/essays/anchoring-replaces-changelogs.md
  documenting the anchoring system design"
````

Commit to music-platform-monorepo:

````
cd ~/Development/music-platform-monorepo
git add -A
git commit -m "feat(.claude): add essays directory + essay-system seed

- New .claude/essays/ directory (tracked) for project-local design
  essays. Anchored to artifacts in this repo.
- Seed essay essay-system.md documenting the essay skill design and
  its integration with the anchoring system created in the previous
  migration."
````

## Phase 5 — Verify and report

Print:
- The new ~/.claude/skills/essay/ structure
- The first 15 lines of essay/SKILL.md
- The two seed essay file paths
- Both commit SHAs

Briefly describe how to use the system:
- "Essay this" mid-conversation
- "Open the X essay" to continue
- "Find essays about Y" to query
- The implicit offer pattern (Claude will surface essay-worthy moments)

## Stop conditions

Stop and ask if:
- The previous anchoring migration verification (Phase 1) fails
- A seed essay's routing is unclear (project-local vs user-wide
  ambiguous)
- A draft essay exceeds 200 lines — that's a sign of insufficient
  compression; surface and ask for trim
- Either commit fails
- The user disagrees with the proposed seed essay split into two
  essays
