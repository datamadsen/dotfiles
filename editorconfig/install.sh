#!/bin/sh

# Remove symlink
echo "[editorconfig] Remove symlink"
rm ~/.editorconfig

# Create symlink
echo "[editorconfig] Create symlink"
ln -s $(pwd)/editorconfig ~/.editorconfig

echo "[editorconfig] Done"
