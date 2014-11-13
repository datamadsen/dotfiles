# Remove symlink
echo "[tmux] Remove symlink"
rm ~/.tmux.conf

# Create symlink
echo "[tmux] Create symlink"
ln -s $(pwd)/tmux.conf ~/.tmux.conf

echo "[tmux] Done - remember to source ~/.tmux.conf"
