# shellcheck shell=bash
# tmux.zsh — tmux session helpers

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
[[ -n $TMUX ]] && export CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1

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
