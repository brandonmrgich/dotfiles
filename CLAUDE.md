# CLAUDE.md — dotfiles repo

> **Claude config moved.** The user-level Claude Code configuration that
> previously lived under `claude/.claude/` (CLAUDE.md, skills, agents,
> environment map, statusline, mantras, references, ideas, essays, tools)
> now lives in a dedicated repo:
> [`brandonmrgich/bam-claude`](https://github.com/brandonmrgich/bam-claude).
>
> Touching anything under `~/.claude/`? Edit the source in
> `~/Development/GithubTools/bam-claude/` and run
> `stow -d .. -t ~/.claude -R bam-claude` from that repo. **Do not** add a
> `claude` package back into this repo.

## Repo structure

This is a GNU Stow-managed dotfiles repo. Each top-level directory is a **stow package** named after the tool it configures. Running `stow <package>` from `~/dotfiles` creates relative symlinks in `~` that mirror the package's directory tree.

```
dotfiles/
  git/             → stow package → ~/
  starship/        → stow package → ~/.config/starship.toml
  tmux/            → stow package → ~/.config/tmux/
  zsh/             → stow package → ~/
```

## Adding a new file to an existing package

1. Mirror the target path inside the package dir.
   e.g. to track `~/.config/foo/bar.toml` → add it at `<package>/.config/foo/bar.toml`
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

| Package    | Target path(s)                  | Notes                                                       |
| ---------- | ------------------------------- | ----------------------------------------------------------- |
| `git`      | `~/.gitconfig`                  | User identity + LFS config                                  |
| `starship` | `~/.config/starship.toml`       | Prompt: directory + git branch/status/state                 |
| `tmux`     | `~/.config/tmux/tmux.conf`      | Prefix C-a, vim-aware nav, vi copy mode                     |
| `zsh`      | `~/.zshrc`, `~/.zsh/`           | Modular: env → omz → completion → aliases → functions → tmux |

## Invariants

- Never edit files directly in `~` — edit the source in `~/dotfiles/<package>/` and the symlink propagates.
- **Never create manual symlinks in `~`.** All symlinks must be created and owned by stow. A manually created symlink breaks stow's conflict detection and will be flagged as "not owned by stow" on the next `stow --simulate`. If you find one, remove it and re-run stow.
- `starship.toml` lives at `starship/.config/starship.toml` — stow targets `~/.config/starship.toml`.
- `~/.zshrc.local` is intentionally untracked — use it for machine-local overrides.
- Anything Claude-related belongs in `~/Development/GithubTools/bam-claude/`, not here.

## STRICT: stow sync required

**Any file added to or removed from this repo MUST be kept in sync with stow. No exceptions.**

- Before committing a new file: verify the corresponding symlink exists in `~` (run `stow --simulate <package>` to check).
- After adding a file to a package: run `stow -d ~/dotfiles -t ~ <package>` immediately — before committing.
- Never let a file live only in `~/dotfiles` without its stow symlink, or only in `~` without being tracked here.
- If a file in `~` is not yet stowed: move it into the package dir, remove the original, then run stow before committing.

Drift between the repo and the live `~` symlinks is a bug. Catch it before every commit.

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
