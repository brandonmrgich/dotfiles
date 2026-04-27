---
title: Permission pre-flight + per-plan settings.local.json for plan-executor
created: 2026-04-27
status: open
tags: [tooling, plan-executor, worktree-orchestrator, permissions]
project: dotfiles
---

# Idea: Permission pre-flight + per-plan settings.local.json for plan-executor

## Motivation

Plan-executor dispatches sub-agents (implementer, tester, documenter, discovery) that each make their own tool calls. Any Bash command outside `permissions.allow` causes a permission prompt that blocks the entire plan until the user responds. This defeats the orchestrator pattern's core value — running unattended (overnight, in another room, in a worktree).

Sibling concern to `git-auth-preflight.md` (which addresses auth/credential prompts). This idea addresses tool-permission prompts. Both are pre-flight gates for plan-executor headless safety, different surfaces.

## Sketch

Two complementary pieces:

**1. Pre-flight permission audit (Phase 0 of plan-executor)**
- Before dispatching the first sub-agent, scan all task files for Bash commands they're likely to run (greppable patterns, common workflows per agent type).
- Cross-reference against current `permissions.allow` (user-level + project-level + plan-local).
- Report gaps before plan starts: "Task 03 will run `pnpm exec foo` which isn't allowlisted — plan will halt for prompt at task 03." Surface the gap upfront, not 4 tasks deep.
- Optionally offer to add gaps to a per-plan `settings.local.json` for the duration of the plan.

**2. Per-plan `settings.local.json`**
- Plan-executor writes `<project>/.claude/settings.local.json` (or worktree-local equivalent) at plan start with a more aggressive allowlist scoped to that plan's needs.
- Cleaned up at plan completion (cleanup phase already exists in plan-executor for orchestrator-generated artifacts).
- Worktree-isolated by default — each worktree has its own settings.local.json.
- Could include `defaultMode: acceptEdits` for the plan's run, then revert.

## Open questions

- How to predict Bash commands sub-agents will run without actually running them? Static grep of task files probably catches most; LLM-based prediction would be more thorough but slower.
- Does this conflict with the "user explicitly approves risky ops" principle? Mitigation: the per-plan allowlist only adds known-safe patterns from the user's main allowlist plus the explicit additions for this plan's task type.
- Should the per-plan allowlist be diff-shown to the user before plan start? (Probably yes — explicit consent.)
- Cleanup edge cases: plan crashes mid-run, leaves `settings.local.json` in elevated state. Need recovery mechanism (orphan detection on next plan-executor invocation).
- Interaction with `worktree-orchestrator` — the per-plan settings should follow the worktree, not the main repo.

## Promotion criteria

- Convert to a plan after the first observed plan-executor session that gets blocked by permission prompts mid-run AND at least one auth-preflight idea has been resolved (so we're not designing two pre-flight systems in parallel).
- Should land after `git-auth-preflight` since they share the Phase 0 architecture.
