# shellcheck shell=bash
# nav.zsh — project bookmarks
#
# label: SIMPLE
# role: supports feature — short names for the directories worked in most
# invariants: a bookmark is defined in exactly one place, its `_nav_add` row;
#   the jump command, the ~name path and the `nav` listing all derive from it.
# gotchas: must load after oh-my-zsh, or the collision check can't see OMZ's
#   aliases and functions. A row whose directory is missing on this host is
#   skipped silently, because hosts differ. Host-only bookmarks go in
#   ~/.zshrc.local as their own `_nav_add` rows.
# last-touched: 2026-11-24
#
# Each row gives one place two surfaces:
#   mp                jump there
#   ~mp/apps/<TAB>    the same place as a path, in any argument, from any cwd
# `nav` lists the bookmarks active on this host.
#
# Naming: the short name of the thing itself (mp = music platform), never a
# role like "work", which can't be guessed back to a directory. A bare name
# shares one namespace with every command, so `_nav_add` refuses a name that
# already resolves to something (dotfiles is `dots` because `dot` is Graphviz).

_nav_names=()

# _nav_add <name> <dir>
_nav_add() {
    local name=$1 dir=$2
    [[ -d $dir ]] || return 0
    if [[ ${aliases[$name]-} != "cd ~$name" ]] && whence -- "$name" >/dev/null; then
        echo "nav: '$name' already resolves to a command; pick another name for $dir" >&2
        return 1
    fi
    hash -d "$name=$dir"
    alias "$name=cd ~$name"
    _nav_names+=("$name")
}

# bam-claude is cloned at a different path on each host. ~/.claude/CLAUDE.md is
# a stow link to <clone>/stow/CLAUDE.md, so the clone is two levels above its
# target. Left empty (row skipped) when the link doesn't resolve that way.
_nav_bam=~/.claude/CLAUDE.md
_nav_bam=${_nav_bam:A:h:h}
[[ -e $_nav_bam/stow/CLAUDE.md ]] || _nav_bam=

_nav_add mp   ~/Development/GitHubProjects/MusicPortfolio
_nav_add wt   ~/Development/GitHubProjects/MusicPortfolio-worktrees
_nav_add bam  "$_nav_bam"
_nav_add dots ~/dotfiles
_nav_add dev  ~/Development
_nav_add dl   ~/Downloads
_nav_add dk   ~/Desktop
_nav_add logic ~/Music/Logic
unset _nav_bam

nav() {
    local name
    for name in "${_nav_names[@]}"; do
        printf '  %-5s %s\n' "$name" "${nameddirs[$name]/#$HOME/~}"
    done
}
