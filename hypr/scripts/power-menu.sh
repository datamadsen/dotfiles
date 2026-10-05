#!/usr/bin/env bash

# Wofi power menu for Hyprland

# Caffeine entry reflects the current state (shared with the waybar icon)
if ~/.config/waybar/caffeine.sh active; then
    caffeine="󰛊 Caffeine off"
else
    caffeine="󰅶 Caffeine on"
fi

# Power menu options
options="$caffeine\n⏻ Shutdown\n⏼ Reboot\n⏾ Suspend\n󰌾 Lock\n󰍃 Logout"

# Show wofi menu and capture selection
chosen=$(echo -e "$options" | wofi --dmenu --prompt "Power Menu" --style="$HOME/.config/farv/current/wofi-search.css")

# Execute based on selection
case $chosen in
    "󰅶 Caffeine on"|"󰛊 Caffeine off")
        ~/.config/waybar/caffeine.sh toggle
        ;;
    "⏻ Shutdown")
        systemctl poweroff
        ;;
    "⏼ Reboot")
        systemctl reboot
        ;;
    "⏾ Suspend")
        systemctl suspend
        ;;
    "󰌾 Lock")
        hyprlock
        ;;
    "󰍃 Logout")
        hyprctl dispatch 'hl.dsp.exit()'
        ;;
esac
