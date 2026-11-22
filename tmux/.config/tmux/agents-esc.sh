#!/bin/sh
# ---
# label: TOOL
# role: handles Esc in the tmux "agents" window. When agent view's list is showing it
#   turns agent nav mode on; otherwise it passes Esc to the pane.
# invariants:
#   - Switches to nav mode only on a positive match of the list's footer and no session
#     marker. Anything else (an opened session, a dialog, a footer it doesn't
#     recognise) gets a real Escape, so interrupting Claude and vim mode keep working.
# gotchas:
#   - Matches Claude Code's footer text, captured 2026-11-22. If an update changes it,
#     Esc just stops turning nav mode on; prefix + A still works. Re-capture with
#     `tmux capture-pane -p -t ':agents.' | tail -8` in both states and update below.
#   - The list and an opened session share one pane and one title, which is why this
#     reads the screen at all (see tmux.conf, agent nav mode).
# last-touched: 2026-11-22
# ---
# Usage: agents-esc.sh <pane-id> <client-name>   (bound to Esc in tmux.conf)
#        agents-esc.sh --classify < capture.txt  (prints "list" or "other"; for testing)

classify() {
  # The last three non-blank lines of the screen: the input box and the hint line.
  lines=$(awk 'NF' | tail -n 3)
  # An opened session's footer: "← 2 agents" / "← for agents", the vim mode tag,
  # or "esc to interrupt" while Claude is working.
  if printf '%s\n' "$lines" | grep -qE '← ([0-9]+ agents?|for agents)|-- (INSERT|NORMAL|VISUAL) --|esc to interrupt'; then
    echo other
  # The list's hint line ends in "? for shortcuts"; its empty input shows the placeholder.
  elif printf '%s\n' "$lines" | tail -n 1 | grep -qF '? for shortcuts' ||
       printf '%s\n' "$lines" | grep -qF 'describe a task for a new session'; then
    echo list
  else
    echo other
  fi
}

if [ "${1:-}" = --classify ]; then
  classify
  exit 0
fi

pane=$1 client=$2
if [ "$(tmux capture-pane -p -t "$pane" | classify)" = list ]; then
  tmux switch-client -c "$client" -T agentnav
else
  tmux send-keys -t "$pane" Escape
fi
