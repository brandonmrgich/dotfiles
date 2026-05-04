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

A continuity probe. Sessions get interrupted — closed, lost to compaction, picked up by a different Claude. The state file gives structural continuity (done / next) but in-session reasoning compacts away. The state file is a skeleton, not a brain.

This skill probes whether docs around the current work carry enough brain for a fresh session to operate cleanly. If not, it surfaces what's missing.

---

## Step 1 — Identify the target

If the user provides one, use it. Otherwise ask: *"What should the fresh Claude pick up? (current plan, specific task, essay-in-progress, or 'whatever I'm working on')"*

Acceptable targets:
- Plan name → `<project>/.claude/plans/<name>/`
- Task path → specific task file
- Essay → `~/.claude/essays/<slug>.md` or project-local
- "Current work" → infer from recent edits, focus.md, recent commits

Build the **target context bundle** — minimum files a fresh Claude needs: MasterPlan + current task + any `from-essay:` essay; project CLAUDE.md; sidecars on touched files; anchored docs whose `covers:` matches.

## Step 2 — Dispatch the fresh-context probe

Use the Task tool with `subagent_type: general-purpose`. The sub-agent has zero conversation history and answers purely from the bundle.

Prompt template:

```
You are a fresh Claude session with no prior context. Verify a fresh session could pick up cleanly.

Read only these files:
- <file 1>
- <file 2>

Answer in one paragraph each:

1. Orientation. What is the current work and why? If unclear, say what's missing.
2. Next action. Immediate next step? List alternatives if multiple plausible.
3. Gaps. What context is referenced but not explained?

Under 300 words. Do not invent — say "unclear" when unclear.
```

## Step 3 — Process the report

Classify:

- **Clean** — orientation crisp, next action obvious, no gaps. Confirm ready.
- **Soft gaps** — orientation works but minor context missing. List remediations.
- **Hard gaps** — sub-agent can't orient, or names plausible-but-wrong next actions. Docs aren't carrying weight.

## Step 4 — Surface remediation

Propose concrete fixes — don't auto-apply; user decides.

Common remediations:
- Stale anchored doc → `/top-down-sweep` from that doc.
- Missing/stale sidecar → propose updates with `# label:` and `# role:`.
- Essay-in-progress lacks decision summary → propose update via `essay` skill.
- Decisions made in chat that aren't written down → propose appending to essay or task description.
- CLAUDE.md missing a load-bearing convention → propose adding it.

Output (1–5 lines):

```
session-ready check on <target>: <verdict>
Gaps: <count>
Remediations: <list, one line each>
```

If the report warrants detail, write to `<project>/.claude/sweeps/session-ready-<date>.md`.

---

## When to suggest proactively

User-invoked, but suggest when:
- End-of-session signal AND mid-flight work.
- Compaction just truncated significant decisions.
- About to hand off via worktree-orchestrator.

Suggest, don't auto-run.

## What you must never do

- Run the probe with full conversation context — sub-agent must NOT receive parent's history.
- Auto-apply remediations — user picks what to fix.
- Treat the probe as a verdict — it's a tool.
- Conflate with `top-down-sweep`: sweep audits docs against code; this audits docs against "could a fresh Claude continue?". They chain (probe finds → sweep fixes) but answer different questions.
