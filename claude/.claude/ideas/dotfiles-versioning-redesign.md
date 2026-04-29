---
title: Redesign the dotfiles versioning system
created: 2026-04-28
status: open
tags: [dotfiles, versioning, semver, tooling, github-skill]
project: ~/dotfiles
---

# Idea: Redesign the dotfiles versioning system

## Motivation

The current scheme is two-component sequential semver (`vMAJOR.MINOR`, no patch component). It collapses "patch" and "minor" severity into the same axis — every meaningful change becomes a MINOR bump regardless of how trivial. There's no way for a tag alone to distinguish "fixed a typo in a comment" from "added a new convention." The version number is less informative than it could be.

The github skill at `~/.claude/skills/github/SKILL.md` §4 already describes the conceptual mapping (patch for trivial, minor for new features, major for breaking) — but the repo's actual cadence (`v1.0 … v2.2`) drops the patch axis entirely, so the conceptual mapping doesn't survive into the tags.

## Sketch

Move to three-component semver (`vMAJOR.MINOR.PATCH`) with clear per-axis rules:

- **PATCH** — typo fixes, comment/wording tweaks, formatting changes, no behavioral change
- **MINOR** — new conventions, new skills, additive changes that don't break existing patterns
- **MAJOR** — breaking changes, large restructures, deletions of conventions or stow packages

Optionally pair with the automation that was deferred during the v2.2 session:

- A `bin/release` helper that reads the last tag, prompts for bump axis, creates the annotated tag + GitHub release in one command.
- A `pre-push` hook on `main` that refuses untagged pushes (the policy enforcement we discussed but explicitly opted out of for now).

## Open questions

- Should PATCH be auto-incremented per commit, or set explicitly per tag? Auto = noisy; explicit = forgettable.
- Migration: does `v2.2` become `v2.2.0` going forward, or is a clean cutover (e.g., `v3.0.0`) cleaner? Probably the former — no rewrite, just continue from `v2.2.0`.
- Is the helper script alone enough, or does the bump axis also need to be encoded in commit message structure (e.g., conventional-commits-style `feat:` / `fix:` / `chore:` mapping to MINOR / PATCH / PATCH)?
- Should sibling auto-tag-on-main repos (`~/.config/nvim`) adopt the same scheme for cross-repo consistency?
- Does the github skill (`§4`) need updating once this lands, so the canonical policy reflects the new scheme?

## Promotion criteria

Promote this to a real plan when:
- The lack of patch granularity has materially gotten in the way (e.g., a rollback was harder than it should have been because two independent changes shared a tag), OR
- The deferred helper-script automation gets requested again, OR
- A second auto-tag-on-main repo joins the system and creates consistency pressure across them.
