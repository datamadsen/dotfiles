# Remove symlink
echo "[utilities] Remove symlinks"
rm ~/.utilities

# Create symlink
echo "[utilities] Create symlinks"
ln -s $(pwd) ~/.utilities

echo "[utilities] Done"
