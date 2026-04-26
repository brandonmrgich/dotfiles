---
name: "[HomebrewSkill] zoom-in"
description: "Narrow focus to a specific task. Fuzzy/exploratory tasks shift attention interactively; well-scoped tasks dispatch an autonomous sub-agent with optional exploration and plan output."
triggers:
  - /zoom-in
  - "zoom in on"
  - "zoom in"
---

# Zoom In

Narrow the active context to a specific task. Two modes depending on task clarity.

## Step 1 — Assess task clarity

Read the user's zoom-in prompt and classify:

- **Interactive mode**: vague, exploratory, needs iteration ("explore why X is slow", "figure out how Y works", "investigate Z")
- **Autonomous mode**: specific and actionable ("implement feature X", "refactor Y", "fix bug Z in file W", "explore X and produce a plan")

When ambiguous, ask one focused question before proceeding.

## Step 2a — Interactive mode

1. Derive relevant paths from the task and codebase context.
2. Write `.claude/focus.md` in the current project:
   ```
   # Focus: <task>
   Started: <ISO timestamp>
   Mode: interactive

   ## Task
   <task description>

   ## Scope
   <relevant paths/modules>

   ## Out of scope
   <what to ignore>
   ```
3. Write `.claude/zoom-state.json`:
   ```json
   { "mode": "interactive", "task": "<task>", "started_at": "<ISO timestamp>" }
   ```
4. Emit one line: `Zoomed in: <task>` — then proceed with full attention on the scoped task.

## Step 2b — Autonomous mode

1. Determine isolation need: code changes expected → `isolation: "worktree"`; pure exploration/planning → no isolation.
2. Craft a sub-agent prompt containing:
   - The task
   - Current branch, repo root, and key paths relevant to the task
   - Instruction: explore first, then produce `.claude/zoom-plan-<slug>.md` if a plan is warranted
   - Instruction: if producing a plan artifact (`.claude/zoom-plan-<slug>.md`), structure it as a valid master plan scaffold — include a `## Task index` section (even if placeholder) and a `Tasks for this plan: <tasks_dir>/` footer line. This allows the artifact to be promoted directly to a plan-executor plan without rewriting.
   - Instruction: implement only if the user's prompt explicitly asks for it
3. Dispatch via the Agent tool. Pass `isolation: "worktree"` for code tasks.
4. Write `.claude/zoom-state.json`:
   ```json
   {
     "mode": "autonomous",
     "task": "<task>",
     "started_at": "<ISO timestamp>",
     "plan_artifact": ".claude/zoom-plan-<slug>.md"
   }
   ```
5. When the agent returns: present a concise summary of findings and note the plan artifact location if one was created.

## Invariants

- State file lives at `.claude/zoom-state.json` in the current project (per-repo).
- Only one zoom context is active at a time. If a state file already exists, surface it and ask before overwriting.
- Never create `.claude/focus.md` or zoom state at the global `~/.claude/` level.
