echo "[waybar] Remove symlink"
rm -rf ~/.config/waybar

echo "[waybar] Create symlink"
ln -s $(pwd)/ ~/.config/waybar

echo "[waybar] Link farv theme hook"
mkdir -p ~/.config/farv/themes
ln -sfn $(pwd)/farv-hook.sh ~/.config/farv/themes/waybar.sh

echo "[waybar] Done."
