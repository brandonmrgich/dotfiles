---
plan: skills-trim-and-discipline
status: ready
from-essay:
  - ~/.claude/essays/skill-system-token-efficiency-audit.md
  - ~/.claude/essays/skill-system-vs-superpowers.md
affects-docs: []
created: 2026-05-01
---

# Master Plan: Skills Trim & Discipline

## Objective

Unify and execute the work proposed in two open essays:

1. **`skill-system-token-efficiency-audit.md`** — measured cost of the existing
   skill system; prescribes a ~40% token-cost reduction by extracting
   reference-shaped content from CLAUDE.md, large SKILL.md bodies, and
   description prose into sibling reference files.
2. **`skill-system-vs-superpowers.md`** — gap analysis vs `obra/superpowers`;
   prescribes adding *discipline-pressure* skills (systematic-debugging, TDD,
   verification-before-completion, design-before-code) plus ritual skills
   (using-homebrew-skills, code-review, finishing-a-branch) and tightening
   existing skills (description format, plan-task quality gate, pressure-test
   methodology, anchor-chain enforcement, slash commands, budget linting).

The two essays overlap in three places (description format, `skill-author`
upgrades, `plan-executor` upgrades). This plan resolves those overlaps with
a deliberate sequence: **trim first → establish format → formalize testing
→ add new skills in the new format → upgrade existing skills → enforce.**

Width is wide; tasks are tight. Quality-check audit gates between phases are
critical — each gate re-measures, smoke-tests, and surfaces any regression
before the next phase starts.

## Sequencing (and why)

| Phase | What | Why this order |
|---|---|---|
| 0 — Discovery | Baseline measurements + cross-ref map | Need before/after numbers to verify each PR's effect |
| 1 — CLAUDE.md trims | Extract 3 reference-shaped sections | Always-loaded baseline drops first; biggest per-session win, simplest extraction |
| 2 — Heavy SKILL.md trims | Move templates/code-blocks to references/ + examples/ | Establishes the references/ pattern at scale before new skills are written |
| 3 — Description format conventions | Spec the new format, then rewrite all 20 descriptions | New skills (Phase 5/6) ship in the new format from day one |
| 4 — Pressure-test methodology | Formalize skill testing in `skill-author` | New discipline skills must be testable when they land |
| 5 — Discipline skills | systematic-debugging, verification, TDD, design-before-code | Highest behavioral leverage; pressure-tested individually |
| 6 — Ritual skills | using-homebrew-skills, code-review (×2), finishing-a-branch | Fills the remaining superpowers parity gap |
| 7 — Existing-skill upgrades | plan-executor task-quality gate; anchor-chain nudges | Reach into mature skills only after their format is settled |
| 8 — Ergonomics & enforcement | Slash commands, budget linter, dedup check, mantra check | Tooling that locks in the gains |
| 9 — Closeout | Mark essays resolved; final umbrella PR; MAJOR tag | Durable record of completion |

## Scope

### Files to create

**References (extracted from CLAUDE.md, Phase 1):**
- `~/dotfiles/claude/.claude/references/sidecar-conventions.md`
- `~/dotfiles/claude/.claude/references/artifact-classes.md`

**References (extracted from heavy SKILL.md files, Phase 2):**
- `~/dotfiles/claude/.claude/references/plan-generation.md`
- `~/dotfiles/claude/.claude/references/plan-failure-handling.md`
- `~/dotfiles/claude/.claude/references/audit-report-template.md`
- `~/dotfiles/claude/.claude/references/skill-authoring-guide.md`
- `~/dotfiles/claude/.claude/references/description-format.md` (Phase 3)
- `~/dotfiles/claude/.claude/references/skill-pressure-testing.md` (Phase 4)

**Specialist examples (Phase 2):**
- `~/dotfiles/claude/.claude/skills/web-audio-howler/examples/audio-engine.example.ts`
- `~/dotfiles/claude/.claude/skills/web-audio-howler/examples/mediasession.example.ts`
- `~/dotfiles/claude/.claude/skills/nextjs-app-router/patterns/bff-proxy.example.ts`
- `~/dotfiles/claude/.claude/skills/nextjs-app-router/patterns/hydration.example.tsx`
- `~/dotfiles/claude/.claude/skills/nextjs-app-router/patterns/theme-cookie.example.ts`
- `~/dotfiles/claude/.claude/skills/turborepo-patterns/examples/turbo.json.example`
- `~/dotfiles/claude/.claude/skills/turborepo-patterns/examples/vercel-ignore.sh`
- `~/dotfiles/claude/.claude/skills/astro-static-sites/examples/content-collections.example.ts`
- `~/dotfiles/claude/.claude/skills/astro-static-sites/examples/view-transitions.example.astro`
- `~/dotfiles/claude/.claude/skills/royalty-splits-music/examples/types.example.ts`

**New skills (Phase 5–6):**
- `~/dotfiles/claude/.claude/skills/systematic-debugging/SKILL.md`
- `~/dotfiles/claude/.claude/skills/verification-before-completion/SKILL.md`
- `~/dotfiles/claude/.claude/skills/test-driven-development/SKILL.md`
- `~/dotfiles/claude/.claude/skills/design-before-code/SKILL.md`
- `~/dotfiles/claude/.claude/skills/using-homebrew-skills/SKILL.md`
- `~/dotfiles/claude/.claude/skills/receiving-code-review/SKILL.md`
- `~/dotfiles/claude/.claude/skills/requesting-code-review/SKILL.md`
- `~/dotfiles/claude/.claude/skills/finishing-a-branch/SKILL.md`

**Optional new agent (Phase 4):**
- `~/dotfiles/claude/.claude/agents/skill-pressure-tester.md` (if methodology lands as an agent rather than inline procedure)

**Slash commands plugin (Phase 8):**
- `~/dotfiles/claude/.claude/commands/<commands-plugin>/...` (final shape decided in Task 33; layout follows existing `commit-commands` plugin)

**Tooling (Phase 8):**
- `~/dotfiles/claude/.claude/tools/skill-budget-lint.sh` (or similar; pre-commit hook script)

### Files to modify

**Always-loaded (Phase 1):**
- `~/dotfiles/claude/.claude/CLAUDE.md` — strip sidecar conventions, artifact-class detail, embedded environment map; replace each with a short pointer-stub

**Heavy SKILL.md trims (Phase 2):**
- `~/dotfiles/claude/.claude/skills/plan-executor/SKILL.md` (19k → ~9k)
- `~/dotfiles/claude/.claude/skills/plan-auditor/SKILL.md` (11k → ~6k)
- `~/dotfiles/claude/.claude/skills/skill-author/SKILL.md` (10k → ~5k, then re-augmented in Phase 4)
- `~/dotfiles/claude/.claude/skills/web-audio-howler/SKILL.md`
- `~/dotfiles/claude/.claude/skills/nextjs-app-router/SKILL.md`
- `~/dotfiles/claude/.claude/skills/turborepo-patterns/SKILL.md`
- `~/dotfiles/claude/.claude/skills/astro-static-sites/SKILL.md`
- `~/dotfiles/claude/.claude/skills/royalty-splits-music/SKILL.md`

**Description rewrites (Phase 3):**
- All 20 SKILL.md files' YAML frontmatter — `description:` field rewritten in trigger-only, "Use when…" form, ≤1024 chars

**Existing skill upgrades (Phase 7):**
- `~/dotfiles/claude/.claude/skills/plan-executor/SKILL.md` — task-quality gate in Phase 1, anchor-chain nudge in Phase 0
- `~/dotfiles/claude/.claude/agents/plan-executor-implementer.md` — reject under-specified tasks back to orchestrator
- `~/dotfiles/claude/.claude/skills/essay/SKILL.md` — anchor-chain nudge on Resolve

**Closeout (Phase 9):**
- `~/dotfiles/claude/.claude/essays/skill-system-token-efficiency-audit.md` — `status: resolved`, real measured savings filled in
- `~/dotfiles/claude/.claude/essays/skill-system-vs-superpowers.md` — `status: resolved`
- Both essays: `anchors.produced` populated with this plan's path

### Out of scope (deferred follow-ups)

- **Project-CLAUDE.md audit (#9 P3.4).** Project-local CLAUDE.md files in
  MusicPortfolio, ContentAutomatorWeb, etc. likely add 5–15k bytes per session
  in those repos. Per-project work, requires PRs into those repos. Track as a
  follow-up plan in each affected repo, using this plan as the template.
- **Full mantra refactor.** Mantra files at `~/.claude/mantras/*.md` total
  ~10k bytes; the CLAUDE.md inline section is ~1.7k. Phase 8 verifies they
  aren't double-loaded but does not restructure them.
- **`dispatching-parallel-agents` skill.** Local plan-executor is sequential
  by design. Adding this skill is not a regression to address — it is a
  separate architectural decision.
- **Full superpowers import via plugin install.** Cherry-picking patterns
  is the correct strategy per essay #8's non-goals.

## Branching, PRs, and tagging

**Cadence: per-phase PR into `main` on one persistent execution branch.**
Refined after Phase 1: the user merged Phase 1 via PR #11, establishing
that phases ship into `main` at audit-PASS boundaries. The same execution
branch is fast-forwarded from `main` between phases and continues to carry
subsequent phase work.

- **Execution branch:** `claude/skills-trim-and-discipline`. Reused
  across all phases. After each phase PR merges, the branch is
  fast-forwarded from `origin/main` and the next phase's commits land
  on it.
- **Within the branch:** Each task gets its own commit (per-task
  surgical reverts, clean history). Audit-gate tasks also commit their
  audit report under `audits/`.
- **Phase MINOR tags on the audit-gate commit.** When a phase's audit
  passes, tag the audit-gate commit (the last commit of the phase)
  with the next MINOR (v2.5 placed on Phase 1's audit commit; v2.6
  for Phase 2; …). Push tag to origin.
- **Phase PR cadence.** After the audit PASS and tag are in place,
  open a PR from `claude/skills-trim-and-discipline → main`. The user
  merges. Branch is then ff-synced with `origin/main` for the next
  phase. **8 phase PRs total** (Phases 1–8).
- **No GitHub releases mid-plan.** Phase MINORs are tags only. Release
  is created at v3.0 from the cumulative work.
- **Final closeout PR (Phase 9 / Task 38):** The closeout commit
  (essay resolutions + Measured outcome appended to essay #9) opens
  the final PR. Body lists every phase MINOR tag with a one-line
  description plus the measured outcome and links to the two source
  essays. **The user merges this PR manually.**
- **MAJOR tag at closeout:** Place v3.0 on the closeout commit before
  the closeout-PR merge (or immediately after; tags reference commits,
  not branches). After the user merges, the user creates the GitHub
  release against v3.0. The agent does NOT create the release.

> **Decision history.** The original plan called for a single
> branch + one umbrella PR. That collapsed to per-phase merges
> after Phase 1 because `main` advancing at audit boundaries makes
> each phase a discrete reviewable unit and matches the auto-tag-on-main
> convention's intent: each landed change earns a tag.

### Tag-bump summary

| Stage | Tag | PR |
|---|---|---|
| Setup PR merged | v2.4 (placed) | #10 (merged) |
| Phase 1 audit PASS | v2.5 (placed) | #11 (merged) |
| Phase 2 audit PASS | v2.6 | per-phase PR |
| Phase 3 audit PASS | v2.7 | per-phase PR |
| Phase 4 audit PASS | v2.8 | per-phase PR |
| Phase 5 audit PASS | v2.9 | per-phase PR |
| Phase 6 audit PASS | v2.10 | per-phase PR |
| Phase 7 complete (no gate; audit folds into Phase 8) | v2.11 | per-phase PR |
| Phase 8 audit PASS | v2.12 | per-phase PR |
| Phase 9 closeout commit | **v3.0** (before merge) | closeout PR |
| **Total** | **8 MINOR + 1 MAJOR** placed during execution | **8 phase PRs + 1 closeout** |

### Audit gates

Tasks 04, 13, 18, 20, 25, 30, 37 are audit gates. Each produces a
report under `.claude/plans/skills-trim-and-discipline/audits/` (now
tracked in git per the gitignore exemption) and commits the report on
the same branch as its preceding implementing tasks. `plan-auditor`
is invoked as a standalone skill between phases; the user (or
plan-executor on demand) triggers it. The audit verdict gates the
phase MINOR tag — PASS → place tag, continue. PARTIAL/FAIL → halt and
surface to user before continuing.

### Per-task "Commit / PR" sections

Each task file's "Commit / PR" section describes the **commit** content
(message, scope). Under single-branch execution, all commits aggregate
into the umbrella PR; the per-task PR target listed in each task file
is shorthand for "lands in the umbrella PR that targets `main`." Task
content, sequencing, and audit gates are unchanged; only the PR
boundary differs.

### Audit report tracking

Because the gitignore exemption makes
`.claude/plans/skills-trim-and-discipline/` tracked, audit reports
written under `audits/` are committed alongside the implementing tasks
of the phase they validate. The audit-gate commit is conventionally
the last commit of a phase, so the MINOR tag is placed on the audit
commit (or on the last implementing commit if the audit phase has
no gate, e.g., Phase 7).

## Constraints

- **Stow discipline.** Every new file under `claude/.claude/` must be stowed
  immediately and verified with `ls -la ~/.claude/<path>` before commit.
  Removed paths require `stow -R claude`. Never create symlinks manually.
- **One commit per task.** Commit messages follow the github skill's
  conventions and include the `Plan: skills-trim-and-discipline` and
  `Task: NN` footers (see `~/.claude/skills/github/SKILL.md`).
- **No hook bypass.** Never `--no-verify`, `--no-gpg-sign`, or amend a pushed
  commit. If a hook fails, fix the cause; commit anew.
- **Quality gates are non-skippable.** A failed audit gate halts the plan;
  user decides remediation (fix-and-continue, descope, defer).
- **No batching of new-skill PRs.** Discipline and ritual skills (Phases 5
  and 6) ship one PR per skill — pressure language and descriptions need
  per-skill iteration; bundling defeats the review surface.
- **Re-measure after every trim.** Phase 1, 2, 3, 8 audit gates run
  `wc -c` over the affected files and record the actual delta in the audit
  report. Estimates from the source essays are projections, not truth.
- **Smoke-test cold sessions.** After Phase 3, after Phase 5, and at the
  Phase 8 final audit, open a fresh Claude Code session and ask a generic
  question; observe context utilization. Document the observation in the
  audit report.
- **No regression of system strengths.** The six-class artifact taxonomy,
  anchor chain, sidecar conventions, mantras, anchored-doc staleness, and
  worktree-orchestrator's never-auto-merge stance are load-bearing. Phase 1
  trims their *prose location*, not their *operational meaning*.

## Key decisions (do not re-litigate)

- **Sequencing.** Trim before add. Cold-session win lands first; new bodies
  do not bloat the still-fat baseline. (User-confirmed; alternative — add
  discipline skills first — was rejected.)
- **Pressure-test methodology before discipline skills.** Phase 4 lands
  before Phase 5 so the four discipline skills are testable when they ship,
  not retrofitted later. (User-confirmed; reverses the order in essay #8.)
- **No worktree.** Special case for dotfiles. Branch lives on `main`'s
  working copy. (User direction.)
- **Audit gates as explicit tasks.** Eight phase gates produce reports under
  `audits/` and are non-skippable. Quality is critical at this width.
- **Each sub-PR targets `main`, not the feature branch.** Sub-PRs merge
  independently and accrue MINOR tags. The umbrella PR is the closer.
- **Project-CLAUDE.md audits are deferred.** Out of scope for this dotfiles
  plan; tracked as future per-project follow-ups.
- **References pattern, not skill-splitting.** Heavy domain specialists keep
  their monolithic SKILL.md (description-cost would rise if split); their
  bulk moves into sibling reference/example files.
- **Description trimming preserves keyword pool.** Activation recall depends
  on keyword density. Trim *prose and pre-summarized workflow*, keep keywords.

## Task index

| # | Phase | File | Summary | Agent | PR? |
|---|---|---|---|---|---|
| 00 | 0 | tasks/00-discovery.md | Baseline measurements + cross-ref graph + working-tree precheck | discovery | no |
| 01 | 1 | tasks/01-extract-sidecars-to-reference.md | Move sidecar conventions to `references/sidecar-conventions.md`; CLAUDE.md keeps stub | implementer | yes |
| 02 | 1 | tasks/02-extract-artifact-classes-to-reference.md | Move artifact-classes detail to `references/artifact-classes.md`; CLAUDE.md keeps stub | implementer | yes |
| 03 | 1 | tasks/03-strip-environment-map-from-claude-md.md | Strip embedded host/repo tables from CLAUDE.md; pointer-only | implementer | yes |
| 04 | 1 | tasks/04-audit-claude-md-trim.md | Re-measure CLAUDE.md; verify ~9k saved; cold-session smoke | auditor | gate |
| 05 | 2 | tasks/05-trim-plan-executor.md | Move plan-generation, failure-handling, state-schema to references/ | implementer | yes |
| 06 | 2 | tasks/06-trim-plan-auditor.md | Move audit-report template to `references/audit-report-template.md` | implementer | yes |
| 07 | 2 | tasks/07-trim-skill-author.md | Move authoring-guide content to `references/skill-authoring-guide.md` (pre-Phase-4 trim) | implementer | yes |
| 08 | 2 | tasks/08-extract-web-audio-howler-examples.md | Move audio-engine + MediaSession code to `examples/` | implementer | yes |
| 09 | 2 | tasks/09-extract-nextjs-app-router-patterns.md | Move BFF, hydration, theme-cookie examples to `patterns/` | implementer | yes |
| 10 | 2 | tasks/10-extract-turborepo-patterns-examples.md | Move turbo.json + vercel-ignore to `examples/` | implementer | yes |
| 11 | 2 | tasks/11-extract-astro-static-sites-examples.md | Move collections + transitions examples to `examples/` | implementer | yes |
| 12 | 2 | tasks/12-extract-royalty-splits-music-examples.md | Move TS types + bulk-replace example to `examples/` | implementer | yes |
| 13 | 2 | tasks/13-audit-skill-trims.md | Re-measure all 8 trimmed SKILL.md; verify reference loading via grep | auditor | gate |
| 14 | 3 | tasks/14-establish-description-format-spec.md | Write `references/description-format.md`; cite from `skill-author` | implementer | yes |
| 15 | 3 | tasks/15-rewrite-workflow-descriptions.md | Rewrite descriptions for the 8 workflow/discipline skills | implementer | yes |
| 16 | 3 | tasks/16-rewrite-capture-descriptions.md | Rewrite descriptions for the 4 capture/knowledge skills | implementer | yes |
| 17 | 3 | tasks/17-rewrite-specialist-descriptions.md | Rewrite descriptions for the 8 domain specialists | implementer | yes |
| 18 | 3 | tasks/18-audit-descriptions-and-cold-session.md | Re-measure description bytes; cold-session smoke; per-class budget pre-check | auditor | gate |
| 19 | 4 | tasks/19-pressure-test-methodology.md | Add pressure-test methodology to `skill-author` + `references/skill-pressure-testing.md` (+ optional agent) | implementer | yes |
| 20 | 4 | tasks/20-audit-pressure-test.md | Verify methodology is runnable on a control fixture | auditor | gate |
| 21 | 5 | tasks/21-systematic-debugging.md | Create `systematic-debugging` skill; pressure-test before commit | implementer | yes |
| 22 | 5 | tasks/22-verification-before-completion.md | Create `verification-before-completion` skill; pressure-test | implementer | yes |
| 23 | 5 | tasks/23-test-driven-development.md | Create `test-driven-development` skill; pressure-test | implementer | yes |
| 24 | 5 | tasks/24-design-before-code.md | Create `design-before-code` skill; pressure-test | implementer | yes |
| 25 | 5 | tasks/25-audit-discipline-skills.md | Verify 4 new skills present + activation triggers + budget compliance | auditor | gate |
| 26 | 6 | tasks/26-using-homebrew-skills.md | Create `using-homebrew-skills` meta-skill (rationalization table) | implementer | yes |
| 27 | 6 | tasks/27-receiving-code-review.md | Create `receiving-code-review` skill (6-step protocol, no-sycophancy) | implementer | yes |
| 28 | 6 | tasks/28-requesting-code-review.md | Create `requesting-code-review` skill | implementer | yes |
| 29 | 6 | tasks/29-finishing-a-branch.md | Create `finishing-a-branch` skill (defers to plan-executor when active) | implementer | yes |
| 30 | 6 | tasks/30-audit-ritual-skills.md | Verify 4 new skills + cross-references + budget compliance | auditor | gate |
| 31 | 7 | tasks/31-plan-executor-task-quality-gate.md | Add Phase-1 task-quality gate; update implementer agent to reject vague tasks | implementer | yes |
| 32 | 7 | tasks/32-anchor-chain-nudges.md | Add anchor-chain soft warnings to plan-executor Phase 0 + essay Resolve mode | implementer | yes |
| 33 | 8 | tasks/33-slash-commands-plugin.md | Create commands plugin: `/zoom-in`, `/zoom-out`, `/session-ready`, `/sweep`, `/audit-task` | implementer | yes |
| 34 | 8 | tasks/34-budget-enforcement-script.md | Per-class budget linter (pre-commit hook) | implementer | yes |
| 35 | 8 | tasks/35-cross-reference-dedup-check.md | Verify shared references load once per session, not per cross-ref | discovery | yes |
| 36 | 8 | tasks/36-lazy-mantra-expansion-check.md | Verify mantras aren't double-loaded; document the loading model | discovery | yes |
| 37 | 8 | tasks/37-audit-final-measurement.md | Full re-measurement vs essay #9's projection table; cold-session smoke; compound scenarios | auditor | gate |
| 38 | 9 | tasks/38-essays-resolved-and-final-pr.md | Mark both essays `status: resolved`; populate `anchors.produced`; open umbrella PR; MAJOR tag after merge | documenter | yes |

Tasks for this plan: `~/dotfiles/.claude/plans/skills-trim-and-discipline/tasks/`
Audits for this plan: `~/dotfiles/.claude/plans/skills-trim-and-discipline/audits/`

## Validation strategy

After each implementing PR:
1. `wc -c` over the affected file(s); record before/after in PR description.
2. `stow --simulate -d ~/dotfiles -t ~ claude` shows no conflicts.
3. `ls -la ~/.claude/<new-or-moved-path>` shows a symlink, not a real file.
4. New SKILL.md activations: open a fresh session, type the canonical
   trigger phrase, observe the skill loads.

After each audit gate:
1. Re-run the cumulative `wc -c` measurement vs Phase 0 baseline.
2. Update the running savings table in the audit report.
3. Compare against essay #9's projection (Compound savings projection table).
4. Smoke-test the affected scenarios where applicable (cold session,
   plan-executor activation, doc-audit session).
5. If projection-vs-actual diverges by >25%, halt and surface the gap.

At plan completion (Task 38):
1. Recompute essay #9's full Compound-savings projection table with real
   numbers.
2. Append to essay #9 a "Measured outcome" section documenting actual
   savings and any items that fell short.
3. Mark both essays `status: resolved` (or `superseded` if a deeper rewrite
   was forced).
4. Update `anchors.produced` on both essays to point at this plan.

## Phase-8 follow-ups (carry-forward)

Tracked across audits. **Phase 8 / Task 37 (final audit) MUST surface
each item; Task 38 (umbrella PR) MUST list any unresolved items in the
PR body so they don't get lost.**

| # | Source | Item | Priority |
|---|---|---|---|
| 1 | Task 13 audit | Prose-pruning for `nextjs-app-router` body (~+2,041 B over [≤6,500 B] specialist body budget) | high |
| 2 | Task 13 audit | Prose-pruning for `turborepo-patterns` body (~+1,024 B) | high |
| 3 | Task 13 audit | Prose-pruning for `royalty-splits-music` body (~+1,104 B) | high |
| 4 | Task 18 audit | Prose-pruning for `ddex-standards` body (~+3,062 B; not in Phase-2 trim list) | high |
| 5 | Task 13 audit | Prose-pruning for `plan-executor` body (~+502 B over [≤8,500 B] workflow budget) | medium |
| 6 | Tasks 04/13/18/25 audits | Cold-session smoke test (deferred 4 times); single user-run check covers all gates | medium |
| 7 | **Task 25 audit (Phase 5)** | **Re-run RED dispatches for all 4 discipline skills** (`systematic-debugging`, `verification-before-completion`, `test-driven-development`, `design-before-code`) **with real orchestrator-scope sub-agent dispatch.** Current rationalizations are hypothetical-labeled (representative but not empirical). Iterate skill bodies if new rationalizations surface. **User-confirmed Phase-8 work, not blocking Phase 6.** | high |
| 8 | Task 18 audit | YAML quoting sweep across project-local skill dirs (any unquoted descriptions with colons should be fixed) | low |

These are non-blocking for plan progression. Items 1–5 + 7 should land
as discrete Phase-8 sub-tasks. Item 6 is a manual user check. Item 8 is
a one-time grep.

---

## Failure handling

Per `~/.claude/skills/plan-executor/SKILL.md`'s stop-and-ask policy:
- Trivial failures (typo in moved file, broken stow link) → fix in the
  task and continue.
- Non-trivial failures (audit gate fails projection by >25%, skill fails
  to activate, smoke-test reveals regression) → halt; produce a failure
  report under `audits/`; user decides remediation.
- A failed Phase-1 audit (CLAUDE.md trim) is the highest-stakes failure —
  it gates everything else. Do not proceed to Phase 2 without resolution.
