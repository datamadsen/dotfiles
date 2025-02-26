echo "[lazygit] Remove symlink"
rm ~/.config/lazygit/config

echo "[lazygit] Make sure the directory exists"
mkdir -p ~/.config/lazygit

echo "[lazygit] Create symlink"
ln -s "$(pwd)/config" ~/.config/lazygit/config

echo "[lazygit] Done."
