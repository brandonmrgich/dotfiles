#!/bin/sh
# ---
# label: TOOL
# role: prefix + A. Jumps to the pane running agent view (`claude agents`), or opens it in
#   a new "agents" window, then turns agent nav mode on.
# invariants:
#   - Finds agent view by pane title, which agent view sets itself ("N awaiting input ·
#     claude agents"), so a `claude agents` started by hand in any window or split is
#     found too and never duplicated.
# gotchas:
#   - If an update changes that title, this opens a second agent view instead of
#     jumping; nothing breaks.
# last-touched: 2026-11-22
# ---
# Usage: agents-open.sh <client-name> <start-dir>
client=$1 dir=$2
pane=$(tmux list-panes -a -F '#{pane_id} #{pane_title}' | awk '/claude agents$/ { print $1; exit }')
if [ -n "$pane" ]; then
  tmux switch-client -c "$client" -t "$pane"
  tmux select-pane -t "$pane"
else
  tmux new-window -n agents -c "$dir" "claude agents"
fi
tmux switch-client -c "$client" -T agentnav
