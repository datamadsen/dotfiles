#!/usr/bin/env bash
# swaync status for waybar, exception-based: hidden (empty text) whenever no
# notifications are pending, do-not-disturb or not (the power menu shows the
# DND state); otherwise passes swaync's JSON through unchanged so the
# format-icons in the config still apply.
exec swaync-client -swb | python3 -u -c '
import json, sys
for line in sys.stdin:
    try:
        d = json.loads(line)
    except ValueError:
        continue
    if str(d.get("class", "")).endswith("none"):
        print(flush=True)   # empty line: waybar hides the module (the format is {icon}, so an empty text would not)
    else:
        print(json.dumps(d), flush=True)
'
