# .zshrc — minimal bootstrap
# Modules live in ~/.zsh/; load order is explicit

# --- Environment (PATH, Homebrew, exports) — must be first ---
source ~/.zsh/env.zsh

# --- Oh My Zsh ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # disabled — starship handles the prompt (fallback: robbyrussell)
CASE_SENSITIVE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
zstyle ':omz:update' mode reminder
zstyle ':omz:update' frequency 7
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# --- Bracketed paste — OMZ skips this when terminfo[smBP] is empty (macOS xterm-256color) ---
unset zle_bracketed_paste  # clear any plugin override (e.g. zsh-autosuggestions)
autoload -Uz bracketed-paste-magic add-zsh-hook
zle -N bracketed-paste bracketed-paste-magic
bindkey $'\e[200~' bracketed-paste
# Re-enable after each command (Neovim sends \e[?2004l on exit, which disables it)
_bp_precmd() { print -n '\e[?2004h' }
add-zsh-hook precmd _bp_precmd

# --- Post-OMZ modules ---
source ~/.zsh/completion.zsh
source ~/.zsh/aliases.zsh
source ~/.zsh/functions.zsh
source ~/.zsh/tmux.zsh

# --- Starship prompt ---
eval "$(starship init zsh)"

# --- Optional local overrides (not tracked in dotfiles) ---
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
