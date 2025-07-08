# Omarchy-inspired theme switcher function
# Usage: theme-switch [theme-name|list]

theme-switch() {
    local THEMES_DIR="$HOME/dotfiles/themes"
    local CURRENT_LINK="$THEMES_DIR/current"

    # Function to list available themes
    list_themes() {
        echo "Available themes:"
        for theme_dir in "$THEMES_DIR"/*/; do
            if [ -d "$theme_dir" ]; then
                local theme_name=$(basename "$theme_dir")
                if [ "$theme_name" != "current" ]; then
                    if [ "$(readlink "$CURRENT_LINK")" = "$THEMES_DIR/$theme_name" ]; then
                        echo "  * $theme_name (current)"
                    else
                        echo "    $theme_name"
                    fi
                fi
            fi
        done
    }

    # Function to switch theme
    switch_theme() {
        local theme_name="$1"
        local theme_path="$THEMES_DIR/$theme_name"
        
        if [ ! -d "$theme_path" ]; then
            echo "Error: Theme '$theme_name' not found"
            echo ""
            list_themes
            return 1
        fi
        
        # Update symlink with absolute path
        rm -f "$CURRENT_LINK"
        ln -sf "$theme_path" "$CURRENT_LINK"
        
        # Touch the main alacritty config to trigger reload
        touch "$HOME/.config/alacritty/alacritty.toml" 2>/dev/null || touch "$HOME/dotfiles/alacritty/alacritty.toml"
        
        # Update bat config by copying theme-specific config and appending base config
        if [ -f "$theme_path/bat.conf" ]; then
            local bat_config="$HOME/.config/bat/config"
            local base_bat_config="$HOME/dotfiles/bat/config"
            local temp_config="/tmp/bat_config_$$"
            
            # Create new config from theme-specific config
            cp "$theme_path/bat.conf" "$temp_config"
            echo "" >> "$temp_config"  # Add newline
            
            # Append base configuration (excluding theme line)
            grep -v "^--theme=" "$base_bat_config" >> "$temp_config"
            
            # Move to final location
            mv "$temp_config" "$bat_config"
        fi
        
        # Update btop theme with symlink
        if [ -f "$theme_path/btop.theme" ]; then
            mkdir -p "$HOME/.config/btop/themes"
            ln -sf "$theme_path/btop.theme" "$HOME/.config/btop/themes/current.theme"
        fi
        
        # Update fzf-tab theme in current shell
        if [ -f "$theme_path/fzf-tab.zsh" ]; then
            source "$theme_path/fzf-tab.zsh"
        fi
        
        # Reload tmux configuration if tmux is running
        if [ -f "$theme_path/tmux.conf" ]; then
            if command -v tmux >/dev/null 2>&1 && tmux list-sessions >/dev/null 2>&1; then
                tmux source-file ~/.tmux.conf 2>/dev/null || true
                echo "  - tmux: Configuration reloaded"
            fi
        fi
        
        echo "Switched to theme: $theme_name"
    }

    # Main logic
    case "${1:-}" in
        "list"|"ls")
            list_themes
            ;;
        "")
            # If fzf is available, use it for theme selection
            if command -v fzf >/dev/null 2>&1; then
                local selected_theme=$(find "$THEMES_DIR" -maxdepth 1 -type d -exec basename {} \; | grep -v "^themes$" | grep -v "^current$" | fzf --prompt="Select theme: " --height=10 --border)
                if [[ -n "$selected_theme" ]]; then
                    switch_theme "$selected_theme"
                fi
            else
                echo "Usage: theme-switch [theme-name|list]"
                echo ""
                list_themes
            fi
            ;;
        *)
            switch_theme "$1"
            ;;
    esac
}

# Tab completion for theme-switch function
_theme_switch() {
    local themes_dir="$HOME/dotfiles/themes"
    local themes=()
    
    # Get available themes (directories in themes folder, excluding 'current')
    for theme_dir in "$themes_dir"/*/; do
        if [ -d "$theme_dir" ]; then
            local theme_name=$(basename "$theme_dir")
            if [ "$theme_name" != "current" ]; then
                themes+=("$theme_name")
            fi
        fi
    done
    
    # Add special commands
    themes+=("list" "ls")
    
    _describe 'themes' themes
}

# Register the completion function
compdef _theme_switch theme-switch
