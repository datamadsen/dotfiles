# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/tmadsen/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/tmadsen/.fzf/bin"
fi

# Auto-completion
# ---------------
source "/Users/tmadsen/.fzf/shell/completion.zsh"

# Key bindings
# ------------
source "/Users/tmadsen/.fzf/shell/key-bindings.zsh"

export FZF_COMPLETION_OPTS='-e'
export FZF_DEFAULT_COMMAND='ag --ignore-dir={bin,obj,node_modules} -g ""'
export FZF_DEFAULT_OPTS="
	--color=fg:#797593,bg:#faf4ed,hl:#d7827e
	--color=fg+:#575279,bg+:#f2e9e1,hl+:#d7827e
	--color=border:#dfdad9,header:#286983,gutter:#faf4ed
	--color=spinner:#ea9d34,info:#56949f
	--color=pointer:#907aa9,marker:#b4637a,prompt:#797593"

