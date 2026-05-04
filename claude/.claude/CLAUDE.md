# Claude Global Config

## Workflow discipline

Before acting on any request:

1. Understand intent — ask one focused clarifying question if the goal is ambiguous
2. Inspect relevant context (files, sidecars, git state) before proposing changes
3. Propose a minimal plan; get implicit or explicit buy-in before executing
4. Apply changes via diffs when possible; avoid full rewrites of unchanged sections
5. After changes, validate edge cases and flag any assumptions made

## Output constraints

- Be concise. Structure (headers, lists) only when it aids scanning.
- No preamble, no trailing summaries, no "here's what I did" narration.
- Prefer actionable output over commentary.
- Do not repeat context the user already provided.

## Reading discipline

- Read only what the task domain explicitly requires. Do not pre-read speculatively or scan broadly.
- Re-read a file only when: the task explicitly modifies what it covers, or the user says to refresh it.
- Never scan the full project or docs directory unprompted.
- "Inspect relevant context" means targeted reads — not exhaustive ones.

## Tool selection

Choose dedicated tools over Bash. Each Bash invocation costs the user a permission prompt — bulk read/move/list operations via Bash spam approvals.

| Task | Use | Not |
|---|---|---|
| Read a file | `Read` | `cat`, `head`, `tail`, `less` |
| Search file contents | `Grep` | `grep`, `rg` |
| Find files by name | `Glob` | `find`, `ls` (when listing) |
| Edit a file | `Edit` | `sed`, `awk`, redirected `echo` |
| Write a new file | `Write` | `cat <<EOF`, `echo >` |

Reserve Bash for: filesystem mutations (`mv`, `cp`, `mkdir`, `rm`), git operations, network calls, process management, running scripts. If a dedicated tool fits, the dedicated tool wins — even when Bash would be one line.

## Debugging behavior

- Ground diagnosis in observable evidence: logs, error messages, reproduction steps.
- Do not guess silently — state uncertainty explicitly.
- Ask precise clarifying questions when the root cause is unclear.
- Propose one fix at a time; confirm before stacking changes.

## CLI UX behavior

For multi-step operations, emit lightweight progress:

```
[1/4] analyzing ...
[2/4] editing src/foo.ts ...
[3/4] running tests ...
[4/4] done
```

- Prefer diff-based output for file changes.
- Keep terminal output compact — no decorative separators or verbose status blocks.

---

## Dotfiles workflow

The `~/.claude/` tree is managed by GNU Stow from `~/dotfiles/claude/.claude/`. When adding, removing, or restructuring anything under `~/.claude/` or any other stow-managed path under `~/dotfiles/`:

- **Never create symlinks manually with `ln -s` or `ln -sf`.** Stow owns the symlinks. Manual symlinks break stow's conflict detection and will surface as "not owned by stow" on the next `stow --simulate`.
- Edit the source file at `~/dotfiles/<package>/<path>`, not the runtime symlink at `~/<path>`.
- After adding or removing a tracked path: run `cd ~/dotfiles && stow <package>` (or `stow -R <package>` to restow). Verify with `ls -la ~/<path>` — should show a symlink.
- This applies even when the primary working directory is a different repo. If you're touching anything under `~/.claude/` or `~/dotfiles/`, this rule fires.

Full conventions in `~/dotfiles/CLAUDE.md`.

---

## Sidecar conventions

Every non-trivial source file should have a sibling `.claude` sidecar
carrying design decisions, invariants, and gotchas the code cannot.
**Read before editing; update after changes that affect intent.**
See `~/.claude/references/sidecar-conventions.md` for label/role
taxonomy, when-to-create rules, and sidecar maxims.

---

## Essay convention

Long-form markdown files for working through ideas in prose — not tickets, not commit messages, not chat turns. Some thoughts need 400–800 words to settle.

- Live alongside the project or in a dedicated `/essays/` directory.
- Written by Claude, the human, or collaboratively.
- **Lifecycle:** most essays are disposable — written to think, then discarded or distilled into memory. A few earn promotion to named docs. Disposability is a feature; quality is cheap to regenerate.
- **Graduation:** moving an essay to a stable named doc is a deliberate act, not a drift.

An insight from an essay often deserves distillation into a memory; a memory describing load-bearing behavior often deserves reflection in the relevant sidecar.

---

## Design doctrines (mantras)

Load-bearing principles internalized as mantras — applied on every shape decision without retrieval. "Doctrine" and "mantra" are interchangeable; full text lives at `~/.claude/mantras/<title>.md`.

### Make state honest

The data shape of the system should match what's actually true about reality at the point of use. Four failure modes:

- **Wider than reality** — type carries a `Maybe`/`NULL` the local site has already ruled out. Alarm: "shouldn't happen by construction."
- **Narrower than reality** — wire throws away data the producer already had. Alarm: "B can re-derive this from A's output."
- **Inventing reality** — naming a non-problem as a recovery scenario. Alarm: "stuck-state recovery."
- **Fragmented** — two representations for one truth that drift and create bugs at the seam.

The fix is always the same: change the shape, not the comment or the adapter layer.

### Eliminate, don't paper over

When code feels contorted — adding adapters, translation helpers, step counters, defer-until-later branches, defensive comments — the discomfort is information about the shape, not noise to suppress. The remedy is structural.

**The license: I own the whole system.** Every contract, both sides. The diagnostic before any patch: does this invariant let me *delete* code? If yes, deleting is the work. Patching without deleting is a smell. When two components feel out of phase, reshape one or both until the translation falls away.

Trigger: any time you hear yourself writing "// shouldn't happen", adding a `step` counter, deferring a decision to a later layer, or reaching for a translation helper — stop. The shape is wrong.

---

## Artifact classes

Six artifact classes share the YAML front-matter mechanism but answer
different questions: **memory**, **mantra**, **idea**, **essay**,
**plan**, **doc**. The anchor chain is `idea → essay → plan → doc → code`,
with mantras informing it. Each class has its own minimal schema —
don't add fields it doesn't need.

Full table, anchor-chain diagram, and field-purpose breakdown:
`~/.claude/references/artifact-classes.md`.
See also `~/.claude/essays/cross-claude-mantras-and-skills-integration.md`
for rationale.

---

## Ideas

Capture pre-plan ideas via the `idea-tracker` skill. Lives at `~/.claude/ideas/`,
tracked in dotfiles. Activates on phrases like "save as idea", "track this", or
"what ideas do I have". Replaces the legacy TODO system — TODOs were the prior
mechanism for stashing things to build that didn't yet have concrete plans.

---

## Homebrew skill standard

Skills are scoped at two levels:

- **User-level** — live at `~/.claude/skills/<skill-name>/SKILL.md`
  (tracked in dotfiles at `claude/.claude/skills/<skill-name>/SKILL.md`)
- **Project-level** — live at `<project>/.claude/skills/<skill-name>/SKILL.md`

The `name` frontmatter field must be prefixed to reflect scope:

```yaml
name: "[HomebrewSkill] skill-name"   # user-level skill
name: "[ProjectSkill] skill-name"    # project-level skill
```

This distinguishes user-authored skills from built-in Claude Code skills in the
skill picker. Apply the correct prefix to every new skill created, without exception.

---

## Plan execution system

Two-layer system installed user-wide:

**Skills (`~/.claude/skills/`):**

- `plan-executor` — main orchestrator. Sequential, dispatch-and-collect.
- `plan-auditor` — independent compliance auditor (separate skill, invoked on-demand)

**Agents (`~/.claude/agents/`):**

- `plan-executor-implementer` — agent for code implementation tasks
- `plan-executor-tester` — agent for test-writing tasks
- `plan-executor-documenter` — agent for documentation tasks
- `plan-executor-discovery` — agent for inventory/discovery tasks

The orchestrator dispatches agents via the Task tool's `subagent_type`
argument. Agents are registered at `~/.claude/agents/<name>.md` and the
`name` in the file's frontmatter must match.

**To run a plan:** invoke `plan-executor` with a master plan path and
tasks directory. State is persisted to `.claude/plan-states/<plan-name>.json`
in the current project, so execution resumes across sessions.

**Failure behavior:** stop-and-ask on non-trivial failures.

**Auditing:** plan-executor invokes plan-auditor only on demand mid-plan,
automatically once at plan completion.

See `~/.claude/references/plan-system.md` for canonical filesystem layout, gitignore rules, and multi-plan/worktree conventions.
See `~/.claude/references/console-discipline.md` for output rules (when to write to file vs print to chat).

---

## Environment Map

Brandon runs a multi-host personal setup (M1 MacBook + Debian agent
host + Pi DNS + AWS prod + Oracle standby). The `environment-map`
skill loads the full topology on demand. Activate it on host names,
service names, or cross-machine queries. See
`~/.claude/environment/` for the source files.

---

## Pull requests

Every PR must have a non-empty summary in its body explaining *what changed and why*. Default to concise: a few bullets plus a Test-plan checklist (the `gh pr create` template). Scale up only when the diff is genuinely nontrivial — multiple concerns, behavior changes, operator-impacting choices — in which case a per-commit breakdown and an "Operator notes" section earn their keep. Empty bodies and generic titles ("Update X") are not acceptable.
