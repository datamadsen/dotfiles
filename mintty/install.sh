#!/bin/sh

# Remove symlink
echo "[mintty] Remove symlink"
rm ~/.minttyrc

# Create symlink
echo "[mintty] Create symlink"
ln -s $(pwd)/minttyrc ~/.minttyrc

echo "[mintty] Done"
