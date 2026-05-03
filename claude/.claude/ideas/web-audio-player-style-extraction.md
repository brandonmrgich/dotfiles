---
title: Web audio player mobile redesign — style extraction & implementation
created: 2026-04-26
status: open
tags: [redesign, music-platform-monorepo, web-audio-player, ui]
project: music-platform-monorepo/apps/web-audio-player
---

# Idea: Web audio player mobile redesign — extraction & implementation

## Motivation

Static HTML mocks of an 8-screen mobile redesign exist for the web audio player. The mocks honor the existing token vocabulary cleanly, with minimal additions: two new tokens (`bg-presence-live`, `bg-accent-button-bg`) and one new component (iOS-style Toggle).

This idea is essentially a working brief. Convert to an implementation plan when the user is ready to schedule the work.

## Sketch

Three phases the implementation plan will cover:

1. **Audit current code against extracted patterns** — identify components to update vs. create, and globals.css changes needed.
2. **Generate implementation brief** at `docs/10-ui-ux/redesign-explorations/2026-04-mobile-community-pivot-IMPLEMENTATION.md` covering: token additions, component changes, new components, screen-by-screen sequencing, deferred decisions, feature flag strategy.
3. **Update existing UX docs** with extracted patterns (surgical, not full rewrite) — `design-tokens.md`, `component-patterns.md`, `web-audio-player.md` (current state).

## Notes from initial extraction (preserve)

- 8 screens covered (Home, Browse subtabs, Library, Listener Profile tabs)
- Two new tokens needed:
  - `bg-presence-live` (`#4ade80`) — green live indicator
  - `bg-accent-button-bg` (`#e85d52`) — primary CTA, AA contrast on white text
- New component: iOS-style `Toggle` (consider Radix Switch vs custom)
- Drifts from brief:
  - No PlayerSheet rendered (only mini-player)
  - Listener-only Studio variant (no Artist Studio)
  - TrackRow without index column
  - Profile tab is minimal (no avatar/banner upload)
  - Artist row uses placeholder circle, not real avatar
- Feature flag strategy needed: production app at `stream.brandonmrgich.com`
- Reference brief: `docs/10-ui-ux/redesign-explorations/2026-04-mobile-community-pivot.md`
- Screens NOT in mocks (must come from brief): PlayerSheet, Room view, Artist profile, Album page, Track detail, Listener profile (other), Auth flows, Artist Studio, Pinned populated state, empty states

## Open questions

- Toggle component: Radix Switch (consistent with existing dialog usage) vs custom impl?
- One bundled PR or split per phase?
- Feature flag: `NEXT_PUBLIC_PLAYER_V2` mirroring the admin pattern?

## Promotion criteria

- Another agent currently working in `music-platform-monorepo` (per user note); wait until that completes
- Plan would likely be non-trivial (multi-domain, large refactor) → run in isolated worktree per the new system
- Convert to a master plan (Mode B with Opus) once the music-platform-monorepo migration idea above is also resolved
