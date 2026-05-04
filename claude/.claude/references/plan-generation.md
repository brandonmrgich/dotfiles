---
title: Plan and task generation (Mode B)
description: Mode B procedure for generating master plans and task files when the user provides only a goal. Steps, master-plan template, task-file template, cross-reference verification, user-approval gate, orchestrator-generated artifact tracking.
static: true
---

# Plan and task generation (Mode B)

When `plan-executor` is invoked in Mode B (user provides a goal but no
plan/tasks), generate the artifacts before dispatching any sub-agent.
Read this reference end-to-end before proceeding.

See also: `~/.claude/references/plan-system.md` for the canonical
filesystem layout (where MasterPlan.md and tasks/ live, where state
files go, gitignore rules).

---

## Step 1 — Clarify the goal

Ask the user clarifying questions if any of these are unclear:

- What is the desired end state?
- What part of the codebase is in scope?
- Are there constraints (no breaking changes, must run on a single
  branch, etc.)?
- What's the rough size — single afternoon, multi-day, multi-week?

Do not guess. One round of focused clarification is cheaper than
generating a plan that misses the goal.

---

## Step 2 — Generate the master plan

Write the master plan to a path the user approves (default suggestion:
`.claude/plans/<short-name>/MasterPlan.md`, per `plan-system.md`).

The master plan MUST include:

- A "Project Vision" or "Objective" section
- An architectural / structural overview
- Constraints and standards
- A "Task index" section listing every task file by path, with the
  exact paths the orchestrator will generate in Step 3
- A footer line: `Tasks for this plan: <tasks_dir>/` so any reader
  knows where to find them

Front-matter on the master plan should follow the standard plan
schema (see `~/.claude/CLAUDE.md` § Artifact classes for fields:
`plan`, `status`, `from-essay`, `affects-docs`, `created`).

---

## Step 3 — Generate the task files

Write each task file under a directory the user approves (default
suggestion: alongside the plan, in `<plan_dir>/tasks/`).

Each task file MUST include:

- A header with the task ID and name
- A `## Context` section that **references the master plan by absolute
  path** with a line like:
  `Part of <absolute path to master plan>, Section <N>.`
- `## Prerequisites` section listing prior task IDs by name
- `## Scope`
- `## Out of Scope`
- `## Acceptance Criteria`
- `## Validation Steps`
- `## Deliverables` (always specifying exactly one commit and the
  exact commit message format)

The Deliverables commit message MUST include the
`Plan: <plan-name>` and `Task: <task-id>` footers. See the `github`
skill for the full commit-footer convention.

---

## Step 4 — Cross-reference verification

Before proceeding to execution:

- Confirm every task file references the master plan path
- Confirm the master plan's task index lists every generated task file
- If a sub-agent type can be inferred from the task content, add a
  `## Sub-agent type: <implementer|tester|documenter|discovery>` line
  near the top of each task file

A missing cross-reference here is a generation bug — fix it before
asking for approval, not after.

---

## Step 5 — User approval

Print to chat:

- The master plan path
- The full list of task file paths
- The total task count
- A one-line summary per task

Then ask: "Generated <N> tasks. Review and approve before execution?
(approve / show <task-id> / regenerate / cancel)"

Only proceed to Phase 0 (initialize) once the user approves.

On `cancel`: discard the generated plan and task files, do not
write the state file, exit cleanly.

---

## Step 6 — Track that artifacts are orchestrator-generated

In `.claude/plan-states/<plan-name>.json`, set
`"artifacts_generated_by_orchestrator": true` at the top level. This
flag is what enables the orchestrator's Phase 5 cleanup to safely
remove generated files. Without this flag, Phase 5 will treat all
files as user-authored and decline to remove them.

---

## Task-quality rationalizations

The universal excuses for shipping vague tasks — and why each fails:

- "The implementer will figure out the details." → No: tasks must
  state what to do, not delegate scope.
- "It's obvious what this means in context." → Pass the zero-context
  engineer test. If a fresh sub-agent can't tell, it isn't.
- "I'll add specifics later." → Later is now or never.
- "Each task is just one chunk of work." → Tasks are 2–5 minutes of
  work each, not whole features.
- "Placeholders are fine for early drafts." → Tasks ship; drafts
  don't. Keep placeholders in essays, not task files.

See `~/.claude/skills/plan-executor/SKILL.md` Phase 1 task-quality
gate for the dispatch-side enforcement.
