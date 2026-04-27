Prompt — Plan-System Coherence Audit

Run BEFORE Prompt A (changelog-migration). Paste into a fresh Claude Code session opened inside ~/dotfiles.

Goal: extract canonical references for the plan execution system and console-output discipline, fix drift across skills, replace inline restatements with citations, and tighten plan-executor with a failure-calibration decision table.

This is preparation for the changelog-migration and essay-skill prompts that follow. Drift in path conventions (`.claude/plans` vs `.claude/plan-states`) and gitignore rules has caused agent uncertainty in past sessions. Fix it once, cite it everywhere.

## Context — read first

1. Read these existing user-wide skills and agents:
   - ~/dotfiles/claude/.claude/skills/plan-executor/SKILL.md
   - ~/dotfiles/claude/.claude/skills/plan-auditor/SKILL.md
   - ~/dotfiles/claude/.claude/skills/worktree-orchestrator/SKILL.md
   - ~/dotfiles/claude/.claude/agents/plan-executor-discovery.md
   - ~/dotfiles/claude/.claude/agents/plan-executor-implementer.md
   - ~/dotfiles/claude/.claude/agents/plan-executor-tester.md
   - ~/dotfiles/claude/.claude/agents/plan-executor-documenter.md

   If a path differs because of symlink resolution, run `readlink ~/.claude/skills/<name>/SKILL.md` to discover the real source. Edit the real source, not the symlink target.

2. Read the dotfiles gitignore for context on which paths are ignored at this level:
   - ~/dotfiles/.gitignore

3. Inspect a real project's plan layout if available (do not modify):
   - `ls -la ~/Development/music-platform-monorepo/.claude/ 2>/dev/null`
   - `grep -i 'plan\|claude' ~/Development/music-platform-monorepo/.gitignore 2>/dev/null`

## Phase 1 — Extract `plan-system.md` reference

Create `~/dotfiles/claude/.claude/references/plan-system.md` (`mkdir -p` as needed). Single source of truth for:

- **Filesystem layout** — what lives in `.claude/plans/<plan-name>/` (plan inputs: MasterPlan.md, numbered task files) vs `.claude/plan-states/<plan-name>.{json,log}` (runtime state). Include a short example tree at the top.
- **Gitignore rules** — always-ignored paths (`.claude/plan-states/`, `.claude/plan-completion-report.md`, `.claude/settings.local.json`), conditionally-tracked paths (`.claude/plans/`), with rationale.
- **Multi-plan support** — separate state file per plan name; plan name derives from the plan dir name.
- **Worktree-orchestrator interaction** — where plan dirs live, worktree branch naming relative to plan names, where state files live during worktree execution.
- **Project vs dotfiles context** — why `~/dotfiles` ignores `.claude/plans/` (no plans run there) but project repos may track them.

Sections in this order: Layout, Gitignore, Multi-plan, Worktrees, Context Notes. Each section terse and authoritative — no narrative, no rationale unless load-bearing.

## Phase 2 — Extract `console-discipline.md` reference

Create `~/dotfiles/claude/.claude/references/console-discipline.md`. Single source of truth for output discipline. The principle: **structured or long content belongs in a file; the chat gets a short status line.**

Required sections:

### Core rule

- A reply over ~15 lines, OR any reply with structure (lists, tables, multi-section markdown), belongs in a file — not printed to the terminal.
- The chat output should be a status line (1–3 lines) that says what happened and where the detailed output lives.

### Plan-executor application

- Phase 3 / Phase 4 summaries, audit reports, completion reports: write to a file under `.claude/plan-states/`. Suggested names:
  - `.claude/plan-states/<plan-name>-summary.md` — orchestrator summary at plan completion.
  - `.claude/plan-states/<plan-name>-audit.md` — auditor verdict.
- Print to chat: a 2–3 line status (verdict, file path, next action).
- These artifacts are runtime state — covered by the existing `.claude/plan-states/` gitignore rule (cite `~/.claude/references/plan-system.md`).

### Plan-auditor application

- Verdict files written to `.claude/plan-states/<plan-name>-audit.md`.
- Chat output: verdict + file path only.

### Github skill application

- Long PR bodies and release notes belong in the PR description (`gh pr create --body ...`), not in the chat reply.
- Status line in chat: PR URL + one-sentence summary.

### When the rule does NOT apply

- Direct user-asked questions ("what does this do?") where the answer is itself short.
- Code being shown as a diff (the diff IS the artifact).
- Quick lookups where writing a file is overkill.

Keep sections terse. The reference is a rule, not a manual.

## Phase 3 — Fix drift in skills and agents

For each file listed in Phase 0.1, identify any place that restates plan-system or console-output rules inline. Replace with a citation:

> See `~/.claude/references/plan-system.md` for the canonical filesystem layout.
> See `~/.claude/references/console-discipline.md` for output rules.

Specifically update plan-executor and plan-auditor SKILL.md so their summary/verdict phases:
- Write artifacts to file paths defined in `console-discipline.md`.
- Print only the status line to chat.

Keep operational steps in the skill (WHAT to do); move conventions to the references (WHERE and WHY).

If you find conflicts between skills, the canonical reference is the resolution — pick the correct answer and update both skills to match.

## Phase 4 — Add failure-calibration decision table to plan-executor

Locate the section in `plan-executor/SKILL.md` describing trivial vs non-trivial failures (the "stop-and-ask on non-trivial failures" guidance). Replace prose examples with a decision table. Each row must earn its place — if a category is rare or covered by another row, drop it.

Suggested starting columns: Failure type · Verdict · Rationale.

Suggested rows (refine during the audit; drop any without strong purpose):

| Failure type | Verdict | Rationale |
|---|---|---|
| Single test fails, fix is obvious from the error | Trivial — agent retries | Self-correctable; halting wastes a roundtrip |
| Lint/format violation | Trivial — agent retries | Mechanical; deterministic fix |
| File path or import not found in fresh agent context | Trivial — agent retries with corrected path | Often a context-load miss, not a real failure |
| Test failure with non-obvious cause | Non-trivial — halt | Risk of compounding wrong fix |
| Build error spanning multiple files | Non-trivial — halt | Cross-file blast radius needs human read |
| Auth/permission failure (push, gh) | Non-trivial — halt | Can't be fixed by retry; needs operator action |
| Agent reports "uncertain" or asks a question | Non-trivial — halt | Explicit signal — surface it |
| Audit verdict: fail | Non-trivial — halt | The audit is the calibration |

The executing session should adjust rows based on what it finds in plan-executor's existing prose. The principle: a trivial failure is one a fresh agent invocation can deterministically fix; a non-trivial failure is one where retrying risks compounding the problem.

## Phase 5 — Update CLAUDE.md pointers

Append two lines to `~/dotfiles/claude/.claude/CLAUDE.md` under the "Plan execution system" section:

> See `~/.claude/references/plan-system.md` for canonical filesystem layout, gitignore rules, and multi-plan/worktree conventions.
> See `~/.claude/references/console-discipline.md` for output rules (when to write to file vs print to chat).

## Phase 6 — Stow + commit

1. Run `stow -d ~/dotfiles -t ~ claude` to symlink the new reference files.
2. Verify both symlinks:
   - `ls -la ~/.claude/references/plan-system.md`
   - `ls -la ~/.claude/references/console-discipline.md`
3. Single commit titled: `feat(claude): extract canonical references and add failure-calibration table`. Body lists the reference files created, the skills/agents updated, the drift resolved, and the decision table added.

## Stop-and-ask conditions

- If a skill describes plan-system or console-output behavior in a way that conflicts with another skill and the correct answer is non-obvious, stop and ask.
- If any plan-state or plan dir paths differ between dotfiles ignore patterns and what the skills imply, stop and ask before reconciling.
- If `~/dotfiles/claude/.claude/references/` already exists with conflicting content, stop and ask.
- If the existing failure-calibration prose in plan-executor materially conflicts with the suggested decision table, stop and ask before resolving.
