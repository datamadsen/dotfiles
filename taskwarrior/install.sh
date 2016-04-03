# Remove symlink
echo "[taskwarrior] Remove symlinks"
rm ~/.taskrc

# Create symlink
echo "[taskwarrior] Create symlinks"
ln -s $(pwd)/taskrc ~/.taskrc

echo "[taskwarrior] Done"
