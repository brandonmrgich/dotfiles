# shellcheck shell=bash
# env.zsh — PATH, Homebrew, exports
# Sourced FIRST, before oh-my-zsh

# User-local binaries (XDG convention) — nvim AppImage, starship, fd shim, etc.
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# System admin binaries (sbin) — Debian omits these from non-root PATH, so
# modprobe/ip/rfkill/update-initramfs aren't found as a normal user. Append
# (low priority) if present and not already on PATH; no-op on macOS.
for _sbin in /usr/local/sbin /usr/sbin /sbin; do
    [[ -d "$_sbin" && ":$PATH:" != *":$_sbin:"* ]] && export PATH="$PATH:$_sbin"
done
unset _sbin

# Homebrew (Apple Silicon)
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Rust release binaries from the shared cargo target dir. CARGO_TARGET_DIR and
# the cargo env are set in ~/.zshenv so they also reach non-interactive shells;
# PATH assembly stays here. Fine while claw-code is the only crate.
[[ -d "$CARGO_TARGET_DIR/release" ]] &&
    export PATH="${PATH}:$CARGO_TARGET_DIR/release"

# Language & editor
export LANG=en_US.UTF-8
export EDITOR='nvim'
