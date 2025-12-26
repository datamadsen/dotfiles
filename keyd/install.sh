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

# Install libinput quirks for disable-while-typing compatibility
# keyd's virtual keyboard needs to be marked as "internal" so libinput
# associates it with the touchpad for disable-while-typing to work
echo "[keyd] Installing libinput quirks for trackpad disable-while-typing"
sudo mkdir -p /etc/libinput
sudo cp "$(pwd)/libinput-keyd.quirks" /etc/libinput/local-overrides.quirks

echo "[keyd] Done"
echo "[keyd] Note: A reboot may be required for trackpad disable-while-typing to work"