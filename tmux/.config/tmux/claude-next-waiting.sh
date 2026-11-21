#!/bin/sh
# Jump to the next tmux pane whose Claude session is waiting (@claude_wait=1),
# searching every session in list-panes order after the current pane and
# wrapping around, then zoom it. Bound to prefix + Tab in tmux.conf.
# $1 = calling pane id, $2 = calling client name.
cur=$1
client=$2
target=$(tmux list-panes -a -F '#{pane_id} #{@claude_wait}' | awk -v c="$cur" '
  { id[NR] = $1; w[NR] = $2; if ($1 == c) ci = NR }
  END { for (i = 1; i <= NR; i++) { j = (ci + i - 1) % NR + 1; if (w[j] == "1") { print id[j]; exit } } }')
if [ -z "$target" ]; then
  tmux display-message -c "$client" 'No Claude sessions waiting'
  exit 0
fi
tmux switch-client -c "$client" -t "$target"
tmux select-pane -t "$target"
[ "$(tmux display-message -p -t "$target" '#{window_zoomed_flag}')" = 1 ] || tmux resize-pane -Z -t "$target"
