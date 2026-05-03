---
name: "[HomebrewSkill] gitignore"
description: "Activate when editing or auditing a .gitignore, when creating a new tracked path that may need ignoring, or when the user asks 'should this be tracked?', 'what do we ignore?', 'audit the gitignore'. Encodes per-context ignore rules (dotfiles vs project vs monorepo), the canonical .claude/ ignore catalog with justification, and general best practices (env files, build artifacts, OS noise, IDE noise, lockfiles policy)."
---

# Gitignore Skill

Policy and catalog for `.gitignore` management. Encodes the canonical Claude-system
ignore rules and general best practices.

---

## 1. When to activate

**Activate on:**
- Editing or creating a `.gitignore`
- Adding a new file/directory that might need ignoring
- User asks "should this be tracked?", "what do we ignore?", "audit the gitignore"

**Stay quiet for:** unrelated git operations, commits, branch management.

---

## 2. The `.claude/` ignore catalog

See `~/.claude/references/plan-system.md` for the authoritative plan-related rules.
This catalog adds justification for each entry.

| Path | Rule | Justification |
|------|------|---------------|
| `.claude/plan-states/` | Always ignore | Runtime state; machine-local; not reproducible from source |
| `.claude/plan-completion-report.md` | Always ignore | Transient artifact; outcome lives in git history |
| `.claude/settings.local.json` | Always ignore | Machine-local overrides; may contain secrets |
| `.claude/worktree-registry.json` | Always ignore | Machine-local; path depends on local directory layout |
| `.claude/plans/` | **Dotfiles: ignore. Project repos: track.** | Dotfiles has no plans to run; project plans are source input |
| `.claude/skills/` | Always track | Skills are authored config, not runtime state |
| `.claude/agents/` | Always track | Same as skills |
| `.claude/essays/` | Always track | Essays are authored reasoning, not transient artifacts |
| `.claude/references/` | Always track | Authored reference docs |

Old paths no longer used (remove if present — they have no effect and add noise):
- `.claude/plan-state.json` — replaced by `.claude/plan-states/<name>.json`
- `.claude/plan-executor.log` — replaced by `.claude/plan-states/<name>.log`
- `.claude/plan-artifacts/` — no longer in use
- `.claude/audits/` — audits now live alongside plan task dirs

---

## 3. Per-context rules

### Dotfiles repo

Ignore both `.claude/plans/` and `.claude/plan-states/`. No plans are executed from
dotfiles itself; plan inputs have no place here.

```gitignore
.claude/plan-states/
.claude/plan-completion-report.md
.claude/plans/
.claude/settings.local.json
```

### Single-project repo

Track `.claude/plans/` (plan inputs are part of project history — auditable, versioned).
Ignore `.claude/plan-states/` (runtime state).

```gitignore
.claude/plan-states/
.claude/plan-completion-report.md
.claude/settings.local.json
```

### Monorepo with workspaces

Same as single-project at the root. Per-package `.gitignore` files only when a package
has unique artifacts not covered by the root (e.g., a package with its own `dist/`
that the root ignore doesn't catch).

---

## 4. General best practices

### Env files
```gitignore
.env
.env.local
.env.*.local
```
Always ignore. Track `.env.example` (never ignore it).

### Build artifacts
```gitignore
dist/
build/
.next/
target/
out/
```

### Dependency directories
```gitignore
node_modules/
vendor/
.venv/
```

### OS noise
```gitignore
.DS_Store
Thumbs.db
desktop.ini
```

### IDE noise
- Ignore user-local files: `.idea/`, `.vscode/launch.json`
- Track shared settings if team-standardized: `.vscode/settings.json`, `.vscode/extensions.json`
- Default: ignore the whole `.vscode/` unless the project explicitly opts in to sharing settings

### Logs and caches
```gitignore
*.log
npm-debug.log*
.cache/
.turbo/
.parcel-cache/
```

---

## 5. Lockfile policy

Always track: `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `Cargo.lock`,
`Gemfile.lock`, `poetry.lock`. Never ignore.

**Exception:** libraries (not applications) sometimes omit lockfiles to avoid pinning
consumers. Document the project's choice in CLAUDE.md if deviating.

---

## 6. Anti-patterns

- **Ignoring already-committed files** — the entry has no effect; must `git rm --cached <file>` first.
- **Broad globs** — `*.log` is fine; `*` is not. Always test with `git check-ignore -v <file>`.
- **Nested `.gitignore` without rationale** — centralize at repo root unless a package genuinely has unique artifacts.
- **Adding secrets to `.gitignore` after commit** — history still has them. Rotate the secret first, then ignore.
- **Stale entries** — paths that no longer exist add noise. Remove them during audits.

---

## 7. Audit recipe

When asked to audit a `.gitignore`:

1. Read top to bottom.
2. Check every entry against this catalog and best practices.
3. Flag **orphan ignores**: entries with no clear justification.
4. Flag **missing always-ignored entries**: especially Claude runtime artifacts.
5. Flag **stale legacy entries**: old Claude paths (`plan-state.json`, `plan-executor.log`, etc.).
6. Verify no tracked file matches an ignore pattern:
   ```
   git ls-files --others --ignored --exclude-standard
   ```
   If output is non-empty, those files are ignored but untracked — check if they should be.
7. Report as a table: `| Entry | Status | Action |`
