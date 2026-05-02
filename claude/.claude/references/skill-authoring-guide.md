---
title: Skill authoring guide
description: Procedure for creating new Claude Code skills and agents. Step-by-step flow, scope-and-prefix conventions, description-format CSO rules, worked examples.
static: true
---

# Skill / Agent Authoring Guide

## Procedure (when capturing a skill)

### Step 1: Confirm scope
Ask the user to clarify ANY of these that aren't already obvious:
- One-line summary of what the skill covers
- Specific keywords/file paths/concepts that should trigger it
- Specific things it should NOT cover (negative triggers)
- Any non-obvious rules or constraints

### Step 2: Draft the frontmatter
The `name` is kebab-case, descriptive, prefixed where useful (e.g.
`music-platform-foo` for project-local skills in this monorepo). The
`description` is the most important field — it determines activation.

A good description:
- Lists 5-15 specific trigger keywords/phrases
- Lists specific file paths or imports that should trigger it (when
  applicable)
- Has a "Do NOT trigger" sentence at the end excluding adjacent topics
- States its boundary relative to other related skills (e.g. "for X see
  the Y skill")

### Step 3: Draft the body
Sections that work well in skill bodies:
- Operating principles or rules (numbered list)
- Decision matrices (when to use X vs Y)
- Code examples showing the canonical pattern
- Common pitfalls (numbered list with brief explanations)
- "What you must never do" (hard rules)
- "When to escalate" or "Out of scope"

Avoid:
- Long historical context (skills are reference, not narrative)
- Verbatim duplication of other skills' content (cross-reference instead)
- Speculative coverage of features that don't exist yet

### Step 4: Choose the path
- User-wide: `~/.claude/skills/<name>/SKILL.md`
- Project-local: `<project>/.claude/skills/<name>/SKILL.md`

If "both," draft TWO files — one user-wide for generic content, one
project-local that references it.

### Step 5: Confirm before writing
Print the draft to chat. Get explicit "yes, write it" before creating
the file. After writing, print:
- Absolute path of the created file
- First 15 lines so the user can verify the frontmatter
- A reminder: "Description is tunable — adjust if triggers misfire."

### Step 6: Update relevant indexes
- If user-wide, update `~/.claude/CLAUDE.md` if it has a skill index section
- If project-local, update the project's `.claude/skills/README.md` (or
  create it) and the project's root `CLAUDE.md` skill list

## Procedure (when capturing an agent)

Agents live in `~/.claude/agents/<name>/AGENT.md` (user-wide) or
`<project>/.claude/agents/<name>/AGENT.md` (project-local).

The agent file format includes:
- Frontmatter with `name` and `description` (same role as skills:
  determines when an orchestrator can find/dispatch it)
- A role definition for the agent
- The agent's allowed tools and constraints
- A required return format if the agent reports back to an orchestrator

For agents, ALSO ask the user:
- Will this agent be dispatched by another agent (orchestrator)?
- Or invoked directly by the user?
- What tools does it need? (Read-only? Bash? Web search?)
- What format does it return its work in?

If you don't know whether the user's Claude Code installation supports
the agent format you're targeting, propose the skill route instead and
offer to convert later.

## Examples of good skill captures

**Good capture (project-local):** User spent a session debugging why
their admin form was sending requests to the wrong origin. Pattern:
"admin client must use BFF proxy via /api/admin/*, never call API
directly." This is project-specific, repeatable, and easy to forget.
Capture as project-local skill.

**Good capture (user-wide):** User researched DDEX standards extensively
across multiple sessions. Pattern: domain reference for music industry
messaging. Generic across any music-related project. Capture as user-wide.

**Bad capture:** User asked one question about a specific Prisma query.
Pattern: too narrow, too one-off. Don't suggest capture.

**Bad capture:** User asked about Next.js basics that are already covered
by an existing skill. Pattern: redundant. Don't suggest capture.

## Examples of when to suggest agent over skill

- "I want a code reviewer that checks every PR for security issues" →
  agent (autonomous, returns a report)
- "I want a research assistant that gathers context before I write a
  spec" → agent (multi-step, produces a deliverable)
- "I want claude to know the conventions of my React codebase" → skill
  (additive context, no autonomous workflow)
- "I want a sub-agent the orchestrator can dispatch for testing tasks"
  → agent (named, dispatched programmatically)
