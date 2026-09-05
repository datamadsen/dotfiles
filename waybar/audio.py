#!/usr/bin/env python3
"""Waybar audio module (PipeWire) with an informative tooltip.

Long-running: polls `pw-dump` every INTERVAL seconds and prints one JSON line.
  text    - volume icon (muted icon when the output is muted), plus a
            microphone-off marker when the default input is muted
  alt     - icon + volume percent (available for format-alt, unused by default)
  tooltip - default output and input with volume bars and the other available
            devices; the applications currently playing audio; click hints
  class   - "muted" when the output is muted, else "normal"

  --once          print one line and exit
  --cycle-output  make the next sink the default output (middle-click)
"""
import json
import math
import re
import subprocess
import sys
import time
from html import escape

ICONS = ["", "", ""]  # low / mid / high (same as before)
MUTED_ICON = "\U000F075F"
MIC_OFF_ICON = "\U000F036D"
INTERVAL = 2
BAR_WIDTH = 20
SUFFIX_RE = re.compile(r"\s+(Digital|Analog|Pro)\s+(Stereo|Mono|Surround[\w. ]*?)(\s*\([^)]*\))?(?=\s*\[|$)|\s+(Mono|Stereo)(?=\s*\[|$)")


def dim(s):
    return f"<span alpha='50%'>{s}</span>"


def bar(frac):
    filled = round(min(max(frac, 0.0), 1.0) * BAR_WIDTH)
    return "█" * filled + dim("░" * (BAR_WIDTH - filled))


def run(cmd, timeout=5):
    try:
        return subprocess.run(cmd, capture_output=True, text=True, timeout=timeout).stdout
    except (OSError, subprocess.TimeoutExpired):
        return ""


def short_name(props):
    name = props.get("node.description") or props.get("node.nick") or props.get("node.name") or "?"
    return SUFFIX_RE.sub("", name)


def cubic(chans):
    return max(chans or [0.0]) ** (1 / 3)  # PipeWire stores linear, wpctl shows cubic


def node_volume(node, routes):
    """(volume 0..1 on wpctl's cubic scale, muted).

    Hardware devices keep volume and mute on the device's active Route (that is
    what wpctl reports); fall back to the node's own Props for virtual nodes.
    """
    props = node.get("info", {}).get("props", {})
    direction = "Output" if props.get("media.class") == "Audio/Sink" else "Input"
    key = (props.get("device.id"), props.get("card.profile.device"), direction)
    if key in routes:
        rp = routes[key]
        return cubic(rp.get("channelVolumes")), bool(rp.get("mute", False))
    for p in node.get("info", {}).get("params", {}).get("Props", []):
        if "channelVolumes" in p:
            return cubic(p["channelVolumes"]), bool(p.get("mute", False))
    return None, False


def snapshot():
    try:
        objects = json.loads(run(["pw-dump"], timeout=5) or "[]")
    except ValueError:
        objects = []
    defaults = {}
    sinks, sources, streams = [], [], []
    # active routes per (device id, profile device index, direction)
    routes = {}
    for o in objects:
        if o.get("info", {}).get("props", {}).get("media.class") == "Audio/Device":
            for r in o["info"].get("params", {}).get("Route", []):
                routes[(o["id"], r.get("device"), r.get("direction"))] = r.get("props", {})
    for o in objects:
        info = o.get("info", {})
        props = info.get("props", {})
        if o.get("type") == "PipeWire:Interface:Metadata" and props.get("metadata.name") == "default":
            for m in o.get("metadata", []):
                if m.get("key") in ("default.audio.sink", "default.audio.source"):
                    defaults[m["key"]] = (m.get("value") or {}).get("name")
            continue
        mc = props.get("media.class", "")
        if mc == "Audio/Sink":
            sinks.append((o["id"], props.get("node.name"), short_name(props), *node_volume(o, routes)))
        elif mc == "Audio/Source":
            sources.append((o["id"], props.get("node.name"), short_name(props), *node_volume(o, routes)))
        elif mc == "Stream/Output/Audio":
            app = props.get("application.name") or props.get("media.name") or props.get("node.name") or "?"
            vol, muted = node_volume(o, routes)
            streams.append((app, vol, muted, o["id"]))
    return defaults, sinks, sources, streams


def pick_default(devices, name):
    for d in devices:
        if d[1] == name:
            return d
    return devices[0] if devices else None


# ---------------------------------------------------------------- rendering

def device_block(kind, devices, default, hint_id=None):
    lines = []
    if not default:
        lines.append(f"<b>No {kind}</b>")
        return lines
    _, _, name, vol, muted = default
    lines.append(f"<b>{escape(name)}</b>  {dim(kind)}")
    if vol is not None:
        pct = f"{vol * 100:.0f}%"
        lines.append(f"<tt>{bar(vol)} {pct:>4}</tt>" + (f"  <b>muted</b>" if muted else ""))
    others = [d for d in devices if d[0] != default[0]]
    for d in others:
        mark = "  muted" if d[4] else ""
        lines.append(dim(f"   {escape(d[2])}{mark}"))
    return lines


def build():
    defaults, sinks, sources, streams = snapshot()
    sink = pick_default(sinks, defaults.get("default.audio.sink"))
    source = pick_default(sources, defaults.get("default.audio.source"))

    lines = device_block("output", sinks, sink)
    lines.append("")
    lines += device_block("input", sources, source)
    lines.append("")

    # merge streams per application (games often open several nodes)
    apps = {}
    for app, vol, muted, _ in streams:
        cur = apps.get(app)
        if cur is None or (vol or 0) > (cur[0] or 0):
            apps[app] = (vol, muted)
    lines.append("<b>Playing</b>")
    if apps:
        for app, (vol, muted) in sorted(apps.items(), key=lambda kv: kv[0].lower()):
            pct = f"{vol * 100:.0f}%" if vol is not None else "  ?"
            lines.append(f"<tt>{pct:>5}</tt>  {escape(app)}" + (dim("  muted") if muted else ""))
    else:
        lines.append(dim("nothing playing"))
    lines.append("")
    lines.append(dim("<i>click: wiremix  ·  right: mute  ·  middle: next output  ·  scroll: volume</i>"))

    vol, muted = (sink[3], sink[4]) if sink else (None, False)
    if sink is None or vol is None:
        icon, pct = MUTED_ICON, 0
    else:
        pct = round(vol * 100)
        icon = MUTED_ICON if muted else ICONS[min(len(ICONS) - 1, int(vol * len(ICONS)))] if vol > 0 else ICONS[0]
    text = icon
    if source and source[4]:
        text += f" {MIC_OFF_ICON}"
    return {
        "text": text,
        "alt": f"{icon} {pct}%",
        "tooltip": "\n".join(lines),
        "class": "muted" if muted else "normal",
        "percentage": pct,
    }


def cycle_output(dry_run=False):
    defaults, sinks, _, _ = snapshot()
    if len(sinks) < 2:
        return
    sinks.sort(key=lambda s: s[0])
    cur = pick_default(sinks, defaults.get("default.audio.sink"))
    idx = sinks.index(cur) if cur in sinks else -1
    nxt = sinks[(idx + 1) % len(sinks)]
    if dry_run:
        print(f"would switch: {cur[2] if cur else None} -> {nxt[2]} (wpctl set-default {nxt[0]})")
        return
    subprocess.run(["wpctl", "set-default", str(nxt[0])])
    subprocess.run(["notify-send", "-e", "-t", "2000", "-h", "string:x-canonical-private-synchronous:audio-output",
                    "Audio output", nxt[2]])


def main():
    if "--cycle-output" in sys.argv:
        cycle_output("--dry-run" in sys.argv)
        return
    if "--once" in sys.argv:
        print(json.dumps(build()), flush=True)
        return
    while True:
        print(json.dumps(build()), flush=True)
        time.sleep(INTERVAL)


if __name__ == "__main__":
    main()
