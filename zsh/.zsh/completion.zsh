# shellcheck shell=bash
# completion.zsh — post-oh-my-zsh completion and suggestion tweaks
#
# label: SIMPLE
# role: supports feature — extra completion sources and zsh-autosuggestions tuning
# gotchas: the grey inline suggestion is the zsh-autosuggestions plugin, not
#   iTerm2 or OMZ core. Right-arrow (forward-char) takes all of it;
#   forward-word, bound to Esc-f and Ctrl-Right, takes one word.
# last-touched: 2026-11-24

# --- zsh-autosuggestions ---
# History first. When history has no match, fall back to what Tab would
# complete, so a path never typed before (~mp/apps/...) still gets a suggestion.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# `work` was renamed to `mp` (nav.zsh) but is still in history, so without this
# the suggestion keeps offering a command that no longer exists.
ZSH_AUTOSUGGEST_HISTORY_IGNORE='work'

# Additional completion sources installed via Homebrew
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi
