#!/bin/bash
# systemd sleep hook: take the Ethernet interface down before any sleep and
# bring it back afterwards. Installed to /usr/lib/systemd/system-sleep/eno1-down
# (systemd 262 does not read /etc/systemd/system-sleep).
#
# The Motorcomm YT6801 NIC (dwmac-motorcomm/stmmac) can keep the SoC busy with
# interrupts during s2idle: screen stays black, fans run, the laptop heats up
# and cannot be woken (seen 2026-10-06 after a lid close; same picture as
# https://bbs.archlinux.org/viewtopic.php?id=314219, where this workaround was
# confirmed). systemd-networkd's default ActivationPolicy=up leaves an admin
# "down" alone, so the interface stays down until "post".
#
# $1 = pre | post        $2 = suspend | hibernate | suspend-then-hibernate | hybrid-sleep
IFACE=eno1
STATE=/run/sleep-hook-$IFACE-was-up
SYSFS=/sys/class/net/$IFACE

[ -d "$SYSFS" ] || exit 0

case "$1" in
    pre)
        if [ $(( $(cat "$SYSFS/flags") & 1 )) -eq 1 ]; then      # IFF_UP
            touch "$STATE"
            ip link set "$IFACE" down && echo "$IFACE down for $2"
        fi
        ;;
    post)
        if [ -e "$STATE" ]; then
            rm -f "$STATE"
            ip link set "$IFACE" up && echo "$IFACE up again after $2"
        fi
        ;;
esac
exit 0
