# Plan to Change Tab Completion to Cross-Shell Standard

## Current Problem

The current implementation uses a zsh-specific wrapper file (`farv.zsh`) that:
- Only works with zsh
- Requires users to source the wrapper file
- Is not the modern standard approach for CLI tools
- Creates an extra file dependency

## Modern Standard Approach Analysis

After researching how established CLI tools handle completion:

### Examples of Modern Tools:
- **GitHub CLI (`gh`)**: `gh completion -s zsh|bash|fish|powershell`
- **Ripgrep (`rg`)**: `rg --generate complete-zsh|complete-bash|complete-fish`
- **Kubectl**: `kubectl completion bash|zsh|fish`
- **Docker**: `docker completion bash|zsh|fish`

### Pattern Analysis:
1. **Tool generates completion scripts** via command flags
2. **Users install once** by redirecting output to shell-specific locations
3. **No wrapper files needed** in the project
4. **Cross-shell compatible** with native completion formats

## Proposed Solution

### Option 1: Automatic Installation (Recommended)
The installer automatically sets up completion for the user's detected shell.

**User Experience:**
```bash
cd ~/dotfiles/farv && ./install.sh
# Installer detects shell and automatically installs completion
# User gets tab completion immediately, no extra steps
```

**Implementation:**
- Detect user's shell during installation
- Generate and install completion script automatically
- Works transparently across zsh, bash, fish

### Option 2: Manual Installation
Users manually set up completion after installation.

**User Experience:**
```bash
# After installing farv
farv --generate-completion zsh > ~/.local/share/zsh/site-functions/_farv
# User must run this once per shell they use
```

**Implementation:**
- Tool provides completion generation flags
- Users responsible for installation
- More steps but more control

## Recommended Approach: Option 1 (Automatic)

### Benefits:
- **Zero user friction** - completion "just works" after installation
- **Cross-shell support** without user shell knowledge
- **Modern UX** - matches user expectations from package managers
- **Maintainable** - all completion logic in one place

### Implementation Plan

#### 1. Remove Current zsh-Specific Approach
- Delete `farv.zsh` file entirely
- Remove zsh-specific alias and completion code

#### 2. Add Completion Generation to Main Script
```bash
# In ~/.farv/bin/farv, add new cases:
case "${1:-}" in
    "--generate-completion")
        case "${2:-}" in
            "zsh") generate_zsh_completion ;;
            "bash") generate_bash_completion ;;
            "fish") generate_fish_completion ;;
            *) echo "Usage: farv --generate-completion {zsh|bash|fish}" ;;
        esac
        ;;
    # ... existing cases
esac
```

#### 3. Implement Shell-Specific Completion Functions

**Zsh Completion (`generate_zsh_completion`):**
```bash
generate_zsh_completion() {
    cat << 'EOF'
#compdef farv

_farv() {
    local context state line
    _arguments \
        '1: :->themes' \
        '*: :->themes'
    
    case $state in
        themes)
            local themes=($(farv --complete 2>/dev/null))
            _describe 'themes' themes
            ;;
    esac
}

compdef _farv farv
EOF
}
```

**Bash Completion (`generate_bash_completion`):**
```bash
generate_bash_completion() {
    cat << 'EOF'
_farv() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    if [[ ${cur} == -* ]]; then
        opts="--help --version --list"
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
    
    local themes=$(farv --complete 2>/dev/null)
    COMPREPLY=( $(compgen -W "${themes}" -- ${cur}) )
    return 0
}

complete -F _farv farv
EOF
}
```

**Fish Completion (`generate_fish_completion`):**
```bash
generate_fish_completion() {
    cat << 'EOF'
function __farv_complete_themes
    farv --complete 2>/dev/null
end

complete -c farv -f -a '(__farv_complete_themes)' -d 'Available themes'
complete -c farv -s l -l list -d 'List available themes'
complete -c farv -l help -d 'Show help'
EOF
}
```

#### 4. Update Installation Script

**Smart Shell Detection:**
```bash
#!/usr/bin/env bash

detect_shell() {
    # Try to detect user's primary shell
    local user_shell=$(basename "$SHELL")
    case "$user_shell" in
        zsh|bash|fish) echo "$user_shell" ;;
        *) echo "zsh" ;;  # Default fallback
    esac
}

install_completion() {
    local shell="$1"
    local completion_script
    
    case "$shell" in
        "zsh")
            # Try common zsh completion directories
            for dir in "$HOME/.local/share/zsh/site-functions" \
                      "/usr/local/share/zsh/site-functions" \
                      "$HOME/.oh-my-zsh/completions"; do
                if [[ -d "$(dirname "$dir")" ]]; then
                    mkdir -p "$dir"
                    farv --generate-completion zsh > "$dir/_farv"
                    echo "[farv] Installed zsh completion to $dir/_farv"
                    return 0
                fi
            done
            ;;
        "bash")
            # Try common bash completion directories
            for dir in "$HOME/.local/share/bash-completion/completions" \
                      "/usr/local/share/bash-completion/completions" \
                      "/etc/bash_completion.d"; do
                if [[ -d "$(dirname "$dir")" ]]; then
                    mkdir -p "$dir"
                    farv --generate-completion bash > "$dir/farv"
                    echo "[farv] Installed bash completion to $dir/farv"
                    return 0
                fi
            done
            ;;
        "fish")
            local fish_dir="$HOME/.config/fish/completions"
            mkdir -p "$fish_dir"
            farv --generate-completion fish > "$fish_dir/farv.fish"
            echo "[farv] Installed fish completion to $fish_dir/farv.fish"
            return 0
            ;;
    esac
    
    echo "[farv] Could not install completion for $shell"
    echo "[farv] You can manually install with: farv --generate-completion $shell"
    return 1
}

# In main install.sh:
echo "[farv] Setting up tab completion..."
shell=$(detect_shell)
echo "[farv] Detected shell: $shell"

if install_completion "$shell"; then
    echo "[farv] Completion installed successfully"
    echo "[farv] Please restart your shell or start a new session"
else
    echo "[farv] Completion installation failed - tab completion may not work"
fi
```

### Fallback and Edge Cases

#### Multiple Shells
```bash
# Allow users to install for additional shells
echo "[farv] To install completion for other shells:"
echo "  farv --generate-completion zsh > ~/.local/share/zsh/site-functions/_farv"
echo "  farv --generate-completion bash > ~/.bash_completion.d/farv"
echo "  farv --generate-completion fish > ~/.config/fish/completions/farv.fish"
```

#### Permission Issues
```bash
# If system directories aren't writable, fall back to user directories
# Provide clear instructions for manual installation
```

#### Unknown Shells
```bash
# Default to zsh completion and provide manual instructions
```

## File Changes Required

### New Files: None
All completion logic goes into existing `farv` script

### Modified Files:
- **`farv/bin/farv`**: Add completion generation functions and cases
- **`farv/install.sh`**: Add shell detection and completion installation
- **`farv/farv.zsh`**: Delete entirely

### Removed Files:
- **`farv/farv.zsh`**: No longer needed

## Testing Plan

1. **Test on multiple shells:**
   - zsh (with and without oh-my-zsh)
   - bash (various versions)
   - fish

2. **Test installation scenarios:**
   - Fresh installation
   - Upgrade from old version
   - Different file permissions
   - Multiple shells on same system

3. **Test completion functionality:**
   - Basic theme completion
   - Command completion (list, help)
   - Error handling for invalid themes

## Implementation Summary

Clean break from zsh-specific approach to modern cross-shell standard.

## Benefits of This Approach

1. **Cross-shell compatibility** - works with zsh, bash, fish, etc.
2. **Zero user friction** - completion works immediately after installation
3. **Industry standard** - matches how modern CLI tools work
4. **Maintainable** - all completion logic in one script
5. **Extensible** - easy to add new shells in the future
6. **No extra files** - eliminates `farv.zsh` dependency

## Conclusion

This approach transforms farv into a modern, cross-shell compatible CLI tool with automatic completion installation. Users get a professional experience that matches their expectations from other well-designed command-line tools.