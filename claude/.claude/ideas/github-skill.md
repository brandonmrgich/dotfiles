Prompt — Create github Skill

Run AFTER the gitignore skill is committed. Paste into a fresh Claude Code session opened inside ~/dotfiles.

Goal: create a new user-wide skill `[HomebrewSkill] github` that is the policy/discipline layer for git/GitHub operations. The existing `commit-commands` plugin (`/commit`, `/commit-push-pr`, `/clean_gone`) stays — those are command runners. This new skill encodes the rules they (and Claude) respect.

## Context — read first

1. Verify prerequisites:
   - `~/dotfiles/claude/.claude/skills/gitignore/SKILL.md` exists.
   - `~/dotfiles/claude/.claude/references/plan-system.md` exists.

2. Read the skill-author skill:
   - `~/dotfiles/claude/.claude/skills/skill-author/SKILL.md`

3. Read the console-discipline reference (created by coherence-audit) — the github skill must cite it for "long content goes in PR body, not chat":
   - `~/dotfiles/claude/.claude/references/console-discipline.md`

4. Read worktree-orchestrator — the github skill must cross-reference it without restating its merge policy:
   - `~/dotfiles/claude/.claude/skills/worktree-orchestrator/SKILL.md`

5. Inspect repo-specific tag/release patterns (do not modify):
   - `cd ~/dotfiles && git tag --sort=-creatordate | head -10`
   - `cd ~/.config/nvim && git tag --sort=-creatordate | head -10`
   - `cd ~/Development/music-platform-monorepo && git tag --sort=-creatordate | head -5`
   - `cd ~/Development/GitHubProjects/MusicPortfolio && git tag --sort=-creatordate | head -5`

   Note the patterns. Auto-tag-on-main repos (dotfiles, nvim) typically have many sequential semver tags; branch-and-PR repos have sparser, milestone-aligned tags.

## Phase 1 — Author the skill

Create `~/dotfiles/claude/.claude/skills/github/SKILL.md`.

Frontmatter:

```yaml
name: "[HomebrewSkill] github"
description: "Activate when pushing, opening a PR, merging, tagging, releasing, or hitting permission/auth issues during git operations. Also activate when working in a non-interactive context (plan-executor, worktree-orchestrator, scheduled agents) where a PIN/passphrase prompt would hang the session. Encodes commit message standards, PR body templates, tag/release conventions per repo type, push/force-push/--no-verify policies, and pre-flight auth checklists."
```

The SKILL.md body, in this order. Section 1 is load-bearing — put it first.

### 1. Headless safety

Define non-interactive contexts: plan-executor sessions, worktree-orchestrator merges, scheduled agents (CronCreate triggers), anything where the user is not at the terminal to enter a PIN/passphrase.

**Pre-flight auth check before any push** in non-interactive context:
- `gh auth status` returns clean.
- `ssh-add -l` lists at least one key (if the remote is SSH).
- gpg-agent has the signing key cached if `git config commit.gpgsign` is `true` — verify with `echo "test" | gpg --clearsign 2>&1 | grep -q PASSPHRASE` (failure means agent will prompt).

If auth is not pre-cached and a PIN/passphrase would be required: **HALT** with a message like "auth not pre-cached; push would hang on PIN prompt — pre-auth (`ssh-add`, `gpg --sign /dev/null`, or `gh auth refresh`) and re-run." Do not attempt the push.

For interactive sessions, normal auth flows are fine — the user is there to enter the PIN.

### 2. Commit message standards

- Read the last 10 commits before writing one (`git log -10 --format='%s'`); match the existing style (conventional commits, gitmoji, plain — whatever the repo uses).
- Imperative mood, lowercase first word after the type prefix.
- Subject under 70 characters.
- Body explains WHY, not WHAT. The diff shows what changed; the body explains why.
- No trailing summaries that just restate the diff.
- Co-author trailer when Claude wrote the commit.

### 3. PR body standards

- Title: under 70 characters, no trailing period, matches commit-style prefix if the repo uses one.
- Body sections, in this order:
  - `## Summary` — 1–3 bullets of what changed and why.
  - `## Test plan` — markdown checklist of what was verified or needs verification.
  - `## Notes` (optional) — caveats, deferred work, follow-ups.
- Link related issues (`Closes #123`), plans, or worktree branch names.
- For worktree-orchestrator-driven PRs, include the audit verdict and worktree branch name. Defer to worktree-orchestrator skill for the exact format — do not restate.
- Long content (release notes, migration steps, audit transcripts) belongs in the PR body, not in chat replies. Cite `~/.claude/references/console-discipline.md`.

### 4. Tag and release conventions

Two repo styles:

**Auto-tag-on-main repos** (`~/dotfiles`, `~/.config/nvim`, similar personal/config repos):
- Small changes commit directly to `main`.
- Increment version after each meaningful change: semver patch for trivial, minor for new features, major for breaking.
- Tag: `git tag -a vX.Y.Z -m "message"` then `git push --tags`.
- Skip PR for trivial config tweaks. Always PR for non-trivial or breaking changes.

**Branch-and-PR repos** (`MusicPortfolio`, `ContentAutomatorWeb`, `music-platform-monorepo`, etc.):
- All changes go through a feature branch + PR. Never direct to `main`.
- Tags are cut from `main` after a meaningful release boundary, not per-commit.
- Releases follow the project's release process (often `gh release create`).

Identify which style a repo uses by checking, in order:
1. Branch protection: `gh api repos/:owner/:repo/branches/main/protection 2>/dev/null` — protected = branch-and-PR.
2. Recent commit history: `git log --first-parent main -20 --format='%s'` — many merge commits = branch-and-PR; many direct commits = auto-tag-on-main.
3. CLAUDE.md if present — explicit project policy wins.

If unclear, ask the user.

### 5. Push policy

- Never `push --force` to `main` or `master`. Force-push to feature branches is permitted.
- `--no-verify` to skip hooks: forbidden unless the user explicitly authorizes that exact push. Hook failures are signal, not noise — fix the underlying issue.
- Never `--amend` a published commit (one already pushed). Create a new commit instead.
- Never `git reset --hard` without confirming with the user when uncommitted work exists.

### 6. Permission troubleshooting recipes

For each common failure mode, the recipe:

- **`remote rejected (push protection)`** — secret detected by GitHub. Reset the commit (`git reset HEAD~1`), remove the secret, re-commit. If already merged, rotate the secret regardless.
- **`Permission denied (publickey)`** — ssh agent missing key. `ssh-add ~/.ssh/<key>`. Check `~/.ssh/config` Host alias matches the remote URL.
- **`gpg failed to sign the data`** — gpg-agent not running or key not cached. `gpgconf --launch gpg-agent`. Verify `git config user.signingkey` matches a present key. Test: `echo test | gpg --clearsign`.
- **`could not read Username for 'https://github.com'`** — gh auth missing or HTTPS remote without token. `gh auth login`, or switch remote to SSH (`git remote set-url origin git@github.com:...`).
- **`Updates were rejected because the remote contains work that you do not have`** — branch is behind. `git fetch && git rebase origin/<branch>` (feature branches) or `git pull --rebase` (per repo policy). Resolve conflicts before pushing.
- **`error: GH013: Repository rule violations`** — branch protection blocking. Read the rule, comply, retry.

### 7. Worktree-orchestrator interaction

- When merging a worktree branch, defer to worktree-orchestrator's prepare-merge flow. Do not bypass it.
- Cite: see `~/.claude/skills/worktree-orchestrator/SKILL.md` for the canonical merge sequence.
- The github skill provides the policies (PR body format, tag conventions); worktree-orchestrator provides the mechanics (when to merge, conflict resolution).

### 8. Cross-references

- Command runners: `commit-commands` plugin (`/commit`, `/commit-push-pr`, `/clean_gone`) — these execute the operations the github skill governs.
- Plan-system paths: `~/.claude/references/plan-system.md`.
- Console / output discipline: `~/.claude/references/console-discipline.md`.
- Worktree merging: worktree-orchestrator skill.
- Gitignore rules: gitignore skill.

## Phase 2 — Stow + commit

1. Run `stow -d ~/dotfiles -t ~ claude`.
2. Verify: `ls -la ~/.claude/skills/github/SKILL.md` shows a symlink.
3. Single commit titled: `feat(claude): add github policy skill`.

## Stop-and-ask conditions

- If `~/dotfiles` or `~/.config/nvim` show no recent tags or stale tagging patterns, stop and ask whether the skill should encode actual current behavior or aspirational behavior.
- If `commit-commands` plugin commands appear to violate any policy you're encoding, stop and surface the conflict before committing the skill.
- If a `github` skill already exists at the target path, stop and ask before overwriting.

## Out of scope (this round)

The github skill describes headless-safety policy. The actual *enforcement* — pre-flight auth check at plan-executor / worktree-orchestrator session start — is a separate future tightening pass. See `~/dotfiles/claude/.claude/ideas/git-auth-preflight.md` for the deferred work.
