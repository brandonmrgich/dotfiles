# CLAUDE.md — dotfiles repo

## Repo structure

This is a GNU Stow-managed dotfiles repo. Each top-level directory is a **stow package** named after the tool it configures. Running `stow <package>` from `~/dotfiles` creates relative symlinks in `~` that mirror the package's directory tree.

```
dotfiles/
  claude/          → stow package → ~/.claude/
  git/             → stow package → ~/
  starship/        → stow package → ~/.config/starship.toml
  tmux/            → stow package → ~/.config/tmux/
  zsh/             → stow package → ~/
```

## Adding a new file to an existing package

1. Mirror the target path inside the package dir.
   e.g. to track `~/.claude/foo.sh` → add it at `claude/.claude/foo.sh`
2. Remove the real file from `~` if it exists.
3. Run `stow <package>` from `~/dotfiles`.

## Adding a new package

```
mkdir -p dotfiles/<tool>/<path mirroring home>
# move the real file in
stow <tool>
```

## Stow commands

```bash
# Apply a package (create symlinks)
stow -d ~/dotfiles -t ~ <package>

# Preview without applying
stow --simulate <package>

# Remove symlinks for a package
stow -D <package>

# Re-apply (delete + relink)
stow -R <package>
```

## Package notes

| Package  | Target path(s)                                  | Notes                                          |
| -------- | ----------------------------------------------- | ---------------------------------------------- |
| `claude` | `~/.claude/CLAUDE.md`, `~/.claude/statusline-command.sh`, `~/.claude/skills/`, `~/.claude/agents/`, `~/.claude/environment/` | Claude Code config, statusline, skills, agents, environment map |
| `git`    | `~/.gitconfig`                                  | User identity + LFS config                    |
| `starship` | `~/.config/starship.toml`                     | Prompt: directory + git branch/status/state   |
| `tmux`   | `~/.config/tmux/tmux.conf`                      | Prefix C-a, vim-aware nav, vi copy mode       |
| `zsh`    | `~/.zshrc`, `~/.zsh/`                           | Modular: env → omz → completion → aliases → functions → tmux |

## Invariants

- Never edit files directly in `~` — edit the source in `~/dotfiles/<package>/` and the symlink propagates.
- **Never create manual symlinks in `~`.** All symlinks must be created and owned by stow. A manually created symlink breaks stow's conflict detection and will be flagged as "not owned by stow" on the next `stow --simulate`. If you find one, remove it and re-run stow.
- `starship.toml` lives at `starship/.config/starship.toml` — stow targets `~/.config/starship.toml`.
- `starship.toml` format string drives the Claude Code statusline (`claude/.claude/statusline-command.sh`) — keep them in sync when changing prompt segments.
- `~/.zshrc.local` is intentionally untracked — use it for machine-local overrides.

## STRICT: stow sync required

**Any file added to or removed from this repo MUST be kept in sync with stow. No exceptions.**

- Before committing a new file: verify the corresponding symlink exists in `~` (run `stow --simulate <package>` to check).
- After adding a file to a package: run `stow -d ~/dotfiles -t ~ <package>` immediately — before committing.
- Never let a file live only in `~/dotfiles` without its stow symlink, or only in `~` without being tracked here.
- If a file in `~` is not yet stowed: move it into the package dir, remove the original, then run stow before committing.

Drift between the repo and the live `~` symlinks is a bug. Catch it before every commit.

## When to run stow (for Claude)

Run `stow -d ~/dotfiles -t ~ claude` after ANY of these actions:

| Action | Why |
|---|---|
| Adding a file to `claude/.claude/skills/<name>/` | New skill needs symlink |
| Adding a file to `claude/.claude/agents/<name>/` | New agent needs symlink |
| Adding a file to `claude/.claude/environment/` | New env doc needs symlink |
| Adding `claude/.claude/<anything>` | Any new tracked path needs symlink |
| Removing a tracked file | Stow may leave a dangling symlink — run `stow -R claude` |

**Do not** create files directly in `~/.claude/` — always create in `~/dotfiles/claude/.claude/` first, then stow.

Verify before committing: `ls -la ~/.claude/<new-path>` should show a symlink, not a real file.

## Tagging and releases

This is an **auto-tag-on-main** repo: every meaningful change to `main` gets a tag and a GitHub release. Tag scheme is sequential two-component semver (`vMAJOR.MINOR`, no patch component). Run `git tag --list --sort=-v:refname | head` for the current cadence.

The canonical policy lives at `~/.claude/skills/github/SKILL.md` §4 ("Auto-tag-on-main repos"). **Invoke the `github` skill before pushing to `main`** — it encodes the per-repo tagging conventions and prevents the "pushed without tagging" miss.

After landing a change on `main`:

```bash
git tag -a vX.Y -m "summary of the change"
git push origin vX.Y
gh release create vX.Y --title "vX.Y — summary" --notes "<release notes>"
```

Bump MINOR for new features, conventions, or substantive doc additions. Bump MAJOR (and reset MINOR to 0) for breaking changes or large restructures.

Trivial config tweaks may skip the PR but never skip the tag — the tag is the "released to my machines" signal, distinct from the commit. If a change feels too small to tag, it's worth bundling with the next change rather than landing it untagged.

> **Provisional.** The two-component scheme collapses "patch" and "minor" severity onto the same axis. Redesign tracked at `~/.claude/ideas/dotfiles-versioning-redesign.md`.
