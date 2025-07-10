# Usage: farv [theme-name|list]

farv() {
    local THEMES_DIR="$HOME/.farv"
    local CURRENT_LINK="$THEMES_DIR/current"

    # Function to list available themes
    list_themes() {
        echo "Available themes:"
        # List light themes
        for theme_dir in "$THEMES_DIR/themes/light"/*/; do
            if [ -d "$theme_dir" ] && [ "$theme_dir" != "$THEMES_DIR/themes/light/*/" ]; then
                local theme_name=$(basename "$theme_dir")
                local full_path="themes/light/$theme_name"
                if [ "$(readlink "$CURRENT_LINK")" = "$THEMES_DIR/$full_path" ]; then
                    echo "  * $theme_name (light) (current)"
                else
                    echo "    $theme_name (light)"
                fi
            fi
        done
        # List dark themes
        for theme_dir in "$THEMES_DIR/themes/dark"/*/; do
            if [ -d "$theme_dir" ] && [ "$theme_dir" != "$THEMES_DIR/themes/dark/*/" ]; then
                local theme_name=$(basename "$theme_dir")
                local full_path="themes/dark/$theme_name"
                if [ "$(readlink "$CURRENT_LINK")" = "$THEMES_DIR/$full_path" ]; then
                    echo "  * $theme_name (dark) (current)"
                else
                    echo "    $theme_name (dark)"
                fi
            fi
        done
    }

    # Function to switch theme
    switch_theme() {
        local theme_input="$1"
        local theme_name theme_path
        
        # Check if input includes category (e.g., "rose-pine-dawn (light)")
        if [[ "$theme_input" == *" (light)" ]]; then
            theme_name="${theme_input%% \(light\)}"
            theme_path="$THEMES_DIR/themes/light/$theme_name"
        elif [[ "$theme_input" == *" (dark)" ]]; then
            theme_name="${theme_input%% \(dark\)}"
            theme_path="$THEMES_DIR/themes/dark/$theme_name"
        else
            # Try to find theme in both light and dark directories
            theme_name="$theme_input"
            if [ -d "$THEMES_DIR/themes/light/$theme_name" ]; then
                theme_path="$THEMES_DIR/themes/light/$theme_name"
            elif [ -d "$THEMES_DIR/themes/dark/$theme_name" ]; then
                theme_path="$THEMES_DIR/themes/dark/$theme_name"
            else
                theme_path=""
            fi
        fi
        
        if [ ! -d "$theme_path" ]; then
            echo "Error: Theme '$theme_input' not found"
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
        
        # Update neovim colorscheme if neovim is installed and configured
        if [ -f "$theme_path/neovim.lua" ]; then
            if command -v nvim >/dev/null 2>&1; then
                local nvim_config_dir="$HOME/.config/nvim"
                local nvim_plugins_dir="$nvim_config_dir/lua/plugins"
                local theme_symlink="$nvim_plugins_dir/farv.lua"
                
                # Check if user has neovim configuration
                if [ -d "$nvim_config_dir" ] && [ -f "$nvim_config_dir/init.lua" ]; then
                    # Check if theme symlink exists and points to farv
                    if [ -L "$theme_symlink" ] && [[ "$(readlink "$theme_symlink")" == *"/.farv/"* ]]; then
                        # Update existing farv theme symlink
                        ln -sf "$theme_path/neovim.lua" "$theme_symlink"
                        echo "  - neovim: Theme configuration updated"
                    elif [ ! -e "$theme_symlink" ]; then
                        # Create new theme symlink if it doesn't exist
                        mkdir -p "$nvim_plugins_dir"
                        ln -sf "$theme_path/neovim.lua" "$theme_symlink"
                        echo "  - neovim: Theme configuration linked"
                    fi
                fi
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
                local themes=()
                # Add light themes
                for theme_dir in "$THEMES_DIR/themes/light"/*/; do
                    # Skip if glob didn't match anything (theme_dir will be the literal pattern)
                    if [ -d "$theme_dir" ] && [ "$theme_dir" != "$THEMES_DIR/themes/light/*/" ]; then
                        local theme_name=$(basename "$theme_dir")
                        themes+=("$theme_name (light)")
                    fi
                done
                # Add dark themes
                for theme_dir in "$THEMES_DIR/themes/dark"/*/; do
                    # Skip if glob didn't match anything (theme_dir will be the literal pattern)
                    if [ -d "$theme_dir" ] && [ "$theme_dir" != "$THEMES_DIR/themes/dark/*/" ]; then
                        local theme_name=$(basename "$theme_dir")
                        themes+=("$theme_name (dark)")
                    fi
                done
                
                local selected_theme=$(printf '%s\n' "${themes[@]}" | fzf --prompt="Select theme: " --height=10 --border)
                if [[ -n "$selected_theme" ]]; then
                    switch_theme "$selected_theme"
                fi
            else
                echo "Usage: farv [theme-name|list]"
                echo ""
                list_themes
            fi
            ;;
        *)
            switch_theme "$1"
            ;;
    esac
}

# Tab completion for farv function
_farv() {
    local themes_dir="$HOME/.farv"
    local themes=()
    
    # Get available light themes
    for theme_dir in "$themes_dir/themes/light"/*/; do
        if [ -d "$theme_dir" ] && [ "$theme_dir" != "$themes_dir/themes/light/*/" ]; then
            local theme_name=$(basename "$theme_dir")
            themes+=("$theme_name (light)")
        fi
    done
    
    # Get available dark themes
    for theme_dir in "$themes_dir/themes/dark"/*/; do
        if [ -d "$theme_dir" ] && [ "$theme_dir" != "$themes_dir/themes/dark/*/" ]; then
            local theme_name=$(basename "$theme_dir")
            themes+=("$theme_name (dark)")
        fi
    done
    
    _describe 'themes' themes
}

# Register the completion function
compdef _farv farv
