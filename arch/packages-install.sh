#!/bin/bash
# Install packages from the packages file, plus packages.<hostname> if present
# (hardware-specific extras such as GPU drivers and compute backends).

cd "$(dirname "$0")"

if [ ! -f packages ]; then
    echo "Error: packages file not found"
    exit 1
fi

host_packages="packages.$(cat /etc/hostname)"

echo "Installing packages from packages file..."
if [ -f "$host_packages" ]; then
    echo "...and host-specific packages from $host_packages"
    cat packages "$host_packages" | yay -S --needed -
else
    yay -S --needed - < packages
fi
echo "Package installation complete"
