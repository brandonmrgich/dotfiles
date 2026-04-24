# env.zsh — PATH, Homebrew, exports
# Sourced FIRST, before oh-my-zsh

# Homebrew (Apple Silicon)
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Claw-code (if installed)
[[ -d "$HOME/Development/GithubTools/claw-code/rust/target/release" ]] && \
    export PATH="${PATH}:$HOME/Development/GithubTools/claw-code/rust/target/release/"

# Language & editor
export LANG=en_US.UTF-8
export EDITOR='nvim'
