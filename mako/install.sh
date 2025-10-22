echo "[mako] Remove symlink"
rm ~/.config/mako/config

echo "[mako] Make sure the directory exists"
mkdir -p ~/.config/mako

echo "[mako] Create symlink"
ln -s "$(pwd)/config" ~/.config/mako/config

echo "[mako] Done."
