#!/usr/bin/env bash
# Caffeine: keep the machine awake by holding a systemd idle inhibitor, which
# hypridle honours (ignore_systemd_inhibit = false). Shared by the waybar
# icon and the power menu so both show and toggle the same state.
#
#   caffeine.sh status   print the waybar JSON line
#   caffeine.sh toggle   turn it on or off
#   caffeine.sh on|off   set it explicitly
#   caffeine.sh active   exit 0 if active (for scripts)
PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/caffeine.pid"
SIGNAL=8   # waybar "signal" number of the custom/caffeine module

active() {
    local pid
    pid=$(cat "$PIDFILE" 2>/dev/null) || return 1
    [ -n "$pid" ] && grep -q systemd-inhibit "/proc/$pid/cmdline" 2>/dev/null
}

on() {
    active && return
    # own session so the whole group (systemd-inhibit + sleep) can be killed at once
    setsid -f bash -c "echo \$\$ > '$PIDFILE'; exec systemd-inhibit --what=idle --who=caffeine --why=Caffeine --mode=block sleep infinity" >/dev/null 2>&1
}

off() {
    active || return 0
    kill -- -"$(cat "$PIDFILE")" 2>/dev/null
    rm -f "$PIDFILE"
}

status() {
    if active; then
        printf '{"text":"󰅶","alt":"on","class":"activated","tooltip":"Caffeine on: the machine stays awake\\nclick to allow idle lock again"}\n'
    else
        printf '{"text":"󰛊","alt":"off","class":"deactivated","tooltip":"Idle lock active\\nclick to keep the machine awake"}\n'
    fi
}

refresh() { pkill -RTMIN+$SIGNAL -x waybar; }

case "${1:-status}" in
    status) status ;;
    active) active ;;
    on)     on; refresh ;;
    off)    off; refresh ;;
    toggle) if active; then off; else on; fi; refresh ;;
    *)      echo "usage: $0 status|toggle|on|off|active" >&2; exit 2 ;;
esac
