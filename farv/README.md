# Omarchy-Inspired Theme System

This dotfiles repository uses an omarchy-inspired theme system that provides coordinated theming across multiple applications with a single command.

## Architecture

### Directory Structure
```
themes/
├── rose-pine-dawn/          # Light theme
│   ├── alacritty.toml      # Terminal colors
│   ├── bat.conf            # Syntax highlighter theme
│   ├── btop.theme          # System monitor theme
│   ├── fzf-tab.zsh         # Tab completion colors
│   ├── neovim.lua          # Editor theme
│   └── tmux.conf           # Terminal multiplexer theme
├── tokyonight-night/        # Dark theme
│   ├── alacritty.toml
│   ├── bat.conf
│   ├── btop.theme
│   ├── fzf-tab.zsh
│   ├── neovim.lua
│   └── tmux.conf
└── current -> rose-pine-dawn/  # Symlink to active theme
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
theme-switch

# Switch themes directly
theme-switch rose-pine-dawn
theme-switch tokyonight-night

# List available themes
theme-switch list
```

### Adding New Themes
1. Create new directory: `themes/new-theme-name/`
2. Add theme files for each application:
   - `alacritty.toml` - Terminal colors
   - `bat.conf` - `--theme="ThemeName"` line
   - `btop.theme` - Full btop color configuration
   - `fzf-tab.zsh` - `zstyle ':fzf-tab:*' fzf-flags --color=light/dark`
   - `neovim.lua` - LazyVim plugin configuration
   - `tmux.conf` - TPM theme plugin configuration
3. Use `theme-switch new-theme-name` to activate

## Application-Specific Notes

### Alacritty
- **Live reload**: Changes apply immediately via `touch` trigger
- **Config location**: `~/.config/alacritty/alacritty.toml`
- **Import line**: `import = ["~/dotfiles/themes/current/alacritty.toml"]`

### Bat
- **Reload**: Immediate for new invocations
- **Config location**: `~/.config/bat/config`
- **Theme sources**: Built-in themes or custom themes

### Neovim
- **Reload**: Next nvim restart or `:source %` on plugin files
- **Config location**: `~/dotfiles/nvim/lua/plugins/theme.lua`
- **Symlink target**: `~/dotfiles/themes/current/neovim.lua`

### Btop
- **Reload**: Immediate via symlink detection
- **Config location**: `~/.config/btop/themes/current.theme`
- **Base config**: `~/dotfiles/btop/btop.conf` (sets `color_theme = "current"`)

### fzf-tab
- **Reload**: Immediate via function sourcing
- **Integration**: Sourced in `~/dotfiles/zsh/zshrc`
- **Fallback**: Basic styling if theme file missing

### Tmux
- **Reload**: Immediate via `tmux source-file` command
- **Config location**: `~/dotfiles/tmux/tmux.conf`
- **Theme plugins**: Managed via TPM (rose-pine/tmux, fabioluciano/tmux-tokyo-night)
- **Integration**: Sources from `~/dotfiles/themes/current/tmux.conf`

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