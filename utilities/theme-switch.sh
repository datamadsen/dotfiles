#!/bin/bash

# Theme switching script for dotfiles
# Usage: theme-switch.sh [light|dark|auto]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Configuration file paths
GHOSTTY_CONFIG="$HOME/.config/ghostty/config"
ZSHRC_FILE="$HOME/.zshrc"
ROSE_PINE_CONFIG="$HOME/.config/nvim/lua/plugins/rose-pine.lua"
TOKYONIGHT_CONFIG="$HOME/.config/nvim/lua/plugins/tokyonight.lua"
TMUX_CONFIG="$HOME/.tmux.conf"

# Function to detect system theme (works on GNOME and macOS)
detect_system_theme() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        local theme=$(defaults read -g AppleInterfaceStyle 2>/dev/null)
        if [[ "$theme" == "Dark" ]]; then
            echo "dark"
        else
            echo "light"
        fi
    elif command -v gsettings >/dev/null 2>&1; then
        # GNOME/Linux
        local theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
        if [[ "$theme" == *"dark"* ]] || [[ "$theme" == *"Dark"* ]]; then
            echo "dark"
        else
            echo "light"
        fi
    else
        # Fallback to checking environment variables
        if [[ "${THEME_MODE:-}" == "dark" ]]; then
            echo "dark"
        else
            echo "light"
        fi
    fi
}

# Function to switch to light theme
switch_to_light() {
    echo "Switching to light theme..."
    
    # Update Ghostty config
    sed -i 's/^theme = tokyonight_night/## Favorite dark theme\n#theme = tokyonight_night/' "$GHOSTTY_CONFIG"
    sed -i 's/^#theme = rose-pine-dawn/theme = rose-pine-dawn/' "$GHOSTTY_CONFIG"
    
    # Update zshrc fzf-tab colors
    sed -i "s/^zstyle ':fzf-tab:\*' fzf-flags --style=full --height=90% --color=dark/# zstyle ':fzf-tab:*' fzf-flags --style=full --height=90% --color=dark/" "$ZSHRC_FILE"
    sed -i "s/^# zstyle ':fzf-tab:\*' fzf-flags --style=full --height=90% --color=light/zstyle ':fzf-tab:*' fzf-flags --style=full --height=90% --color=light/" "$ZSHRC_FILE"
    
    # Update Neovim rose-pine config
    sed -i 's/^    -- vim\.cmd("colorscheme rose-pine-dawn")/    vim.cmd("colorscheme rose-pine-dawn")/' "$ROSE_PINE_CONFIG"
    
    # Update Neovim tokyonight config
    sed -i 's/^    vim\.cmd("colorscheme tokyonight-night")/    -- vim.cmd("colorscheme tokyonight-night")/' "$TOKYONIGHT_CONFIG"
    
    # Update tmux config
    sed -i "s/^set -g @rose_pine_variant 'main'/set -g @rose_pine_variant 'dawn'/" "$TMUX_CONFIG"
    sed -i "s/^set -g @rose_pine_variant 'moon'/set -g @rose_pine_variant 'dawn'/" "$TMUX_CONFIG"
    sed -i 's/^set -g @plugin '\''fabioluciano\/tmux-tokyo-night'\''/# set -g @plugin '\''fabioluciano\/tmux-tokyo-night'\''/' "$TMUX_CONFIG"
    sed -i 's/^# set -g @plugin '\''rose-pine\/tmux'\''/set -g @plugin '\''rose-pine\/tmux'\''/' "$TMUX_CONFIG"
    
    
    # Reload tmux config if tmux is running or we're in a tmux session
    if [[ -n "$TMUX" ]] || pgrep tmux > /dev/null 2>&1; then
        tmux source-file ~/.tmux.conf \; display "Reloaded!" 2>/dev/null || true
        echo "  - Reloaded tmux configuration"
    fi
    
    echo "Light theme applied successfully!"
}

# Function to switch to dark theme
switch_to_dark() {
    echo "Switching to dark theme..."
    
    # Update Ghostty config
    sed -i 's/^theme = rose-pine-dawn/## favorite light theme\n#theme = rose-pine-dawn/' "$GHOSTTY_CONFIG"
    sed -i 's/^#theme = tokyonight_night/theme = tokyonight_night/' "$GHOSTTY_CONFIG"
    
    # Update zshrc fzf-tab colors
    sed -i "s/^zstyle ':fzf-tab:\*' fzf-flags --style=full --height=90% --color=light/# zstyle ':fzf-tab:*' fzf-flags --style=full --height=90% --color=light/" "$ZSHRC_FILE"
    sed -i "s/^# zstyle ':fzf-tab:\*' fzf-flags --style=full --height=90% --color=dark/zstyle ':fzf-tab:*' fzf-flags --style=full --height=90% --color=dark/" "$ZSHRC_FILE"
    
    # Update Neovim rose-pine config
    sed -i 's/^    vim\.cmd("colorscheme rose-pine-dawn")/    -- vim.cmd("colorscheme rose-pine-dawn")/' "$ROSE_PINE_CONFIG"
    
    # Update Neovim tokyonight config
    sed -i 's/^    -- vim\.cmd("colorscheme tokyonight-night")/    vim.cmd("colorscheme tokyonight-night")/' "$TOKYONIGHT_CONFIG"
    
    # Update tmux config
    sed -i "s/^set -g @rose_pine_variant 'dawn'/set -g @rose_pine_variant 'main'/" "$TMUX_CONFIG"
    sed -i 's/^set -g @plugin '\''rose-pine\/tmux'\''/# set -g @plugin '\''rose-pine\/tmux'\''/' "$TMUX_CONFIG"
    sed -i 's/^# set -g @plugin '\''fabioluciano\/tmux-tokyo-night'\''/set -g @plugin '\''fabioluciano\/tmux-tokyo-night'\''/' "$TMUX_CONFIG"
    
    
    # Reload tmux config if tmux is running or we're in a tmux session
    if [[ -n "$TMUX" ]] || pgrep tmux > /dev/null 2>&1; then
        tmux source-file ~/.tmux.conf \; display "Reloaded!" 2>/dev/null || true
        echo "  - Reloaded tmux configuration"
    fi
    
    echo "Dark theme applied successfully!"
}

# Function to show current theme
show_current_theme() {
    echo "Current theme configuration:"
    echo "  Ghostty: $(grep "^theme = " "$GHOSTTY_CONFIG" | cut -d'=' -f2 | xargs)"
    echo "  fzf-tab: $(grep "^zstyle.*fzf-flags.*color=" "$ZSHRC_FILE" | grep -o 'color=[^[:space:]]*' | cut -d'=' -f2 || echo "unknown")"
    echo "  tmux: $(grep "^set -g @rose_pine_variant" "$TMUX_CONFIG" | cut -d"'" -f2 2>/dev/null || echo "tokyonight")"
    
    # Check active neovim theme
    if grep -q "^    vim\.cmd.*rose-pine-dawn" "$ROSE_PINE_CONFIG"; then
        echo "  neovim: rose-pine-dawn"
    elif grep -q "^    vim\.cmd.*tokyonight-night" "$TOKYONIGHT_CONFIG"; then
        echo "  neovim: tokyonight-night"
    else
        echo "  neovim: unknown"
    fi
    
}

# Main logic
case "${1:-}" in
    "light")
        switch_to_light
        ;;
    "dark")
        switch_to_dark
        ;;
    "auto")
        detected_theme=$(detect_system_theme)
        echo "Detected system theme: $detected_theme"
        if [[ "$detected_theme" == "dark" ]]; then
            switch_to_dark
        else
            switch_to_light
        fi
        ;;
    "status"|"show")
        show_current_theme
        ;;
    *)
        echo "Usage: $0 [light|dark|auto|status]"
        echo ""
        echo "Commands:"
        echo "  light   - Switch to light theme (rose-pine-dawn)"
        echo "  dark    - Switch to dark theme (tokyonight)"
        echo "  auto    - Detect and apply system theme"
        echo "  status  - Show current theme configuration"
        echo ""
        echo "Current system theme: $(detect_system_theme)"
        exit 1
        ;;
esac