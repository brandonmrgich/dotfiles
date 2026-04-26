> **STATUS (2026-04-26):** Context note for TODO_01. The items listed here
> (auto-spawning agents in worktrees, cross-worktree status reporting, stale
> worktree auto-detection) remain out of scope as originally noted. See
> TODO_01 banner for the executed plan. See TODO_03 for doc-freshness context.

What's NOT in this prompt (referring to ~/.claude/TODO/TODO_01.md) that may come later:

The actual triggering of agent sessions in worktrees. Right now you'd manually cd into the worktree and open a new Claude Code session. There's no automation for "spawn a Claude Code agent on the worktree." That's a separate workflow concern.
Cross-worktree status reporting. A "what's everyone working on" command that surveys all active worktrees and reports plan progress. Could be added to worktree-orchestrator or a sibling skill later.
Auto-detection of stale worktrees. Worktrees abandoned without status update. Could be a periodic check; not yet automated.
