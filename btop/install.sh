#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create btop config directory and themes directory
mkdir -p ~/.config/btop/themes

# Create symlink to btop config
ln -sf "$SCRIPT_DIR/btop.conf" ~/.config/btop/btop.conf

echo "Btop configuration installed successfully!"
echo "  ~/.config/btop/btop.conf -> $SCRIPT_DIR/btop.conf"
echo "  ~/.config/btop/themes/ ready for theme files"