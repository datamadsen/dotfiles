echo "[aerospace] Remove symlink"
rm ~/.aerospace.toml

echo "[aerospace] Create symlink"
ln -s "$(pwd)/aerospace.toml" ~/.aerospace.toml

echo "[aerospace] Done."
