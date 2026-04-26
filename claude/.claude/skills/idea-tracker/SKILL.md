---
name: "[HomebrewSkill] idea-tracker"
description: "Capture and manage ideas — pre-plan stash for things to build that don't yet have concrete scope. Triggers when user says \"save as idea\", \"track this idea\", \"let's remember this for later\", \"we should eventually X\", or asks \"what ideas do I have\". Activates when conversation surfaces a future direction worth preserving but not actioning now. Replaces the legacy TODO system."
triggers:
  - "save as idea"
  - "track this idea"
  - "remember this for later"
  - "park this for now"
  - "we should eventually"
  - "what ideas do I have"
  - "list my ideas"
  - "shelve this idea"
  - "promote this idea"
---

# idea-tracker

Captures and manages ideas — future directions the user wants to build that don't yet have concrete plans. Lives at `~/.claude/ideas/`, tracked in dotfiles, stowed.

## What's an idea?

A pre-plan stash. Something the user wants to do *eventually* without committing to scope or timeline.

Distinct from:

- **Memory** (facts about the user/project) → use auto-memory instead
- **Tasks** (things to do now) → handle inline, don't store
- **Plans** (scoped work with task files) → live in `<project>/.claude/plans/<plan-name>/`

If an idea matures, promote it to a plan. The idea file is then archived (not deleted) — kept as a reference.

## When to capture

**Capture without asking** when the user explicitly says:

- "save as idea"
- "track this idea"
- "remember this for later"
- "park this for now"

**Suggest capture (ask first)** when the conversation surfaces:

- "we should eventually..."
- "later, we'll need to..."
- Out-of-scope items being cut from a plan
- A pain point the user mentions but isn't ready to fix
- An external link/article + user expresses curiosity about applying it
- Claude proposes an improvement that's outside current scope

**Don't capture** when:

- The item is concrete enough to be a plan (offer to make it one instead)
- It's a memory candidate (user preference, project fact)
- It's a task the user wants done right now

## File format

`~/.claude/ideas/<slug>.md`:

```markdown
---
title: <human-readable title>
created: <YYYY-MM-DD>
status: open | shelved | archived
tags: [optional, list, of, tags]
project: <optional path or repo name>
---

# Idea: <title>

## Motivation
Why this is worth doing.

## Sketch
Rough shape — no commitment to scope.

## Open questions
What needs to be figured out before this could become a plan.

## Promotion criteria
What conditions would trigger this becoming a real plan.
```

Slugs are descriptive — lowercased, hyphen-separated, no numbers (e.g., `github-projects-integration.md`). Numbers were a TODO-system artifact; ideas use semantic names so a list is self-documenting.

## Status lifecycle

- `open` — active, captured, no action yet
- `shelved` — explicitly parked, not pursuing for now (kept for reference)
- `archived` — promoted to a plan or no longer relevant; reference any plan path in body

Idea files are **never deleted** — even archived ones stay for reference and history.

## Workflows

### Capture an idea

1. Confirm with user (skip if explicit save trigger): "Capture as an idea? Title: `<suggested>`"
2. Generate slug from title
3. Check `~/.claude/ideas/` for related existing ideas — if found, offer to update instead of duplicate
4. Write file with frontmatter + sections (some may be empty — fine)
5. Confirm: "Captured: `~/.claude/ideas/<slug>.md`"

The parent directory is symlinked via stow, so writing to `~/dotfiles/claude/.claude/ideas/<slug>.md` makes it appear at `~/.claude/ideas/<slug>.md` automatically. No re-stow needed.

### List ideas

When user asks "what ideas do I have", "list ideas", or similar:

- Read all files in `~/.claude/ideas/`
- Return as a table: `Title | Status | Created | Tags | Project`
- Group by status: `open` first, `shelved` second, `archived` hidden by default (mention count)

### Promote an idea to a plan

When user says "let's plan idea X", "promote this", or similar:

1. Confirm which idea
2. Hand off to `plan-executor` for plan generation (Mode B), passing the idea's content as the goal
3. After plan generation, update idea status to `archived` and append a `## Promoted to plan` line with the plan path

### Shelve an idea

User says "shelve idea X" or similar:

- Update status to `shelved`
- Optionally append a "shelved because" note in the body

### Update an existing idea

User refines an idea or adds context:

- Find the matching file (semantic match on title, slug, or topic)
- Append rather than overwrite when adding new context
- Bump `created` date only on creation; track updates inline if needed

## What you must never do

- Capture a memory in this skill (use auto-memory)
- Capture concrete in-flight tasks (those happen inline or as plans)
- Delete idea files automatically — even archived ones stay for reference
- Capture without confirmation unless an explicit save trigger phrase was used
- Use numeric filenames — slugs only
