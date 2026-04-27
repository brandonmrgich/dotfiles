Prompt — Create gitignore Skill

Run AFTER Prompt B (essays-skill) is committed. Paste into a fresh Claude Code session opened inside ~/dotfiles.

Goal: create a new user-wide skill `[HomebrewSkill] gitignore` that encodes best practices for `.gitignore` management plus the canonical Claude-system ignore catalog with justification.

## Context — read first

1. Verify prerequisites are committed:
   - `~/dotfiles/claude/.claude/references/plan-system.md` exists (from coherence-audit prompt)
   - `~/dotfiles/claude/.claude/skills/doc-freshness/SKILL.md` exists (from changelog-migration / Prompt A)
   - `~/dotfiles/claude/.claude/skills/essay/SKILL.md` exists (from essays-skill / Prompt B)

   If any prerequisite is missing, stop and report.

2. Read the skill-author skill so you follow `[HomebrewSkill]` naming and scoping conventions:
   - `~/dotfiles/claude/.claude/skills/skill-author/SKILL.md`

3. Read the canonical plan-system reference — your authoritative source for plan-related ignore rules:
   - `~/dotfiles/claude/.claude/references/plan-system.md`

4. Read existing `.gitignore` files for the practical catalog:
   - `~/dotfiles/.gitignore`
   - `~/Development/music-platform-monorepo/.gitignore` (if present)
   - `~/Development/GitHubProjects/MusicPortfolio/.gitignore` (if present)

## Phase 1 — Author the skill

Create `~/dotfiles/claude/.claude/skills/gitignore/SKILL.md`. Use skill-author conventions.

Frontmatter:

```yaml
name: "[HomebrewSkill] gitignore"
description: "Activate when editing or auditing a .gitignore, when creating a new tracked path that may need ignoring, or when the user asks 'should this be tracked?', 'what do we ignore?', 'audit the gitignore'. Encodes per-context ignore rules (dotfiles vs project vs monorepo), the canonical .claude/ ignore catalog with justification, and general best practices (env files, build artifacts, OS noise, IDE noise, lockfiles policy)."
```

The SKILL.md body, in this order:

### 1. When to activate

Explicit triggers and when to stay quiet. Activate on `.gitignore` edits, new tracked path additions, and audit requests. Stay quiet for unrelated git operations.

### 2. The `.claude/` ignore catalog

For each path, state always-ignored vs conditionally-tracked, plus a one-line justification. Include at minimum:

- `.claude/plan-states/` — always ignored. Cite plan-system reference.
- `.claude/plans/` — conditionally tracked (project policy). Cite plan-system reference.
- `.claude/plan-completion-report.md` — always ignored.
- `.claude/settings.local.json` — always ignored (machine-local overrides; secrets risk).
- `.claude/worktree-registry.json` if present — always ignored (machine-local).
- Any other Claude runtime artifacts you discover during the read phase.

Cite `~/.claude/references/plan-system.md` as the authority for plan-related entries — do not restate plan-system rules inline.

### 3. Per-context rules

What differs between:

- **Dotfiles repo** — no plans run here; ignore both `.claude/plans/` and `.claude/plan-states/`.
- **Single-project repo** — track `.claude/plans/` (plan inputs are part of the project history); ignore `.claude/plan-states/`.
- **Monorepo with workspaces** — same as single-project at the root; per-package `.gitignore` files only when a package has unique artifacts.

State the rationale for each.

### 4. General best practices

- Env files: `.env`, `.env.local`, `.env.*.local` — always ignore. Track `.env.example`.
- Build artifacts: `dist/`, `build/`, `.next/`, `target/`, `out/` — always ignore.
- Dependency dirs: `node_modules/`, `vendor/`, `.venv/` — always ignore.
- OS noise: `.DS_Store`, `Thumbs.db`, `desktop.ini` — always ignore.
- IDE noise: `.idea/`, `.vscode/` — track shared settings (e.g. `.vscode/settings.json` if team-standardized), ignore user-local files (`.vscode/launch.json` if user-specific).
- Logs: `*.log`, `npm-debug.log*` — ignore.
- Caches: `.cache/`, `.turbo/`, `.parcel-cache/` — ignore.

### 5. Lockfile policy

Always track `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `Cargo.lock`, `Gemfile.lock`, `poetry.lock`. Never ignore.

Exception: libraries (not applications) sometimes ignore lockfiles to avoid version pinning. Document the project's choice in CLAUDE.md.

### 6. Anti-patterns

- Ignoring already-committed files (entry has no effect; must `git rm --cached` first).
- Broad globs that catch wanted files (e.g., `*.log` catching `CHANGELOG.md` if poorly named — unlikely but illustrates the risk).
- `.gitignore` in nested dirs without rationale (centralize at repo root unless package-specific).
- Adding secrets to `.gitignore` after commit (history still has them — rotate the secret, don't just ignore).

### 7. Audit recipe

How to audit an existing `.gitignore`:

1. Read top to bottom.
2. Check every entry against this skill's catalog and best practices.
3. Flag entries with no clear justification (orphan ignores).
4. Flag missing always-ignored entries (especially Claude runtime artifacts).
5. Verify no tracked file matches an ignore pattern (`git ls-files --others --ignored --exclude-standard`).

## Phase 2 — Stow + commit

1. Run `stow -d ~/dotfiles -t ~ claude`.
2. Verify: `ls -la ~/.claude/skills/gitignore/SKILL.md` shows a symlink.
3. Single commit titled: `feat(claude): add gitignore skill`.

## Stop-and-ask conditions

- If any always-ignored Claude path appears tracked in a real project's `.gitignore`, stop and ask whether to flag the project for cleanup.
- If per-context rules conflict with what's actually in `~/dotfiles/.gitignore`, stop and ask before reconciling.
- If a `gitignore` skill already exists at the target path, stop and ask before overwriting.
