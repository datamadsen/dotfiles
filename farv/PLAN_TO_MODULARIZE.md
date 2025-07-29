# FARV Modularization Plan

## Current State Analysis

The current `farv.zsh` is a monolithic 291-line file containing:
- Theme listing functionality
- Theme switching logic with 11 different application handlers
- Interactive fzf-based theme selection
- Zsh completion support
- All logic embedded in a single zsh function

## Modularization Goals

1. **Convert from zsh function to standalone script** with completion support
2. **Separate application-specific handlers** into individual scripts
3. **Maintain completion functionality** in the standalone script
4. **Preserve existing interface** and user experience
5. **Enable easier maintenance** and individual handler modification

## Proposed Structure

```
~/.farv/
├── bin/
│   ├── farv                    # Main executable script (contains all core logic)
│   └── handlers/
│       ├── alacritty.sh
│       ├── bat.sh
│       ├── btop.sh
│       ├── fzf-tab.sh
│       ├── tmux.sh
│       ├── neovim.sh
│       ├── waybar.sh
│       ├── wallpaper.sh
│       ├── clipboard.sh
│       ├── ghostty.sh
│       └── gtk.sh
└── themes/
    ├── light/
    └── dark/
```

## Implementation Plan

### Phase 1: Create Main Executable (`~/.farv/bin/farv`)

The main script will contain all core functionality:

```bash
#!/usr/bin/env bash

# Constants
FARV_DIR="$HOME/.farv"
THEMES_DIR="$FARV_DIR/themes"
CURRENT_LINK="$FARV_DIR/current"
HANDLERS_DIR="$FARV_DIR/bin/handlers"

# Utility functions
log_action() { echo "  - $1"; }
is_running() { pgrep -x "$1" >/dev/null 2>&1; }
has_command() { command -v "$1" >/dev/null 2>&1; }

# Theme management functions
list_themes() { ... }
find_theme_path() { ... }
switch_theme() { ... }
generate_completions() { ... }

# Main logic
case "${1:-}" in
    "--complete") generate_completions ;;
    "list"|"ls") list_themes ;;
    "") interactive_selection ;;
    *) switch_theme "$1" ;;
esac
```

### Phase 2: Application Handlers

Extract each application's update logic into individual handler scripts:

#### 2.1 Handler Interface
Each handler script will follow this interface:
```bash
#!/usr/bin/env bash
# Handler: Application Name
# Purpose: Update application configuration when theme changes

# Utility functions (duplicated in each handler for simplicity)
log_action() { echo "  - $1"; }
is_running() { pgrep -x "$1" >/dev/null 2>&1; }
has_command() { command -v "$1" >/dev/null 2>&1; }

# Check if application is available and configured
check_availability() {
    # Return 0 if handler should run, 1 if should skip
}

# Apply theme configuration
apply_theme() {
    local theme_path="$1"
    # Application-specific theme switching logic
}

# Main execution
if check_availability; then
    apply_theme "$1"
    log_action "$(basename "$0" .sh)"
fi
```

#### 2.2 Individual Handlers

**alacritty.sh:**
```bash
check_availability() {
    [ -f "$HOME/.config/alacritty/alacritty.toml" ]
}

apply_theme() {
    local theme_path="$1"
    touch "$HOME/.config/alacritty/alacritty.toml"
}
```

**bat.sh:**
```bash
check_availability() {
    [ -f "$theme_path/bat.conf" ] && [ -f "$HOME/.config/bat/config" ]
}

apply_theme() {
    local theme_path="$1"
    local bat_config="$HOME/.config/bat/config"
    local base_bat_config="$HOME/dotfiles/bat/config"
    local temp_config="/tmp/bat_config_$$"
    
    cp "$theme_path/bat.conf" "$temp_config"
    echo "" >> "$temp_config"
    grep -v "^--theme=" "$base_bat_config" >> "$temp_config"
    mv "$temp_config" "$bat_config"
}
```

**ghostty.sh:**
```bash
check_availability() {
    [ -f "$theme_path/ghostty" ] && has_command ghostty
}

apply_theme() {
    local theme_path="$1"
    if is_running ghostty; then
        local ghostty_addresses=$(hyprctl clients -j | jq -r '.[] | select(.class == "com.mitchellh.ghostty") | .address')
        
        if [[ -n "$ghostty_addresses" ]]; then
            local current_window=$(hyprctl activewindow -j | jq -r '.address')
            
            while IFS= read -r address; do
                hyprctl dispatch sendshortcut "CTRL SHIFT, comma, address:$address"
            done <<< "$ghostty_addresses"
            
            if [[ -n "$current_window" ]]; then
                hyprctl dispatch focuswindow "address:$current_window"
            fi
        fi
    fi
}
```

### Phase 3: Zsh Integration
Update `farv.zsh` to be a thin wrapper:
```bash
# New farv.zsh - just completion registration
_farv() {
    local themes=($(~/.farv/bin/farv --complete 2>/dev/null))
    _describe 'themes' themes
}

compdef _farv farv

# Alias to the actual script
alias farv='~/.farv/bin/farv'
```

### Phase 4: Installation Updates
Update `farv/install.sh`:
```bash
#!/usr/bin/env bash

# Create directory structure
mkdir -p "$HOME/.farv/bin/handlers"

# Make scripts executable
chmod +x "$HOME/.farv/bin/farv"
chmod +x "$HOME/.farv/bin/handlers/"*.sh

# Update PATH if needed
if [[ ":$PATH:" != *":$HOME/.farv/bin:"* ]]; then
    echo 'export PATH="$HOME/.farv/bin:$PATH"' >> ~/.zshrc
fi

# Source the new completion
ln -sf "$PWD/farv.zsh" "$HOME/.farv/completion.zsh"
```

### Phase 5: Enhanced Features

#### 5.1 Configuration File Support
Create `~/.farv/config` for user customization:
```bash
# Which handlers to run (space-separated)
ENABLED_HANDLERS="alacritty bat btop fzf-tab tmux neovim ghostty"

# Handler execution timeout (seconds)
HANDLER_TIMEOUT=5

# Verbose output
VERBOSE=false
```

#### 5.2 Plugin System
Enable user-defined handlers:
```bash
# In ~/.farv/bin/handlers/custom-app.sh
# User can create custom handlers following the same interface
```

#### 5.3 Performance Optimizations
- Parallel handler execution where safe
- Handler dependency management
- Caching of availability checks

## Benefits of This Approach

1. **Maintainability:** Each handler is isolated and can be modified independently
2. **Extensibility:** Easy to add new application support
3. **Performance:** Can optimize individual handlers without affecting others
4. **Testability:** Each component can be tested in isolation
5. **User Customization:** Users can disable specific handlers or add custom ones
6. **Shell Independence:** Main functionality works in any POSIX shell
7. **Completion Support:** Maintains zsh completion while being shell-agnostic

## Implementation Timeline

1. **Phase 1:** Create infrastructure (common.sh, theme-manager.sh, main script)
2. **Phase 2:** Extract all handlers (alacritty, bat, btop, clipboard, ghostty, neovim, gtk, tmux, etc.)
3. **Phase 3:** Implement completion system and zsh integration
4. **Phase 4:** Update installation and test complete system

## File Changes Summary

**New Files:**
- `~/.farv/bin/farv` (main executable with all core logic)
- `~/.farv/bin/handlers/*.sh` (11 handler scripts)

**Modified Files:**
- `~/.farv/farv.zsh` (completely rewritten as thin completion wrapper)
- `~/.farv/install.sh` (updated installation logic)

This modularization will transform farv from a monolithic zsh function into a maintainable, extensible, and shell-agnostic theme management system while preserving all existing functionality and user experience.