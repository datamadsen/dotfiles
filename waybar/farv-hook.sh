#!/bin/bash
# farv runs every executable in ~/.config/farv/themes after a theme switch, and
# a user script overrides the system script of the same name. This replaces
# farv's waybar.sh, which sends SIGUSR2 and thereby restarts every module
# script. Waybar watches style.css (and the *resolved* theme import, which farv
# never modifies), so rewrite style.css in place with identical bytes: that
# emits the change event waybar listens for, and it re-reads the @import
# through the freshly repointed symlink. Then ask the theme module to redraw.
#   args: <script dir> <theme name> <category> <current link>

style="$HOME/.config/waybar/style.css"
if [ -f "$style" ] && pgrep -x waybar > /dev/null; then
    tmp=$(mktemp) && cat "$style" > "$tmp" && cat "$tmp" > "$style"
    rm -f "$tmp"
    pkill -RTMIN+10 waybar
fi
exit 0
