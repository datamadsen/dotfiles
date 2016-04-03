# Remove symlink
echo "[thyme] Remove symlinks"
rm ~/.thymerc

# Create symlink
echo "[thyme] Create symlinks"
ln -s $(pwd)/thymerc ~/.thymerc

echo "[thyme] Done"
