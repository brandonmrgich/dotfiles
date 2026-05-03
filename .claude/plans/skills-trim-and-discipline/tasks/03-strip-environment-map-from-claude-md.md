# Task 03 — Strip embedded environment map from CLAUDE.md

**Phase:** 1 (CLAUDE.md trims)
**Agent:** plan-executor-implementer
**Produces PR:** Yes

## Goal

Replace the embedded `## Environment Map` section (host table + repo table
+ Tailscale prose) with a 3-line pointer to the `environment-map` skill.
The host/repo tables are *already* loaded on demand from
`~/.claude/environment/{hosts,networks,repos,services}.md` when the
`environment-map` skill activates — the inline copy in CLAUDE.md is pure
duplication.

Targets ~2,952 bytes saved on every session.

## Context

The `environment-map` skill (added in PR #4) was designed to load
host/network/repo data on demand. CLAUDE.md still carries the full table
inline, contradicting the skill's design intent. This task makes
CLAUDE.md state honest: it should *announce* the multi-host setup, not
*describe* it.

Source: essay #9 §"P0.3 — Strip duplicated environment content from
CLAUDE.md".

## Files

**Affected:**
- `~/dotfiles/claude/.claude/CLAUDE.md`

## Steps

1. Identify the `## Environment Map` section through the trailing
   "For host details see..." paragraph.
2. Replace with a 3-line stub:
   ```
   ## Environment Map

   Brandon runs a multi-host personal setup (M1 MacBook + Debian agent
   host + Pi DNS + AWS prod + Oracle standby). The `environment-map`
   skill loads the full topology on demand. Activate it on host names,
   service names, or cross-machine queries. See
   `~/.claude/environment/` for the source files.
   ```
3. Verify the `environment-map` skill's `description:` already covers
   the activation triggers (it does, per the existing SKILL.md).
4. No reference file needed — the data already lives at
   `~/.claude/environment/*.md` and `environment-map` skill knows where.
5. Stow + verify.
6. Commit + PR.

## Acceptance criteria

- [ ] CLAUDE.md `## Environment Map` is the 3-line stub.
- [ ] No data lost: `~/.claude/environment/{hosts,networks,repos,services}.md`
      files unchanged.
- [ ] `environment-map` skill activations still resolve all the data they
      need (smoke-test in audit gate).
- [ ] PR description shows CLAUDE.md byte delta.

## Validation

- `wc -c` on CLAUDE.md drops by ~2,900 bytes.
- Test in a fresh session: ask "how do I SSH into the agent host?" —
  `environment-map` skill activates and reads `hosts.md`.

## Commit / PR

- Commit message:
  ```
  refactor(claude): strip duplicated environment map from CLAUDE.md

  The host/repo tables are already loaded on demand by the environment-map
  skill from ~/.claude/environment/. The inline copy in CLAUDE.md was
  pure duplication. Replaced with a 3-line pointer.

  Refs: essay skill-system-token-efficiency-audit.md §P0.3

  Plan: skills-trim-and-discipline
  Task: 03
  ```
- PR target: `main`.
