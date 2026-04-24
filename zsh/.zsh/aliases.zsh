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
