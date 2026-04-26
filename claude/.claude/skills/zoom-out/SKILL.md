---
name: "[HomebrewSkill] zoom-out"
description: "Surface from a zoomed-in task back to the big picture. Summarizes what was accomplished and cleans up focus state."
triggers:
  - /zoom-out
  - "zoom out"
  - "back to the big picture"
---

# Zoom Out

Return from a focused task context to the broader view. Summarize what was done, clean up state.

## Steps

1. Read `.claude/zoom-state.json`. If it doesn't exist, say there is no active zoom context and stop.

2. **If mode is `interactive`**:
   - Read `.claude/focus.md`.
   - Write a one-paragraph summary of what was accomplished during the zoom.
   - Delete `.claude/focus.md` and `.claude/zoom-state.json`.
   - Emit: `Zoomed out. <summary>`
   - Resume broad attention to the project.

3. **If mode is `autonomous`**:
   - The agent already returned. If `plan_artifact` is set in state, read it.
   - Write a brief summary of what the agent did and any artifacts produced.
4. **Plan promotion check**: If `plan_artifact` is set and the artifact contains a `## Task index` section (i.e., it looks like a promotable plan scaffold):
   - Ask the user: "This zoom produced a plan scaffold. Promote it to a full plan for execution? (yes/no)"
   - On **yes**: suggest the steps — move the scaffold to `.claude/plans/<slug>/MasterPlan.md`, create a `tasks/` directory alongside it, then use `worktree-orchestrator` to create an isolated worktree: "Use `worktree-orchestrator` to create a worktree, then open Claude Code there and run `plan-executor`."
   - Do NOT auto-move files or auto-create the worktree. Surface the suggestion only; the user confirms and triggers each step explicitly.
   - On **no** or if the artifact is not a promotable scaffold: proceed with normal zoom-out (emit summary, delete zoom-state.json).
   - Delete `.claude/zoom-state.json`.
   - Emit: `Zoomed out. <summary>` and note plan artifact path if applicable.

5. Return to the big-picture context — no lingering scoped attention.
