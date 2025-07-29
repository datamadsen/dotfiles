#!/usr/bin/env bash

# Remove old symlink
echo "[farv] Remove old symlink"
rm -f ~/.farv

# Create symlink
echo "[farv] Create symlink"
ln -s "$(pwd)" ~/.farv

# Create directory structure for modular scripts
echo "[farv] Create bin directory structure"
mkdir -p ~/.farv/bin/handlers

# Copy and make scripts executable
echo "[farv] Install modular farv scripts"
cp bin/farv ~/.farv/bin/farv
cp bin/handlers/*.sh ~/.farv/bin/handlers/
chmod +x ~/.farv/bin/farv
chmod +x ~/.farv/bin/handlers/*.sh

# Detect user's shell
detect_shell() {
    local user_shell=$(basename "$SHELL")
    case "$user_shell" in
        zsh|bash|fish) echo "$user_shell" ;;
        *) echo "zsh" ;;  # Default fallback
    esac
}

# Install completion for detected shell
install_completion() {
    local shell="$1"
    
    case "$shell" in
        "zsh")
            # Try common zsh completion directories
            for dir in "$HOME/.local/share/zsh/site-functions" \
                      "/usr/local/share/zsh/site-functions" \
                      "$HOME/.oh-my-zsh/completions"; do
                if [[ -d "$(dirname "$dir")" ]]; then
                    mkdir -p "$dir"
                    ~/.farv/bin/farv --generate-completion zsh > "$dir/_farv"
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
                if [[ -d "$(dirname "$dir")" ]] || [[ -w "$(dirname "$dir")" ]]; then
                    mkdir -p "$dir" 2>/dev/null
                    if ~/.farv/bin/farv --generate-completion bash > "$dir/farv" 2>/dev/null; then
                        echo "[farv] Installed bash completion to $dir/farv"
                        return 0
                    fi
                fi
            done
            ;;
        "fish")
            local fish_dir="$HOME/.config/fish/completions"
            mkdir -p "$fish_dir"
            ~/.farv/bin/farv --generate-completion fish > "$fish_dir/farv.fish"
            echo "[farv] Installed fish completion to $fish_dir/farv.fish"
            return 0
            ;;
    esac
    
    echo "[farv] Could not install completion for $shell"
    echo "[farv] You can manually install with: farv --generate-completion $shell"
    return 1
}

# Update PATH if needed
shell_config=""
case "$(detect_shell)" in
    "zsh") shell_config="$HOME/.zshrc" ;;
    "bash") shell_config="$HOME/.bashrc" ;;
    "fish") shell_config="$HOME/.config/fish/config.fish" ;;
esac

if [[ ":$PATH:" != *":$HOME/.farv/bin:"* ]]; then
    echo "[farv] Adding ~/.farv/bin to PATH"
    if [[ -n "$shell_config" ]] && [[ -f "$shell_config" ]]; then
        echo '' >> "$shell_config"
        echo '# farv theme manager' >> "$shell_config"
        if [[ "$shell_config" == *"fish"* ]]; then
            echo 'set -gx PATH $HOME/.farv/bin $PATH' >> "$shell_config"
        else
            echo 'export PATH="$HOME/.farv/bin:$PATH"' >> "$shell_config"
        fi
        echo "[farv] Updated $shell_config"
    else
        echo "[farv] Please add ~/.farv/bin to your PATH manually"
    fi
fi

# Install completion
echo "[farv] Setting up tab completion..."
shell=$(detect_shell)
echo "[farv] Detected shell: $shell"

if install_completion "$shell"; then
    echo "[farv] Completion installed successfully"
    echo "[farv] Please restart your shell or start a new session to enable tab completion"
else
    echo "[farv] Completion installation failed - you can set it up manually:"
    echo "  For other shells, run: farv --generate-completion <shell>"
fi

echo "[farv] Done - modular farv with cross-shell completion is now installed"