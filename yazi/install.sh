echo "[yazi] Remove existing config files"
rm -f ~/.config/yazi/yazi.toml
rm -f ~/.config/yazi/package.toml

echo "[yazi] Make sure the directory exists"
mkdir -p ~/.config/yazi

echo "[yazi] Create symlinks"
ln -s "$(pwd)/yazi.toml" ~/.config/yazi/yazi.toml
ln -s "$(pwd)/package.toml" ~/.config/yazi/package.toml

echo "[yazi] Done."
