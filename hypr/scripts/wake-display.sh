#!/usr/bin/env bash
# Turn the displays back on after resume from suspend.
#
# hypridle runs after_sleep_cmd as soon as logind reports the system is back,
# which can be before Hyprland is ready to act on it, so keep asking until
# every monitor reports dpms on (a few seconds at most).
#
# Note the table form of the Lua dispatcher: hl.dsp.dpms("on") with a plain
# string is parsed as *toggle*, which is what caused the panel to go dark (or
# flicker) after resume.
for _ in $(seq 1 20); do
    hyprctl dispatch 'hl.dsp.dpms({ action = "on" })' >/dev/null 2>&1
    sleep 0.3
    if hyprctl monitors -j 2>/dev/null | grep -q '"dpmsStatus": false'; then
        continue
    fi
    exit 0
done
