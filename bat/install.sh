#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create bat config directory
mkdir -p ~/.config/bat

# Create symlink to bat config
ln -sf "$SCRIPT_DIR/config" ~/.config/bat/config

echo "Bat configuration installed successfully!"
echo "  ~/.config/bat/config -> $SCRIPT_DIR/config"