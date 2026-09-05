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

# ── Flutter / Dart / Android toolchain ───────────────────────────────────────
# These live in .zshenv rather than ~/.zsh/env.zsh for the same reason as the
# build caches above: .zshrc (and therefore env.zsh) is interactive-only, and
# the primary consumer here is a tool-spawned NON-interactive shell — Claude
# Code, plan-executor agents, and Gradle's own subshells all run `flutter`
# without a tty. With the block in env.zsh, `zsh -lc 'flutter --version'`
# resolved to "command not found" while `zsh -lic` worked (verified 2026-09-05).
#
# Flutter is a full git checkout at ~/sdks/flutter — not a Homebrew cask, which
# ships a zip and breaks `flutter upgrade`, and not fvm, which adds a
# resolution layer a single-SDK machine doesn't need. ~/sdks, not ~/development,
# because the latter case-folds into the existing ~/Development on APFS.
#
# Only $FLUTTER_ROOT/bin goes on PATH: it carries BOTH `flutter` and `dart`
# from the SDK's bundled Dart. Deliberately NOT bin/cache/dart-sdk/bin — that
# pins a second Dart entry point which drifts out of sync the moment
# `flutter upgrade` swaps the bundled SDK underneath it.
export FLUTTER_ROOT="$HOME/sdks/flutter"
if [[ -d "$FLUTTER_ROOT/bin" && ":$PATH:" != *":$FLUTTER_ROOT/bin:"* ]]; then
    export PATH="$FLUTTER_ROOT/bin:$PATH"
fi

# Android SDK from the Homebrew android-commandlinetools cask — sdkmanager and
# adb without Android Studio. ANDROID_HOME is the current variable;
# ANDROID_SDK_ROOT is exported alongside it because some Gradle plugins and
# older tooling still read only the deprecated name.
export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
for _andir in "$ANDROID_HOME/platform-tools" "$ANDROID_HOME/cmdline-tools/latest/bin" "$ANDROID_HOME/emulator"; do
    [[ -d "$_andir" && ":$PATH:" != *":$_andir:"* ]] && export PATH="$PATH:$_andir"
done
unset _andir

# JDK for Gradle / Android Gradle Plugin. Zulu 17 was already installed and AGP
# 8.x targets 17, so no new JDK is needed. Flutter is pointed at this same JDK
# via `flutter config --jdk-dir` so the Flutter CLI and Gradle can never
# resolve different Javas. Guarded so a host without Zulu 17 doesn't export a
# dangling JAVA_HOME. Note /usr/bin/java is only Apple's stub here — nothing
# else competes for the name.
if [[ -d /Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home ]]; then
    export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
    [[ ":$PATH:" != *":$JAVA_HOME/bin:"* ]] && export PATH="$PATH:$JAVA_HOME/bin"
fi
