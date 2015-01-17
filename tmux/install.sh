# Remove symlink
echo "[tmux] Remove symlink"
rm ~/.tmux.conf

# Create symlink
echo "[tmux] Create symlink"
ln -s $(pwd)/tmux.conf ~/.tmux.conf
ln -s $(pwd)/dev-env-ruby-on-rails.sh ~/.dev-env-ruby-on-rails.sh

echo "[tmux] Done - remember to source ~/.tmux.conf"
