#!/bin/sh

# Check if keyd is installed
echo "[keyd] Checking if keyd is installed"
if ! command -v keyd >/dev/null 2>&1; then
    echo "[keyd] Error: keyd is not installed. Please install keyd first."
    echo "[keyd] On Arch Linux: sudo pacman -S keyd"
    echo "[keyd] On Ubuntu/Debian: sudo apt install keyd"
    exit 1
fi

# Make sure the keyd directory exists
echo "[keyd] Create keyd directory"
sudo mkdir -p /etc/keyd

# Copy configuration file
echo "[keyd] Copy configuration to /etc/keyd/"
sudo cp "$(pwd)/default.conf" /etc/keyd/default.conf

# Reload keyd configuration
echo "[keyd] Reload keyd configuration"
sudo keyd reload

echo "[keyd] Done"