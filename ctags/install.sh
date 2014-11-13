#!/bin/sh

# Remove symlink
echo "[ctags] Remove symlink."
rm ~/.ctags

# Create symlink
echo "[ctags] Create symlink."
ln -s $(pwd)/ctags ~/.ctags

echo "[ctags] Done."
