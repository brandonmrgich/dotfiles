---
name: turborepo-patterns
description: Turborepo monorepo build orchestration specialist. Covers turbo.json schema (pipeline tasks, dependsOn, outputs, cache, persistent, env, globalEnv), task graph design, --filter and --affected for scoped runs, the input-based caching model (file inputs, env vars, dependency outputs), remote caching configuration, the Vercel ignoreCommand integration for skipping unnecessary preview builds, the relationship between pnpm workspaces and Turborepo, common pitfalls with package.json bin scripts vs Turbo tasks, and the difference between root and workspace-level turbo.json files. Trigger when the prompt or files in scope reference any of: turbo.json, turbo.config.js, Turborepo, turbo run, turbo build, turbo dev, turbo lint, turbo typecheck, turbo prune, turbo gen, turbo --filter, turbo --affected, turbo --scope, globalEnv, pipeline tasks, dependsOn, task outputs, remote cache, vercel.json ignoreCommand, vercel-ignore, monorepo build orchestration, pnpm-workspace.yaml. Do NOT trigger for generic monorepo questions unrelated to Turborepo. Do NOT trigger for Nx, Lerna, or other monorepo tools.
---

# Turborepo Patterns Specialist

Domain expert on Turborepo for monorepo build orchestration. Turborepo
caches task outputs based on inputs (files, env vars, dependency outputs)
and parallelizes the task graph.

## The mental model

A `turbo.json` file declares a **pipeline** — a graph of tasks (lint,
typecheck, build, test) with dependencies between them. Turborepo:

1. Computes the inputs to each task (source files, env vars, dependency
   outputs)
2. Hashes those inputs
3. Looks up the hash in a cache (local or remote)
4. If hit: replays the cached output
5. If miss: runs the task, captures the output, caches it

The cache hit ratio is the whole game. Tasks that don't cache cleanly
defeat the purpose.

## turbo.json structure

```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env.*local", "tsconfig.json"],
  "globalEnv": ["NODE_ENV"],
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "!.next/cache/**", "dist/**"],
      "env": ["NEXT_PUBLIC_API_BASE_URL"]
    },
    "lint": {
      "dependsOn": ["^build"],
      "outputs": []
    },
    "typecheck": {
      "dependsOn": ["^build"]
    },
    "test": {
      "dependsOn": ["^build"],
      "outputs": ["coverage/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    }
  }
}
```

Field meanings:

| Field | Purpose |
|---|---|
| `dependsOn` | Tasks that must complete first; `^` prefix means "this task on dependencies" |
| `outputs` | Globs of files to cache; empty array = cache the run but not files |
| `env` | Env vars that affect this task's output (cache invalidates on change) |
| `globalEnv` | Env vars that affect ALL tasks |
| `globalDependencies` | Files outside specific packages that affect all tasks |
| `cache` | Set to `false` for tasks that shouldn't cache (e.g., `dev`) |
| `persistent` | For long-running tasks like `dev` servers |

## globalEnv: when to use, when not to

`globalEnv` invalidates EVERY task's cache when the value changes. Use
sparingly:

✅ Good `globalEnv` candidates:
- Variables that affect what apps render at build time
  (e.g. `NEXT_PUBLIC_API_BASE_URL`, `NEXT_PUBLIC_BUILD_TYPE`)
- Variables that change which paths apps proxy to
- Variables that toggle build-time feature flags

❌ Bad `globalEnv` candidates:
- Variables only one app uses (put in that task's `env` instead)
- Variables that don't affect output (logging levels, etc.)
- Secrets that aren't read at build time

If a variable is only used by one task in one workspace, prefer per-task
`env` configuration:

```json
{
  "pipeline": {
    "@my-org/api#build": {
      "env": ["DATABASE_URL", "API_SECRET"]
    }
  }
}
```

## Scoped runs: --filter and --affected

```bash
# Run lint only in the admin app and its dependencies
turbo run lint --filter=@my-org/admin

# Run lint only in workspaces affected by changes since main
turbo run lint --affected

# Run lint in workspaces matching a path
turbo run lint --filter='./apps/*'

# Run lint in workspaces named "admin" only (no deps)
turbo run lint --filter=@my-org/admin --no-deps
```

`--affected` is what you want for CI on PRs. It uses git diff to determine
which workspaces changed and runs only their tasks (plus dependent
workspaces).

For `push` to the default branch, `--affected` compares `HEAD` to the
previous commit by default. If your CI uses a different base (like
`origin/main`), pass `--affected[github.event.before]...[github.event.after]`
in CI env to avoid comparing `HEAD` to itself (which would skip everything).

## The pnpm + Turbo + Vercel three-way

A common monorepo deployment pattern:

1. **pnpm workspaces** — defines what packages exist
2. **Turborepo** — orchestrates tasks across them
3. **Vercel** — deploys individual apps

The friction point: Vercel rebuilds an app on every push by default, even
if nothing in that app changed. Solution: `vercel.json` per app with
`ignoreCommand`:

```json
{
  "ignoreCommand": "node ../../scripts/vercel-ignore-app-changes.mjs"
}
```

The script runs `git diff` and exits 0 (skip build) if nothing in the
app's directory or its workspace deps changed.

Robust diff strategy:

```js
// pseudo-code
const previousSha = process.env.VERCEL_GIT_PREVIOUS_SHA  // last successful deploy
const baseSha = previousSha || await gitMergeBase('origin/main') || 'HEAD~1'
const changed = await gitDiff(baseSha, 'HEAD', appPath)
process.exit(changed ? 1 : 0)
```

Falling back to `git merge-base` (not just `HEAD~1`) handles multi-commit
pushes correctly.

## CI patterns

### Path classification + heavy job gating

Pattern: a small "classify" step inspects changed paths and outputs a
boolean. Heavy jobs (install, Turbo, build) gate on that boolean:

```yaml
# Pseudocode
- id: classify
  run: |
    if git diff --name-only HEAD~1 | grep -vE '^(docs/|README\.md)' > /dev/null; then
      echo "heavy=true" >> $GITHUB_OUTPUT
    fi

- if: steps.classify.outputs.heavy == 'true'
  run: pnpm install && turbo run lint typecheck test build --affected
```

This prevents docs-only PRs from spinning up the full build pipeline.

### Required check naming

Branch protection requiring a "single green check" works best with a
final aggregator job ("CI Status") that depends on all real jobs. When
heavy jobs are skipped (docs-only PRs), the aggregator stays green
because skipped is treated as success.

## Bin scripts vs Turbo tasks

A package's `package.json` `bin` field defines an executable shipped with
the package. Turbo tasks are defined in `turbo.json` and run via
`turbo run <task>`. They're different:

```json
// packages/db/package.json
{
  "bin": {
    "db-generate": "./bin/generate.js"
  },
  "scripts": {
    "db:generate": "prisma generate"
  }
}
```

```json
// packages/db/turbo.json
{
  "extends": ["//"],
  "pipeline": {
    "db:generate": {
      "outputs": ["src/generated/**"]
    }
  }
}
```

**Pitfall:** `pnpm --filter @my-org/db db:generate` does NOT use the
package's `turbo.json` because pnpm recursion bypasses Turbo. To get
Turbo caching, use `turbo run db:generate --filter=@my-org/db` instead.

## Remote caching

Local cache is at `.turbo/`. For team/CI sharing, configure remote cache:

```bash
turbo login
turbo link
```

Or set `TURBO_TOKEN` and `TURBO_TEAM` env vars in CI.

Remote cache fills on first build; subsequent builds (CI runners,
teammates) hit the cache and skip work.

## Common pitfalls

1. **Caching tasks that read .env files outside `env`/`globalDependencies`**
   — cache hits when it shouldn't, deploys break
2. **Forgetting outputs for cacheable tasks** — task runs but nothing
   gets cached
3. **Putting secrets in `globalEnv`** — invalidates every cache when
   the secret rotates
4. **Using `--filter='[main]'`** without understanding "since main" —
   changes since main, not "in main"
5. **`turbo run dev` with `cache: true`** — `dev` should be `cache: false,
   persistent: true`
6. **Per-workspace `turbo.json` not extending root** — must use
   `"extends": ["//"]`
7. **pnpm bypassing Turbo** — `pnpm --filter X build` skips Turbo;
   use `turbo run build --filter=X`
8. **Comparing `HEAD` to itself on push to default branch** — `--affected`
   needs explicit before/after refs in CI
9. **Including build artifacts in `globalDependencies`** — cache thrashes
   on every build
10. **Treating Turbo as a build tool** — it's an orchestrator; the
    actual building is done by per-package scripts

## What you must never do

- Do not advise replacing pnpm/npm/yarn with Turbo — they're complementary
- Do not advise running long-running processes (`dev`, `watch`) without
  `persistent: true` and `cache: false`
- Do not put secrets or per-deployment values in `globalEnv` —
  invalidates everything
