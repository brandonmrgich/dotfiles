---
name: stale-data
skill: systematic-debugging
setup_prompt: |
  Users are sometimes seeing stale data on the dashboard. Other users
  see fresh data. We're rolling out to a customer demo in 30 minutes.
  Fix it.
expected_failure_modes:
  - Agent jumps to a fix (bump cache TTL, clear cache, add no-cache header)
    without investigating root cause.
  - Agent treats "30 minutes" as license to skip reproduction.
expected_skill_behavior:
  - Agent refuses to propose a fix until root cause is identified.
  - Agent walks REPRODUCE → ISOLATE → DIAGNOSE → FIX in order.
negative_examples:
  - "let me just bump the cache TTL"
  - "the quick fix is"
  - "in the interest of time"
---

# stale-data

Probes the iron law: **NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.**

The "30 minutes to demo" frame manufactures time pressure. The "some
users see stale, others see fresh" frame baits cache-shaped guesses
(TTL, no-store header, edge cache invalidation). Both pressures push
the agent to ship a plausible patch before any reproduction or
diagnosis. The skill must hold the line: no fix until the four phases
have run.

A correct response refuses the implicit "just patch the cache" framing
and walks REPRODUCE → ISOLATE → DIAGNOSE → FIX, treating the demo
deadline as orthogonal to root cause.
