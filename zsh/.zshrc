# .zshrc — minimal bootstrap
# Modules live in ~/.zsh/; load order is explicit

# --- Environment (PATH, Homebrew, exports) — must be first ---
source ~/.zsh/env.zsh

# --- Oh My Zsh ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
CASE_SENSITIVE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
zstyle ':omz:update' mode reminder
zstyle ':omz:update' frequency 7
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# --- Post-OMZ modules ---
source ~/.zsh/completion.zsh
source ~/.zsh/aliases.zsh
source ~/.zsh/functions.zsh
source ~/.zsh/tmux.zsh

# --- Optional local overrides (not tracked in dotfiles) ---
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
