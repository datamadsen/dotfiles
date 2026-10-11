#!/usr/bin/env bash
# hypridle after_sleep_cmd: drop the lock screen when the sleep we just came
# back from was a hibernate.
#
# before_sleep_cmd locks the session for every sleep. A resume from
# hibernation already went through the LUKS passphrase at boot, so asking for
# the user password on top of that is redundant. systemd-sleep logs
# "Performing sleep operation '<op>'" before each phase; the last such line in
# this boot is the phase we woke from ('hibernate' also covers the hibernate
# leg of suspend-then-hibernate, since that is logged as its own phase).
# A plain s2idle resume stays locked.
last=$(journalctl -b -q -o cat _COMM=systemd-sleep 2>/dev/null \
       | sed -n "s/.*Performing sleep operation '\([a-z-]*\)'.*/\1/p" | tail -1)
[ "$last" = hibernate ] || exit 0
# hyprlock unlocks on SIGUSR1 ("Unlocking with a SIGUSR1" in its log). That is
# independent of logind session bookkeeping, which is unreliable here because
# Hyprland (and so hypridle and hyprlock) run under the user manager's
# hyprland.service, not inside the tty session's scope, so logind's Unlock
# signal for session 1 never reached hyprlock.
for _ in $(seq 1 20); do           # hyprlock may still be starting up
    if pkill -USR1 -x hyprlock; then exit 0; fi
    sleep 0.25
done
