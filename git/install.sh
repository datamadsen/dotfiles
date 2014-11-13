#!/bin/sh

# Remove symlink
echo "[git] Remove symlink"
rm ~/.gitconfig
rm ~/.gitignore

# Create symlink
echo "[git] Create symlink"
ln -s $(pwd)/gitconfig ~/.gitconfig
ln -s $(pwd)/gitignore ~/.gitignore

echo "[git] Done"
