# Remove old symlinks and directory if it exists
echo "[tmux] Remove old symlinks and config directory"
rm -f ~/.tmux.conf
rm -rf ~/.config/tmux

# Create symlink for entire tmux directory
echo "[tmux] Create symlink to ~/.config/tmux"
ln -s $(pwd) ~/.config/tmux

echo "[tmux] clone tmux plugin manager"
mkdir -p ~/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "[tmux] Done - tmux will automatically load config from ~/.config/tmux/tmux.conf"
