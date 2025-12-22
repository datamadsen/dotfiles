#!/bin/bash

echo "[nunchux] Remove symlink"
rm -f ~/.config/nunchux/config

echo "[nunchux] Make sure the directory exists"
mkdir -p ~/.config/nunchux

echo "[nunchux] Create symlink"
ln -s "$(pwd)/config" ~/.config/nunchux/config

echo "[nunchux] Done."
