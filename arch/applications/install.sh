#!/usr/bin/env bash

# Install script for custom desktop applications
# Creates symlinks from this directory to ~/.local/share/applications/

set -e

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPLICATIONS_DIR="$HOME/.local/share/applications"

echo "Installing custom desktop applications..."

# Ensure the .local/share/applications directory exists
mkdir -p "$APPLICATIONS_DIR"

# Copy all .desktop files to the applications directory
for desktop_file in "$SCRIPT_DIR"/*.desktop; do
    if [ -f "$desktop_file" ]; then
        filename=$(basename "$desktop_file")
        cp "$desktop_file" "$APPLICATIONS_DIR/$filename"
        chmod +x "$APPLICATIONS_DIR/$filename"
        echo "  Copied: $filename"
    fi
done

# Copy mimeinfo.cache if it exists
if [ -f "$SCRIPT_DIR/mimeinfo.cache" ]; then
    cp "$SCRIPT_DIR/mimeinfo.cache" "$APPLICATIONS_DIR/mimeinfo.cache"
    echo "  Copied: mimeinfo.cache"
fi

# Copy icons directory if it exists
if [ -d "$SCRIPT_DIR/icons" ]; then
    ICONS_DIR="$HOME/.local/share/icons"
    mkdir -p "$ICONS_DIR"
    cp -r "$SCRIPT_DIR/icons/"* "$ICONS_DIR/"
    echo "  Copied: icons directory"
fi

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$APPLICATIONS_DIR"
    echo "  Updated desktop database"
fi

echo "Custom desktop applications installed successfully!"
