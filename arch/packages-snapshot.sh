#!/bin/bash
# Update the list of installed packages. Packages listed in packages.<hostname>
# are host-specific and stay out of the shared list.

cd "$(dirname "$0")"

host_packages="packages.$(cat /etc/hostname)"

if [ -f "$host_packages" ]; then
    pacman -Qqe | sort | comm -23 - <(sort "$host_packages") > packages
else
    pacman -Qqe | sort > packages
fi
echo "Package list updated in packages file"
