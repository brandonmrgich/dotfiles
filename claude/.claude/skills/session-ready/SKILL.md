---
name: "[HomebrewSkill] session-ready"
class: workflow
description: "Activates on '/session-ready', 'is this session ready', 'fresh claude check', 'before closing', 'can a new session pick this up', or when the user is about to close a session at end of day, hand work to a different session, or suspects the docs no longer carry enough context. Target may be a current task, plan, essay, or working state."
triggers:
  - /session-ready
  - "session ready"
  - "fresh claude check"
  - "can a new session pick this up"
  - "before closing"
---

# Session Ready

A continuity probe. Sessions get interrupted — closed for the night, lost to compaction, picked up by a different Claude. The state file gives structural continuity (what's done, what's next) but conversational context — *why* a task was scoped this way, in-session decisions — compacts away. The state file is a skeleton, not a brain.

This skill probes whether the docs around the current work carry enough brain for a fresh session to operate cleanly. If not, it surfaces what's missing so you can fix it before the next session inherits the gap.

---

## Step 1 — Identify the target

If the user provides a target, use it. Otherwise ask one focused question:
"What should the fresh Claude be able to pick up? (current plan, a specific task, an essay-in-progress, or 'whatever I'm working on')"

Acceptable targets:
- A plan name → `<project>/.claude/plans/<name>/`
- A task path → specific task file
- An essay → `~/.claude/essays/<slug>.md` or project-local
- "Current work" → infer from recent file edits, focus.md if present, recent commits

Determine the **target context bundle**: the minimum set of files a fresh Claude would need to read to orient. Typically:
- The MasterPlan + current task + any `from-essay:` referenced essay
- Project CLAUDE.md
- Sidecars on files being modified
- Anchored docs (`docs/...`) whose `covers:` matches files being touched

## Step 2 — Dispatch the fresh-context probe

Use the Task tool with `subagent_type: general-purpose`. The sub-agent has zero conversation history and must answer purely from the target context bundle.

Prompt template:

```
You are a fresh Claude session with no prior context. The user/parent agent has been working on a task and is asking you to verify a fresh session could pick it up cleanly.

Target context bundle (read these and only these):
- <file 1>
- <file 2>
- ...

Answer three questions, each in one paragraph:

1. **Orientation.** From these files alone, what is the current work and why? Be specific. If you cannot tell, say what's missing.

2. **Next action.** What is the immediate next step? If the work is mid-task, what would you do first? If there are multiple plausible next actions, list them.

3. **Gaps.** What context would you want that the bundle does not provide? Be concrete — name the specific decision, invariant, or piece of history that's referenced but not explained.

Report in under 300 words. Do not invent context — say "unclear" when it's unclear.
```

## Step 3 — Process the report

Read the sub-agent's report. Classify:

- **Clean** — orientation crisp, next action obvious, no significant gaps. Confirm session is ready.
- **Soft gaps** — orientation mostly works but minor context missing (a sidecar lacks a recent invariant, an essay needs a closing paragraph). List remediations.
- **Hard gaps** — sub-agent can't orient, or names plausible-but-wrong next actions. The docs are not carrying their weight.

## Step 4 — Surface remediation

For each gap the sub-agent named, propose a concrete fix. Don't fix automatically — the user decides.

Common remediations:
- Stale anchored doc → `/top-down-sweep` from that doc.
- Missing or stale sidecar → propose specific sidecar updates with `# label:` and `# role:`.
- Essay-in-progress lacks decision summary → propose an essay update via the `essay` skill.
- Plan task description references decisions made in chat that aren't written down → propose appending to the relevant essay or task description.
- CLAUDE.md doesn't mention a load-bearing convention being followed → propose adding it.

Output to console (1-5 lines):

```
session-ready check on <target>: <verdict>
Gaps: <count>
Remediations: <list, each one line>
```

If the report is long enough to warrant detail, write it to `<project>/.claude/sweeps/session-ready-<date>.md`.

---

## When to invoke proactively

The skill is user-invoked, but you can suggest invoking it when:
- The user says "let's call it for the night" or similar end-of-session signal AND there's mid-flight work.
- Compaction has just happened and significant decisions were in the truncated history.
- The user is about to start a worktree-orchestrator handoff to a different agent.

Suggest, don't auto-run. The probe is cheap but not free.

## What you must never do

- Run the probe with full conversation context — the whole point is fresh context. The sub-agent must NOT receive any of the parent's history.
- Auto-apply remediations — gaps surface to the user; the user picks what to fix.
- Use the probe as a substitute for the user's own judgment about whether a session is ready. It's a tool, not a verdict.
- Conflate this skill with `top-down-sweep` — sweep audits docs against code; this audits docs against the question "could a fresh Claude continue from here?". The skills can chain (probe finds gaps → sweep fixes them) but they answer different questions.
