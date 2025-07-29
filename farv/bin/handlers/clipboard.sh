#!/usr/bin/env bash
# Handler: Clipboard (wofi)
# Purpose: Update clipboard styling when theme changes

# Utility functions
log_action() { echo "  - $1"; }

# Check if application is available and configured
check_availability() {
    [ -f "$theme_path/wofi-clipboard.css" ]
}

# Apply theme configuration
apply_theme() {
    local theme_path="$1"
    local current_link="$HOME/.farv/current"
    # Update clipboard wofi styling
    cp "$theme_path/wofi-clipboard.css" "$current_link/"
}

# Main execution
theme_path="$1"
if check_availability; then
    apply_theme "$1"
    log_action "clipboard"
fi