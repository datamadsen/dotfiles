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
# Rose pine
# export FZF_DEFAULT_OPTS="
# 	--color=fg:#797593,bg:#faf4ed,hl:#d7827e
# 	--color=fg+:#575279,bg+:#f2e9e1,hl+:#d7827e
# 	--color=border:#dfdad9,header:#286983,gutter:#faf4ed
# 	--color=spinner:#ea9d34,info:#56949f
# 	--color=pointer:#907aa9,marker:#b4637a,prompt:#797593"
#

# Tokyonight
export FZF_DEFAULT_OPTS="
    --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
    --color=fg+:#a9b1d6,bg+:#24283b,hl+:#bb9af7
    --color=border:#414868,header:#7aa2f7,gutter:#1a1b26
    --color=spinner:#9ece6a,info:#3d59a1
    --color=pointer:#c0caf5,marker:#bb9af7,prompt:#c0caf5"
