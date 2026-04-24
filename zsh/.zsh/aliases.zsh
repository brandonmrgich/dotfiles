# aliases.zsh — shell aliases

alias vim='nvim'
alias chvim='vim ~/.config/nvim/'
alias venv='. $(pwd)/venv/bin/activate'
alias psef='ps -ef | grep -v grep | grep'
alias c='clear'
alias todo='grep -Ri "todo:" --exclude-dir={node_modules,.git,build}'
