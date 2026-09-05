#!/usr/bin/env python3
"""Waybar media module driven by `playerctl --follow`.

Prints one JSON line whenever the active player's metadata or status changes.
  text    - player icon + "Artist – Title" (truncated), pause mark when paused;
            empty when nothing is playing, which hides the module
  tooltip - title, artist, album, player and status, plus click hints
  class   - "playing", "paused" or "stopped"

Run with --test to render a synthetic sample and exit.
"""
import json
import subprocess
import sys
from html import escape

PLAYER_ICONS = {
    "spotify": "\U000F04C7",
    "chromium": "\U000F02AF",
    "chrome": "\U000F02AF",
    "firefox": "\U000F0239",
}
DEFAULT_ICON = "\U000F075A"  # music note
PAUSE = "\U000F03E4"
MAX_LEN = 48
FORMAT = "{{status}}\t{{playerName}}\t{{artist}}\t{{album}}\t{{title}}"


def dim(s):
    return f"<span alpha='50%'>{s}</span>"


def render(line):
    parts = line.rstrip("\n").split("\t")
    if len(parts) < 5 or not parts[0] or parts[0] == "Stopped":
        return {"text": "", "class": "stopped"}
    status, player, artist, album, title = parts[:5]
    icon = PLAYER_ICONS.get(player.lower().split(".")[0], DEFAULT_ICON)
    label = " – ".join(p for p in (artist, title) if p) or player
    if len(label) > MAX_LEN:
        label = label[:MAX_LEN - 1].rstrip() + "…"
    text = f"{icon} {escape(label)}"
    if status == "Paused":
        text += f"  {PAUSE}"
    tooltip = [f"<b>{escape(title or 'Unknown title')}</b>"]
    if artist:
        tooltip.append(escape(artist))
    if album:
        tooltip.append(dim(escape(album)))
    tooltip += ["", dim(f"{escape(player)}  ·  {status.lower()}"), "",
                dim("<i>click: play/pause  ·  right-click: next  ·  scroll: volume</i>")]
    return {"text": text, "tooltip": "\n".join(tooltip), "class": status.lower()}


def main():
    if "--test" in sys.argv:
        for sample in ("Playing\tspotify\tKhruangbin\tMordechai\tTime (You and I)",
                       "Paused\tchromium\t\t\tSome very long video title that goes on and on and on forever",
                       ""):
            print(json.dumps(render(sample)))
        return
    proc = subprocess.Popen(["playerctl", "-a", "metadata", "--format", FORMAT, "--follow"],
                            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
    for line in proc.stdout:
        print(json.dumps(render(line)), flush=True)


if __name__ == "__main__":
    main()
