echo "[alacritty] Remove symlink"
rm ~/.config/alacritty

echo "[alacritty] Create symlink"
ln -s $(pwd)/ ~/.config/alacritty

echo "[alacritty] Done."
