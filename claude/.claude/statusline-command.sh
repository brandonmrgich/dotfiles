#!/usr/bin/env bash
# ~/.claude/statusline-command.sh
# Mirrors: $directory$git_branch$git_status$git_state

BOLD_CYAN="\033[1;36m"
BOLD_PURPLE="\033[1;35m"
BOLD_YELLOW="\033[1;33m"
BOLD_RED="\033[1;31m"
BOLD_GREEN="\033[1;32m"
RESET="\033[0m"

# Parse all stdin fields in one jq call
eval "$(jq -r '
  "current_dir=" + (.workspace.current_dir | @sh),
  "project_dir=" + ((.workspace.project_dir // "") | @sh),
  "ctx_used=" + ((.context_window.used_percentage // "") | tostring | @sh),
  "ctx_size=" + ((.context_window.context_window_size // "") | tostring | @sh),
  "model_name=" + ((.model.display_name // "") | @sh),
  "five_pct=" + ((.rate_limits.five_hour.used_percentage // "") | tostring | @sh),
  "week_pct=" + ((.rate_limits.seven_day.used_percentage // "") | tostring | @sh)
')"

# --- Directory ---
if [ -n "$project_dir" ] && [ "$current_dir" != "$project_dir" ]; then
  repo_name=$(basename "$project_dir")
  rel="${current_dir#"$project_dir"/}"
  truncated=$(printf '%s' "$rel" | awk -F/ '{ n=NF; if(n>3){ printf "..."; for(i=n-2;i<=n;i++) printf "/" $i } else print $0 }')
  dir_display="$repo_name/$truncated"
else
  dir_display=$(printf '%s' "$current_dir" | sed 's|'"$HOME"'|~|' | awk -F/ '{ n=NF; if(n>3){ printf "..."; for(i=n-2;i<=n;i++) printf "/" $i } else print $0 }')
fi

# --- Git info (2s TTL cache per directory) ---
git_branch=""
git_status_str=""
git_state_str=""

git_dir=$(git -C "$current_dir" --no-optional-locks rev-parse --git-dir 2>/dev/null)
if [ -n "$git_dir" ]; then
  _cache_key=$(printf '%s' "$current_dir" | md5 -q 2>/dev/null || printf '%s' "$current_dir" | md5sum | cut -c1-32)
  _cache_file="/tmp/claude-sl-${_cache_key}.cache"
  _use_cache=0

  if [ -f "$_cache_file" ]; then
    _mtime=$(stat -f %m "$_cache_file" 2>/dev/null)
    if [ -n "$_mtime" ] && [ $(( $(date +%s) - _mtime )) -lt 2 ]; then
      IFS=$'\t' read -r git_branch git_status_str git_state_str < "$_cache_file"
      _use_cache=1
    fi
  fi

  if [ "$_use_cache" -eq 0 ]; then
    # Branch
    branch=$(git -C "$current_dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
             || git -C "$current_dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    git_branch=" $branch"

    # Status flags — single awk pass replaces 6 grep subprocesses
    status_output=$(git -C "$current_dir" --no-optional-locks status --porcelain 2>/dev/null)
    read -r has_conflict has_staged has_modified has_untracked has_deleted has_renamed <<< \
      "$(printf '%s\n' "$status_output" | awk '
        /^UU/              { c++ }
        /^[MADRC]/         { s++ }
        /^.[MD]/           { m++ }
        /^\?\?/            { u++ }
        /^.D/ || /^D./     { d++ }
        /^R./              { r++ }
        END { print (c+0), (s+0), (m+0), (u+0), (d+0), (r+0) }
      ')"

    # Stash — check ref existence, avoid listing all entries
    git -C "$current_dir" --no-optional-locks rev-parse --verify refs/stash >/dev/null 2>&1 \
      && has_stash=1 || has_stash=0

    flags=""
    [ "${has_conflict:-0}" -gt 0 ] && flags="${flags}!"
    [ "${has_staged:-0}"   -gt 0 ] && flags="${flags}+"
    [ "${has_modified:-0}" -gt 0 ] && flags="${flags}~"
    [ "${has_deleted:-0}"  -gt 0 ] && flags="${flags}✘"
    [ "${has_renamed:-0}"  -gt 0 ] && flags="${flags}»"
    [ "${has_untracked:-0}" -gt 0 ] && flags="${flags}?"
    [ "${has_stash:-0}"    -gt 0 ] && flags="${flags}\$"

    # Ahead/behind
    upstream=$(git -C "$current_dir" --no-optional-locks rev-parse --abbrev-ref '@{u}' 2>/dev/null)
    if [ -n "$upstream" ]; then
      read -r ahead behind <<< "$(git -C "$current_dir" --no-optional-locks rev-list --left-right --count HEAD...@{u} 2>/dev/null)"
      [ "${ahead:-0}"  -gt 0 ] && flags="${flags}⇡${ahead}"
      [ "${behind:-0}" -gt 0 ] && flags="${flags}⇣${behind}"
    fi

    [ -n "$flags" ] && git_status_str=" $flags"

    # State (rebase, merge, cherry-pick, etc.)
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

    printf '%s\t%s\t%s\n' "$git_branch" "$git_status_str" "$git_state_str" > "$_cache_file"
  fi
fi

# --- Context window ---
ctx_str=""
if [ -n "$ctx_used" ] && [ "$ctx_used" != "null" ]; then
  ctx_used_int=$(printf '%.0f' "$ctx_used")
  ctx_label="ctx:${ctx_used_int}%"
  if [ -n "$ctx_size" ] && [ "$ctx_size" != "null" ] && [ "$ctx_size" != "0" ]; then
    read -r used_k size_k <<< "$(awk "BEGIN { printf \"%.0f %.0f\", $ctx_used_int * $ctx_size / 100000, $ctx_size / 1000 }")"
    ctx_label="ctx:${used_k}k/${size_k}k(${ctx_used_int}%)"
  fi
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
[ -n "$model_name" ] && model_str=" $model_name"

# --- Plan usage ---
plan_str=""
if [ -n "$five_pct" ] && [ "$five_pct" != "null" ] || { [ -n "$week_pct" ] && [ "$week_pct" != "null" ]; }; then
  plan_parts=""
  [ -n "$five_pct" ] && [ "$five_pct" != "null" ] && plan_parts="5h:$(printf '%.0f' "$five_pct")%"
  [ -n "$week_pct" ] && [ "$week_pct" != "null" ] && plan_parts="${plan_parts:+$plan_parts }7d:$(printf '%.0f' "$week_pct")%"
  [ -n "$plan_parts" ] && plan_str=" $plan_parts"
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
