---
title: Sidecar conventions
description: Full sidecar-file taxonomy — label table, role table, when-to-create rules, maxims. Referenced from ~/.claude/CLAUDE.md.
static: true
---

# Sidecar conventions

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
