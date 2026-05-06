# shellcheck shell=bash
# aliases.zsh — shell aliases

# Defaults
alias vim='nvim'

# Shorthands
alias chvim='vim ~/.config/nvim/'
alias venv='. $(pwd)/venv/bin/activate'
alias psef='ps -ef | grep -v grep | grep'
alias c='clear'
alias todo='grep -Ri "todo:" --exclude-dir={node_modules,.git,build}'
alias loc='tokei'

# Navigation
alias work='cd ~/Development/GitHubProjects/MusicPortfolio/'
alias ccfg='cd ~/Development/GithubTools/bam-claude'
alias dotfiles='cd ~/dotfiles'

# Tail github runner logs (Debian agent host only)
if [[ "$(uname -s)" == "Linux" ]] && command -v systemctl >/dev/null 2>&1 &&
    systemctl list-unit-files 'actions.runner.*.service' --no-legend 2>/dev/null | grep -q .; then
    _gh_runner_unit=$(systemctl list-unit-files 'actions.runner.*.service' --no-legend 2>/dev/null | awk '{print $1; exit}')
    alias gitlogs="sudo journalctl -u ${_gh_runner_unit} -f"
    unset _gh_runner_unit
fi
