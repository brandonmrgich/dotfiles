---
name: "[HomebrewSkill] doc-freshness"
description: "Detects stale documentation using front-matter staleness markers. Activates when an agent is about to read a doc that declares covers: paths, when a doc has been updated and last-verified needs bumping, or when a user asks 'is this doc stale', 'check doc freshness', or 'verify this doc'. Does NOT activate for docs with covers: [] or static: true (static/reference docs). The skill checks git log on the covered paths since last-verified and surfaces a staleness warning when code changed after the doc was last verified."
triggers:
  - "is this doc stale"
  - "check doc freshness"
  - "verify this doc"
  - "bump last-verified"
---

# doc-freshness skill

Detects stale documentation using front-matter staleness markers. This skill
replaces changelog-based staleness tracking with a lightweight, per-doc
approach: each doc declares what code it covers and when it was last verified.

---

## Front-matter format

Place this front-matter on any doc that describes code:

```yaml
---
covers:
  - path/to/module/
  - path/to/another/
last-verified: YYYY-MM-DD
static: false   # omit or set true for reference docs (DDEX standards, etc.)
---
```

Field semantics:

- `covers`: list of file paths or directories this doc describes. Paths are
  relative to the repo root. Can be files or directories (trailing slash optional).
- `last-verified`: ISO date (YYYY-MM-DD) a human or agent last confirmed the
  doc still accurately matches the code it describes.
- `static: true`: opt-out of staleness checks. Use for external standards,
  generated references, or any doc whose staleness is irrelevant (e.g., DDEX
  spec summaries, API schema snapshots).
- `covers: []`: equivalent opt-out shorthand — empty covers list means no
  paths to check.

---

## Staleness check procedure

When this skill activates (user asks, or an agent is about to rely on a doc):

1. Read the doc's front-matter.
2. If `static: true` OR `covers` is empty/absent:
   - Emit: "Doc is static — no staleness check needed."
   - Stop.
3. Confirm `last-verified` is present and a valid ISO date. If missing, warn:
   "Doc has no last-verified date — treat as potentially stale."
4. For each path in `covers`, run:
   ```
   git log --since=<last-verified> --oneline -- <path>
   ```
   Execute from the repo root (use `git -C <repo-root>` if needed).
5. Collect results:
   - If ANY path returns one or more commits: emit a staleness warning:
     ```
     WARNING: Doc may be stale. Changes since <last-verified>:
       <path>:
         <sha> <subject>
         ...
     ```
   - If no paths return commits: emit:
     ```
     Doc appears current as of <last-verified>.
     ```

---

## Verification workflow

When an agent (or the user) has read a doc and confirmed it still matches the code:

1. Agent states: "I've verified this doc is accurate."
2. Skill offers: "Bump last-verified to today? (yes/no)"
3. On yes: edit the doc's front-matter `last-verified` field to today's ISO
   date (YYYY-MM-DD). Use the Edit tool on the exact `last-verified:` line.
4. Do not touch any other front-matter fields.
5. The calling agent or user should commit the bump as part of the same task
   commit, or as a standalone "chore: bump last-verified" commit.

---

## Integration with plan-executor

The doc-freshness skill replaces changelog writes in plan-executor workflows.

**Pattern for plan-executor implementer agents:**

After completing a task commit, check if any modified files fall under a doc's
`covers` paths. If yes, surface a recommendation — not automatic action:

> "Files modified in this task are covered by `<doc-path>` (last-verified:
> YYYY-MM-DD). Consider running doc-freshness on that doc before the plan
> completes."

This is advisory only. The agent does not auto-update docs or auto-bump
`last-verified`. A human or a dedicated verification step makes that call.

**Where the signal comes from:**

The implementer agent knows which files it touched. Compare those paths against
any docs in the repo that carry a `covers:` list. If there is an overlap, note
the relevant doc(s) in the task summary under "Notes for orchestrator".

---

## What this skill does NOT do

- Does not auto-update docs or auto-bump `last-verified` without confirmation.
- Does not enforce doc coverage — no error if a modified file has no covering doc.
- Does not migrate existing docs — adding `covers:` front-matter to existing docs
  is a per-project task, deferred to whenever the team finds it valuable.
- Does not block commits or CI — purely advisory.
- Does not track docs that opt out via `static: true` or `covers: []`.
