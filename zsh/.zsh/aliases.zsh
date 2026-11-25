# shellcheck shell=bash
# aliases.zsh — shell aliases
#
# label: SIMPLE
# role: supports feature — command shorthands; directory bookmarks live in nav.zsh
# last-touched: 2026-11-24

# Defaults
alias vim='nvim'

# Shorthands
alias chvim='vim ~/.config/nvim/'
alias venv='. $(pwd)/venv/bin/activate'
alias psef='ps -ef | grep -v grep | grep'
alias c='clear'
alias todo='grep -Ri "todo:" --exclude-dir={node_modules,.git,build}'
alias loc='tokei'

# Novelty / fun brew tools — kept intentionally; run `novelty` to remember them
alias novelty='printf "%s\n" "novelty tools (brew-installed, kept on purpose):" "  asciiquarium   animated ASCII aquarium" "  cmatrix        Matrix rain" "  figlet <text>  big ASCII banner" "  lolcat         rainbow-colorize a pipe" "  gnuchess       terminal chess engine"'

# Tail github runner logs (Debian agent host only)
if [[ "$(uname -s)" == "Linux" ]] && command -v systemctl >/dev/null 2>&1 &&
    systemctl list-unit-files 'actions.runner.*.service' --no-legend 2>/dev/null | grep -q .; then
    _gh_runner_unit=$(systemctl list-unit-files 'actions.runner.*.service' --no-legend 2>/dev/null | awk '{print $1; exit}')
    alias gitlogs="sudo journalctl -u ${_gh_runner_unit} -f"
    unset _gh_runner_unit
fi
