#!/bin/sh

# Remove symlink
echo "[bash] Remove symlinks"
rm ~/.bash_profile
rm ~/.aliases
rm ~/.ssh-start.sh

# Create symlink
echo "[bash] Create symlinks"
ln -s $(pwd)/bash_profile ~/.bash_profile
ln -s $(pwd)/aliases ~/.aliases
ln -s $(pwd)/ssh-start.sh ~/.ssh-start.sh

echo "[bash] Done - remember to source ~/.bash_profile"
