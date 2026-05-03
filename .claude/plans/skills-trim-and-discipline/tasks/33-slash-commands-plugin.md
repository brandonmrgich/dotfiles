# Task 33 — Slash commands plugin

**Phase:** 8 (Ergonomics & enforcement)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Wire up slash commands for the most-used skills. Ergonomic shortcuts
that don't replace the skills — they *invoke* them. Lives in a new
commands plugin alongside the existing `commit-commands`.

## Context

Per essay #8 §"Gap 9", local skills like `zoom-in`, `zoom-out`,
`session-ready`, `top-down-sweep`, `plan-auditor` are most-used but
require typing the trigger phrase. Slash commands provide a one-step
invocation. The existing `commit-commands` plugin is the layout
template.

## Files

**Created:**
- `~/dotfiles/claude/.claude/commands/skill-commands/...` (final layout
  decided in implementation; mirror `commit-commands` structure)

Recommended commands:
- `/zoom-in`
- `/zoom-out`
- `/session-ready`
- `/sweep` (alias for `top-down-sweep`)
- `/audit-task` (alias for `plan-auditor` task-scoped invocation)

## Steps

1. Read existing `commit-commands` plugin layout to understand the
   structure (typically `<plugin-dir>/commands/<command-name>.md` or
   similar).
2. Decide plugin name: `skill-commands` (or `homebrew-commands` —
   pick one that doesn't collide with `commit-commands`).
3. Create plugin scaffolding under `~/dotfiles/claude/.claude/commands/<plugin>/`.
4. For each of the 5 commands, write a one-paragraph definition:
   - Name (with leading slash).
   - Description (purpose).
   - Action (invoke skill X with default args).
5. Stow + verify all new files appear as symlinks under
   `~/.claude/commands/<plugin>/`.
6. Verify the commands appear in the skill picker (`/<command-name>`
   tab-completion or skill-list).
7. Commit + PR.

## Acceptance criteria

- [ ] Plugin dir present under `~/.claude/commands/<plugin>/`.
- [ ] All 5 commands defined.
- [ ] Each command invokes the right underlying skill on a smoke test.
- [ ] PR description lists each command and its mapped skill.

## Validation

- Type `/zoom-in <task>` in a fresh session; `zoom-in` skill activates
  with the provided task arg.
- Type `/session-ready`; `session-ready` skill activates.
- Type `/sweep <doc>`; `top-down-sweep` activates with the doc as
  starting point.

## Commit / PR

- Commit message:
  ```
  feat(claude): add slash-commands plugin for top-used skills

  /zoom-in, /zoom-out, /session-ready, /sweep, /audit-task. Mirrors
  the commit-commands plugin layout. Skills unchanged — commands are
  ergonomic shortcuts.

  Refs: essay skill-system-vs-superpowers.md §Gap 9

  Plan: skills-trim-and-discipline
  Task: 33
  ```
- PR target: `main`.
