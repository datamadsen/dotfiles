#!/usr/bin/env bash
# Wofi power menu for Hyprland: quick toggles (with live state), status lines
# that double as shortcuts, and the power actions last so a mis-click lands
# on something harmless. Run with --list to print the entries without wofi.

WB=~/.config/waybar
SC=~/.config/hypr/scripts

labels=()
declare -A actions
add() { labels+=("$1"); actions["$1"]="$2"; }

# ---------------------------------------------------------------- hardware
# The same script serves the laptop and the desktop: laptop-only entries are
# gated on the hardware being present (sysfs / Hyprland / logind), not hostname.
has_battery=false;  [ -d /sys/class/power_supply/BAT0 ] && has_battery=true
has_touchpad=false; hyprctl devices -j 2>/dev/null | grep -qi '"name": *"[^"]*touchpad' && has_touchpad=true
has_bluetooth=false; [ -n "$(ls -A /sys/class/bluetooth 2>/dev/null)" ] && has_bluetooth=true
has_wifi=false;     compgen -G '/sys/class/net/*/wireless' >/dev/null && has_wifi=true
logind_can() { [ "$(busctl --system call org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager "$1" 2>/dev/null)" = 's "yes"' ]; }

# ---------------------------------------------------------------- toggles
if "$WB/caffeine.sh" active; then
    add "󰅶 Caffeine on"            "$WB/caffeine.sh off"
else
    add "󰛊 Caffeine off"           "$WB/caffeine.sh on"
fi

if [ "$(swaync-client -D 2>/dev/null)" = "true" ]; then
    add "󰂛 Do not disturb on"      "swaync-client -d"
else
    add "󰂚 Do not disturb off"     "swaync-client -d"
fi

if ! $has_touchpad; then
    :
elif [ "$(cat /tmp/trackpad_state 2>/dev/null || echo true)" = "true" ]; then
    add "󰟸 Trackpad on"            "$SC/trackpad-toggle.sh"
else
    add "󰟸 Trackpad off"           "$SC/trackpad-toggle.sh"
fi

if mic=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null); then
    case $mic in
        *MUTED*) add "󰍭 Mic muted"  "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" ;;
        *)       add "󰍬 Mic on"     "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" ;;
    esac
fi

if snd=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null); then
    case $snd in
        *MUTED*) add "󰝟 Sound muted" "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" ;;
        *)       add "󰕾 Sound on"    "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" ;;
    esac
fi

# bluetoothctl blocks forever when bluetoothd is not running (no adapter on
# the desktop), so cap it and only offer the toggle when a controller answered.
bt=""; $has_bluetooth && bt=$(timeout 2 bluetoothctl show 2>/dev/null)
if grep -q 'Powered: yes' <<<"$bt"; then
    add "󰂯 Bluetooth on"           "bluetoothctl power off"
elif grep -q 'Powered: no' <<<"$bt"; then
    add "󰂲 Bluetooth off"          "bluetoothctl power on"
fi

add "󰏘 Theme: $(farv current 2>/dev/null || echo '?')"   "setsid -f $WB/theme.py --pick"

# ---------------------------------------------------------------- status
if $has_battery; then
    add "$("$WB/battery.py" brief 2>/dev/null || echo '󰁹 Battery')"   "setsid -f ghostty --class=TUI.float.info -e bash -c '$WB/battery.py info; read -rsn1'"
fi

netact=":"; $has_wifi && netact="setsid -f alacritty --class=Impala -e impala"
dev=$(ip -j route show default 2>/dev/null | python3 -c 'import json,sys; r=json.load(sys.stdin); print(min(r, key=lambda x: x.get("metric",0))["dev"] if r else "")' 2>/dev/null)
if [ -z "$dev" ]; then
    add "󰖪 Offline"                "$netact"
elif [ -d "/sys/class/net/$dev/wireless" ]; then
    ssid=$(iwctl station "$dev" show 2>/dev/null | sed -n 's/^\s*Connected network\s\{2,\}\(.*\S\)\s*$/\1/p')
    add "󰤨 Wi-Fi: ${ssid:-$dev}"   "$netact"
else
    add "󰈀 Ethernet: $dev"         "$netact"
fi

status=$(playerctl status 2>/dev/null)
if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
    track=$(playerctl metadata --format '{{artist}} – {{title}}' 2>/dev/null)
    track=${track#" – "}; track=${track%" – "}
    [ ${#track} -gt 48 ] && track="${track:0:47}…"
    [ "$status" = "Paused" ] && track="$track  󰏤"
    add "󰝚 $track"                 "playerctl play-pause"
fi

# ---------------------------------------------------------------- power
add "󰌾 Lock"                       "hyprlock"
if logind_can CanSuspendThenHibernate; then
    add "⏾ Suspend"                    "systemctl suspend-then-hibernate"   # s2idle, hibernates after 2h on battery (see arch/hibernation)
elif logind_can CanSuspend; then
    add "⏾ Suspend"                    "systemctl suspend"
fi
if logind_can CanHibernate; then
    add "󰒲 Hibernate"                  "systemctl hibernate"
fi
add "⏼ Reboot"                     "systemctl reboot"
add "⏻ Shutdown"                   "systemctl poweroff"
add "󰍃 Logout"                     "hyprctl dispatch 'hl.dsp.exit()'"

if [ "$1" = "--list" ]; then
    printf '%s\n' "${labels[@]}"
    exit 0
fi

chosen=$(printf '%s\n' "${labels[@]}" | wofi --dmenu --prompt "Power Menu" --style="$HOME/.config/farv/current/wofi-search.css")
[ -n "$chosen" ] && [ -n "${actions[$chosen]}" ] && eval "${actions[$chosen]}"
