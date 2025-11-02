#!/bin/bash

STATE_FILE="/tmp/trackpad_state"

# Get current state (default to enabled if file doesn't exist)
if [ -f "$STATE_FILE" ]; then
    current_state=$(cat "$STATE_FILE")
else
    current_state="true"
fi

# Output JSON for waybar
if [ "$current_state" = "false" ]; then
    echo '{"text": "󰟸", "tooltip": "Trackpad disabled", "class": "disabled"}'
else
    # Don't show anything when enabled (or use empty text)
    echo '{"text": "", "tooltip": "Trackpad enabled", "class": "enabled"}'
fi
