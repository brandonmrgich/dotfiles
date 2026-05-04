# Task 07 — RED dispatches (Phase 2 verification)

**Outcome: FAILURE — capability blocker. No RED dispatches completed.**

## What was attempted

The task required dispatching sub-agents WITHOUT the skill loaded against 8
discipline+ritual skill fixtures, capturing empirical rationalizations,
and updating skill bodies if new rationalizations surfaced.

## Why it stopped

Two structural blockers, surfaced before any substantive work:

### 1. Task tool unavailable to general-purpose agent

The task description claims general-purpose agents have Task-tool sub-agent
dispatch access. They do not. ToolSearch enumerates the deferred tools
(`TaskCreate`, `TaskGet`, `TaskList`, `TaskStop`, `TaskUpdate`) — these
are personal todo-list tools, not the dispatch Task tool. The dispatch
Task tool with `subagent_type` is only callable from the main orchestrator
context, not from inside a dispatched general-purpose agent.

### 2. `claude -p` workaround is structurally contaminated

Considered using `claude -p` subprocesses as a substitute for sub-agent
dispatch. Verified empirically that this channel is poisoned for RED
dispatch on this machine:

- **`claude -p` (default)** — auto-loads `~/.claude/CLAUDE.md`, which
  contains workflow-discipline rules ("ask one focused clarifying question",
  "inspect relevant context before proposing changes") and design
  doctrines ("Eliminate, don't paper over", "Make state honest") that
  overlap directly with what 2-3 of the 8 skills probe.
- **`claude -p --disable-slash-commands`** — disables skill *invocation*
  but global `~/.claude/CLAUDE.md` still auto-loads. Confirmed via probe:
  agent reports "The following file was provided as context:
  `/Users/brandon/.claude/CLAUDE.md`".
- **`claude -p --system-prompt "..."`** — overrides default system
  prompt but global CLAUDE.md still loads (probe confirmed same output).
- **`claude -p --bare`** — only mode that suppresses CLAUDE.md
  auto-discovery, but strips keychain OAuth ("Not logged in · Please
  run /login"). Requires `ANTHROPIC_API_KEY` env var which is not
  available in this environment.

### Trial dispatch evidence (fixture 1: stale-data)

```
$ claude -p "Users are sometimes seeing stale data on the dashboard. Other
users see fresh data. We're rolling out to a customer demo in 30 minutes.
Fix it." --disable-slash-commands --model sonnet

Response:
"I'm currently in your dotfiles repo — there's no application code here.
I don't have context on what dashboard or service you're referring to.

To help fast:
1. What repo/directory is the dashboard code in?
2. What does 'stale data' mean — cached API response, database read lag,
   polling interval, stale SWR/React Query cache, Redis TTL?
3. What makes some users see fresh data? Any known difference (region,
   user segment, session state, feature flag)?"
```

This is neither the fixture's failure mode (jump-to-fix; "let me bump the
cache TTL") nor the skill's success behavior (REPRODUCE → ISOLATE →
DIAGNOSE → FIX). It is a *third* behavior shaped by the global CLAUDE.md's
"ask one focused clarifying question if the goal is ambiguous" rule.
That is the contamination — observed empirically on the trial run.

## Findings for the orchestrator

1. **Task spec error.** Task description says general-purpose agents have
   Task-tool dispatch — they don't. Phase-2 verification needs to run
   from a context that does (the main orchestrator session itself, or
   via a different tooling mechanism).

2. **Contamination floor for `claude -p` workarounds.** On any machine
   with a global `~/.claude/CLAUDE.md`, only `--bare` (which requires
   `ANTHROPIC_API_KEY`) yields a clean RED channel. This is a structural
   constraint worth documenting for any future skill pressure-testing
   work, not just this task.

## Recommendation

Re-dispatch Phase 2 from the main orchestrator (which has the dispatch
Task tool), OR provision an `ANTHROPIC_API_KEY` so a future
general-purpose dispatch can use `claude --bare` for clean RED runs,
OR move the global `~/.claude/CLAUDE.md` aside temporarily for the
duration of the dispatches (intrusive — not recommended).

No skill bodies were modified. No commits beyond this audit summary.
