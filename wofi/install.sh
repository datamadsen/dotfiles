echo "[wofi] Remove symlink"
rm -rf ~/.config/wofi

echo "[wofi] Create symlink"
ln -s $(pwd)/ ~/.config/wofi

echo "[wofi] Done."
