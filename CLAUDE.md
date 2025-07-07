# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive personal dotfiles repository containing configuration files and scripts for various development tools and applications. The repository uses a modular approach where each tool has its own directory with configuration files and installation scripts.

## Installation & Management

### Main Installation
- **Primary command**: `./install.sh` - Runs all individual install scripts
- **Individual installs**: Each directory has its own `install.sh` script that creates symlinks to configuration files
- **Theme switching**: `./utilities/theme-switch.sh [light|dark|auto|status]` - Unified theme switching across all tools

### Software Management
- **Homebrew formulas**: `./software/install.py` - Installs packages from `brew-formulas` list
- **Package snapshot**: `./software/snapshot.sh` - Creates snapshots of installed packages

## Key Components

### Neovim Configuration
- **Location**: `./nvim/`
- **Framework**: LazyVim with custom plugin configurations
- **Key files**:
  - `init.lua` - Bootstrap entry point
  - `lua/config/lazy.lua` - LazyVim setup with extras (omnisharp, sql, markdown)
  - `lua/plugins/` - Custom plugin configurations
- **Themes**: Supports both rose-pine and tokyonight with automatic switching
- **Language support**: Configured for C#, SQL, Markdown with LSP integration

### Zsh Configuration
- **Location**: `./zsh/`
- **Key features**:
  - Pure prompt theme
  - Vi mode with cursor changes
  - fzf-tab for enhanced tab completion
  - Syntax highlighting
  - Custom aliases and utilities
- **Dependencies**: Requires fzf-tab plugin (included as submodule)

### Tmux Configuration
- **Location**: `./tmux/`
- **Key features**:
  - Vim-aware pane navigation
  - Plugin management via TPM
  - Session resurrection and continuum
  - Theme integration with rose-pine/tokyonight
- **Plugins**: Managed via tmux-plugins/tpm

### Terminal & Shell Integration
- **Ghostty**: Terminal emulator configuration with theme switching
- **Alacritty**: Alternative terminal with theme support
- **Git**: Enhanced configuration with custom aliases and settings

## Architecture & Design Patterns

### Modular Installation System
Each tool directory follows this pattern:
- `install.sh` - Creates symlinks from dotfiles to expected locations
- Configuration files specific to that tool
- Tool-specific themes and customizations

### Theme System
Coordinated theming across all tools:
- **Light theme**: rose-pine-dawn
- **Dark theme**: tokyonight-night
- **Auto detection**: Based on system preferences (macOS/GNOME)
- **Components**: Ghostty, Neovim, tmux, fzf-tab, and zsh all participate

### Configuration Philosophy
- **Symlink-based**: Configuration files remain in repo, symlinked to expected locations
- **Version controlled**: All changes tracked in git
- **Modular**: Each tool can be installed/configured independently
- **Cross-platform**: Works on macOS and Linux with appropriate detection

## Common Development Workflows

### Initial Setup
1. Clone repository
2. Run `./install.sh` to install all configurations
3. Install software packages with `./software/install.py`
4. Configure themes with `./utilities/theme-switch.sh auto`
5. Set up environment variables (see Environment Variables section below)

### Theme Management
- Switch themes: `./utilities/theme-switch.sh [light|dark|auto]`
- Check current theme: `./utilities/theme-switch.sh status`
- Auto-detect system theme: `./utilities/theme-switch.sh auto`

### Neovim Plugin Management
- LazyVim handles plugin installation and updates
- Custom plugins configured in `lua/plugins/`
- LSP servers managed via Mason

### Tmux Session Management
- Plugin installation: `<prefix>I` (after tmux setup)
- Session restore: Automatic via continuum plugin
- Pane navigation: Vim-aware with Ctrl+hjkl

### Environment Variables
Required environment variables for full functionality:
- `CODECOMPANION_ANTHROPIC_API_KEY`: Anthropic API key for codecompanion.nvim

API keys are managed through the `api_keys` file in the repository root:
- This file is automatically sourced by zsh on startup
- The file is gitignored to prevent accidental commits of sensitive information
- Add new API keys or secrets to this file following the same pattern

## Important Notes

### Security Considerations
- **API Keys**: Stored in gitignored `api_keys` file, automatically sourced by zsh
- **Sensitive Data**: The `api_keys` file is excluded from version control to prevent accidental commits

### Dependencies
- **System packages**: zsh, tmux, neovim, fzf, bat, eza
- **Plugin managers**: LazyVim (Neovim), TPM (tmux)
- **Package managers**: Homebrew (macOS), apt/yum (Linux)

### Platform Differences
- **macOS**: Uses Homebrew, pbcopy for clipboard
- **Linux**: Uses system package managers, xclip/xsel for clipboard
- **Path handling**: Scripts detect platform and adjust paths accordingly