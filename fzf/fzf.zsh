# Setup fzf
# ---------
if [[ ! "$PATH" == */home/tmadsen/dotfiles/fzf/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/tmadsen/dotfiles/fzf/fzf/bin"
fi

source <(fzf --zsh)
