---
title: Migrate auth layer to refresh tokens with rotation
created: 2026-05-04
status: open
tags: [auth, security]
---

# Idea: Migrate auth layer to refresh tokens with rotation

## Motivation
Move the auth layer off its current scheme onto refresh tokens with rotation — shorter-lived access tokens, rotating refresh tokens to limit blast radius of token theft, and detection of replayed refresh tokens as a compromise signal.

## Sketch
- Short-lived access token + longer-lived refresh token.
- Each refresh issues a new refresh token and invalidates the prior one (rotation).
- Reuse of an invalidated refresh token = suspected compromise → revoke the family.

## Open questions
- Which auth layer specifically (which project / service)?
- Storage for refresh-token families and revocation state.
- Client-side token storage strategy and rotation race handling.
- Migration path for existing sessions.

## Promotion criteria
A concrete target service is identified and the current token scheme is documented enough to scope the migration.
