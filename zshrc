setopt prompt_subst
autoload -U colors && colors

source ~/.git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE="hey"
GIT_PS1_SHOWUNTRACKEDFILES="hey"
GIT_PS1_SHOWUPSTREAM="auto"

prompt="%{$fg[yellow]%}%n@%m %{$fg[blue]%}%~ %{$fg[green]%}$(__git_ps1)
%{$fg[red]%}$ %{$reset_color%}"
