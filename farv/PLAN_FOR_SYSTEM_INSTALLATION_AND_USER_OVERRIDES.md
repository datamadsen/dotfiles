# Plan for System Installation and User Overrides

## Vision

Transform farv from a personal dotfiles tool into a system-wide rice configuration framework that:

1. **Framework**: Provides structured approach to managing desktop themes across applications
2. **Default themes**: Ships with curated, ready-to-use themes out of the box
3. **Extensibility**: Clear extension points for users to add custom themes and handlers
4. **User overrides**: Allow users to customize or replace any part of the system

## Directory Structure

### System Installation Locations

```
/usr/bin/farv                           # Main executable
/usr/share/farv/
├── themes/
│   ├── light/
│   │   ├── rose-pine-dawn/
│   │   │   ├── alacritty.toml
│   │   │   ├── bat.conf
│   │   │   ├── btop.theme
│   │   │   ├── ghostty
│   │   │   ├── neovim.lua
│   │   │   ├── tmux.conf
│   │   │   ├── waybar.css
│   │   │   └── background.png
│   │   └── catppuccin-latte/           # Additional system themes
│   └── dark/
│       ├── tokyonight-night/
│       ├── catppuccin-mocha/
│       └── gruvbox-dark/
└── handlers/
    ├── alacritty.sh
    ├── bat.sh
    ├── btop.sh
    ├── clipboard.sh
    ├── fzf-tab.sh
    ├── ghostty.sh
    ├── gtk.sh
    ├── neovim.sh
    ├── tmux.sh
    ├── wallpaper.sh
    └── waybar.sh
```

### User Override Locations

```
$XDG_CONFIG_HOME/farv/                  # User configuration (defaults to ~/.config/farv/)
├── themes/
│   ├── light/
│   │   └── my-custom-light/            # User's custom themes
│   └── dark/
│       └── my-custom-dark/
├── handlers/
│   ├── my-app.sh                       # User's custom handlers
│   ├── alacritty.sh                    # Override system handler
│   └── waybar.sh                       # Disabled system handler (empty file)
├── current -> /usr/share/farv/themes/dark/tokyonight-night/  # Current theme symlink
└── config                              # User configuration file
```


## Search Priority System

### Theme Resolution Priority
1. `$XDG_CONFIG_HOME/farv/themes/{light,dark}/theme-name/`
2. `/usr/share/farv/themes/{light,dark}/theme-name/`

### Handler Resolution Priority  
1. `$XDG_CONFIG_HOME/farv/handlers/handler-name.sh`
2. `/usr/share/farv/handlers/handler-name.sh`

### Special Handler Behaviors
- **Disabled handlers**: Create an empty handler script in `$XDG_CONFIG_HOME/farv/handlers/` to disable system handler
- **Custom handlers**: Any `.sh` file in `$XDG_CONFIG_HOME/farv/handlers/` will be executed
- **Handler overrides**: User handlers completely replace system handlers of the same name

## Code Architecture Changes

### Environment Variables and Paths

```bash
# System paths
FARV_SYSTEM_DIR="/usr/share/farv"
FARV_SYSTEM_THEMES="$FARV_SYSTEM_DIR/themes"
FARV_SYSTEM_HANDLERS="$FARV_SYSTEM_DIR/handlers"

# User paths (XDG compliant)
FARV_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/farv"
FARV_USER_THEMES="$FARV_CONFIG_HOME/themes"  
FARV_USER_HANDLERS="$FARV_CONFIG_HOME/handlers"
FARV_CURRENT_LINK="$FARV_CONFIG_HOME/current"
```

### Theme Discovery Function

```bash
discover_themes() {
    local category="$1"  # light or dark
    local themes=()
    
    # User themes first (higher priority)
    if [ -d "$FARV_USER_THEMES/$category" ]; then
        for theme_dir in "$FARV_USER_THEMES/$category"/*/; do
            if [ -d "$theme_dir" ]; then
                local theme_name=$(basename "$theme_dir")
                themes+=("$theme_name ($category) [user]")
            fi
        done
    fi
    
    # System themes second
    if [ -d "$FARV_SYSTEM_THEMES/$category" ]; then
        for theme_dir in "$FARV_SYSTEM_THEMES/$category"/*/; do
            if [ -d "$theme_dir" ]; then
                local theme_name=$(basename "$theme_dir")
                # Only add if not already found in user themes
                if [[ ! " ${themes[@]} " =~ " $theme_name ($category) [user] " ]]; then
                    themes+=("$theme_name ($category)")
                fi
            fi
        done
    fi
    
    printf '%s\n' "${themes[@]}"
}
```

### Theme Path Resolution Function

```bash
resolve_theme_path() {
    local theme_name="$1"
    local category="$2"  # light or dark
    
    # Check user themes first
    local user_path="$FARV_USER_THEMES/$category/$theme_name"
    if [ -d "$user_path" ]; then
        echo "$user_path"
        return 0
    fi
    
    # Fall back to system themes
    local system_path="$FARV_SYSTEM_THEMES/$category/$theme_name"
    if [ -d "$system_path" ]; then
        echo "$system_path"
        return 0
    fi
    
    return 1
}
```

### Handler Discovery and Execution

```bash
discover_handlers() {
    local handlers=()
    
    # Get all available handlers from both locations
    for handler_path in "$FARV_SYSTEM_HANDLERS"/*.sh "$FARV_USER_HANDLERS"/*.sh; do
        if [ -f "$handler_path" ]; then
            local handler_name=$(basename "$handler_path")
            
            # User handlers override system ones
            if [[ "$handler_path" == "$FARV_USER_HANDLERS"/* ]]; then
                handlers+=("$handler_path")
            elif [ ! -f "$FARV_USER_HANDLERS/$handler_name" ]; then
                handlers+=("$handler_path")
            fi
        fi
    done
    
    printf '%s\n' "${handlers[@]}"
}

execute_handlers() {
    local theme_path="$1"
    
    while IFS= read -r handler_path; do
        if [ -f "$handler_path" ] && [ -x "$handler_path" ]; then
            "$handler_path" "$theme_path"
        fi
    done < <(discover_handlers)
}
```

### User Configuration Support

```bash
# $XDG_CONFIG_HOME/farv/config
# User configuration file

# Custom handler timeout (seconds)
HANDLER_TIMEOUT=10

# Verbose output
VERBOSE=true

# Default theme category preference
DEFAULT_CATEGORY="dark"
```

## Installation Strategy

### System Package Structure

```bash
# Package files
/usr/bin/farv
/usr/share/farv/themes/light/rose-pine-dawn/...
/usr/share/farv/themes/dark/tokyonight-night/...
/usr/share/farv/handlers/alacritty.sh
/usr/share/farv/handlers/bat.sh
# ... etc

# Completion files
/usr/share/bash-completion/completions/farv
/usr/share/zsh/site-functions/_farv
/usr/share/fish/vendor_completions.d/farv.fish
```

### First-Run Initialization

```bash
# On first run, farv creates user directories:
mkdir -p "$FARV_CONFIG_HOME"/{themes/{light,dark},handlers}

# Create example user configuration
if [ ! -f "$FARV_CONFIG_HOME/config" ]; then
    cat > "$FARV_CONFIG_HOME/config" << 'EOF'
# Farv user configuration
# Uncomment and modify as needed

# HANDLER_TIMEOUT=10
# VERBOSE=true
# DEFAULT_CATEGORY="dark"
EOF
fi
```

### Package Manager Integration

**Arch Linux (PKGBUILD)**:
```bash
# PKGBUILD structure
package() {
    install -Dm755 farv "$pkgdir/usr/bin/farv"
    
    # Install system themes
    cp -r themes "$pkgdir/usr/share/farv/"
    
    # Install system handlers  
    cp -r handlers "$pkgdir/usr/share/farv/"
    chmod +x "$pkgdir/usr/share/farv/handlers/"*.sh
    
    # Install completions
    install -Dm644 completions/_farv "$pkgdir/usr/share/zsh/site-functions/_farv"
    install -Dm644 completions/farv.bash "$pkgdir/usr/share/bash-completion/completions/farv"
    install -Dm644 completions/farv.fish "$pkgdir/usr/share/fish/vendor_completions.d/farv.fish"
}
```

## User Experience

### Out-of-Box Experience
1. `sudo pacman -S farv` (or equivalent)
2. `farv list` - shows bundled themes
3. `farv rose-pine-dawn` - switches to bundled theme
4. Tab completion works immediately
5. All supported applications themed automatically

### Customization Workflow

**Adding Custom Theme:**
```bash
# Create user theme directory
mkdir -p ~/.config/farv/themes/dark/my-theme

# Add application configs
echo 'background_color = "#1a1a1a"' > ~/.config/farv/themes/dark/my-theme/alacritty.toml
# ... add other app configs

# Theme is now available
farv list  # shows "my-theme (dark) [user]"
farv my-theme
```

**Custom Handler:**
```bash
# Create custom handler
cat > ~/.config/farv/handlers/firefox.sh << 'EOF'
#!/usr/bin/env bash
# Custom Firefox theme handler

log_action() { echo "  - $1"; }

apply_theme() {
    local theme_path="$1"
    if [ -f "$theme_path/firefox-userchrome.css" ]; then
        # Apply Firefox theme
        log_action "firefox"
    fi
}

if [ -f "$1/firefox-userchrome.css" ]; then
    apply_theme "$1"
fi
EOF

chmod +x ~/.config/farv/handlers/firefox.sh
```

**Override System Handler:**
```bash
# Override system alacritty handler with custom behavior
cp /usr/share/farv/handlers/alacritty.sh ~/.config/farv/handlers/alacritty.sh
# Edit ~/.config/farv/handlers/alacritty.sh for custom behavior
```

**Disable Handler:**
```bash
# Disable waybar handler by creating empty script
touch ~/.config/farv/handlers/waybar.sh
# Or with explanation comment:
echo '# Waybar handler disabled by user' > ~/.config/farv/handlers/waybar.sh
```

### Advanced Features

**Theme Inheritance:**
```bash
# ~/.config/farv/themes/dark/my-variant/
# Can inherit from system theme and override specific files
ln -s /usr/share/farv/themes/dark/tokyonight-night/* ~/.config/farv/themes/dark/my-variant/
# Override specific files
echo 'custom config' > ~/.config/farv/themes/dark/my-variant/alacritty.toml
```

**Development Workflow:**
```bash
# Developer working on new theme
farv --verbose my-new-theme  # See which handlers run and what they do
farv --dry-run my-new-theme  # Preview what would happen without applying
```

## Migration Path

### Phase 1: Core Architecture
- Implement search priority system
- Add XDG directory support
- Update theme/handler discovery functions
- Maintain backward compatibility with current installation

### Phase 2: System Integration  
- Create proper system installation scripts
- Package for common distributions
- Implement first-run initialization
- Add user configuration support

### Phase 3: Enhanced Features
- Add theme inheritance
- Implement verbose/dry-run modes
- Create theme development tools
- Add handler dependency management

## Benefits

### For Users
- **Zero setup**: Works immediately after system installation
- **Customizable**: Easy to add themes and handlers
- **Non-destructive**: User customizations never conflict with system updates
- **Discoverable**: Clear separation between system and user content

### For Developers
- **Maintainable**: System handlers maintained centrally
- **Extensible**: Clear API for custom handlers
- **Distributeable**: Proper package manager integration
- **Testable**: Handlers can be tested independently

### For System Administrators
- **Standard locations**: Follows XDG specifications
- **Manageable**: System themes managed via package manager
- **Secure**: User customizations isolated to user directories
- **Auditable**: Clear separation of system vs user components

## Example Package Contents

A distribution package would include:
- **Core binary**: `/usr/bin/farv`
- **5-10 curated themes**: Popular, high-quality themes
- **10-15 application handlers**: Most common applications
- **Completion scripts**: All major shells
- **Documentation**: Man page, examples, API reference

This transforms farv from a personal tool into a proper desktop theming framework that other users can adopt and extend.

## Direct System Installation via install.sh

You're absolutely right - why complicate things? Let's just modify `install.sh` to do exactly what the Arch package would do, using system directories directly.

### Modified install.sh Approach

**Goal**: Implement the actual system installation structure directly from the dotfiles installer.

#### System Installation Steps

```bash
#!/usr/bin/env bash

echo "[farv] Installing farv system-wide..."

# Install binary to system location (requires sudo)
echo "[farv] Installing binary to /usr/bin/"
sudo cp bin/farv /usr/bin/farv
sudo chmod +x /usr/bin/farv

# Create system directories
echo "[farv] Creating system directories"
sudo mkdir -p /usr/share/farv/{themes/{light,dark},handlers}

# Install system themes
echo "[farv] Installing system themes"
if [ -d "themes/light" ]; then
    sudo cp -r themes/light/* /usr/share/farv/themes/light/ 2>/dev/null || true
fi
if [ -d "themes/dark" ]; then
    sudo cp -r themes/dark/* /usr/share/farv/themes/dark/ 2>/dev/null || true
fi

# Install system handlers
echo "[farv] Installing system handlers"  
sudo cp bin/handlers/*.sh /usr/share/farv/handlers/
sudo chmod +x /usr/share/farv/handlers/*.sh

# Install completions to system locations
echo "[farv] Installing completion scripts"
sudo mkdir -p /usr/share/{bash-completion/completions,zsh/site-functions,fish/vendor_completions.d}
farv --generate-completion bash | sudo tee /usr/share/bash-completion/completions/farv > /dev/null
farv --generate-completion zsh | sudo tee /usr/share/zsh/site-functions/_farv > /dev/null  
farv --generate-completion fish | sudo tee /usr/share/fish/vendor_completions.d/farv.fish > /dev/null

# Create user configuration directory (no sudo needed)
echo "[farv] Setting up user configuration"
FARV_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/farv"
mkdir -p "$FARV_CONFIG_HOME"/{themes/{light,dark},handlers}

# Create user config file
if [ ! -f "$FARV_CONFIG_HOME/config" ]; then
    cat > "$FARV_CONFIG_HOME/config" << 'EOF'
# Farv user configuration
# Uncomment and modify as needed

# HANDLER_TIMEOUT=10
# VERBOSE=true  
# DEFAULT_CATEGORY="dark"
EOF
fi

echo "[farv] Installation complete!"
echo ""
echo "System installation:"
echo "  Binary: /usr/bin/farv"
echo "  Themes: /usr/share/farv/themes/"
echo "  Handlers: /usr/share/farv/handlers/"
echo "  Completions: /usr/share/{bash-completion,zsh,fish}/"
echo ""
echo "User configuration:"
echo "  Config: ~/.config/farv/"
echo "  Current theme: ~/.config/farv/current (after first theme switch)"
echo ""
echo "Usage:"
echo "  farv list           # List available themes"
echo "  farv <theme>        # Switch to theme"
echo "  farv                # Interactive selection"
echo ""
echo "Tab completion should work immediately in new shell sessions."
```

### Key Changes from Current install.sh

1. **Uses `sudo`**: Installs to actual system directories (`/usr/bin`, `/usr/share`)
2. **System completions**: Installs to standard system completion directories
3. **No PATH changes needed**: `/usr/bin` is already in PATH
4. **True system installation**: Identical to what a package manager would do
5. **User config setup**: Creates `~/.config/farv/` structure for user customizations

### Benefits of This Approach

1. **Identical to package**: Exact same result as `pacman -S farv`
2. **No migration needed**: When AUR package arrives, it's the same installation
3. **Standard locations**: Uses proper system directories
4. **Immediate completion**: Works with system completion loaders
5. **Clean uninstall**: Can remove with standard locations

### Uninstallation

```bash
# Simple uninstall script (uninstall.sh)
sudo rm /usr/bin/farv
sudo rm -rf /usr/share/farv
sudo rm /usr/share/bash-completion/completions/farv
sudo rm /usr/share/zsh/site-functions/_farv  
sudo rm /usr/share/fish/vendor_completions.d/farv.fish
# User config in ~/.config/farv/ is left intact
```

### User Experience

After installation:
- `farv` command available immediately (no shell restart needed)
- Tab completion works in new shells automatically  
- User can customize in `~/.config/farv/` exactly as planned
- System themes and handlers work out of the box
- When AUR package becomes available, user just uninstalls manually and installs via pacman

### Requirements

- **sudo access**: Required for system directory installation
- **Same as package**: This is exactly what a distribution package does

This approach eliminates all complexity - we're just doing a manual system installation that's identical to what any package manager would do.