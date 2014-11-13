# Remove symlink
echo "[irssi] Remove symlink"
rm ~/.irssi

# Create symlink
echo "[irssi] Create symlink"
ln -s $(pwd)/ ~/.irssi

echo "[irssi] Done"
