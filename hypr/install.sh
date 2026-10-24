#!/usr/bin/env bash
# Symlink this directory to ~/.config/hypr. Run from inside the hypr directory
# (the top-level install.sh does that).
set -euo pipefail

target=~/.config/hypr
src=$(cd "$(dirname "$0")" && pwd)

if [ -L "$target" ]; then
  echo "[hypr] Remove old symlink"
  rm "$target"
elif [ -e "$target" ]; then
  echo "[hypr] $target exists and is not a symlink; move it away first." >&2
  exit 1
fi

echo "[hypr] Create symlink"
ln -s "$src" "$target"

echo "[hypr] Done."
