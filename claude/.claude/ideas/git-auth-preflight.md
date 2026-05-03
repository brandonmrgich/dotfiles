---
title: Pre-flight git auth check in plan-executor and worktree-orchestrator
created: 2026-04-26
status: open
tags: [tooling, plan-executor, worktree-orchestrator, github-skill]
project: dotfiles
---

# Idea: Pre-flight git auth check in plan-executor and worktree-orchestrator

## Motivation

The `github` skill encodes headless safety — refuse to push if a PIN/passphrase prompt would hang the session. That guardrail lives in the skill, but the actual non-interactive surfaces (plan-executor, worktree-orchestrator) don't yet enforce it at session start.

A plan that runs for an hour and then hangs on the final push because gpg-agent expired is the exact failure mode the github skill describes — but currently nothing checks BEFORE the work is done.

## Sketch

Add a Phase 0 pre-flight gate to both skills:

- **plan-executor** — before dispatching the first agent, verify `gh auth status`, `ssh-add -l`, and (if signing) gpg-agent has the key cached. If not, halt with a clear remediation message. Same check must pass before any final-push step.
- **worktree-orchestrator** — same check at worktree creation (so the worktree session doesn't hit it later) and at merge prep.

Optional: shared helper at `~/.claude/skills/_shared/preflight-auth.sh` that both skills call, so the check has one implementation.

## Open questions

- Advisory (warn + continue) or strict (halt)? Strict is safer for headless; advisory is friendlier for interactive.
- Does worktree-orchestrator need the check at every merge attempt, or only the first?
- Is gpg signing assumed required, or detected per-repo (`git config commit.gpgsign`)?

## Promotion criteria

- Convert to a plan when there's been at least one observed hang-on-push incident in a long-running plan, OR when worktree-orchestrator gets enough use that interactive auth surprises become a recurring annoyance.
- Block this work behind the github skill landing first — it owns the policy that this would enforce mechanically.
