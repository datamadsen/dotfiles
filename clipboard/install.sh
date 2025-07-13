#!/bin/bash

echo "[clipboard] Remove existing symlinks"
rm -f ~/.config/cliphist/config
rm -f ~/.local/bin/clipboard-manager

echo "[clipboard] Create directories"
mkdir -p ~/.config/cliphist
mkdir -p ~/.local/bin
mkdir -p ~/.cache/cliphist/thumbs

echo "[clipboard] Create symlinks"
ln -s $(pwd)/config ~/.config/cliphist/config
ln -s $(pwd)/clipboard-manager ~/.local/bin/clipboard-manager

echo "[clipboard] Make clipboard-manager executable"
chmod +x ~/.local/bin/clipboard-manager

echo "[clipboard] Done - cliphist config and script installed"
echo "Remember to:"
echo "  1. Install dependencies: sudo pacman -S cliphist wl-clipboard imagemagick"
echo "  2. Update hyprland.conf with clipboard bindings"
echo "  3. Add clipboard watcher to hyprland autostart"