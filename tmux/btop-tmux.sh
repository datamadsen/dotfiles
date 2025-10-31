#!/bin/bash
# Wrapper script to launch tmux with btop.conf on a separate socket
# This ensures the config is always applied and doesn't interfere with your main tmux server

SOCKET_NAME="btop"
SESSION_NAME="btop"
CONFIG_FILE="$HOME/.config/tmux/btop.conf"

# Check if the session already exists
if tmux -L "$SOCKET_NAME" has-session -t "$SESSION_NAME" 2>/dev/null; then
    # Session exists, attach to it
    tmux -L "$SOCKET_NAME" attach-session -t "$SESSION_NAME"
else
    # Session doesn't exist, create it and start btop
    tmux -L "$SOCKET_NAME" -f "$CONFIG_FILE" new-session -s "$SESSION_NAME" btop
fi
