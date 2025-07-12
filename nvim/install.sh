echo "[nvim] Remove symlink"
rm -rf ~/.config/nvim

echo "[nvim] Create symlink"
ln -s $(pwd)/ ~/.config/nvim

echo "[nvim] Done."
