#!/usr/bin/env zsh
# Pure-style minimal prompt
# Just the arrow: cyan on success, red on error
# Arrow direction changes based on vi mode (❯ insert, ❮ command)

# Disable Pure prompt if it's loaded
if (( $+functions[prompt_pure_precmd] )); then
    prompt_pure_precmd() { }
    PROMPT_EOL_MARK=''
fi

# Set up the prompt character variable
typeset -g prompt_char='❯'

# Function to update prompt based on vi mode
function zle-keymap-select {
    # Update prompt character based on keymap
    prompt_char=${${KEYMAP/vicmd/❮}/(main|viins)/❯}
    zle reset-prompt
}

# Function to reset prompt character (called on each new prompt)
function zle-line-init {
    prompt_char='❯'
    zle reset-prompt
}

# Register the functions as widgets
zle -N zle-keymap-select
zle -N zle-line-init

PS1=$'\n%(?.%F{cyan}.%F{red})${prompt_char}%f '
