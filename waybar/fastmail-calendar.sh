#!/bin/bash
# Open Fastmail's calendar from the waybar clock.
#
# Focuses the running Fastmail desktop app (launching it if needed) and, unless the
# window already shows the calendar, sends Fastmail's "Shift+g, c" (go to calendar)
# shortcut. The fastmail:// deep links only reach the web app as opaque events and
# did not switch views in testing, hence the keyboard shortcut.

CLASS='com.fastmail.Fastmail'

window_title() {
    hyprctl -j clients | python3 -c '
import sys, json
for c in json.load(sys.stdin):
    if c["class"] == "'"$CLASS"'":
        print(c["title"]); break'
}

title=$(window_title)
launched=0
if [ -z "$title" ]; then
    setsid -f fastmail > /dev/null 2>&1
    launched=1
    for _ in $(seq 1 40); do
        sleep 0.25
        title=$(window_title)
        [ -n "$title" ] && break
    done
    [ -z "$title" ] && exit 1
fi

# Focusing warps the cursor to the window; put it back where the click happened
read -r cx cy <<< "$(hyprctl cursorpos | tr -d ',')"
hyprctl dispatch "hl.dsp.focus({ window = \"class:^($CLASS)\$\" })" > /dev/null
hyprctl dispatch "hl.dsp.cursor.move({ x = $cx, y = $cy })" > /dev/null

if [ "$title" != "Calendar" ]; then
    # Give a freshly launched app time to finish loading before sending keys
    [ "$launched" = 1 ] && sleep 2 || sleep 0.2
    wtype -M shift -k g -m shift -s 80 -k c
fi
