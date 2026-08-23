# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

> **Claude Code config moved.** Everything that used to live in the
> `claude/` package now lives in a dedicated repo:
> [`brandonmrgich/bam-claude`](https://github.com/brandonmrgich/bam-claude).
> See that repo's `MIGRATION.md` for the split details and post-install
> steps for refreshing `~/.claude/` symlinks.

## What's included

| Package    | What it configures |
| ---------- | ------------------ |
| `git`      | Git identity, LFS, default branch |
| `starship` | Shell prompt (directory, git branch/status/state) |
| `tmux`     | Prefix `C-a`, vim-aware pane nav, vi copy mode, splits that inherit cwd |
| `zsh`      | Oh My Zsh bootstrap + modular config files |

## Install

```bash
git clone https://github.com/brandonmrgich/dotfiles ~/dotfiles
cd ~/dotfiles

# Apply all packages
stow git starship tmux zsh
```

Or apply individually:

```bash
stow zsh
stow tmux
# etc.
```

> Stow creates relative symlinks in `~` that mirror each package's directory tree.
> Existing files will conflict — back them up first.

## Dependencies

- [Homebrew](https://brew.sh)
- [GNU Stow](https://formulae.brew.sh/formula/stow) — `brew install stow`
- [Oh My Zsh](https://ohmyz.sh) — `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
- [Starship](https://starship.rs) — `brew install starship`
- [Neovim](https://neovim.io) — `brew install neovim` (aliases `vim` → `nvim`)
- [tmux](https://github.com/tmux/tmux) — `brew install tmux`
- [tokei](https://github.com/XAMPPRocky/tokei) — `brew install tokei` (aliased as `loc`)

## zsh layout

```
zsh/
  .zshrc              # bootstrap — loads modules in order
  .zsh/
    env.zsh           # PATH, Homebrew, exports (loaded first)
    completion.zsh    # completion settings
    aliases.zsh       # shell aliases
    functions.zsh     # shell functions (youtube-dl wrapper, tarxz)
    tmux.zsh          # tmux helpers: ts, tls, ta
```

Local machine overrides go in `~/.zshrc.local` (untracked).

## Claude Code

Claude Code's user-level config (`~/.claude/`, statusline, skills, agents,
environment map, etc.) is no longer part of this repo. It lives at
[`brandonmrgich/bam-claude`](https://github.com/brandonmrgich/bam-claude),
stowed independently into `~/.claude/`.

If you previously stowed the old `claude` package from this repo, see
`bam-claude`'s README § *Post-install: fix old stow links* for the steps
that clean up dangling symlinks pointing into `~/dotfiles/claude/`.

## Adding new dotfiles

```bash
# Mirror the target path inside the package dir, then stow
mkdir -p ~/dotfiles/<package>/<path>
mv ~/<dotfile> ~/dotfiles/<package>/<path>/
stow <package>
```
