setopt prompt_subst
autoload -U colors && colors

source ~/.git-prompt.sh
#GIT_PS1_SHOWCOLORHINTS="1" (slows shit down)
#GIT_PS1_SHOWDIRTYSTATE="1" (slows shit down)
local gitval='%{$fg[green]%}$(__git_ps1 "(%s)")'

prompt="%{$fg[yellow]%}%n@%m %{$fg[blue]%}%~ ${gitval}
%{$fg[red]%}$ %{$reset_color%}"
