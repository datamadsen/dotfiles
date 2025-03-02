#!/bin/sh

# Remove symlink
echo "[fzf] Remove symlinks"
rm ~/.fzf.zsh
rm ~/.fzf/

# Create symlink
echo "[fzf] Create symlinks"
ln -s "$(pwd)/fzf" ~/.fzf
ln -s "$(pwd)/fzf.zsh" ~/.fzf.zsh

echo "[fzf] Done"
