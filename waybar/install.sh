echo "[waybar] Remove symlink"
rm -rf ~/.config/waybar

echo "[waybar] Create symlink"
ln -s $(pwd)/ ~/.config/waybar

echo "[waybar] Done."
