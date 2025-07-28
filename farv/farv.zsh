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
        if [ -f "$HOME/.config/alacritty/alacritty.toml" ]; then
            touch "$HOME/.config/alacritty/alacritty.toml"
            echo "  - alacritty"
        fi
        
        # Update bat config by copying theme-specific config and appending base config
        if [ -f "$theme_path/bat.conf" ] && [ -f "$HOME/.config/bat/config" ]; then
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
            echo "  - bat"
        fi
        
        # Update btop theme with symlink
        if [ -f "$theme_path/btop.theme" ] && [ -f "$HOME/.config/btop/btop.conf" ]; then
            mkdir -p "$HOME/.config/btop/themes"
            ln -sf "$theme_path/btop.theme" "$HOME/.config/btop/themes/current.theme"
            echo "  - btop"
        fi
        
        # Update fzf-tab theme in current shell
        if [ -f "$theme_path/fzf-tab.zsh" ] && typeset -f _fzf_tab_complete >/dev/null 2>&1; then
            source "$theme_path/fzf-tab.zsh"
            echo "  - fzf-tab"
        fi
        
        # Reload tmux configuration if tmux is running
        if [ -f "$theme_path/tmux.conf" ]; then
            if command -v tmux >/dev/null 2>&1 && tmux list-sessions >/dev/null 2>&1; then
                tmux source-file ~/.tmux.conf 2>/dev/null || true
                echo "  - tmux"
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
                        echo "  - neovim"
                    elif [ ! -e "$theme_symlink" ]; then
                        # Create new theme symlink if it doesn't exist
                        mkdir -p "$nvim_plugins_dir"
                        ln -sf "$theme_path/neovim.lua" "$theme_symlink"
                        echo "  - neovim"
                    fi
                fi
            fi
        fi
        
        # Reload waybar if running
        if [ -f "$theme_path/waybar.css" ]; then
            if command -v waybar >/dev/null 2>&1 && pgrep -x waybar >/dev/null 2>&1; then
                pkill -SIGUSR2 waybar 2>/dev/null || true
                echo "  - waybar"
            fi
        fi
        
        # Update wallpaper using swaybg if on Hyprland
        if [ -f "$theme_path/background.png" ]; then
            if command -v swaybg >/dev/null 2>&1 && [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
                pkill -x swaybg
                (setsid swaybg -i "$theme_path/background.png" -m fill >/dev/null 2>&1 &)
                echo "  - wallpaper"
            fi
        fi
        
        # Update clipboard wofi styling
        if [ -f "$theme_path/wofi-clipboard.css" ]; then
            cp "$theme_path/wofi-clipboard.css" "$CURRENT_LINK/"
            echo "  - clipboard"
        fi
        
        # Update Ghostty theme if Ghostty is installed
        if [ -f "$theme_path/ghostty" ] && command -v ghostty >/dev/null 2>&1; then
            # Reload Ghostty configuration if running
            if pgrep -x ghostty &> /dev/null; then
              ghostty_addresses=$(hyprctl clients -j | jq -r '.[] | select(.class == "com.mitchellh.ghostty") | .address')
              
              if [[ -n "$ghostty_addresses" ]]; then
                # Save current active window
                current_window=$(hyprctl activewindow -j | jq -r '.address')
                
                # Focus each ghostty window and send reload key combo
                while IFS= read -r address; do
                  # hyprctl dispatch focuswindow "address:$address"
                  hyprctl dispatch sendshortcut "CTRL SHIFT, comma, address:$address"
                done <<< "$ghostty_addresses"
                
                # Return focus to original window
                if [[ -n "$current_window" ]]; then
                  hyprctl dispatch focuswindow "address:$current_window"
                fi
              fi
            fi
            echo "  - ghostty"
        fi
        
        # Apply GTK theme settings with fallback
        local theme_category
        if [[ "$theme_path" == *"/light/"* ]]; then
            theme_category="light"
        elif [[ "$theme_path" == *"/dark/"* ]]; then
            theme_category="dark"
        fi

        if [ -n "$theme_category" ]; then
            local gtk_script=""
            
            # First priority: theme-specific gtk.sh
            local theme_specific_script="$theme_path/gtk.sh"
            if [ -f "$theme_specific_script" ] && [ -x "$theme_specific_script" ]; then
                gtk_script="$theme_specific_script"
            else
                # Fallback: category-level gtk.sh
                local category_script="$THEMES_DIR/themes/$theme_category/gtk.sh"
                if [ -f "$category_script" ] && [ -x "$category_script" ]; then
                    gtk_script="$category_script"
                fi
            fi
            
            # Execute the selected GTK script
            if [ -n "$gtk_script" ]; then
                # Check if we're in a GNOME/GTK environment
                if [ -n "$XDG_CURRENT_DESKTOP" ] && command -v gsettings >/dev/null 2>&1; then
                    "$gtk_script" >/dev/null 2>&1 && echo "  - gtk"
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
