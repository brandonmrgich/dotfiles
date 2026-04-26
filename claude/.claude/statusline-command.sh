#!/usr/bin/env bash
# ~/.claude/statusline-command.sh

BOLD_GREEN="\033[1;32m"
BOLD_YELLOW="\033[1;33m"
BOLD_RED="\033[1;31m"
BOLD_CYAN="\033[1;36m"
RESET="\033[0m"

eval "$(jq -r '
  "five_pct=" + ((.rate_limits.five_hour.used_percentage // "") | tostring | @sh),
  "week_pct=" + ((.rate_limits.seven_day.used_percentage // "") | tostring | @sh),
  "ctx_used=" + ((.context_window.used_percentage // "") | tostring | @sh),
  "ctx_size=" + ((.context_window.context_window_size // "") | tostring | @sh)
')"

# --- Context ---
ctx_str=""
if [ -n "$ctx_used" ] && [ "$ctx_used" != "null" ] && [ -n "$ctx_size" ] && [ "$ctx_size" != "null" ] && [ "$ctx_size" != "0" ]; then
  ctx_used_int=$(printf '%.0f' "$ctx_used")
  read -r used_k size_k <<< "$(awk "BEGIN { printf \"%.0f %.0f\", $ctx_used_int * $ctx_size / 100000, $ctx_size / 1000 }")"
  ctx_str="${used_k}k/${size_k}k"
fi

# --- Rate limits ---
five_int=0
week_int=0
[ -n "$five_pct" ] && [ "$five_pct" != "null" ] && five_int=$(printf '%.0f' "$five_pct")
[ -n "$week_pct" ] && [ "$week_pct" != "null" ] && week_int=$(printf '%.0f' "$week_pct")

max=$five_int
[ "$week_int" -gt "$max" ] && max=$week_int

if [ "$max" -ge 80 ]; then
  usage_color="$BOLD_RED"
elif [ "$max" -ge 50 ]; then
  usage_color="$BOLD_YELLOW"
else
  usage_color="$BOLD_GREEN"
fi

usage_str=""
[ -n "$five_pct" ] && [ "$five_pct" != "null" ] && usage_str="5h:${five_int}%"
[ -n "$week_pct" ] && [ "$week_pct" != "null" ] && usage_str="${usage_str:+$usage_str }7d:${week_int}%"

# --- Output ---
[ -n "$ctx_str" ]   && printf "%b%s%b" "$BOLD_CYAN" "$ctx_str" "$RESET"
[ -n "$usage_str" ] && printf " %b%s%b" "$usage_color" "$usage_str" "$RESET"
[ -n "$ctx_str" ] || [ -n "$usage_str" ] && printf "\n"
