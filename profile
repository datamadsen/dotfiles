export CLICOLOR=1
Color_Off='\[\e[0m\]'
Green='\[\e[0;32m\]'
Blue='\[\e[0;34m\]'
Yellow='\[\e[0;33m\]'
Red='\[\e[0;31m\]'
export PS1="${Yellow}\u@\h${Color_Off} ${Blue}\w${Color_Off} ${Green}$(__git_ps1 "(%s)")\n${Red}$ ${Color_Off}"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export EDITOR="mvim -v"
export VISUAL="mvim -v"

alias l='ls -lhoG'
alias ll='ls -G'
alias la='ls -laho'
alias venv='source venv/bin/activate'
alias mkvenv='virtualenv venv'
alias s='cd ..'
alias vim='mvim -v'
alias ctags="`brew --prefix`/bin/ctags"
alias ccat='pygmentize -O style=fruity,linenos=1 -f console256 -g'

export PATH=/usr/local/share/python:/usr/local/opt/ruby/bin:/usr/local/bin:$PATH

if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi
