#!/usr/bin/env bash
# ~/.claude/statusline-command.sh
# Mirrors: $directory$git_branch$git_status$git_state
# Sourced from starship.toml — no trailing prompt character

BOLD_CYAN="\033[1;36m"
BOLD_PURPLE="\033[1;35m"
BOLD_YELLOW="\033[1;33m"
BOLD_RED="\033[1;31m"
BOLD_GREEN="\033[1;32m"
RESET="\033[0m"

input=$(cat)
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // empty')

# --- Directory (truncation_length=3, truncate_to_repo=true) ---
if [ -n "$project_dir" ] && [ "$current_dir" != "$project_dir" ]; then
  repo_name=$(basename "$project_dir")
  rel="${current_dir#"$project_dir"/}"
  # Keep at most 3 path segments of the relative portion
  truncated=$(echo "$rel" | awk -F/ '{ n=NF; if(n>3){ printf "..."; for(i=n-2;i<=n;i++) printf "/" $i } else print $0 }')
  dir_display="$repo_name/$truncated"
else
  # Outside a repo or at repo root — show last 3 segments
  dir_display=$(echo "$current_dir" | sed 's|'"$HOME"'|~|' | awk -F/ '{ n=NF; if(n>3){ printf "..."; for(i=n-2;i<=n;i++) printf "/" $i } else print $0 }')
fi

# --- Git info (requires git in PATH) ---
git_branch=""
git_status_str=""
git_state_str=""

if git -C "$current_dir" --no-optional-locks rev-parse --git-dir >/dev/null 2>&1; then
  # Branch
  branch=$(git -C "$current_dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$current_dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  git_branch=" $branch"

  # Status flags
  flags=""
  status_output=$(git -C "$current_dir" --no-optional-locks status --porcelain 2>/dev/null)
  has_conflict=$(echo "$status_output" | grep -c '^UU' || true)
  has_staged=$(echo "$status_output" | grep -c '^[MADRC]' || true)
  has_modified=$(echo "$status_output" | grep -c '^.[MD]' || true)
  has_untracked=$(echo "$status_output" | grep -c '^??' || true)
  has_deleted=$(echo "$status_output" | grep -cE '^.D|^D.' || true)
  has_renamed=$(echo "$status_output" | grep -c '^R.' || true)
  has_stash=$(git -C "$current_dir" --no-optional-locks stash list 2>/dev/null | grep -c '' || true)

  [ "$has_conflict" -gt 0 ]  && flags="${flags}!"
  [ "$has_staged" -gt 0 ]    && flags="${flags}+"
  [ "$has_modified" -gt 0 ]  && flags="${flags}~"
  [ "$has_deleted" -gt 0 ]   && flags="${flags}✘"
  [ "$has_renamed" -gt 0 ]   && flags="${flags}»"
  [ "$has_untracked" -gt 0 ] && flags="${flags}?"
  [ "$has_stash" -gt 0 ]     && flags="${flags}\$"

  # Ahead/behind
  upstream=$(git -C "$current_dir" --no-optional-locks rev-parse --abbrev-ref '@{u}' 2>/dev/null)
  if [ -n "$upstream" ]; then
    read -r ahead behind <<< "$(git -C "$current_dir" --no-optional-locks rev-list --left-right --count HEAD...@{u} 2>/dev/null)"
    [ "${ahead:-0}" -gt 0 ]  && flags="${flags}⇡${ahead}"
    [ "${behind:-0}" -gt 0 ] && flags="${flags}⇣${behind}"
  fi

  [ -n "$flags" ] && git_status_str=" $flags"

  # State (rebase, merge, cherry-pick, etc.)
  git_dir=$(git -C "$current_dir" --no-optional-locks rev-parse --git-dir 2>/dev/null)
  state=""
  if [ -d "$git_dir/rebase-merge" ] || [ -d "$git_dir/rebase-apply" ]; then
    cur=$(cat "$git_dir/rebase-merge/msgnum" 2>/dev/null || cat "$git_dir/rebase-apply/next" 2>/dev/null || echo "")
    tot=$(cat "$git_dir/rebase-merge/end"    2>/dev/null || cat "$git_dir/rebase-apply/last" 2>/dev/null || echo "")
    state="REBASING"
    [ -n "$cur" ] && [ -n "$tot" ] && state="REBASING $cur/$tot"
  elif [ -f "$git_dir/MERGE_HEAD" ]; then
    state="MERGING"
  elif [ -f "$git_dir/CHERRY_PICK_HEAD" ]; then
    state="CHERRY-PICKING"
  elif [ -f "$git_dir/BISECT_LOG" ]; then
    state="BISECTING"
  fi
  [ -n "$state" ] && git_state_str=" ($state)"
fi

# --- Context window usage ---
ctx_str=""
ctx_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$ctx_used" ]; then
  ctx_used_int=$(printf '%.0f' "$ctx_used")
  ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
  ctx_label="ctx:${ctx_used_int}%"
  if [ -n "$ctx_size" ]; then
    used_k=$(awk "BEGIN { printf \"%.0f\", $ctx_used_int * $ctx_size / 100000 }")
    size_k=$(awk "BEGIN { printf \"%.0f\", $ctx_size / 1000 }")
    ctx_label="ctx:${used_k}k/${size_k}k(${ctx_used_int}%)"
  fi
  # Color by threshold
  if [ "$ctx_used_int" -ge 80 ]; then
    ctx_color="$BOLD_RED"
  elif [ "$ctx_used_int" -ge 50 ]; then
    ctx_color="$BOLD_YELLOW"
  else
    ctx_color="$BOLD_GREEN"
  fi
  ctx_str=" $ctx_label"
fi

# --- Model ---
model_str=""
model_name=$(echo "$input" | jq -r '.model.display_name // empty')
[ -n "$model_name" ] && model_str=" $model_name"

# --- Plan usage (Claude Max subscription rate limits) ---
plan_str=""
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
if [ -n "$five_pct" ] || [ -n "$week_pct" ]; then
  plan_parts=""
  [ -n "$five_pct" ] && plan_parts="5h:$(printf '%.0f' "$five_pct")%"
  [ -n "$week_pct" ] && plan_parts="${plan_parts:+$plan_parts }7d:$(printf '%.0f' "$week_pct")%"
  plan_str=" $plan_parts"
fi

# --- Assemble ---
printf "${BOLD_CYAN}%s${RESET}" "$dir_display"
[ -n "$git_branch" ]     && printf "${BOLD_PURPLE}%s${RESET}" "$git_branch"
[ -n "$git_status_str" ] && printf "${BOLD_YELLOW}%s${RESET}" "$git_status_str"
[ -n "$git_state_str" ]  && printf "${BOLD_RED}%s${RESET}" "$git_state_str"
[ -n "$model_str" ]      && printf "${BOLD_CYAN}%s${RESET}" "$model_str"
[ -n "$ctx_str" ]        && printf "%b%s%b" "$ctx_color" "$ctx_str" "$RESET"
[ -n "$plan_str" ]       && printf "${BOLD_GREEN}%s${RESET}" "$plan_str"
printf "\n"
