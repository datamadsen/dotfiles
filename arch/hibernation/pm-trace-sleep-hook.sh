#!/bin/bash
# systemd sleep hook, DIAGNOSTIC: arm the kernel's PM trace before every sleep.
# Installed to /usr/lib/systemd/system-sleep/pm-trace.
#
# With /sys/power/pm_trace = 1 the kernel writes a hash of the device whose
# suspend callback is running into the RTC. If the machine hangs while
# suspending devices (hard reset needed), the next boot's kernel log names the
# device: `journalctl -b -k | grep -A2 'Magic number'` shows
# "hash matches device ..." and /sys/power/pm_trace_dev_match lists it.
# Side effect: the RTC clock is garbage after every sleep while this is on;
# systemd-timesyncd corrects the system clock within seconds. Remove the hook
# (setup.sh --no-pm-trace, or delete the file) once the culprit is known.
case "$1" in
    pre)  [ -w /sys/power/pm_trace ] && echo 1 > /sys/power/pm_trace && echo "pm_trace armed for $2" ;;
esac
exit 0
