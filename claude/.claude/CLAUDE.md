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

- Creating a new non-trivial source file
- Asked to analyze or explain a file that lacks one
- Discovering buried decisions, gotchas, or cross-file invariants while working

### What belongs in a sidecar

Good: why a decision was made, invariants the code assumes but doesn't enforce,
known gotchas, cross-language contracts, what NOT to do here and why.

Not: anything obvious from reading the code, narration of what the code does,
ephemeral TODOs.
