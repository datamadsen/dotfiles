#!/bin/bash

echo "[smiley-menu] Remove existing symlinks"
rm -f ~/.local/bin/smiley-menu

echo "[smiley-menu] Create directories"
mkdir -p ~/.local/bin

echo "[smiley-menu] Create symlinks"
ln -s $(pwd)/smiley-menu.sh ~/.local/bin/smiley-menu

echo "[smiley-menu] Make script executable"
chmod +x smiley-menu.sh

echo "[smiley-menu] Done - smiley-menu script installed to ~/.local/bin/smiley-menu"