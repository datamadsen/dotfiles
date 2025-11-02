#!/bin/bash
# Update the list of installed packages

cd "$(dirname "$0")"

pacman -Qqe | sort > packages
echo "Package list updated in packages file"
