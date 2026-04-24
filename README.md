# dotfiles

Personal macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's included

| Package    | What it configures |
| ---------- | ------------------ |
| `claude`   | Claude Code — global `CLAUDE.md` instructions + statusline script |
| `git`      | Git identity, LFS, default branch |
| `starship` | Shell prompt (directory, git branch/status/state) |
| `tmux`     | Prefix `C-a`, vim-aware pane nav, vi copy mode, splits that inherit cwd |
| `zsh`      | Oh My Zsh bootstrap + modular config files |

## Install

```bash
git clone https://github.com/brandonmrgich/dotfiles ~/dotfiles
cd ~/dotfiles

# Apply all packages
stow claude git starship tmux zsh
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

## Claude Code statusline

The `claude` package includes a statusline script that mirrors the Starship prompt and adds Claude-specific info:

```
dotfiles  main ~  Sonnet 4.6  ctx:42k/200k(21%)  5h:25% 7d:6%
```

- **directory** — truncated repo-relative path (cyan)
- **branch** — current git branch (purple)
- **git flags** — `+` staged, `~` modified, `?` untracked, `✘` deleted, `⇡⇣` ahead/behind (yellow)
- **model** — active Claude model (cyan)
- **ctx** — context window used / max with percentage, color-coded green → yellow → red (green/yellow/red)
- **5h / 7d** — Claude Max plan usage percentages (green)

## Adding new dotfiles

```bash
# Mirror the target path inside the package dir, then stow
mkdir -p ~/dotfiles/<package>/<path>
mv ~/<dotfile> ~/dotfiles/<package>/<path>/
stow <package>
```
