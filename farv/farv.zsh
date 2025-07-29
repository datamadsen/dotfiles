# Farv theme manager - thin completion wrapper for modular farv script

# Tab completion for farv command
_farv() {
    local themes=($(~/.farv/bin/farv --complete 2>/dev/null))
    _describe 'themes' themes
}

# Register the completion function
compdef _farv farv

# Alias to the actual script
alias farv='~/.farv/bin/farv'
