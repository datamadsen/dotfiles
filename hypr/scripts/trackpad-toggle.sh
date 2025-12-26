#!/bin/bash

# Trackpad device name (found via: hyprctl devices)
TRACKPAD="uniw0001:00-093a:0255-touchpad"

# State file to track current state
STATE_FILE="/tmp/trackpad_state"
CURSOR_POS_FILE="/tmp/trackpad_cursor_pos"

# Get current state (default to enabled if file doesn't exist)
if [ -f "$STATE_FILE" ]; then
    current_state=$(cat "$STATE_FILE")
else
    current_state="true"
fi

# Handle explicit enable/disable arguments (used by workspace daemon)
case "$1" in
    enable)
        [ "$current_state" = "true" ] && exit 0
        new_state="true"
        if [ -f "$CURSOR_POS_FILE" ]; then
            saved_pos=$(cat "$CURSOR_POS_FILE" | tr -d ',' | awk '{print $1, $2}')
            hyprctl dispatch movecursor $saved_pos
        fi
        ;;
    disable)
        [ "$current_state" = "false" ] && exit 0
        new_state="false"
        hyprctl cursorpos > "$CURSOR_POS_FILE"
        hyprctl dispatch movecursor 10000 10000
        ;;
    *)
        # Toggle behavior (original)
        if [ "$current_state" = "true" ]; then
            new_state="false"
            notify-send -e -u normal "Trackpad" "Disabled" -t 2000
            hyprctl cursorpos > "$CURSOR_POS_FILE"
            hyprctl dispatch movecursor 10000 10000
        else
            new_state="true"
            notify-send -e -u normal "Trackpad" "Enabled" -t 2000
            if [ -f "$CURSOR_POS_FILE" ]; then
                saved_pos=$(cat "$CURSOR_POS_FILE" | tr -d ',' | awk '{print $1, $2}')
                hyprctl dispatch movecursor $saved_pos
            fi
        fi
        ;;
esac

# Apply the new state
hyprctl keyword "device[$TRACKPAD]:enabled" "$new_state"

# Save the new state
echo "$new_state" > "$STATE_FILE"

# Refresh waybar to update the icon
pkill -RTMIN+1 waybar
