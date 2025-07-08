# Theme System TODO

## Completed ✅

- [x] Design omarchy-inspired theme system architecture
- [x] Create theme directory structure with `current` symlink
- [x] Implement `theme-switch` zsh function
- [x] **Alacritty integration** - Symlink-based with live reload
- [x] **Bat integration** - Dynamic config generation  
- [x] **Neovim integration** - Symlink-based theme.lua plugin
- [x] **Btop integration** - Symlink-based current.theme
- [x] **fzf-tab integration** - Function-based sourcing with immediate effect
- [x] **tmux integration** - TPM-based theme plugins with automatic reload
- [x] **fzf integration** - Interactive theme picker (completed)

## Remaining Work 🚧

### Application Integration

- [ ] **Dircolors integration** - Theme-aware LS_COLORS
- [ ] **Git integration** - Theme-aware git diff colors (optional)

### Theme Expansion

- [ ] **Add more themes** - gruvbox, catppuccin, nord, etc.
- [ ] **Custom theme creation** - Template/generator script
- [ ] **Theme validation** - Script to check all required files exist

### Installation & Setup

- [ ] **Update main install.sh** - Include new theme system setup
- [ ] **Consolidate install scripts** - Single command to set up all theme integrations
- [ ] **Migration script** - Migrate from old theme system to new one

### Documentation & Polish

- [ ] **Update main README** - Document new theme system
- [ ] **Add screenshots** - Show each theme in action
- [ ] **Performance optimization** - Optimize theme switching speed
- [ ] **Error handling** - Better error messages and validation
- [ ] **Switcher name** - Find a better name for the theme switching function.

### Nice-to-Have Features

- [ ] **Auto theme switching** - Based on time of day or system appearance
- [ ] **Theme preview** - Preview themes without switching
- [ ] **Backup/restore** - Save and restore theme preferences
- [ ] **Remote themes** - Download themes from repositories
- [ ] **Fix tab completion** - Debug why tab completion isn't working for theme-switch function

## Current Theme Files Status

### rose-pine-dawn (Light Theme)

- [x] alacritty.toml
- [x] bat.conf  
- [x] btop.theme
- [x] fzf-tab.zsh
- [x] neovim.lua
- [x] tmux.conf

### tokyonight-night (Dark Theme)  

- [x] alacritty.toml
- [x] bat.conf
- [x] btop.theme  
- [x] fzf-tab.zsh
- [x] neovim.lua
- [x] tmux.conf

## Integration Methods Used

1. **Symlink Method** (Alacritty, Neovim, Btop)
   - Main config imports from `themes/current/`
   - Clean, no file duplication
   - Immediate or app-restart updates

2. **Config Generation** (Bat)
   - Theme switcher builds final config
   - Combines theme + base configuration
   - Handles apps without import support

3. **Function Sourcing** (fzf-tab)
   - zsh function sources theme config
   - Immediate shell environment update
   - Works for shell-specific configurations

## Next Session Priorities

1. Tmux integration (highest priority)
2. Fix tab completion for theme-switch function
3. Update main install.sh script  
4. Add gruvbox theme for variety
5. Test complete system end-to-end

