---
name: turborepo-patterns
class: specialist
description: "Use when the prompt or files in scope reference Turborepo: turbo.json / turbo.config.js (root vs workspace-level), pipeline tasks, dependsOn, outputs, cache, persistent, env, globalEnv, turbo run / build / dev / lint / typecheck / prune / gen, --filter / --affected / --scope, the input-based caching model (file inputs, env vars, dependency outputs), remote cache configuration, vercel.json ignoreCommand / vercel-ignore for preview-build skipping, pnpm-workspace.yaml + Turborepo integration, package.json bin scripts vs Turbo tasks pitfalls, and monorepo build orchestration generally. Do NOT trigger for generic monorepo questions unrelated to Turborepo. Do NOT trigger for Nx, Lerna, or other monorepo tools."
---

# Turborepo Patterns Specialist

Domain expert on Turborepo for monorepo build orchestration. Turborepo
caches task outputs based on inputs (files, env vars, dependency outputs)
and parallelizes the task graph.

## The mental model

`turbo.json` declares a **pipeline** — a graph of tasks (lint, typecheck,
build, test) with dependencies. For each task: hash inputs (source files,
env vars, dependency outputs) → cache lookup → replay on hit, run + cache
on miss. Cache hit ratio is the whole game; tasks that don't cache
cleanly defeat the purpose.

## turbo.json structure

**Full example:** `~/.claude/skills/turborepo-patterns/examples/turbo.json.example`
— root pipeline covering build, lint, typecheck, test, dev with the
common dependsOn/outputs/env patterns.

| Field | Purpose |
|---|---|
| `dependsOn` | Tasks that must complete first; `^` prefix = "this task on dependencies" |
| `outputs` | Globs of files to cache; empty array = cache the run but not files |
| `env` | Env vars that affect this task's output (cache invalidates on change) |
| `globalEnv` | Env vars that affect ALL tasks |
| `globalDependencies` | Files outside specific packages that affect all tasks |
| `cache` | `false` for tasks that shouldn't cache (e.g., `dev`) |
| `persistent` | For long-running tasks like `dev` servers |

## globalEnv: when to use, when not to

`globalEnv` invalidates EVERY task's cache when the value changes. Use sparingly.

✅ Good:
- Vars that affect what apps render at build time (`NEXT_PUBLIC_API_BASE_URL`, `NEXT_PUBLIC_BUILD_TYPE`)
- Vars that change which paths apps proxy to
- Build-time feature flag toggles

❌ Bad:
- Vars only one app uses → put in that task's `env`
- Vars that don't affect output (logging levels)
- Secrets not read at build time

If a variable is only used by one task, prefer per-task `env` (e.g.
`"@my-org/api#build": { "env": ["DATABASE_URL", "API_SECRET"] }`).

## Scoped runs: --filter and --affected

```bash
turbo run lint --filter=@my-org/admin       # app + its deps
turbo run lint --filter=@my-org/admin --no-deps  # app only
turbo run lint --filter='./apps/*'          # path glob
turbo run lint --affected                   # changed workspaces (CI on PRs)
```

`--affected` uses git diff. On `push` to default branch it compares
`HEAD` to the previous commit by default — if your CI uses a different
base (like `origin/main`), pass
`--affected[github.event.before]...[github.event.after]` to avoid
comparing `HEAD` to itself (skips everything). `--scope` is the legacy
synonym for `--filter`; prefer `--filter`.

## The pnpm + Turbo + Vercel three-way

pnpm workspaces define what packages exist; Turborepo orchestrates tasks
across them; Vercel deploys individual apps. Friction: Vercel rebuilds
every app on every push by default. Solution: per-app `vercel.json` with
an `ignoreCommand` script that runs `git diff` and exits 0 (skip build)
when nothing in the app's directory or its workspace deps changed.

**Full example:** `~/.claude/skills/turborepo-patterns/examples/vercel-ignore.js`
— ignoreCommand with three-tier base-SHA fallback
(`VERCEL_GIT_PREVIOUS_SHA` → `git merge-base origin/main` → `HEAD~1`)
for correct multi-commit pushes.

## CI patterns

**Path classification + heavy job gating.** A small "classify" step
inspects changed paths and outputs a boolean; heavy jobs (install, Turbo,
build) gate on it so docs-only PRs skip the full pipeline.

**Required check naming.** Branch protection requiring a "single green
check" works best with a final aggregator job ("CI Status") that depends
on all real jobs — skipped is treated as success, so the aggregator
stays green on docs-only PRs.

## Bin scripts vs Turbo tasks

Two different layers: `bin` (in `package.json`) ships an executable to
downstream consumers; a Turbo task (in `turbo.json`) orchestrates
monorepo runs and adds caching. Per-package `turbo.json` must use
`"extends": ["//"]` to inherit the root pipeline.

**Pitfall:** `pnpm --filter @my-org/db db:generate` does NOT use the
package's `turbo.json` — pnpm recursion bypasses Turbo. Use
`turbo run db:generate --filter=@my-org/db` for caching.

**Full example:** `~/.claude/skills/turborepo-patterns/examples/bin-vs-turbo-task.example`
— paired `package.json` + per-package `turbo.json` for a `db:generate` task.

## Remote caching

Local cache is at `.turbo/`. For team/CI sharing: `turbo login && turbo
link`, or set `TURBO_TOKEN` and `TURBO_TEAM` in CI. Remote cache fills
on first build; subsequent builds (CI runners, teammates) hit it.

## Common pitfalls

1. **Reading `.env` files outside `env`/`globalDependencies`** — cache hits when it shouldn't, deploys break
2. **Forgetting `outputs` for cacheable tasks** — task runs but nothing gets cached
3. **Secrets in `globalEnv`** — invalidates every cache when the secret rotates
4. **`--filter='[main]'` misread** — that's "since main", not "in main"
5. **`turbo run dev` with `cache: true`** — `dev` should be `cache: false, persistent: true`
6. **Per-workspace `turbo.json` not extending root** — must use `"extends": ["//"]`
7. **pnpm bypassing Turbo** — `pnpm --filter X build` skips Turbo; use `turbo run build --filter=X`
8. **`HEAD` compared to itself on push to default** — `--affected` needs explicit before/after refs in CI
9. **Build artifacts in `globalDependencies`** — cache thrashes on every build
10. **Treating Turbo as a build tool** — it's an orchestrator; per-package scripts do the actual building

## What you must never do

- Do not advise replacing pnpm/npm/yarn with Turbo — they're complementary
- Do not advise running `dev`/`watch` without `persistent: true` and `cache: false`
- Do not put secrets or per-deployment values in `globalEnv` — invalidates everything
