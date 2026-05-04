# Audit 00 — Pre-followup Baseline

**Plan:** skills-trim-followups
**Task:** 00 (Discovery)
**Captured:** 2026-05-01
**Branch:** `claude/skills-trim-followups`
**HEAD SHA:** `f326822f7ed739c37ba787f6739eb66e32ca4189` (matches expected `f326822`)
**Parent plan tag:** `v3.0` (skills-trim-and-discipline closed at this tag; setup PR for this followup landed `v3.1`)

## Working tree state

`git status --short` returned empty prior to audit-file creation. Clean working tree confirmed.

## Linter snapshot

Command: `python3 ~/dotfiles/claude/.claude/tools/skill-budget-lint.py`

> **Path note:** the linter is tracked at `~/dotfiles/claude/.claude/tools/skill-budget-lint.py` but **was not stowed** to `~/.claude/tools/` after the setup PR merge. Invocation per the canonical path (`~/.claude/tools/skill-budget-lint.py`) currently fails with `No such file or directory`. The Phase 1 tasks invoke the linter via that canonical path (per master plan §"Constraints"), so a `stow` of the `claude` package is required before Task 01 can run. Surfaced for the orchestrator below; not part of this baseline task.

### Summary

```
OK=12  WARN=4  FAIL=12  UNKNOWN=0  (total=28)
```

This matches the parent plan's exit state (12 OK / 4 WARN / 12 FAIL).

### Per-skill table

```
skill                           class        desc   body   total  verdict
-------------------------------------------------------------------------
astro-static-sites              specialist    893   5525    6418  OK
ddex-standards                  specialist    967   6990    7957  FAIL  [body>6000]
design-before-code              discipline    598   3020    3618  OK
doc-freshness                   workflow      332   3978    4310  OK
environment-map                 capture         1   1677    1678  OK
essay                           capture       508   8365    8873  FAIL  [desc>500, body>4000, total>5000]
finishing-a-branch              ritual        623   3033    3656  FAIL  [desc>500]
github                          specialist    451   6214    6665  WARN  [body>6000]
gitignore                       specialist    420   4928    5348  OK
idea-tracker                    capture       341   4356    4697  WARN  [body>4000]
nextjs-app-router               specialist    994   7698    8692  FAIL  [body>6000, total>8000]
plan-auditor                    workflow      505   5823    6328  FAIL  [desc>500, body>4000, total>5000]
plan-executor                   workflow      432   9939   10371  FAIL  [body>4000, total>5000]
receiving-code-review           ritual        605   3330    3935  FAIL  [desc>500]
requesting-code-review          ritual        619   3058    3677  FAIL  [desc>500]
royalty-splits-music            specialist    870   7271    8141  FAIL  [body>6000, total>8000]
session-ready                   workflow      337   4947    5284  FAIL  [body>4000, total>5000]
skill-author                    meta          760   5012    5772  WARN  [desc>700, body>5000]
systematic-debugging            discipline    631   3051    3682  OK
test-driven-development         discipline    589   3049    3638  OK
top-down-sweep                  workflow      257   3628    3885  OK
turborepo-patterns              specialist    713   7164    7877  FAIL  [body>6000]
using-homebrew-skills           ritual        535   2181    2716  WARN  [desc>500]
verification-before-completion  discipline    547   2891    3438  OK
web-audio-howler                specialist    915   5601    6516  OK
worktree-orchestrator           workflow      485   5019    5504  FAIL  [body>4000, total>5000]
zoom-in                         workflow      221   2564    2785  OK
zoom-out                        workflow      126   1728    1854  OK
```

## Per-target body byte counts (5 Phase 1 prose-prune targets)

Two measurements per target. The task spec called for raw `wc -c ~/.claude/skills/<name>/SKILL.md` (total file bytes). The linter additionally parses out the body section (post-frontmatter prose), which is the figure the body-budget gate operates on. Both are recorded; subsequent Phase 1 tasks should compare against the **linter body** column, not raw file size.

| skill                | wc -c (total file bytes) | linter body bytes | linter verdict   | body budget overage |
|----------------------|--------------------------|-------------------|------------------|---------------------|
| ddex-standards       | 8043                     | 6990              | FAIL [body>6000] | +990                |
| nextjs-app-router    | 8761                     | 7698              | FAIL [body>6000, total>8000] | +1698   |
| royalty-splits-music | 8229                     | 7271              | FAIL [body>6000, total>8000] | +1271   |
| turborepo-patterns   | 7945                     | 7164              | FAIL [body>6000] | +1164               |
| plan-executor        | 10450                    | 9939              | FAIL [body>4000, total>5000] | +5939 (workflow class — body budget is 4000, not 6000) |

Per-target overages here differ from the master plan's task-index estimates (e.g., ddex listed as "+3,062 B over body budget"). The plan's numbers may have been pre-setup-PR; the post-merge actuals on `f326822` are smaller for ddex/nextjs/royalty/turbo and substantially larger for plan-executor. **Notable:** plan-executor is a `workflow`-class skill (body budget 4000 B), so its overage is +5,939 B — far larger than the master-plan estimate of +502 B. Phase 1 sequencing in the master plan ordered targets "by yield, largest first" assuming a 6000 B budget for plan-executor. With workflow's 4000 B budget the actual yield order is: **plan-executor (+5939) > nextjs (+1698) > royalty-splits (+1271) > turborepo (+1164) > ddex (+990)**. Surfaced below.

## Reference

- Parent plan `skills-trim-and-discipline`: status `completed`, tagged `v3.0`.
- Setup PR for this followup: tagged `v3.1`. Branch `claude/skills-trim-followups` is at `f326822` (post-PR-#18-merge into main + ff-sync).
- Closeout target: `v3.2` MINOR tag on the closeout PR.

## Orchestrator notes

1. **Linter not stowed.** The canonical-path invocation `python3 ~/.claude/tools/skill-budget-lint.py` referenced in the master plan §"Constraints" and in Phase 1 tasks currently fails because `~/.claude/tools/` does not exist. The file is tracked at `~/dotfiles/claude/.claude/tools/skill-budget-lint.py` and needs `stow -d ~/dotfiles -t ~ claude` to materialize the symlink. **This is a setup-PR drift, not a Task-00 deliverable** — flagging for the orchestrator to address before Task 01.

2. **Master plan's per-target overage estimates are stale.** Particularly plan-executor: the plan estimates +502 B over budget; actual is +5,939 B. The cause is the body budget for `workflow`-class skills (4000 B) vs the implicit 6000 B assumed when the plan was drafted. Phase 1 sequencing "by largest yield first" should be reconsidered against the corrected numbers.

3. **No code-bearing files modified.** Only this audit file written.
