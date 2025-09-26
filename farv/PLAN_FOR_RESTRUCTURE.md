# Plan for Theme-Centric Restructure

## Vision

Transform farv from a handler-based system to a theme-centric system where:

1. **Self-contained themes**: Each theme directory contains both config files and executable scripts
2. **Layered configuration**: Files can be overridden at multiple levels with clear precedence
3. **Executable scripts**: Any executable file in a theme gets run during theme switching
4. **Symlinked configs**: Config files are symlinked to `~/.config/farv/current/` for applications to reference

## New Directory Structure

### System Installation
```
/usr/share/farv/
└── themes/
    ├── alacritty.toml              # Global fallback configs
    ├── bat.conf
    ├── setup.sh                    # Global setup script (executable)
    ├── light/
    │   ├── alacritty.toml          # Light theme fallback configs
    │   ├── gtk.sh                  # Light-specific script (executable)
    │   └── rose-pine-dawn/
    │       ├── alacritty.toml      # Theme-specific configs
    │       ├── bat.conf
    │       ├── ghostty
    │       ├── background.png
    │       ├── alacritty.sh        # Theme-specific scripts (executable)
    │       ├── custom-setup.sh     # Custom theme logic (executable)
    │       └── neovim.lua
    └── dark/
        ├── bat.conf                # Dark theme fallback configs
        ├── tmux.conf
        └── tokyonight-night/
            ├── alacritty.toml
            ├── bat.conf
            ├── ghostty
            ├── setup-dark-mode.sh  # Theme-specific script (executable)
            └── ...
```

### User Configuration
```
~/.config/farv/
├── themes/
│   ├── gtk.sh                      # User global overrides (executable)
│   ├── light/
│   │   ├── alacritty.toml          # User light theme overrides
│   │   └── rose-pine-dawn/
│   │       ├── alacritty.toml      # User theme-specific overrides
│   │       ├── custom.sh           # User custom scripts (executable)
│   │       └── wallpaper.png       # User theme-specific files
│   └── dark/
│       └── my-custom-theme/        # User's completely custom theme
│           ├── alacritty.toml
│           ├── setup.sh            # Custom theme script (executable)
│           └── ...
├── current/                        # Symlinked active theme files
│   ├── alacritty.toml -> /usr/share/farv/themes/light/rose-pine-dawn/alacritty.toml
│   ├── bat.conf -> ~/.config/farv/themes/light/rose-pine-dawn/bat.conf
│   ├── ghostty -> /usr/share/farv/themes/light/rose-pine-dawn/ghostty
│   └── background.png -> ~/.config/farv/themes/light/rose-pine-dawn/wallpaper.png
└── config                          # User configuration file
```

## Layering System (File Resolution Priority)

For any file (e.g., `alacritty.toml`), farv searches in this order:

1. **User theme-specific**: `~/.config/farv/themes/{category}/{theme-name}/alacritty.toml`
2. **System theme-specific**: `/usr/share/farv/themes/{category}/{theme-name}/alacritty.toml`
3. **User category-level**: `~/.config/farv/themes/{category}/alacritty.toml`
4. **System category-level**: `/usr/share/farv/themes/{category}/alacritty.toml`
5. **User global**: `~/.config/farv/themes/alacritty.toml`
6. **System global**: `/usr/share/farv/themes/alacritty.toml`

**First match wins** and gets symlinked to `~/.config/farv/current/filename`.

### Example Resolution

Switching to `rose-pine-dawn (light)` with user customizations:

```bash
# alacritty.toml resolution:
# ✓ Found: ~/.config/farv/themes/light/rose-pine-dawn/alacritty.toml (USER OVERRIDE)
# → Symlink: ~/.config/farv/current/alacritty.toml

# bat.conf resolution:
# ✗ Not found: ~/.config/farv/themes/light/rose-pine-dawn/bat.conf
# ✓ Found: /usr/share/farv/themes/light/rose-pine-dawn/bat.conf (SYSTEM)
# → Symlink: ~/.config/farv/current/bat.conf

# tmux.conf resolution:
# ✗ Not found: ~/.config/farv/themes/light/rose-pine-dawn/tmux.conf
# ✗ Not found: /usr/share/farv/themes/light/rose-pine-dawn/tmux.conf
# ✗ Not found: ~/.config/farv/themes/light/tmux.conf
# ✓ Found: /usr/share/farv/themes/light/tmux.conf (CATEGORY FALLBACK)
# → Symlink: ~/.config/farv/current/tmux.conf
```

## Executable Script System

### Script Discovery and Execution

**Discovery Priority** (same layering as files):
1. User theme-specific executables
2. System theme-specific executables  
3. User category-level executables
4. System category-level executables
5. User global executables
6. System global executables

**Execution Rules**:
- Any file with execute permission (`chmod +x`) gets executed
- Scripts executed in dependency order (if determinable) or alphabetical order
- Each script receives the theme path as first argument: `script.sh /path/to/resolved/theme`
- Scripts run in order of discovery priority (user overrides system)

**Script Interface**:
```bash
#!/usr/bin/env bash
# Script receives theme information as arguments
THEME_PATH="$1"           # Path to the theme directory being applied
THEME_NAME="$2"           # Theme name (e.g., "rose-pine-dawn")
THEME_CATEGORY="$3"       # Theme category (e.g., "light")
CURRENT_LINK="$4"         # Path to ~/.config/farv/current/

# Script can access all symlinked config files
ALACRITTY_CONFIG="$CURRENT_LINK/alacritty.toml"
BAT_CONFIG="$CURRENT_LINK/bat.conf"

# Example: Reload alacritty if running
if pgrep -x alacritty > /dev/null && [ -f "$ALACRITTY_CONFIG" ]; then
    # Custom alacritty reload logic
    pkill -USR1 alacritty
fi
```

### Script Examples

**Theme-specific script** (`/usr/share/farv/themes/light/rose-pine-dawn/setup.sh`):
```bash
#!/usr/bin/env bash
CURRENT_LINK="$4"

# Set light-specific GTK theme
if command -v gsettings >/dev/null; then
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 
fi

# Update wallpaper if background exists
if [ -f "$CURRENT_LINK/background.png" ]; then
    if command -v swaybg >/dev/null && [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        pkill -x swaybg
        swaybg -i "$CURRENT_LINK/background.png" -m fill &
    fi
fi
```

**User override script** (`~/.config/farv/themes/light/rose-pine-dawn/custom.sh`):
```bash
#!/usr/bin/env bash
THEME_NAME="$2"
CURRENT_LINK="$4"

# Custom user logic that runs after system script
echo "Applied user customizations for $THEME_NAME"

# Update custom applications not handled by farv
if [ -f "$CURRENT_LINK/my-app.conf" ]; then
    cp "$CURRENT_LINK/my-app.conf" ~/.config/my-app/config
    pkill -HUP my-app
fi
```

## Implementation Changes

### Core Algorithm Changes

```bash
apply_theme() {
    local theme_name="$1"
    local theme_category="$2"
    
    # 1. Clear current symlinks
    rm -rf "$FARV_CONFIG_HOME/current"
    mkdir -p "$FARV_CONFIG_HOME/current"
    
    # 2. Discover all files in theme hierarchy
    local all_files=($(discover_theme_files "$theme_category" "$theme_name"))
    
    # 3. For each unique filename, resolve and symlink highest priority version
    for filename in "${all_files[@]}"; do
        local resolved_path=$(resolve_file_path "$theme_category" "$theme_name" "$filename")
        if [ -n "$resolved_path" ]; then
            ln -sf "$resolved_path" "$FARV_CONFIG_HOME/current/$filename"
        fi
    done
    
    # 4. Discover and execute all scripts in priority order
    local scripts=($(discover_theme_scripts "$theme_category" "$theme_name"))
    for script in "${scripts[@]}"; do
        if [ -x "$script" ]; then
            "$script" "$resolved_theme_path" "$theme_name" "$theme_category" "$FARV_CONFIG_HOME/current"
        fi
    done
}
```

### File Discovery Function

```bash
discover_theme_files() {
    local category="$1"
    local theme_name="$2"
    local files=()
    
    # Collect all possible file paths in reverse priority order
    local search_paths=(
        "/usr/share/farv/themes"
        "~/.config/farv/themes" 
        "/usr/share/farv/themes/$category"
        "~/.config/farv/themes/$category"
        "/usr/share/farv/themes/$category/$theme_name"
        "~/.config/farv/themes/$category/$theme_name"
    )
    
    # Get unique filenames from all locations
    for path in "${search_paths[@]}"; do
        if [ -d "$path" ]; then
            for file in "$path"/*; do
                if [ -f "$file" ] && [[ ! "$file" =~ \.sh$ ]] && [[ ! -x "$file" ]]; then
                    files+=($(basename "$file"))
                fi
            done
        fi
    done
    
    # Return unique filenames
    printf '%s\n' "${files[@]}" | sort -u
}
```

## User Experience Changes

### Theme Creation Workflow

**Creating a custom theme:**
```bash
# Create theme directory
mkdir -p ~/.config/farv/themes/dark/my-theme

# Add config files
echo 'background_color = "#1a1a1a"' > ~/.config/farv/themes/dark/my-theme/alacritty.toml
cp ~/wallpapers/dark.png ~/.config/farv/themes/dark/my-theme/background.png

# Add custom setup script
cat > ~/.config/farv/themes/dark/my-theme/setup.sh << 'EOF'
#!/usr/bin/env bash
CURRENT_LINK="$4"

# Custom theme setup
echo "Setting up my custom dark theme"

# Update Firefox theme
if [ -d ~/.mozilla/firefox ]; then
    # Custom Firefox theming logic
fi
EOF
chmod +x ~/.config/farv/themes/dark/my-theme/setup.sh

# Theme is now available
farv list  # Shows "my-theme (dark) [user]"
farv my-theme
```

**Customizing existing theme:**
```bash
# Override just alacritty config for rose-pine-dawn
mkdir -p ~/.config/farv/themes/light/rose-pine-dawn
echo 'font_size = 14' > ~/.config/farv/themes/light/rose-pine-dawn/alacritty.toml

# Add custom script for this theme
cat > ~/.config/farv/themes/light/rose-pine-dawn/notifications.sh << 'EOF'
#!/usr/bin/env bash
# Disable notifications in light theme
pkill -x mako
mako --background-color "#ffffff" --text-color "#000000" &
EOF
chmod +x ~/.config/farv/themes/light/rose-pine-dawn/notifications.sh

# Changes take effect immediately
farv rose-pine-dawn
```

**Category-level customization:**
```bash
# All light themes get this gtk script
cat > ~/.config/farv/themes/light/gtk.sh << 'EOF'
#!/usr/bin/env bash
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
EOF
chmod +x ~/.config/farv/themes/light/gtk.sh

# Script runs for any light theme
farv rose-pine-dawn    # Runs the gtk.sh script
farv catppuccin-latte  # Also runs the gtk.sh script
```

### Application Integration

Applications reference configs via the current symlinks:

**Alacritty** (`~/.config/alacritty/alacritty.toml`):
```toml
import = ["~/.config/farv/current/alacritty.toml"]

[font]
normal = { family = "JetBrains Mono", style = "Regular" }
```

**Tmux** (`~/.tmux.conf`):
```bash
# Source farv theme if available
if-shell "test -f ~/.config/farv/current/tmux.conf" \
    "source-file ~/.config/farv/current/tmux.conf"
```

## Migration Strategy

### Phase 1: Implement New Core Logic
- Add layered file resolution system
- Add executable script discovery and execution
- Maintain existing handler system as fallback

### Phase 2: Convert Existing Themes
- Move handler logic into theme-specific scripts
- Test with existing themes to ensure compatibility
- Create migration script for user themes

### Phase 3: Remove Handler System
- Remove handlers/ directory support
- Update documentation and examples
- Clean up legacy code

## Benefits of New System

### For Users
1. **Intuitive**: Everything for a theme is in one place
2. **Powerful**: Can override any aspect at any level
3. **Flexible**: Themes can have completely custom logic
4. **Discoverable**: Easy to see what files/scripts a theme uses

### For Theme Creators
1. **Self-contained**: Ship theme as single directory
2. **Extensible**: Add custom applications easily
3. **Layered**: Users can override specific parts
4. **Scriptable**: Full shell scripting power for complex setups

### For Applications
1. **Simple integration**: Just reference `~/.config/farv/current/appname.conf`
2. **Dynamic**: Configs update automatically when themes change
3. **Reliable**: Always have a config file (fallback system)

This restructure transforms farv from an application-centric tool into a true theme management framework where themes are first-class citizens with complete control over the user's desktop environment.