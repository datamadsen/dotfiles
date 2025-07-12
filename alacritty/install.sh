echo "[alacritty] Remove symlink"
rm -rf ~/.config/alacritty

echo "[alacritty] Create symlink"
ln -s $(pwd)/ ~/.config/alacritty

echo "[alacritty] Done."
