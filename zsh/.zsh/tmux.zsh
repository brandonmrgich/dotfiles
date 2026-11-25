# shellcheck shell=bash
# tmux.zsh — tmux session helpers
#
# label: SIMPLE
# role: supports feature — tmux helpers and Claude Code terminal env fixes
# gotchas: the exports below are read only when `claude` launches; a tmux
#   reload or detach/reattach never reaches a running claude. Relaunch it from
#   a freshly sourced shell to test any change here.
# last-touched: 2026-11-24

# --- Claude Code fullscreen-renderer workaround (tmux-scoped) ---
# Claude Code 2.1.202's fullscreen (alt-screen) TUI renderer mis-positions
# incremental cell writes under tmux -> overlapping/garbled output + input;
# only a manual pane-switch repaint clears it. Ruled out empirically 2026-07-14:
# CLAUDE_CODE_ALT_SCREEN_FULL_REPAINT=1 (targets the Windows ConPTY bug, wrong
# class) and CLAUDE_CODE_FORCE_SYNC_OUTPUT=0 both had no effect. Dropping the
# alternate screen falls back to the classic inline renderer, which tmux handles
# without the corruption. Gated on $TMUX so a bare iTerm2 session keeps fullscreen.
# TODO(claude-code > 2.1.202): on each Claude Code upgrade, delete this line and
# retest fullscreen in a FRESH tmux pane; remove for good once upstream fixes it.
# Tracking: https://github.com/anthropics/claude-code/issues/77615
#[[ -n $TMUX ]] && export CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1

# --- Claude Code Shift+Enter over ssh from a tmux pane ---
# Claude enables extended keys (kitty push + modifyOtherKeys) only when it
# recognizes the terminal from TERM_PROGRAM or $TMUX. ssh forwards neither, so
# a session ssh'd in from a tmux pane arrives with just TERM=tmux-256color,
# extended keys stay off, and the client-side tmux sends Shift+Enter as a plain
# Enter, which submits. TERM still names the client tmux, so restore the hint.
# Scoped to tmux* (screen* may be GNU screen). Confirmed 2026-11-24 on Claude
# Code 2.1.331, Mac tmux -> ssh -> debian-macbook.
[[ -n $SSH_CONNECTION && -z $TERM_PROGRAM && $TERM == tmux* ]] && export TERM_PROGRAM=tmux

# Create or attach to a session named after the current directory
ts() {
    local name="${1:-$(basename "$PWD")}"
    if tmux has-session -t "$name" 2>/dev/null; then
        tmux attach-session -t "$name"
    else
        tmux new-session -s "$name"
    fi
}

# List sessions with their working directories
tls() {
    tmux list-sessions -F "#{session_name}: #{session_path}" 2>/dev/null || echo "No tmux sessions"
}

# Attach to a session via fzf
ta() {
    local session
    session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --height 40% --reverse)
    [[ -n "$session" ]] && tmux attach-session -t "$session"
}
