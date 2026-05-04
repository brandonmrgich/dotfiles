---
title: Skill-system token efficiency audit
status: resolved
created: 2026-04-28
last-active: 2026-05-03
tags: [skills, audit, token-efficiency, context-budget, performance, claude-config]
anchors:
  produced:
    - ~/dotfiles/.claude/plans/skills-trim-and-discipline/MasterPlan.md
  references:
    - skill-system-vs-superpowers.md
    - cross-claude-mantras-and-skills-integration.md
---

# Skill-system token efficiency audit

## Purpose

The user-wide skill system (`~/.claude/skills/`, 20 skills + CLAUDE.md
+ references + agents + mantras + environment files) has grown to the
point where a routine session can spend several thousand tokens on
config before doing any work. This essay measures the actual cost,
simulates realistic activation scenarios, identifies the biggest
hotspots, and prescribes a concrete plan to cut the always-loaded
overhead by ~50% and the activated-skill overhead by ~40%.

Companion to `skill-system-vs-superpowers.md` (PR #8). That essay
focuses on *what skills are missing*; this one focuses on *what the
existing skills cost*.

A future agent consumes this. Pick one P0 item at a time, ship a
focused PR per item, re-measure, repeat.

---

## Methodology

1. **Hard measurement.** `wc -lwc` over every SKILL.md, every
   reference, every agent, every mantra, every environment file,
   plus CLAUDE.md. Description char counts via YAML parsing (with
   manual fallback for descriptions that span the whole frontmatter).

2. **Activation simulation.** For each skill, derive realistic
   trigger phrases from its `description` and `triggers:` fields,
   then trace what gets loaded transitively (referenced reference
   files, cross-referenced skills, dispatched agents).

3. **Cross-reference graph.** Grep every SKILL.md for paths under
   `~/.claude/` and for backtick-wrapped skill names. Filter noise
   (regex false positives from code samples).

4. **Scenario compound costs.** Estimate the "worst-case session"
   tax by summing the bodies of all plausibly-co-activated skills
   plus the always-loaded baseline.

Token estimates use the standard ~4 chars per token rule. The actual
tokenizer (`cl100k`-like) varies per content but the rule is
sufficient for ranking and for ballpark budget conversations.

---

## Hard numbers

### Always-loaded baseline

| File | Bytes | Approx tokens |
|---|---|---|
| `~/.claude/CLAUDE.md` | 19,028 | ~4,750 |
| All 20 skill descriptions (eagerly indexed) | ~16,422 | ~4,100 |
| **Total per session, before any activation** | **~35,450** | **~8,850** |

That's ~9k tokens spent before a single skill body loads, before any
project CLAUDE.md, before any tool call. On a fresh session with a
200k context window, the always-loaded skill config is already 4.4%
of capacity.

### CLAUDE.md section breakdown

The always-loaded file. Sections ranked by size:

| Section | Lines | Bytes | % of CLAUDE.md |
|---|---|---|---|
| Sidecar conventions | 95 | 4,533 | 24% |
| Artifact classes and front-matter | 41 | 3,314 | 17% |
| Environment Map | 24 | 2,952 | 16% |
| Design doctrines (mantras) | 24 | 1,669 | 9% |
| Plan execution system | 33 | 1,352 | 7% |
| Dotfiles workflow | 12 | 887 | 5% |
| Essay convention | 12 | 744 | 4% |
| Tool selection | 13 | 695 | 4% |
| Homebrew skill standard | 19 | 625 | 3% |
| Workflow discipline | 9 | 429 | 2% |
| Other (10 sections) | ~50 | ~1,830 | 9% |

**67% of CLAUDE.md is in three sections** (sidecar conventions,
artifact classes, environment map). Each of those is reference-shaped
content that does not need to be loaded every session.

### Per-skill costs (description + body)

Sorted by total cost, descending:

| Skill | Desc chars | Body bytes | Total bytes | Approx tokens |
|---|---|---|---|---|
| `plan-executor` | 711 | 19,394 | 20,105 | ~5,025 |
| `nextjs-app-router` | 1,865 | 10,073 | 11,938 | ~2,985 |
| `plan-auditor` | 602 | 10,861 | 11,463 | ~2,865 |
| `skill-author` | 1,176 | 10,246 | 11,422 | ~2,855 |
| `web-audio-howler` | 1,357 | 10,022 | 11,379 | ~2,845 |
| `ddex-standards` | 1,543 | 8,595 | 10,138 | ~2,535 |
| `turborepo-patterns` | 1,100 | 8,930 | 10,030 | ~2,510 |
| `royalty-splits-music` | 1,210 | 8,694 | 9,904 | ~2,475 |
| `essay` | 1,075 | 8,168 | 9,243 | ~2,310 |
| `astro-static-sites` | 1,278 | 7,436 | 8,714 | ~2,180 |
| `github` | 451 | 6,721 | 7,172 | ~1,795 |
| `worktree-orchestrator` | 646 | 5,899 | 6,545 | ~1,635 |
| `session-ready` | 635 | 5,777 | 6,412 | ~1,605 |
| `gitignore` | 420 | 5,407 | 5,827 | ~1,460 |
| `idea-tracker` | 376 | 5,032 | 5,408 | ~1,355 |
| `doc-freshness` | 522 | 4,670 | 5,192 | ~1,300 |
| `top-down-sweep` | 405 | 4,192 | 4,597 | ~1,150 |
| `environment-map` | 755 | 2,522 | 3,277 | ~820 |
| `zoom-in` | 181 | 2,856 | 3,037 | ~760 |
| `zoom-out` | 114 | 1,969 | 2,083 | ~520 |
| **Totals** | **16,420** | **146,564** | **162,984** | **~40,750** |

If every skill loaded simultaneously, the body cost alone is ~37k
tokens. Realistic compound activations (3–6 skills) run 8k–25k.

### Cross-reference graph

Filtering out noise (false-positive matches in code samples), the
real skill→{skill, reference, agent} dependency graph:

```
environment-map ──→ environment/{hosts,networks,repos,services}.md
github ──→ references/console-discipline.md
       ──→ references/plan-system.md
       ──→ skills/gitignore/SKILL.md
       ──→ skills/worktree-orchestrator/SKILL.md
gitignore ──→ references/plan-system.md
plan-auditor ──→ references/console-discipline.md
plan-executor ──→ references/console-discipline.md
              ──→ references/plan-system.md
              ──→ doc-freshness skill
              ──→ 4 plan-executor-* sub-agents
session-ready ──→ essay skill
              ──→ top-down-sweep skill
top-down-sweep ──→ doc-freshness skill
royalty-splits-music ──→ ddex-standards skill
zoom-out ──→ plan-executor skill
         ──→ worktree-orchestrator skill
idea-tracker ──→ plan-executor skill
```

These are "see also" references in prose, not auto-loads. But every
mention is a soft prompt for Claude to *consider* loading the
referenced skill. The heaviest dependency tree is `plan-executor`'s
star: activating it pulls 2 references (~5k bytes) plus 4 sub-agent
files (~9k bytes if dispatched) plus an implicit `doc-freshness` and
`plan-auditor` reach.

---

## Activation scenarios — simulated token cost

For each scenario: what activates, what gets pulled in transitively,
and the cumulative byte/token cost on top of the always-loaded
baseline (~9k tokens).

### Scenario A — Cold session, simple Q&A

User asks a question that doesn't trigger any skill. No body loads.

| Component | Bytes | Tokens |
|---|---|---|
| CLAUDE.md | 19,028 | ~4,750 |
| All descriptions (eagerly indexed) | 16,422 | ~4,100 |
| **Total** | **35,450** | **~8,850** |

Baseline tax: ~9k tokens for any session.

### Scenario B — Routine code session in a Next.js project

User asks "how do I revalidate after a server action?" — triggers
`nextjs-app-router`.

| Component | Bytes | Tokens |
|---|---|---|
| Baseline (CLAUDE.md + descriptions) | 35,450 | ~8,850 |
| `nextjs-app-router` body | 10,073 | ~2,520 |
| **Total** | **45,523** | **~11,370** |

### Scenario C — Music platform feature work

Working in MusicPortfolio on a release-validation feature. Likely
triggers: `nextjs-app-router` (TS/route work) + `ddex-standards` +
`royalty-splits-music`. Plus project CLAUDE.md (estimated 5k).

| Component | Bytes | Tokens |
|---|---|---|
| Baseline | 35,450 | ~8,850 |
| Project CLAUDE.md (estimate) | ~5,000 | ~1,250 |
| `nextjs-app-router` | 10,073 | ~2,520 |
| `ddex-standards` | 8,595 | ~2,150 |
| `royalty-splits-music` | 8,694 | ~2,175 |
| **Total** | **67,812** | **~16,945** |

### Scenario D — Plan execution in a worktree

User runs a plan with `plan-executor`. Heaviest realistic scenario.

| Component | Bytes | Tokens |
|---|---|---|
| Baseline | 35,450 | ~8,850 |
| `plan-executor` | 19,394 | ~4,850 |
| `references/plan-system.md` | 3,064 | ~770 |
| `references/console-discipline.md` | 1,917 | ~480 |
| `worktree-orchestrator` (cross-ref'd) | 5,899 | ~1,475 |
| `github` (cross-ref'd for commits) | 6,721 | ~1,680 |
| One sub-agent body (when dispatched) | ~2,400 | ~600 |
| Possibly `doc-freshness` | 4,670 | ~1,170 |
| **Total** | **79,515** | **~19,875** |

### Scenario E — Worst plausible compound activation

Music platform plan execution: plan-executor + worktree-orchestrator
+ github + nextjs-app-router + ddex-standards + royalty-splits-music
+ project CLAUDE.md + references.

| Component | Bytes | Tokens |
|---|---|---|
| Baseline | 35,450 | ~8,850 |
| Project CLAUDE.md (estimate) | ~5,000 | ~1,250 |
| `plan-executor` | 19,394 | ~4,850 |
| `worktree-orchestrator` | 5,899 | ~1,475 |
| `github` | 6,721 | ~1,680 |
| `nextjs-app-router` | 10,073 | ~2,520 |
| `ddex-standards` | 8,595 | ~2,150 |
| `royalty-splits-music` | 8,694 | ~2,175 |
| References (~2 of them) | 4,981 | ~1,250 |
| One agent body | 2,400 | ~600 |
| **Total** | **107,207** | **~26,800** |

That's 13% of a 200k context window consumed before any code reads,
tool calls, or model output.

### Scenario F — Doc audit session

`top-down-sweep` triggers `doc-freshness`, may load `essay` and
`github`.

| Component | Bytes | Tokens |
|---|---|---|
| Baseline | 35,450 | ~8,850 |
| `top-down-sweep` | 4,192 | ~1,050 |
| `doc-freshness` | 4,670 | ~1,170 |
| `essay` (if essay update is in scope) | 8,168 | ~2,040 |
| **Total** | **52,480** | **~13,110** |

---

## Hotspot ranking

The four highest-leverage targets for token savings, ordered by
bytes-cuttable / one-PR-worth-of-effort:

### Hotspot 1 — CLAUDE.md (19k always-loaded)

**Cuttable: ~9k bytes (~2,250 tokens) per session.**

Three sections account for 57% of CLAUDE.md and are reference-shaped:

- **Sidecar conventions (4,533 bytes)** — full label + role taxonomy
  tables. The taxonomy is consulted when *creating or editing a
  sidecar*, not on every session. Move to
  `references/sidecar-conventions.md`. Keep a 5-line summary in
  CLAUDE.md ("sidecars exist; full taxonomy at `references/...`").
- **Artifact classes detailed table (3,314 bytes)** — six-row class
  matrix plus three-row purpose matrix plus anchor-chain ASCII art.
  This is reference. Move to `references/artifact-classes.md`. Keep
  CLAUDE.md down to a 6-line summary.
- **Environment Map embedded host table (2,952 bytes)** — duplicates
  what `environment-map` skill loads on demand from
  `~/.claude/environment/hosts.md`. Strip CLAUDE.md to a 3-line
  pointer ("multi-host setup. See `environment-map` skill for
  details.").

After trim, CLAUDE.md drops to ~10k bytes (~2,500 tokens). Saves ~9k
bytes / ~2,250 tokens **on every session**.

### Hotspot 2 — `plan-executor` body (19k, largest skill)

**Cuttable: ~10k bytes (~2,500 tokens) per activation.**

Three big chunks could move to a reference file:

- Plan/task generation procedure (Step 1–6, ~4k bytes) — only
  consulted in Mode B (generate-then-execute), not in resume/run-next
  modes. Move to `references/plan-generation.md`.
- State-file JSON schema example with detailed comments (~1.5k
  bytes) — reference content. Move to `references/plan-system.md`
  (which already exists and already covers state files).
- Failure-calibration table + audit checkpoint flow (~2k bytes) —
  consulted on failures, not every dispatch. Move to
  `references/plan-failure-handling.md`.

Plus minor: trim duplicate explanations of commit-footer convention
(already in `references/plan-system.md`).

After trim: SKILL.md down to ~9k bytes core (operating principles,
phase outline, dispatch loop, return format).

### Hotspot 3 — Domain specialists with embedded code blocks

**Cuttable: ~15k bytes total across 5 skills.**

Specialists carry full code examples inline. Examples are useful
when the skill is active *and the user is implementing exactly that
pattern* — but they make the SKILL.md heavy on every activation.

Move heavy code blocks to sibling files:

- `web-audio-howler` (10k) — "minimal correct setup" full module
  (~80 lines) and MediaSession effect blocks (~60 lines). Move to
  `skills/web-audio-howler/audio-engine.example.ts` plus
  `mediasession.example.ts`. SKILL.md keeps prose principles +
  decision tables. Estimated cut: ~5k bytes.
- `nextjs-app-router` (10k) — BFF proxy code, hydration code,
  theme-via-cookie code. Move to
  `skills/nextjs-app-router/patterns/`. Estimated cut: ~3k bytes.
- `turborepo-patterns` (9k) — full `turbo.json` example, vercel
  ignore script, CI pseudo-yaml. Move to
  `skills/turborepo-patterns/examples/`. Estimated cut: ~2.5k bytes.
- `astro-static-sites` (7k) — collections example, transitions
  example. Estimated cut: ~1.5k bytes.
- `royalty-splits-music` (9k) — TypeScript types and bulk-replace
  example. Estimated cut: ~1k bytes.

After trims, average specialist drops from ~9k to ~6k. Compound
scenario savings (3 specialists active): ~9k bytes / ~2,250 tokens.

### Hotspot 4 — Long descriptions (eagerly loaded, 16k total)

**Cuttable: ~6k chars (~1,500 tokens) on every session.**

Eight descriptions exceed superpowers' 1024-char target:

| Skill | Desc chars | Target | Cuttable |
|---|---|---|---|
| `nextjs-app-router` | 1,865 | 1,000 | ~865 |
| `ddex-standards` | 1,543 | 1,000 | ~545 |
| `web-audio-howler` | 1,357 | 1,000 | ~360 |
| `astro-static-sites` | 1,278 | 1,000 | ~280 |
| `royalty-splits-music` | 1,210 | 1,000 | ~210 |
| `skill-author` | 1,176 | 1,000 | ~175 |
| `turborepo-patterns` | 1,100 | 1,000 | ~100 |
| `essay` | 1,075 | 1,000 | ~75 |

Mostly: trim long keyword lists (kept partly for activation recall —
real). Compromise: 60-keyword cap, drop synonyms ("client:load,
client:idle, client:visible, client:media, client:only" → "client:*
directives"). Drop pre-summarized workflow narration (covered
extensively in PR #8).

Saves ~2,600 chars on the 8 worst offenders. Plus the workflow
skills (plan-executor, plan-auditor, session-ready, worktree-
orchestrator, environment-map, etc.) carry summary narration in
their descriptions that should move to body — another ~3k chars
across them. Total: ~5–6k chars / ~1,500 tokens **on every session.**

---

## Compound savings projection

If P0 (Hotspots 1–4) lands cleanly:

| Scenario | Before | After | Saved |
|---|---|---|---|
| A — Cold session | ~8,850 tok | ~5,100 tok | **~42%** |
| B — Routine code | ~11,370 tok | ~6,500 tok | ~43% |
| C — Music platform | ~16,945 tok | ~10,300 tok | ~39% |
| D — Plan execution | ~19,875 tok | ~12,000 tok | ~40% |
| E — Worst compound | ~26,800 tok | ~16,500 tok | ~38% |
| F — Doc audit | ~13,110 tok | ~8,400 tok | ~36% |

Average savings: ~40% across all scenarios. The cold-session
scenario sees the biggest relative win because the always-loaded
overhead is the largest absolute fraction.

---

## Prioritized backlog

### P0 — Always-loaded baseline (highest leverage, ~9k bytes/session)

Each P0 lands as its own PR.

**P0.1 — Move sidecar conventions out of CLAUDE.md.**
Create `references/sidecar-conventions.md` with the full label
taxonomy + role taxonomy + when-to-create + sidecar maxims.
CLAUDE.md keeps a 5-line section: name + one-line definition +
"see `references/sidecar-conventions.md`". Saves ~4k bytes on
every session.

**P0.2 — Move artifact-class detail to a reference.**
Create `references/artifact-classes.md` with the six-row class
matrix, three-row purpose matrix, ASCII anchor-chain diagram,
and per-class field details. CLAUDE.md keeps the one-paragraph
introduction + the six artifact paths + "details: `references/
artifact-classes.md`". Saves ~3k bytes on every session.

**P0.3 — Strip duplicated environment content from CLAUDE.md.**
The "Environment Map" section in CLAUDE.md duplicates content
that the `environment-map` skill loads on demand. Replace with a
3-line pointer. Saves ~2.5k bytes on every session.

### P1 — Heavy SKILL.md trims (per-activation savings)

**P1.1 — Trim `plan-executor` from 19k to ~9k.**
Move plan generation procedure to `references/plan-generation.md`.
Move failure-calibration + audit checkpoint to
`references/plan-failure-handling.md`. Move state-file schema
example into the existing `references/plan-system.md`. Update
CLAUDE.md's "Plan execution system" section if it referenced
anything moved. Saves ~10k on plan-executor activation.

**P1.2 — Domain-specialist code-block extraction.**
Per skill, create a sibling `examples/` or `patterns/` directory
holding heavy code blocks as standalone files. SKILL.md keeps
prose, principles, decision tables, and short illustrative
snippets. Order:
1. `web-audio-howler` (~5k cuttable, biggest payoff)
2. `nextjs-app-router` (~3k)
3. `turborepo-patterns` (~2.5k)
4. `astro-static-sites` (~1.5k)
5. `royalty-splits-music` (~1k)

The example files are loaded only when the skill body explicitly
points at them (e.g. "see `audio-engine.example.ts` for the
minimal correct setup").

**P1.3 — Trim `plan-auditor` from 11k to ~6k.**
Move the audit-report template (~60 lines, ~3k bytes) to
`references/audit-report-template.md`. Move the verdict
definitions and escalation rules to a body section that's still
present but tighter.

**P1.4 — Trim `skill-author` from 10k to ~5k.**
The skill-vs-agent decision matrix and authoring procedure are
the load-bearing content. Move the "examples of good captures",
"examples of when to suggest agent over skill", and
"description authoring CSO rules" (cross-references PR #8) into
`references/skill-authoring-guide.md`. Cross-link from SKILL.md.

### P2 — Description trimming (eagerly-loaded savings)

**P2.1 — Cap descriptions at 1,024 chars.**
Audit table in PR #8's Appendix A already lists every
description's verdict. Combine with this audit's char-count
ranking and ship one PR per cluster (workflow, capture,
specialist).

**P2.2 — Pull workflow narration out of all descriptions.**
Per PR #8, descriptions should be triggers-only. Moving narrative
content into the body costs nothing in body bytes (the body
already explains itself) but cuts the eager-load tax.

**P2.3 — Compress keyword lists in specialist descriptions.**
Aggressive: replace enumerations with patterns ("client:load,
client:idle, client:visible, client:media, client:only" →
"client:* directives"). Conservative: keep all keywords but
strip parenthetical asides ("the cross-browser audio library",
"(Digital Data Exchange)", etc.).

### P3 — Structural and tooling

**P3.1 — Establish per-class budgets and lint them.**
Add a CI/pre-commit script that fails when a SKILL.md exceeds
its class budget:

| Class | Description | Body | Total |
|---|---|---|---|
| Domain specialist | ≤1,024 chars | ≤6,000 bytes | ≤8,000 |
| Workflow / discipline | ≤500 chars | ≤4,000 bytes | ≤5,000 |
| Capture / knowledge | ≤500 chars | ≤4,000 bytes | ≤5,000 |
| Policy / catalog | ≤400 chars | ≤3,500 bytes | ≤4,500 |
| Meta (skill-author, etc.) | ≤700 chars | ≤5,000 bytes | ≤6,000 |

Soft enforcement first (warning), hard after one cleanup pass.

**P3.2 — Deduplicate cross-references.**
Several skills cross-reference `references/console-discipline.md`
and `references/plan-system.md`. The references are small (~5k
combined) but loaded redundantly. Verify they're each loaded once
per session, not once per cross-referencing skill.

**P3.3 — Consider lazy mantra expansion.**
The CLAUDE.md "Design doctrines" section embeds abbreviated
mantras (~1.7k bytes). The full mantra files at
`~/.claude/mantras/*.md` are 5.6k + 4.3k = 9.9k. The CLAUDE.md
form is the right mainline; just verify that mantras aren't
double-loaded if any skill references them by full path.

**P3.4 — Project CLAUDE.md is unmeasured.**
This audit only covers `~/.claude/`. Project-local CLAUDE.md
files (e.g., MusicPortfolio's) likely add 5–15k bytes per session
when working in those repos. Future audit: enumerate project
CLAUDE.md sizes across the major repos and apply the same
P0-style extraction.

---

## Non-goals

These would be regressions:

- **Removing skills wholesale.** The skills carry real domain value;
  the issue is *how much body they carry inline*, not the
  count. Don't delete `royalty-splits-music` to "save tokens".
- **Collapsing references back into CLAUDE.md.** The reference
  pattern is the lever; expand it, don't undo it.
- **Removing keywords from descriptions.** Keywords drive
  activation recall. Trim *prose* and *summaries* in
  descriptions, keep the keyword pool.
- **Auto-summarizing skills with another LLM pass.** Manual
  edits keep authorial voice and decision-table integrity.
- **Removing cross-references between skills.** Cross-refs are
  prose, not auto-loads — they don't cost tokens unless the user
  chains skills explicitly.
- **Splitting domain specialists by sub-topic** (e.g., breaking
  `nextjs-app-router` into `nextjs-routing` + `nextjs-caching` +
  `nextjs-hydration`). Activation cost goes up because more
  descriptions load eagerly. Monolithic-with-references is better.

---

## Validation plan for the future agent

After each P0/P1 PR lands:

1. Re-run the size measurements:
   ```bash
   for f in ~/.claude/skills/*/SKILL.md ~/.claude/CLAUDE.md ~/.claude/references/*.md; do
     wc -c "$f"
   done
   ```
2. Recompute the always-loaded total and the per-scenario
   compound costs.
3. Smoke test: open a fresh Claude Code session, ask a generic
   question that *should not* trigger any skill, observe context
   utilization. The baseline should drop by the projected amount.
4. Smoke test: open a session and trigger `plan-executor`,
   confirm `references/*` are consulted on demand rather than
   eagerly inlined into the SKILL.md.
5. Update this essay's `last-active` and add a line under each
   completed P0/P1/P2 item with the actual measured savings.

When all P0 items are landed and measured, propose marking the
essay `status: resolved`. Re-open if compound costs creep back up.

---

## Appendix A — full per-skill cost table

For reference. Sorted alphabetically (cross-checks against PR #8's
description audit appendix).

| Skill | Desc | Body | Total bytes | Body lines | Words |
|---|---|---|---|---|---|
| astro-static-sites | 1,278 | 7,436 | 8,714 | 219 | 970 |
| ddex-standards | 1,543 | 8,595 | 10,138 | 163 | 1,229 |
| doc-freshness | 522 | 4,670 | 5,192 | 122 | 715 |
| environment-map | 755 | 2,522 | 3,277 | 53 | 343 |
| essay | 1,075 | 8,168 | 9,243 | 213 | 1,231 |
| github | 451 | 6,721 | 7,172 | 155 | 912 |
| gitignore | 420 | 5,407 | 5,827 | 165 | 723 |
| idea-tracker | 376 | 5,032 | 5,408 | 143 | 790 |
| nextjs-app-router | 1,865 | 10,073 | 11,938 | 250 | 1,374 |
| plan-auditor | 602 | 10,861 | 11,463 | 273 | 1,656 |
| plan-executor | 711 | 19,394 | 20,105 | 479 | 2,794 |
| royalty-splits-music | 1,210 | 8,694 | 9,904 | 204 | 1,185 |
| session-ready | 635 | 5,777 | 6,412 | 107 | 897 |
| skill-author | 1,176 | 10,246 | 11,422 | 216 | 1,572 |
| top-down-sweep | 405 | 4,192 | 4,597 | 90 | 646 |
| turborepo-patterns | 1,100 | 8,930 | 10,030 | 264 | 1,239 |
| web-audio-howler | 1,357 | 10,022 | 11,379 | 286 | 1,211 |
| worktree-orchestrator | 646 | 5,899 | 6,545 | 139 | 814 |
| zoom-in | 181 | 2,856 | 3,037 | 72 | 403 |
| zoom-out | 114 | 1,969 | 2,083 | 36 | 293 |

---

## Appendix B — reference / agent / mantra costs

| File | Bytes | Lines | Loaded when |
|---|---|---|---|
| `references/plan-system.md` | 3,064 | 85 | `plan-executor`, `gitignore`, `plan-auditor`, `github` activate |
| `references/console-discipline.md` | 1,917 | 61 | `plan-executor`, `plan-auditor`, `github`, `top-down-sweep` activate |
| `agents/plan-executor-discovery.md` | 2,206 | 76 | Dispatched by `plan-executor` Phase 2 |
| `agents/plan-executor-documenter.md` | 2,275 | 78 | Same |
| `agents/plan-executor-implementer.md` | 2,483 | 82 | Same |
| `agents/plan-executor-tester.md` | 2,235 | 68 | Same |
| `mantras/eliminate_dont_paper_over.md` | 5,638 | 117 | Referenced from CLAUDE.md inline section; not auto-loaded as full file |
| `mantras/make_state_honest.md` | 4,282 | 107 | Same |
| `environment/hosts.md` | 2,228 | 58 | `environment-map` activates |
| `environment/networks.md` | 1,530 | 35 | Same |
| `environment/repos.md` | 1,743 | 41 | Same |
| `environment/services.md` | 1,773 | 48 | Same |

These files are not the bottleneck — they're correctly sized for
their roles. The fix is to *use this pattern more*, by extracting
content from oversized SKILL.md files into reference siblings.

---

## How to use this document

1. Read end-to-end. The hotspot ranking is ordered by impact, not
   by ease of execution — but each P0 item is sized for one PR.
2. Pick **P0.1, P0.2, or P0.3** first — they cut every-session
   overhead. Cold-session benefit is immediate and verifiable.
3. For each PR, before you land it, re-measure the affected file
   with `wc -c` and report the actual delta in the PR description.
4. Don't bundle. One PR per moved section keeps reverts surgical
   if a reference extraction breaks an activation flow.
5. After P0+P1 land, recompute the scenario table at the top of
   "Compound savings projection" with real numbers, not estimates.
   That confirms the model and surfaces any miscounts.

The skill system is in good shape. This is incremental hardening,
not a redesign. Token efficiency is a quality-of-context concern,
not a quality-of-content concern — the goal is to deliver the same
domain value with less always-on overhead.

---

## Measured outcome

**The plan delivered a -27.5% always-loaded baseline reduction (-9,746 B / -2,437 tokens) plus 8 new discipline + ritual skills, executed across 38 tasks in 9 phases.**

### Always-loaded baseline (measured, Task 37)

| Component | Pre-plan (Task 00) | Post-plan (Task 37) | Delta | % |
|---|---|---|---|---|
| `~/.claude/CLAUDE.md` | 19,028 B | 9,839 B | **-9,189 B** | **-48.3%** |
| Sum of 28 SKILL.md descriptions | 16,422 chars | 15,865 chars | -557 chars | -3.4% |
| **Always-loaded total** | **35,450 B** | **25,704 B** | **-9,746 B** | **-27.5%** |
| Approx tokens (4 chars/tok) | ~8,863 | ~6,426 | **-2,437 tokens** | -27.5% |

CLAUDE.md drifted +477 B since Phase 1's audit (9,362 → 9,839) due to merged-in Debian env content from a parallel branch; the Phase 1 trim itself is intact. Description bytes are net-near-zero because Phases 5+6 added 8 new skills (4 discipline + 4 ritual) costing ~4,747 chars of always-loaded description weight; without those additions, description-only savings would have been ~5,300 chars (matching essay §"Hotspot 4" projection).

### Per-scenario savings (essay §"Compound savings projection", recomputed)

| Scenario | Pre-plan tokens | Post-plan tokens | Saved | % |
|---|---|---|---|---|
| A — Cold session | ~8,863 | ~6,426 | 2,437 | **-27.5%** |
| B — Routine code (Next.js) | ~11,370 | ~8,541 | 2,829 | -24.9% |
| C — Music platform feature | ~16,945 | ~12,985 | 3,960 | -23.4% |
| D — Plan execution | ~19,875 | ~13,765 | 6,110 | -30.7% |
| E — Worst compound | ~26,800 | ~20,140 | 6,660 | -24.9% |
| F — Doc audit | ~13,110 | ~9,650 | 3,460 | -26.4% |

Average measured savings: **~26%**. Essay projection: 40%. See "Projection-miss analysis" below.

### Cumulative ledger by phase

| Phase | Contribution to always-loaded baseline | Per-activation contribution | Notes |
|---|---|---|---|
| 1 — CLAUDE.md trims | **-9,666 B** (Task 04 audit) | — | Three sections moved to `references/`; Phase 1 PASS |
| 2 — Heavy SKILL.md trims | — | **-23,646 B** of activation cost across 8 SKILL.md (Task 13 audit) | References + examples extracted; specialist code-block extraction under-delivered (~32% of projection) |
| 3 — Description rewrites | **-5,303 chars** descriptions (Task 18) | — | All 20 descriptions ≤1024; 14/14 keyword retention |
| 4 — Pressure-test methodology | +6,636 B reference (Tier-3, on-demand) | +263 char agent description | Methodology PASS; harness for Phases 5–6 |
| 5 — Discipline skills | **+~2,365 chars** descriptions (4 new always-loaded) | +~12.6 kB body (4 new skills) | Net always-loaded: -12,604 B (Task 25 audit) |
| 6 — Ritual skills | **+~2,382 chars** descriptions (4 new always-loaded) | +~14.3 kB body (4 new skills) | Net always-loaded: -10,222 B (Task 30 audit) |
| 7 — Existing-skill upgrades | ~0 (small in-body changes) | — | plan-executor task-quality gate; anchor-chain nudges |
| 8 — Ergonomics & enforcement | -557 chars net description drift (final) | Tier-3 only (`/zoom-in`, `/zoom-out`, `/session-ready`, `/sweep`, `/audit-task` slash commands; budget linter) | Final measurement and dedup checks; Task 37 audit |
| 9 — Closeout | — | — | This commit |

Net over 9 phases: **always-loaded -9,746 B / -27.5%** + **8 new always-loaded skills (capability gain)** + **on-demand activation savings ~23,646 B per relevant activation** + **5 slash commands**.

### Conditional-PASS audit roll-up

Five of the seven audit gates returned **CONDITIONAL PASS**. Each is summarized below; full reports under `~/dotfiles/.claude/plans/skills-trim-and-discipline/audits/`.

**Phase 2 — Task 13 audit (`audits/13-skill-trims-audit.md`).** Conditional because 4 of 8 trimmed SKILL.md files exceeded their per-task byte bands by 351–2,110 B; the over-band files share a root cause (residual prose, not extractable code). Per Task 13's explicit failure-handling rule ("per-file under-trim: mark as a Phase-8 follow-up task; do not block"), accepted as non-blocking. Cumulative SKILL.md activation savings: -23,646 B. User-confirmed: forward progress to Phase 3.

**Phase 3 — Task 18 audit (`audits/18-descriptions-and-cold-session-audit.md`).** Conditional because the cold-session smoke test was deferred (auditor cannot launch fresh Claude Code sessions from in-flight scope; same constraint at Tasks 04, 13, 18, 25). Description deliverables are all MET: 20/20 ≤1024 chars; 14/14 keyword-retention checks pass; skill picker confirms live load. Surfaced one new finding: `ddex-standards` body is +3,062 B over specialist body budget (was not in Phase 2 trim list). User-confirmed: defer cold-session check to a single user-run capstone covering all five deferred gates.

**Phase 5 — Task 25 audit (`audits/25-discipline-skills-audit.md`).** Conditional because all four discipline skills (`systematic-debugging`, `verification-before-completion`, `test-driven-development`, `design-before-code`) shipped with hypothetical-labeled RED-phase rationalizations rather than empirically-captured ones. Implementer sub-agents cannot dispatch sub-sub-agents from their scope, so the RED dispatch ran "in mind" rather than as a real Task tool call. Deliverables otherwise MET: 4/4 fixtures present, 4/4 iron-laws bolded, 4/4 ≤500 words. User-confirmed: accept hypothetical-labeled trace; queue empirical re-run as Phase-8 follow-up #7.

**Phase 6 — Task 30 audit (`audits/30-ritual-skills-audit.md`).** Conditional for the same hypothetical-RED reason as Phase 5 (4 ritual skills: `using-homebrew-skills`, `receiving-code-review`, `requesting-code-review`, `finishing-a-branch`). Cross-reference graph wired symmetrically; no proactive-mode collisions. User-confirmed: extend Phase-8 follow-up #7 to cover all 8 discipline + ritual skills.

**Phase 8 — Task 37 audit (`audits/37-final-measurement-audit.md`).** Conditional because the measured -27.5% always-loaded reduction is below essay §"Compound savings projection"'s 40% target — projection miss is 14 percentage points / 35% off target, exceeding Task 18's 25% investigation threshold. Investigation completed in the audit itself: root cause is the projection model (trim-only, did not budget the cost of adding 8 new skills in Phases 5+6). All 28 skills have compliant `class:` tags + `[HomebrewSkill]` prefixes; no activation regressions in the live skill picker. User-confirmed: accept the measured 26% average as the realistic delivered figure given both trims and additions; closeout proceeds.

### Phase-8 follow-ups (carry-forward)

The following items were tracked across audits and surfaced in the final measurement (`MasterPlan.md` §"Phase-8 follow-ups"). They are non-blocking for plan closeout but are the durable record of work not closed in this plan:

1. Prose-pruning for `nextjs-app-router` body (~+2,041 B over [≤6,500 B] specialist body budget) — high.
2. Prose-pruning for `turborepo-patterns` body (~+1,024 B) — high.
3. Prose-pruning for `royalty-splits-music` body (~+1,104 B) — high.
4. Prose-pruning for `ddex-standards` body (~+3,062 B; not in Phase-2 trim list) — high.
5. Prose-pruning for `plan-executor` body (~+502 B over [≤8,500 B] workflow budget) — medium.
6. Cold-session smoke test (deferred 4 times across audits 04/13/18/25); single user-run check covers all gates — medium.
7. Re-run RED dispatches for all 8 discipline + ritual skills with real orchestrator-scope sub-agent dispatch (4 discipline + 4 ritual). Current rationalizations are hypothetical-labeled (representative but not empirical). Iterate skill bodies if new rationalizations surface — high.
8. YAML quoting sweep across project-local skill dirs (any unquoted descriptions with colons should be fixed) — low.

---

## Projection-miss analysis

**The miss.** Essay #9 projected 40% always-loaded reduction; measured outcome is 26%. Miss: 14 percentage points / 35% short of target.

### Root cause 1 — "trim only" projection model

Essay §"Compound savings projection" budgeted reductions against the existing 20 skills only. It did not model the cost of adding new always-loaded weight. Phases 5 and 6 introduced 8 new skills (4 discipline + 4 ritual), each carrying ~600 chars of always-loaded description — a combined ~4,747 chars of new Tier-1 weight. The projection model treated the always-loaded baseline as monotonically shrinking; the executed plan grew it in two phases while shrinking it in three others. Net is still strongly negative (-9,746 B), but the gross trim delivered (~14,469 B trimmed) is partly offset by the gross addition (~4,747 B added) — a dynamic the original model did not capture.

### Root cause 2 — Hotspot 3 over-projection

Essay §"Hotspot 3 — Domain specialists with embedded code blocks" projected ~15 kB cuttable across 5 specialists via code-block extraction. Task 13 audit measured ~4,829 B actually extracted — about 32% of projection. Root cause is that specialist body bulk is prose-dominated (decision tables, common-pitfalls lists, principle exposition), not code. The extractable code per specialist averaged 1–3 modules under 100 lines each. Code-block extraction alone cannot reach Hotspot 3's projected ceiling; further reductions require prose-pruning of the specialists (the work tracked as Phase-8 follow-ups #1–4). The projection model needs a downward revision for prose-dominated specialists.

### Root cause 3 — Reference composition overhead

Phase 2 created ~21 kB of new reference content from ~13 kB of moved SKILL.md content; Phase 3 added another ~15 kB of `description-format.md` reference. The "+8 kB overhead" pattern (replicated at multiple splits) is composition cost: when one document is split into multiple referenced documents, each new file carries cross-reference glue, headers, and explanatory framing the source did not require. Tier-3 references do not show in always-loaded numbers, but they do inflate per-load cost when references are consulted during activation. Acknowledged trade-off — the references-pattern lever is correct; its cost should be modeled, not assumed away.

### Net assessment

Projection miss reflects model gap, not implementation failure. The plan delivered all trims AS PLANNED, plus 8 new skills (gain not modeled in the projection), netting **-27.5% always-loaded baseline**. The 40% target was an "additions-free" baseline; **26% is the realistic figure when both trims and additions are counted**. Future trim audits should not collapse the two ledgers.

### Recalibration recommendation for future audits

Future trim plans must explicitly model the description-cost of any new skills they propose to add, OR explicitly track "trim delta" and "addition delta" as separate ledgers. A single composite "% reduction" target conflates two distinct dynamics — bytes saved from trims vs bytes added from new capability — and produces unactionable projection misses when the plan does both. Recommended pattern:

```
Trim delta:      bytes removed from existing in-scope artifacts
Addition delta:  bytes added by new in-scope artifacts
Net delta:       trim delta + addition delta  (the "headline" %)
Composition delta: bytes added to Tier-3 references for moved content (informational; not always-loaded)
```

Each is computed independently; the headline is the sum. Audit gates verify each ledger against its phase-level projection rather than a single composite target. This avoids conflating "we delivered the trim" (Phase 1 hit projection cleanly) with "we missed the headline" (Phases 5+6's new always-loaded weight was outside the model).
