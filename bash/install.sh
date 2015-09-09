#!/bin/sh

# Remove symlink
echo "[bash] Remove symlinks"
rm ~/.bashrc
rm ~/.aliases
rm ~/.ssh-start.sh

# Create symlink
echo "[bash] Create symlinks"
ln -s $(pwd)/bashrc ~/.bashrc
ln -s $(pwd)/aliases ~/.aliases
ln -s $(pwd)/ssh-start.sh ~/.ssh-start.sh

echo "[bash] Done - remember to source ~/.bashrc"
