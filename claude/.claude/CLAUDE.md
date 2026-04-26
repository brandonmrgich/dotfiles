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

## Sidecar conventions

Every non-trivial source file should have a sibling `.claude` sidecar
(`<file>.<ext>.claude`, e.g. `auth.go.claude`). The sidecar carries what the
code cannot: design decisions, invariants, gotchas, cross-module contracts.

**Read the sidecar before editing any non-trivial file.**
**Update the sidecar after any change that affects design intent or invariants.**

### Sidecar format

```
just_use <filename>.<ext>

# label: LABEL
# role: <one-line description>

<free-form prose>
```

> **Exception:** Match the existing `.claude` suffix convention if a repo already
> uses `auth.claude` instead of `auth.go.claude`.

### Label taxonomy

| Label         | Meaning                                                |
| ------------- | ------------------------------------------------------ |
| `CANONICAL`   | Single source of truth; edits ripple widely            |
| `ELEGANT`     | Exemplary — match its style nearby                     |
| `INTRICATE`   | Algorithmically dense; test rigorously before touching |
| `WORKHORSE`   | Ugly but productive; don't polish, just modify         |
| `CLEAN_INFRA` | Well-factored plumbing; don't bloat it                 |
| `SCAFFOLD`    | Wires things together; easy to miss a connection       |
| `ROUTER`      | Top-level dispatcher; low logic density                |
| `SIMPLE`      | Short and obvious                                      |
| `TINY`        | Fits entirely in your head                             |
| `EARLY`       | Work-in-progress; shape not settled                    |
| `SPIKE`       | Exploratory; may be ripped — don't build on it         |
| `BUGGY`       | Known-broken; advertise rather than hide               |
| `VESTIGIAL`   | Superseded or dead; candidate for removal              |
| `SPRAWLING`   | Big and growing; be careful adding scope               |
| `ONE_OFF`     | Genuinely unique; accept its idiosyncrasy              |
| `GENERATED`   | Do NOT hand-edit; regenerate instead                   |
| `TOOL`        | Stand-alone utility; edits ripple nowhere              |

### Role taxonomy

| Role keyword               | Meaning                                         |
| -------------------------- | ----------------------------------------------- |
| `domain`                   | Core types, rules, invariants; no I/O           |
| `encodes domain knowledge` | Alias for `domain`                              |
| `supports feature`         | Handler, endpoint, or product feature           |
| `agent tool`               | Script/CLI run by an agent or developer         |
| `pure helpers`             | Stateless utilities; no side effects            |
| `derived data`             | Computes from other sources; no canonical state |
| `read-side`                | Read-only surface over a data layer             |
| `one-shot`                 | Runs once; not part of normal flow              |
| `historical`               | Preserved for context; do not modify            |
| `legacy`                   | Functional but slated for replacement           |

**Format:** `# role: <keyword>` or `# role: <keyword> — <what specifically>`

### When to create a sidecar

**Required — do not skip:**
- Creating a new non-trivial source file → create its sidecar in the same commit
- Editing a non-trivial file → update the sidecar if design intent or invariants changed
- Discovering buried decisions, gotchas, or cross-file invariants while working

**Not required:**
- Do NOT sidecar every file in a codebase unless explicitly asked
- Trivial files (simple configs, generated files, tiny utilities) do not need sidecars

**Why sidecars matter:**
Sidecars are stability signals and lightweight context anchors. They prevent codebase
scouring by giving future sessions exactly the non-obvious information needed to touch
a file safely — without re-reading the whole tree.

### What belongs in a sidecar

Good: why a decision was made, invariants the code assumes but doesn't enforce,
known gotchas, cross-language contracts, what NOT to do here and why.

Not: anything obvious from reading the code, narration of what the code does,
ephemeral TODOs.

### Sidecar maxims

- **Honest labels.** If something is `SPIKE`, say `SPIKE`. Hiding maturity hurts future readers.
- **Pointers matter.** Link consumers, memories, and sibling modules. The sidecar is a node in a graph, not a file in isolation.
- **A stale sidecar is worse than a missing one.** Update whenever the source's role or load-bearing invariants change.

---

## Essay convention

Long-form markdown files for working through ideas in prose — not tickets, not commit messages, not chat turns. Some thoughts need 400–800 words to settle.

- Live alongside the project or in a dedicated `/essays/` directory.
- Written by Claude, the human, or collaboratively.
- **Lifecycle:** most essays are disposable — written to think, then discarded or distilled into memory. A few earn promotion to named docs. Disposability is a feature; quality is cheap to regenerate.
- **Graduation:** moving an essay to a stable named doc is a deliberate act, not a drift.

An insight from an essay often deserves distillation into a memory; a memory describing load-bearing behavior often deserves reflection in the relevant sidecar.

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
tasks directory. State is persisted to `.claude/plan-state.json` in the
current project, so execution resumes across sessions.

**Failure behavior:** stop-and-ask on non-trivial failures.

**Auditing:** plan-executor invokes plan-auditor only on demand mid-plan,
automatically once at plan completion.

---

## Environment Map

Brandon runs a personal multi-host setup centered on a MacBook Pro M1 (primary dev + music production). Always-on infrastructure: Debian MacBook 2012 (agent host, Tailscale-routed), Raspberry Pi 4 (DNS via Pi-hole + Unbound), AWS EC2 (MusicPlatform production backend), Oracle Cloud (legacy standby). Tailscale (`tail2c0e11.ts.net`) is the cross-device network layer for personal devices; AWS and Oracle are public-IP only. All hosts have `~/.ssh/config` entries — access is always `ssh <alias>`.

### Hosts

| Host | Tailscale / IP | SSH user | Purpose |
|---|---|---|---|
| MacBook Pro M1 (`Brandons-MacBook-Pro.local`) | `m1-macbook` | — | Primary dev, Logic Pro, music production |
| Debian MacBook 2012 (`macbook-intel-2012-debian`) | `debian-macbook` | brandon | Always-on agent host; Gastown orchestration planned |
| Raspberry Pi 4 (`DietPi`) | `pi` · `100.78.214.27` | dietpi | Pi-hole + Unbound DNS; MVP config, early stage |
| Oracle Cloud (`instance-20230401-new`) | none · `129.213.56.229` | opc | Legacy standby, no active services |
| AWS EC2 (`ip-172-31-91-143`) | none · Elastic IP | ubuntu | MusicPlatform production (Docker + Nginx) |

### Major repos

| Path | Purpose |
|---|---|
| `~/Development/GitHubProjects/MusicPortfolio` | Full-stack music platform — Fastify API, Next.js, Postgres, Cloudflare CDN |
| `~/Development/Freelance/Dubsync` | Freelance client work (fullstack) |
| `~/Development/GitHubProjects/ContentAutomatorWeb/content-automator-web` | Multi-platform content posting, web (Vite/TS/Tailwind — active) |
| `~/dotfiles` | GNU Stow dotfiles — shell, Claude, tmux, git, starship |
| `~/.config/nvim` | Neovim config |

For host details see `~/.claude/environment/hosts.md`. For network and DNS see `~/.claude/environment/networks.md`. For services see `~/.claude/environment/services.md`. For repo details see `~/.claude/environment/repos.md`. The `environment-map` skill activates these on demand for cross-host or cross-repo queries.
