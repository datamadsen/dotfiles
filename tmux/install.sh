# Remove symlink
echo "[tmux] Remove symlinks"
rm ~/.tmux.conf

# Create symlink
echo "[tmux] Create symlinks"
ln -s "$(pwd)/tmux.conf" ~/.tmux.conf
mkdir -p ~/.config/tmux
ln -s "$(pwd)/btop-tmux.sh" ~/.config/tmux/btop-tmux.sh
ln -s "$(pwd)/btop.conf" ~/.config/tmux/btop.conf
ln -s "$(pwd)/pane-border-format.sh" ~/.config/tmux/pane-border-format.sh
ln -s "$(pwd)/status-left-padding.sh" ~/.config/tmux/status-left-padding.sh

echo "[tmux] clone tmux plugin manager"
rm -rf ~/.tmux/plugins/
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "[tmux] Done - remember to source ~/.tmux.conf and install plugins with c-b I"
