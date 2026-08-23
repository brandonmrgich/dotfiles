# shellcheck shell=bash
# .zshenv — sourced by EVERY zsh invocation: interactive, non-interactive,
# scripts, and tool-spawned shells alike. Runs before .zshrc and oh-my-zsh.
#
# Only things that must hold for every process belong here. PATH assembly,
# prompt, aliases, and completion stay in .zshrc → ~/.zsh/*.zsh.
#
# The build caches below live here SPECIFICALLY because .zshrc is
# interactive-only. While TURBO_CACHE_DIR sat in ~/.zsh/env.zsh, any
# non-interactive shell silently fell back to the per-repo default — measured
# on 2026-08-23, a tool-spawned `turbo run` wrote straight back into
# <repo>/.turbo/cache minutes after that 12 GB directory had been cleared.

# Rust toolchain (installer-managed). Guarded, unlike the line this replaces,
# so a host without cargo doesn't error on every shell start.
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# ── Shared build-artifact caches ─────────────────────────────────────────────
# Both tools default to a cache inside each repo, so every clone and every git
# worktree grows its own and none of them ever share a hit. Neither tool prunes.
# One absolute path per machine means one cache to reuse and one place to GC.
# Everything under both is source-reconstructible — safe to delete at any time.

# cargo: cannot be set in ~/.cargo/config.toml, which requires a literal
# absolute path — it expands neither `~` nor env vars, so a committed value
# could not survive syncing these dotfiles to another host. $HOME resolves
# per-machine. (claw-code alone had held 1.5 GB in its own ./target.)
export CARGO_TARGET_DIR="$HOME/.cache/cargo-target"

# turbo: cannot be set as `cacheDir` in turbo.json, which resolves RELATIVE to
# the repo root — a committed value cannot point every worktree at one shared
# absolute path. Safe to share: turbo cache keys are content hashes over each
# task's full inputs, the same property remote caching relies on.
export TURBO_CACHE_DIR="$HOME/.cache/turbo"
