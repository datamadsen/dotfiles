#!/usr/bin/env bash

# Wofi power menu for Hyprland

# Power menu options
options="⏻ Shutdown\n⏼ Reboot\n⏾ Suspend\n󰌾 Lock\n󰍃 Logout"

# Show wofi menu and capture selection
chosen=$(echo -e "$options" | wofi --dmenu --prompt "Power Menu" --style="$HOME/.config/farv/current/wofi-search.css")

# Execute based on selection
case $chosen in
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
        hyprctl dispatch exit
        ;;
esac
