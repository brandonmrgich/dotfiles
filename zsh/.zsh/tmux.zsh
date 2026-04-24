# tmux.zsh — tmux session helpers

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
