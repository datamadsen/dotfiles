echo "[swaync] Remove symlink"
rm -rf ~/.config/swaync

echo "[swaync] Create symlink"
ln -s $(pwd)/ ~/.config/swaync

echo "[swaync] Done."
