#!/usr/bin/env bash
#
#  setup_hyprland_user_service.sh
#
#  Creates ~/.config/systemd/user/hyprland.service
#  Enables it for the current user.
#
#  Usage:
#      ./setup_hyprland_user_service.sh   # run as your normal (non‑root) account

set -euo pipefail

SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="${SERVICE_DIR}/hyprland.service"

echo "=== Hyprland systemd‑user service installer ==="

# 1. Make sure the directory exists
mkdir -p "$SERVICE_DIR"

cat <<EOF >"$SERVICE_FILE"
[Unit]
Description=Hyprland Wayland compositor
After=graphical-session-pre.target
Partof=graphical-session.target

[Service]
Type=Simple
ExecStart=/usr/bin/hyprland
Restart=on-failure
RestartSec=1
TimeoutStopSec=10

[Install]
WantedBy=default.target
EOF

echo "Created $SERVICE_FILE"

# 2. Enable the service for this user
systemctl --user daemon-reload
if systemctl --user is-enabled hyprland.service &>/dev/null; then
  echo "hyprland.service is already enabled."
else
  systemctl --user enable hyprland.service
  echo "Enabled hyprland.service"
fi
