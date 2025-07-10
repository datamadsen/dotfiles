# Omarchy-Inspired Theme System

This dotfiles repository uses an omarchy-inspired theme system that provides coordinated theming across multiple applications with a single command.

## Architecture

### Directory Structure

```
themes/
├── light/
│   └── rose-pine-dawn/      # Light theme
│       ├── alacritty.toml   # Terminal colors
│       ├── bat.conf         # Syntax highlighter theme
│       ├── btop.theme       # System monitor theme
│       ├── fzf-tab.zsh      # Tab completion colors
│       ├── neovim.lua       # Editor theme
│       └── tmux.conf        # Terminal multiplexer theme
├── dark/
│   └── tokyonight-night/    # Dark theme
│       ├── alacritty.toml
│       ├── bat.conf
│       ├── btop.theme
│       ├── fzf-tab.zsh
│       ├── neovim.lua
│       └── tmux.conf
└── current -> light/rose-pine-dawn/  # Symlink to active theme
```

### Core Principles

1. **Symlink-Based Switching**: The `current` symlink points to the active theme directory
2. **Per-App Theme Files**: Each application has its own theme configuration file within each theme directory
3. **Multiple Integration Strategies**: Different apps use different approaches based on their capabilities

## Integration Strategies

### 1. Symlink-Based (Alacritty, Neovim, Btop, Tmux)

- **How it works**: Main config imports/sources from `themes/current/app.extension`
- **Benefits**: Clean, no file copying, automatic updates
- **Example**: `~/.config/alacritty/alacritty.toml` imports `~/dotfiles/themes/current/alacritty.toml`

### 2. Dynamic Config Generation (Bat)

- **How it works**: Theme switcher generates new config by combining theme-specific and base configs
- **Benefits**: Handles apps that don't support includes/imports
- **Example**: Copies `themes/current/bat.conf` + base config to `~/.config/bat/config`

### 3. Function-Based Sourcing (fzf-tab)

- **How it works**: zsh function sources theme config directly into current shell
- **Benefits**: Immediate effect, no restart required
- **Example**: `theme-switch` function sources `themes/current/fzf-tab.zsh`

## Usage

### Theme Switching

```bash
# Interactive theme selection with fzf
farv

# Switch themes directly
farv rose-pine-dawn
farv tokyonight-night

# List available themes
farv list
```

### Adding New Themes

1. Create new directory: `themes/light/new-theme-name/` or `themes/dark/new-theme-name/`
2. Add theme files for each application:
   - `alacritty.toml` - Terminal colors
   - `bat.conf` - `--theme="ThemeName"` line
   - `btop.theme` - Full btop color configuration
   - `fzf-tab.zsh` - `zstyle ':fzf-tab:*' fzf-flags --color=light/dark`
   - `neovim.lua` - LazyVim plugin configuration
   - `tmux.conf` - TPM theme plugin configuration
3. Use `farv new-theme-name` to activate

## Application-Specific Notes

### Alacritty

- **Live reload**: Changes apply immediately via `touch` trigger
- **Config location**: `~/.config/alacritty/alacritty.toml`
- **Import line**: `import = ["~/.farv/current/alacritty.toml"]`

### Bat

- **Reload**: Immediate for new invocations
- **Config location**: `~/.config/bat/config`
- **Theme sources**: Built-in themes or custom themes

**Base config in bat/config:**
```bash
--style="numbers,changes,header"
--italic-text=always
--tabs=4
```

**Theme file example (automatically merged):**
```bash
--theme="Solarized (light)"
```

### Neovim

- **Reload**: Next nvim restart or `:source %` on plugin files
- **Config location**: `~/.config/nvim/lua/plugins/farv.lua`
- **Symlink target**: `~/.farv/current/neovim.lua`

### Btop

- **Reload**: Immediate via symlink detection
- **Config location**: `~/.config/btop/themes/current.theme`
- **Base config**: `~/dotfiles/btop/btop.conf` (sets `color_theme = "current"`)

**Integration code in btop.conf:**
```bash
color_theme = "current"
```

### fzf-tab

- **Reload**: Immediate via function sourcing
- **Integration**: Sourced in `~/dotfiles/zsh/zshrc`
- **Fallback**: Basic styling if theme file missing

**Integration code in zshrc:**

```bash
# Source fzf-tab theme from current theme
if [ -f ~/.farv/current/fzf-tab.zsh ]; then
    source ~/.farv/current/fzf-tab.zsh
else
    # Fallback if no theme-specific config exists
    zstyle ':fzf-tab:*' fzf-flags --style=full --height=90%
fi
```

### Tmux

- **Reload**: Immediate via `tmux source-file` command
- **Config location**: `~/dotfiles/tmux/tmux.conf`
- **Theme plugins**: Managed via TPM (rose-pine/tmux, fabioluciano/tmux-tokyo-night)
- **Integration**: Sources from `~/.farv/current/tmux.conf`

**Integration code in tmux.conf:**
```bash
# Theme plugins are loaded via themes/current/tmux.conf
source-file ~/.farv/current/tmux.conf
```

## Installation

Each application needs its install script run to set up the initial configuration and symlinks:

```bash
~/dotfiles/alacritty/install.sh
~/dotfiles/bat/install.sh
~/dotfiles/btop/install.sh
# Neovim uses existing LazyVim setup
# fzf-tab integrated via zshrc
```

## Inspiration

This system is inspired by [omarchy](https://github.com/basecamp/omarchy), which pioneered the symlink-based theme switching approach for Linux desktop environments. We've adapted their concepts for a development-focused dotfiles setup.

