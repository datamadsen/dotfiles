# Remove symlink
echo "[tmux] Remove symlinks"
rm ~/.tmux.conf
rm ~/.ide-rails.sh

# Create symlink
echo "[tmux] Create symlinks"
ln -s $(pwd)/tmux.conf ~/.tmux.conf
ln -s $(pwd)/ide-rails.sh ~/.ide-rails.sh

echo "[tmux] clone tmux plugin manager"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "[tmux] Done - remember to source ~/.tmux.conf"
