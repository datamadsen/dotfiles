#!/usr/bin/env bash
#
#  arch_autologin.sh
#
#  Create a systemd override that auto‑logs in <user> on tty1.
#
#  Usage:
#      sudo arch_autologin.sh [username]
#
#  If no username is given, the script will prompt for one.

set -euo pipefail

TARGET_TTY="tty1" # change if you want a different console
SERVICE_DIR="/etc/systemd/system/getty@${TARGET_TTY}.service.d"
CONF_FILE="${SERVICE_DIR}/autologin.conf"

# 1. Get the username -----------------------------------------------
if [[ $# -eq 0 ]]; then
  read -rp "Enter the username to auto‑login: " USERNAME
else
  USERNAME="$1"
fi

# Basic sanity check – does the user exist?
if ! id "$USERNAME" &>/dev/null; then
  echo >&2 "Error: User '$USERNAME' does not exist."
  exit 1
fi

# 2. Create directory and write override -----------------------------
sudo mkdir -p "$SERVICE_DIR"

cat <<EOF | sudo tee "$CONF_FILE" >/dev/null
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin ${USERNAME} --noclear %I \$TERM
EOF

echo "Created $CONF_FILE for user '$USERNAME'."

# 3. Reload systemd --------------------------------------------------
sudo systemctl daemon-reload
echo "Reloaded systemd."

# 4. Optionally restart the service (or reboot) ----------------------
while true; do
  read -rp "Restart getty@${TARGET_TTY}.service now? [y/N] " yn
  case $yn in
  [Yy]*)
    sudo systemctl restart getty@"${TARGET_TTY}".service
    break
    ;;
  *)
    echo "Skipping restart. Reboot when ready."
    break
    ;;
  esac
done

echo "Done. You can reboot to test the auto‑login."
