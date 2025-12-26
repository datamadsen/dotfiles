#!/bin/bash

# Daemon that listens to Hyprland workspace events and toggles trackpad
# Disables trackpad on workspace 1, enables on all others

SCRIPT_DIR="$(dirname "$0")"
TOGGLE_SCRIPT="$SCRIPT_DIR/trackpad-toggle.sh"

handle_workspace() {
    local workspace="$1"
    if [ "$workspace" = "1" ]; then
        "$TOGGLE_SCRIPT" disable
    else
        "$TOGGLE_SCRIPT" enable
    fi
}

# Check initial workspace on startup
current_ws=$(hyprctl activeworkspace -j | jq -r '.id')
handle_workspace "$current_ws"

# Listen to Hyprland socket for workspace events
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    case "$line" in
        workspace\>\>*)
            workspace="${line#workspace>>}"
            handle_workspace "$workspace"
            ;;
    esac
done
