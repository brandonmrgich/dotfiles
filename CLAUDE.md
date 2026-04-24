# CLAUDE.md — dotfiles repo

## Repo structure

This is a GNU Stow-managed dotfiles repo. Each top-level directory is a **stow package** named after the tool it configures. Running `stow <package>` from `~/dotfiles` creates relative symlinks in `~` that mirror the package's directory tree.

```
dotfiles/
  claude/          → stow package → ~/.claude/
  git/             → stow package → ~/
  starship/        → stow package → ~/
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
| `claude` | `~/.claude/CLAUDE.md`, `~/.claude/statusline-command.sh` | Claude Code config + statusline script |
| `git`    | `~/.gitconfig`                                  | User identity + LFS config                    |
| `starship` | `~/starship.toml`                             | Prompt: directory + git branch/status/state   |
| `tmux`   | `~/.config/tmux/tmux.conf`                      | Prefix C-a, vim-aware nav, vi copy mode       |
| `zsh`    | `~/.zshrc`, `~/.zsh/`                           | Modular: env → omz → completion → aliases → functions → tmux |

## Invariants

- Never edit files directly in `~` — edit the source in `~/dotfiles/<package>/` and the symlink propagates.
- `starship.toml` format string drives the Claude Code statusline (`claude/.claude/statusline-command.sh`) — keep them in sync when changing prompt segments.
- `~/.zshrc.local` is intentionally untracked — use it for machine-local overrides.
