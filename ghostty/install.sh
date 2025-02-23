echo "[ghostty] Remove symlink"
rm ~/.config/ghostty/config

echo "[ghostty] Make sure the directory exists"
mkdir -p ~/.config/ghostty

echo "[ghostty] Create symlink"
ln -s "$(pwd)/config" ~/.config/ghostty/config

echo "[ghostty] Done."
