---
name: "[HomebrewSkill] github"
description: "Activate when pushing, opening a PR, merging, tagging, releasing, or hitting permission/auth issues during git operations. Also activate when working in a non-interactive context (plan-executor, worktree-orchestrator, scheduled agents) where a PIN/passphrase prompt would hang the session. Encodes commit message standards, PR body templates, tag/release conventions per repo type, push/force-push/--no-verify policies, and pre-flight auth checklists."
---

# Github Skill

Policy and discipline layer for git/GitHub operations. The `commit-commands` plugin
(`/commit`, `/commit-push-pr`, `/clean_gone`) executes the operations this skill governs.

---

## 1. Headless safety (read this first)

**Non-interactive contexts:** plan-executor sessions, worktree-orchestrator merges,
scheduled agents (CronCreate triggers), anything where the user is not at the terminal
to enter a PIN/passphrase.

### Pre-flight auth check — required before any push in a non-interactive context

```bash
gh auth status                          # must return clean
ssh-add -l                              # must list at least one key (SSH remotes)
echo "test" | gpg --clearsign 2>&1 | grep -q PASSPHRASE  # must NOT match (signing repos)
```

If auth is not pre-cached and a PIN/passphrase would be required: **HALT.**

Print: "auth not pre-cached; push would hang on PIN prompt — pre-auth (`ssh-add`,
`gpg --sign /dev/null`, or `gh auth refresh`) and re-run."

Do not attempt the push. Do not retry.

For interactive sessions: normal auth flows are fine — the user is present.

---

## 2. Commit message standards

- Read last 10 commits before writing one: `git log -10 --format='%s'`. Match the repo's style (conventional commits, plain imperative, etc.).
- Imperative mood, lowercase first word after type prefix.
- Subject under 70 characters.
- Body explains WHY, not WHAT. The diff shows what changed.
- No trailing summaries that restate the diff.
- Co-author trailer when Claude wrote the commit:
  ```
  Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
  ```
- Plan-executor commits append plan attribution footers (see plan-executor skill):
  ```
  Plan: <plan-name>
  Task: <task-id>
  ```

---

## 3. PR body standards

- **Title:** under 70 characters, no trailing period, matches commit-style prefix if the repo uses one.
- **Body sections in order:**
  ```
  ## Summary
  <1–3 bullets: what changed and why>

  ## Test plan
  <markdown checklist of what was verified or needs verification>

  ## Notes (optional)
  <caveats, deferred work, follow-ups>
  ```
- Link related issues (`Closes #123`), plan names, or worktree branch names.
- For worktree-orchestrator PRs: include the audit verdict and worktree branch name.
  Defer to worktree-orchestrator skill for exact format — do not restate.
- Long content (release notes, migration steps, audit transcripts) belongs in the PR
  body, not in chat. See `~/.claude/references/console-discipline.md`.

---

## 4. Tag and release conventions

### Auto-tag-on-main repos
`~/dotfiles`, `~/.config/nvim`, similar personal config repos.

- Small changes commit directly to `main`.
- Increment version after each meaningful change: patch for trivial, minor for new features, major for breaking.
- Tag: `git tag -a vX.Y.Z -m "message"` then `git push --tags`.
- Skip PR for trivial config tweaks. Always PR for non-trivial or breaking changes.
- Current cadence: sequential semver (v1.1, v1.2, ... v2.0).

### Branch-and-PR repos
`MusicPortfolio`, `ContentAutomatorWeb`, `music-platform-monorepo`, and similar.

- All changes go through a feature branch + PR. Never direct to `main`.
- Tags are cut from `main` after a meaningful release boundary, not per-commit.
- Use `gh release create vX.Y.Z` for formal releases.
- Confirmed branch-and-PR: all MusicPortfolio `main` commits are merge commits.

### Identifying repo style (in order)

1. Branch protection: `gh api repos/:owner/:repo/branches/main/protection 2>/dev/null` — protected = branch-and-PR.
2. Commit history: `git log --first-parent main -20 --format='%s'` — many merge commits = branch-and-PR; many direct commits = auto-tag-on-main.
3. CLAUDE.md if present — explicit policy wins.

If unclear, ask the user.

---

## 5. Push policy

- **Never `push --force` to `main` or `master`.** Force-push to feature branches is permitted with explicit user confirmation.
- **`--no-verify` is forbidden** unless the user explicitly authorizes that exact push. Hook failures are signal — fix the underlying issue.
- **Never `--amend` a published commit** (already pushed). Create a new commit instead.
- **Never `git reset --hard`** without confirming uncommitted work is intentionally discarded.

---

## 6. Permission troubleshooting recipes

| Failure | Recipe |
|---------|--------|
| `remote rejected (push protection)` | Secret detected. `git reset HEAD~1`, remove secret, re-commit. If merged: rotate the secret regardless. |
| `Permission denied (publickey)` | `ssh-add ~/.ssh/<key>`. Check `~/.ssh/config` Host alias matches the remote URL. |
| `gpg failed to sign the data` | `gpgconf --launch gpg-agent`. Verify `git config user.signingkey`. Test: `echo test | gpg --clearsign`. |
| `could not read Username for 'https://github.com'` | `gh auth login`, or switch remote to SSH: `git remote set-url origin git@github.com:...` |
| `Updates were rejected because the remote contains work` | `git fetch && git rebase origin/<branch>` (feature branches). Resolve conflicts before pushing. |
| `error: GH013: Repository rule violations` | Read the rule, comply, retry. |

---

## 7. Worktree-orchestrator interaction

When merging a worktree branch, defer to worktree-orchestrator's prepare-merge flow.
Do not bypass it. The github skill provides the policies (PR body format, tag conventions);
worktree-orchestrator provides the mechanics (when to merge, conflict resolution).

See `~/.claude/skills/worktree-orchestrator/SKILL.md` for the canonical merge sequence.

---

## 8. Cross-references

| What | Where |
|------|-------|
| Command runners (`/commit`, `/commit-push-pr`, `/clean_gone`) | `commit-commands` plugin |
| Plan filesystem paths | `~/.claude/references/plan-system.md` |
| Output discipline (long content → PR body, not chat) | `~/.claude/references/console-discipline.md` |
| Worktree merge sequence | `~/.claude/skills/worktree-orchestrator/SKILL.md` |
| Gitignore rules | `~/.claude/skills/gitignore/SKILL.md` |

---

## Out of scope (this version)

Actual enforcement of the pre-flight auth check at plan-executor / worktree-orchestrator
session start is a separate future pass. See `~/.claude/ideas/git-auth-preflight.md`.
