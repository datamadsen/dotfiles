# Remove symlink
echo "[vim] Remove symlink"
rm ~/.vimrc

# Create symlink
echo "[vim] Create symlink"
ln -s $(pwd)/vimrc ~/.vimrc

echo "[vim] Done"
