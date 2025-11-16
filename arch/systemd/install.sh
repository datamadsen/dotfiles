#!/usr/bin/env bash
#
# Install systemd service files and configurations
#
# This script installs:
#   - autologin.conf: System-level getty override for autologin (requires sudo)
#   - hyprland.service: User-level Hyprland compositor service
#   - ssh-agent.service: User-level SSH agent service
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_SYSTEMD_DIR="$HOME/.config/systemd/user"

echo "=== Installing systemd configurations ==="

# ------------------------------------------------------------------------------
# User services (no sudo required)
# ------------------------------------------------------------------------------

echo ""
echo "Installing user systemd services..."
mkdir -p "$USER_SYSTEMD_DIR"

# Install hyprland.service
if [[ -f "$SCRIPT_DIR/hyprland.service" ]]; then
  ln -sf "$SCRIPT_DIR/hyprland.service" "$USER_SYSTEMD_DIR/hyprland.service"
  echo "  ✓ Linked hyprland.service"
fi

# Install ssh-agent.service
if [[ -f "$SCRIPT_DIR/ssh-agent.service" ]]; then
  ln -sf "$SCRIPT_DIR/ssh-agent.service" "$USER_SYSTEMD_DIR/ssh-agent.service"
  echo "  ✓ Linked ssh-agent.service"
fi

# Reload user systemd daemon
systemctl --user daemon-reload
echo "  ✓ Reloaded user systemd daemon"

# ------------------------------------------------------------------------------
# System service overrides (requires sudo)
# ------------------------------------------------------------------------------

echo ""
echo "Installing system systemd overrides (autologin)..."

if [[ -f "$SCRIPT_DIR/autologin.conf" ]]; then
  read -rp "Install autologin for which user? [default: $USER]: " AUTOLOGIN_USER
  AUTOLOGIN_USER="${AUTOLOGIN_USER:-$USER}"

  # Verify user exists
  if ! id "$AUTOLOGIN_USER" &>/dev/null; then
    echo "  ✗ User '$AUTOLOGIN_USER' does not exist. Skipping autologin setup."
  else
    TARGET_TTY="tty1"
    SERVICE_DIR="/etc/systemd/system/getty@${TARGET_TTY}.service.d"
    CONF_FILE="${SERVICE_DIR}/autologin.conf"

    # Create directory and install config with username substitution
    sudo mkdir -p "$SERVICE_DIR"
    sed "s/USERNAME/$AUTOLOGIN_USER/g" "$SCRIPT_DIR/autologin.conf" | sudo tee "$CONF_FILE" >/dev/null
    echo "  ✓ Installed autologin.conf for user '$AUTOLOGIN_USER'"

    # Reload system daemon
    sudo systemctl daemon-reload
    echo "  ✓ Reloaded system systemd daemon"

    # Ask about restart
    read -rp "Restart getty@${TARGET_TTY}.service now? [y/N]: " yn
    case $yn in
      [Yy]*)
        sudo systemctl restart "getty@${TARGET_TTY}.service"
        echo "  ✓ Restarted getty@${TARGET_TTY}.service"
        ;;
      *)
        echo "  ! Skipped restart. Reboot or restart the service manually."
        ;;
    esac
  fi
fi

# ------------------------------------------------------------------------------
# Optional: Enable services
# ------------------------------------------------------------------------------

echo ""
read -rp "Enable ssh-agent.service? [y/N]: " enable_ssh
case $enable_ssh in
  [Yy]*)
    systemctl --user enable ssh-agent.service
    echo "  ✓ Enabled ssh-agent.service"
    echo "  ! Don't forget to add to your shell config:"
    echo "    export SSH_AUTH_SOCK=\"\$XDG_RUNTIME_DIR/ssh-agent.socket\""
    ;;
esac

echo ""
read -rp "Enable hyprland.service? [y/N]: " enable_hyprland
case $enable_hyprland in
  [Yy]*)
    systemctl --user enable hyprland.service
    echo "  ✓ Enabled hyprland.service"
    ;;
esac

echo ""
echo "=== Installation complete ==="
echo ""
echo "User services installed to: $USER_SYSTEMD_DIR"
echo "System overrides installed to: /etc/systemd/system/"
echo ""
echo "To start services now:"
echo "  systemctl --user start ssh-agent.service"
echo "  systemctl --user start hyprland.service"
