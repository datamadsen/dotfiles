setopt prompt_subst
autoload -U colors && colors

source ~/.git-prompt.sh
local gitval='%{$fg[green]%}$(__git_ps1 "(%s)")'

prompt="%{$fg[yellow]%}%n@%m %{$fg[blue]%}%~ ${gitval}
%{$fg[red]%}$ %{$reset_color%}"
