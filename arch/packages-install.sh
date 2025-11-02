#!/bin/bash
# Install packages from the packages file

cd "$(dirname "$0")"

if [ ! -f packages ]; then
    echo "Error: packages file not found"
    exit 1
fi

echo "Installing packages from packages file..."
yay -S --needed - < packages
echo "Package installation complete"
