# add 'source dotfiles/bash_profile' to ~/.bash_profile

alias p='ls -GF'
alias pg='p | grep -i'
alias ..='cd ..'
alias ...='cd ../..'
alias tre='tree -FCA'
alias cpwd="pwd | tr -d '\n' | pbcopy"
alias g='git'
alias s='svn'
alias npm-exec='PATH=$(npm bin):$PATH'

alias emulsion.me='ssh emulsion@emulsion.me'
alias mattschick.com='ssh mattschick.com@s35017.gridserver.com'
alias schickm.com='ssh schickmc@schickm.com'

function parse_git_branch () {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
 
RED="\[\033[0;31m\]"
YELLOW="\[\033[0;33m\]"
GREEN="\[\033[0;32m\]"
NO_COLOR="\[\033[0m\]"
 
PS1="$GREEN\u@\h$NO_COLOR:\w$YELLOW\$(parse_git_branch)$NO_COLOR\$ "