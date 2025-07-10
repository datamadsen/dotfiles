#!/bin/sh

# Remove symlink
echo "[farv] Remove symlink"
rm ~/.farv

# Create symlink
echo "[farv] Create symlink"
ln -s "$(pwd)" ~/.farv

echo "[farv] Done - farv folder is now available at ~/.farv"