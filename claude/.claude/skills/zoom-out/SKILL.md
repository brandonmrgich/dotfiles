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
   - Delete `.claude/zoom-state.json`.
   - Emit: `Zoomed out. <summary>` and note plan artifact path if applicable.

4. Return to the big-picture context — no lingering scoped attention.
