echo "[hypr] Remove symlink"
rm -rf ~/.config/hypr

echo "[hypr] Create symlink"
ln -s $(pwd)/ ~/.config/hypr

echo "[hypr] Done."
