# shellcheck shell=bash
# completion.zsh — post-oh-my-zsh completion tweaks

# Additional completion sources installed via Homebrew
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi
