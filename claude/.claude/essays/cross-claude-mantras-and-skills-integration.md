---
title: Cross-Claude integration — mantras, artifact taxonomy, and continuity skills
status: resolved
created: 2026-04-27
last-active: 2026-04-27
tags: [claude-config, mantras, artifact-taxonomy, skills, anchoring, cross-claude]
anchors:
  produced:
    - ~/.claude/mantras/make_state_honest.md
    - ~/.claude/mantras/eliminate_dont_paper_over.md
    - ~/.claude/skills/top-down-sweep/SKILL.md
    - ~/.claude/skills/session-ready/SKILL.md
    - ~/.claude/CLAUDE.md
    - ~/.claude/ideas/plan-executor-permission-preflight.md
    - ~/.claude/settings.json
    - ~/Development/GitHubProjects/MusicPortfolio/.claude/settings.json
    - ~/Development/GitHubProjects/MusicPortfolio/CLAUDE.md
  references: []
---

# Cross-Claude integration — mantras, artifact taxonomy, and continuity skills

Brandon and Claude integrated contributions from Steve Showell's Claude (via the `claude-collab` repo) into Brandon's global Claude configuration. The process surfaced structural decisions about artifact organization that hadn't been made explicit before — captured here so future evolution can be coherent rather than accretive.

## Context

Steve and Brandon collaborate via a shared markdown repo where their Claudes leave each other notes. This session pulled in five upstream commits introducing the TOP_DOWN_SWEEP protocol, doctrine essays (`make_state_honest`, `eliminate_dont_paper_over`), tool snapshot conventions, and an essay-server implementation. The work landed alongside an in-flight feature branch (`feat/claude-system-overhaul`) already adding the `essay`, `gitignore`, and `github` skills, the `references/` directory, and the front-matter anchoring system.

Two distinct contribution streams converged. They needed reconciling.

## Decisions

### 1. Six-class artifact taxonomy with disjoint schemas

**What was decided:** Define artifact classes with distinct schemas and locations: Memory, Mantra, Idea, Essay, Plan, Doc.

**Options considered:**
- Acknowledge Steve's import schema and Brandon's essay-skill schema as dual variants of one "essay" class — papers over the truth that they have different lifecycles
- Move imports to `~/.claude/memory/` to match auto-memory schema — splits a coherent import group and breaks CLAUDE.md prose pointers
- Reformat imports to essay schema — loses Steve's `originSessionId` provenance and forces lifecycle metadata that doctrines don't have
- **Extract a new artifact class for doctrines** (chosen) — most honest match for what they are

**Rationale:** Applying *make state honest* to our own metadata. Each class answers a different question (recall during work, embodied principle, pre-plan stash, decision artifact, execution unit, code description). Forcing one schema makes the data shape wider than reality for some classes and narrower than useful for others. Different lifecycles also rule out unification — mantras are stable and embodied, essays move open→resolved→superseded, ideas mature into plans.

The probe that surfaced this was a `/session-ready` run: a fresh Claude reading the bundle conflated artifacts and asked "why mantras separate from essays?" — the system had no answer because no one had written the rationale down.

### 2. "Mantra" and "doctrine" as interchangeable terms

**Decision:** Both valid; `~/.claude/mantras/` is canonical directory name. CLAUDE.md header reads "Design doctrines (mantras)".

**Rationale:** Brandon will likely say "mantra" in conversation. The word captures what they are functionally — load-bearing principles internalized via CLAUDE.md reference, never retrieved by query because they're already in context. Memories are recalled, essays are consulted, mantras are *embodied*.

### 3. Anchor chain: idea → essay → plan → doc → code

**Decision:** Linear, one-way, acyclic. Children point to parents (`from-essay:`, `from-plan:`); parents declare children forward only when verification needs it (`anchors.produced`, `affects-docs:`). Mantras inform from outside the chain. Memories sit aside as operational rules.

**Rationale:** A bidirectional or branching chain risks pointer spaghetti. Forward declarations are needed because verification (auditor checking `affects-docs` were touched) requires them; back-references are needed because traceability ("where did this come from?") requires them. Forward + back is the minimum honest set; anything more breeds drift.

### 4. Two new user-level skills: `top-down-sweep` and `session-ready`

**What was decided:** Build both as distinct skills, not one combined.

**Rationale:** They answer different questions. Sweep audits docs against code (does the doc still match reality?); session-ready audits docs against "could a fresh Claude continue from here?". They chain naturally (probe finds gaps → sweep fixes them) but conflating them weakens both. Both are user-level because the questions cross projects.

Session-ready specifically dispatches a sub-agent with zero parent context — the probe must run blind to surface real orientation gaps. This very essay was prompted by such a probe finding the WHY-gap in our own work.

### 5. Workflow rules promoted to global CLAUDE.md

**Trigger:** Two preventable failures occurred mid-session — manual `ln -s` for stow-managed paths (caught and corrected); Bash used for file reads/listings (causing permission-prompt spam).

**Decision:** Add explicit rules to global CLAUDE.md:
- *Dotfiles workflow* — never `ln -s` for stow-managed paths
- *Tool selection* — prefer dedicated tools (Read/Grep/Glob/Edit/Write) over Bash

**Rationale:** Both rules existed implicitly (dotfiles CLAUDE.md, system prompt) but were ignored because they weren't loaded with the right priority during cross-repo work. The dotfiles CLAUDE.md only auto-loads when cwd is `~/dotfiles`; the system prompt's tool-preference guidance wasn't weighty enough. Promoting to global CLAUDE.md ensures both load every session regardless of cwd.

### 6. Permission allowlist split — project vs user level

**Decision:** Project-specific patterns (pnpm scripts, npx tooling) in `<project>/.claude/settings.json`; cross-cutting patterns (git mutations, file movements, stow) in `~/.claude/settings.json`. Destructive commands (rm, force-push) deliberately excluded — those should keep prompting.

**Rationale:** The `less-permission-prompts` skill defaults to project-only installation, but most observed Bash patterns came from MusicPortfolio sessions, not the current project. Installing in claude-collab settings would have been useless. Splitting by scope matches reality.

Brandon explicitly took a position to override the skill's read-only-only default for git mutations: prompts were blocking autonomous plan-executor work too aggressively. The github skill encodes safety at a different layer (no force-push to main, no `--no-verify`), so the allowlist can be permissive without losing guardrails.

### 7. Capture this session as an essay

**Decision:** Snapshot via the essay skill rather than leave reasoning in commit history alone.

**Rationale:** The session-ready probe found that CLAUDE.md captures rules but not the reasoning that produced them. A future Claude can apply the system but can't extend it coherently because they don't know which choices are load-bearing principles vs convenient stopping points. The essay closes that gap. The essay's `anchors.produced` lists the concrete artifacts; the body explains why each shape was chosen.

### 8. Add Idea to the artifact-class table

**Decision:** Six classes, not five. Idea was missing from the original table even though it has YAML front-matter, a known location (`~/.claude/ideas/`), a lifecycle (open/shelved/archived), and an owning skill (`idea-tracker`).

**Rationale:** The probe naturally expected ideas in the table and listed them as one of the classes. Excluding them was state-dishonest. Ideas precede essays in the chain — most mature into either an essay (when design discussion is needed) or directly into a plan (when scope is already clear).

## Resolution

All decisions implemented and committed across two repos. The dotfiles changes are pushed to `origin/main`; the MusicPortfolio commit is local only (push pending SSH auth — flagged in conversation).

The system now has six artifact classes with distinct schemas, two new skills for doc continuity, and two workflow rules preventing the failures observed mid-session. Future evolution can extend coherently because the WHY for each piece is captured here, in this essay, anchored to the artifacts it produced.

## Open follow-ups

- `~/.claude/ideas/plan-executor-permission-preflight.md` — natural extension to make plan-executor headless-safe by pre-checking permission gaps
- The `<project>/.claude/sweeps/` convention referenced by both new skills hasn't been added to `~/.claude/references/plan-system.md` gitignore rules yet — minor, can address when first sweep runs
- Steve's open question about orchestrator calibration ("does the line between trivial and non-trivial drift?") wasn't answered this session — sits in `~/Development/GithubTools/claude-collab/claude-claude/03_steves_claude_round_two.md` as a thread to pull
