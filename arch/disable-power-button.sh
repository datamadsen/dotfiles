#!/bin/bash

# Script to disable default power button behavior
# This allows window managers like Hyprland to intercept the power button

set -e

echo "Configuring systemd-logind to ignore power button..."

# Create the drop-in directory if it doesn't exist
sudo mkdir -p /etc/systemd/logind.conf.d

# Create the configuration file
echo "[Login]
HandlePowerKey=ignore" | sudo tee /etc/systemd/logind.conf.d/power-button.conf > /dev/null

echo "Configuration file created at /etc/systemd/logind.conf.d/power-button.conf"

# Restart systemd-logind to apply changes
echo "Restarting systemd-logind..."
sudo systemctl restart systemd-logind

echo "Done! Power button now ignored by systemd."
echo ""
echo "Add this to your Hyprland config to handle the power button:"
echo "  bindl = , XF86PowerOff, exec, <your-menu-command>"
