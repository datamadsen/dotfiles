# Remove symlink
echo "[tmux] Remove symlinks"
rm ~/.tmux.conf

# Create symlink
echo "[tmux] Create symlinks"
ln -s $(pwd)/tmux.conf ~/.tmux.conf

echo "[tmux] clone tmux plugin manager"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "[tmux] Done - remember to source ~/.tmux.conf"
