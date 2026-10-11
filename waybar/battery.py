#!/usr/bin/env python3
"""Waybar battery module with an informative tooltip.

Long-running: samples /sys/class/power_supply every INTERVAL seconds, appends
the sample to a log and prints one JSON line.
  text    - icon only (class "warning"/"critical" when low, "charging" on AC)
  alt     - icon + percent (shown on right-click via format-alt)
  tooltip - state, percent, energy, draw and time left; charge and health bars;
            a draw sparkline over the last SPARK_HOURS; an "Away" section:
            what the machine used since you came back and during the last
            away period (lock -> activity); and a "Sleep" section listing the
            last SLEEP_ROWS suspends, most recent first.

The away/sleep numbers come from marks written by hypridle:
  battery.py mark away    on the lock listener's on-timeout
  battery.py mark back    on its on-resume
  battery.py mark sleep   in before_sleep_cmd
  battery.py mark wake    in after_sleep_cmd

The wake mark also records what kind of sleep it was (s2idle, hibernate, or
both for suspend-then-hibernate), read from the systemd-sleep journal lines
written since the sleep mark.

Run with --once to print a single line and exit (handy for testing).
"""
import json
import os
import re
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path

INTERVAL = 10
SPARK_HOURS = 2
SPARK_BUCKETS = 40
SPARK_MAX_W = 30.0        # draw that fills the tallest block
LOG_KEEP = 48 * 3600       # seconds of samples to keep
SLEEP_ROWS = 10            # suspends to list in the Sleep section
SLEEP_MIN = 60             # ignore suspends shorter than this (seconds)
WARNING, CRITICAL = 20, 10
# exception-based icon: shown while charging, or while discharging at or below
# SHOW_BELOW percent / with less than SHOW_UNDER_HOURS left; hidden otherwise
SHOW_BELOW = 40
SHOW_UNDER_HOURS = 1.5
BLOCKS = "▁▂▃▄▅▆▇█"

BAT = Path("/sys/class/power_supply/BAT0")
STATE = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "waybar-battery"
SAMPLES = STATE / "samples.log"   # ts charge_uAh power_uW status
EVENTS = STATE / "events.log"     # ts kind charge_uAh status [sleep_type]

ICONS_DISCHARGING = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
ICONS_CHARGING = ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
ICON_PLUGGED = ""
ICON_FULL = "󰂅"


def dim(s):
    return f"<span alpha='50%'>{s}</span>"


def block(frac):
    frac = min(max(frac, 0.0), 1.0)
    return BLOCKS[round(frac * (len(BLOCKS) - 1))]


def bar(frac, width):
    filled = round(min(max(frac, 0.0), 1.0) * width)
    return "█" * filled + dim("░" * (width - filled))


# ---------------------------------------------------------------- sysfs

def read_int(name, default=0):
    try:
        return int((BAT / name).read_text())
    except (OSError, ValueError):
        return default


def read_str(name, default=""):
    try:
        return (BAT / name).read_text().strip()
    except OSError:
        return default


class Sample:
    def __init__(self):
        self.ts = int(time.time())
        self.status = read_str("status", "Unknown")
        self.capacity = read_int("capacity")
        self.charge = read_int("charge_now")                 # µAh
        self.full = read_int("charge_full")
        self.design = read_int("charge_full_design")
        self.vdesign = read_int("voltage_min_design", 15400000)
        self.voltage = read_int("voltage_now")
        self.current = read_int("current_now")               # µA
        self.cycles = read_int("cycle_count")
        self.power_uw = self.current * self.voltage // 1_000_000

    @property
    def power_w(self):
        return self.power_uw / 1e6

    @property
    def discharging(self):
        return self.status == "Discharging"

    @property
    def charging(self):
        return self.status == "Charging"

    def wh(self, charge_uah):
        """µAh -> Wh at the pack's design voltage (the same convention upower uses)."""
        return charge_uah * self.vdesign / 1e12

    def hours_left(self):
        if self.current <= 0:
            return None
        if self.discharging:
            return self.charge / self.current
        if self.charging:
            return (self.full - self.charge) / self.current
        return None


# ---------------------------------------------------------------- state files

def append_line(path, line):
    STATE.mkdir(parents=True, exist_ok=True)
    with path.open("a") as f:
        f.write(line + "\n")


def load_samples():
    out = []
    try:
        for line in SAMPLES.read_text().splitlines():
            try:
                ts, charge, power, status = line.split()
                out.append((int(ts), int(charge), int(power), status))
            except ValueError:
                continue
    except OSError:
        pass
    return out


def trim_samples(samples):
    cutoff = time.time() - LOG_KEEP
    keep = [s for s in samples if s[0] >= cutoff]
    SAMPLES.write_text("".join(f"{a} {b} {c} {d}\n" for a, b, c, d in keep))
    return keep


def load_events():
    """(ts, kind, charge_uAh, status, sleep_type) tuples; sleep_type is "" unless kind is wake."""
    out = []
    try:
        for line in EVENTS.read_text().splitlines():
            parts = line.split()
            try:
                ts, kind, charge, status = parts[:4]
                out.append((int(ts), kind, int(charge), status, parts[4] if len(parts) > 4 else ""))
            except ValueError:
                continue
    except OSError:
        pass
    return out


def sleep_type(since_ts):
    """What systemd-sleep did since since_ts: "s2idle", "hibernate", "s2idle+hibernate" or ""."""
    try:
        out = subprocess.run(
            ["journalctl", "-q", "-o", "cat", "--since", f"@{since_ts}", "_COMM=systemd-sleep"],
            capture_output=True, text=True, timeout=10).stdout
    except (OSError, subprocess.SubprocessError):
        return ""
    ops = re.findall(r"Performing sleep operation '([\w-]+)'", out)
    mem = re.search(r"\[(\w+)\]", Path("/sys/power/mem_sleep").read_text()) if Path("/sys/power/mem_sleep").exists() else None
    mem = mem.group(1) if mem else "suspend"
    seen = []
    for op in ops:
        name = {"suspend": mem}.get(op, op)
        if name not in seen:
            seen.append(name)
    return "+".join(seen)


def mark(kind):
    s = Sample()
    line = f"{s.ts} {kind} {s.charge} {s.status[:1]}"
    if kind == "wake":
        sleeps = [e for e in load_events() if e[1] == "sleep"]
        since = sleeps[-1][0] if sleeps else s.ts - 3 * 86400
        kind_of_sleep = sleep_type(since)
        if kind_of_sleep:
            line += f" {kind_of_sleep}"
    append_line(EVENTS, line)


# ---------------------------------------------------------------- formatting

def duration(secs):
    secs = max(int(secs), 0)
    d, rem = divmod(secs, 86400)
    h, rem = divmod(rem, 3600)
    m = rem // 60
    if d:
        return f"{d}d {h}h"
    if h:
        return f"{h}h {m:02d}m"
    return f"{m}m"


def clock(ts):
    t = datetime.fromtimestamp(ts)
    if t.date() == datetime.now().date():
        return t.strftime("%H:%M")
    return t.strftime("%b %-d %H:%M")


def span(a, b):
    return f"{clock(a)}–{datetime.fromtimestamp(b).strftime('%H:%M')}"


def icon_for(s):
    if s.status == "Full":
        return ICON_FULL
    if s.charging:
        return ICONS_CHARGING[min(9, s.capacity // 10)]
    if s.discharging:
        return ICONS_DISCHARGING[min(9, s.capacity // 10)]
    return ICON_PLUGGED


# ---------------------------------------------------------------- periods

def period_line(label, start, end, charge0, charge1, samples, s, now_ts=None, note=""):
    """One <tt> row: label, duration, energy used, percent, average draw, when [, note]."""
    secs = end - start
    if secs <= 0:
        return None
    on_ac = any(st in "CF" for ts, _, _, st in samples if start <= ts <= end)
    used_wh = s.wh(charge0 - charge1)
    pct = (charge0 - charge1) / s.full * 100 if s.full else 0
    when = dim(span(start, end) if now_ts is None else f"since {clock(start)}")
    tail = f"  {when}" + (f"  {dim(note)}" if note else "")
    if on_ac or used_wh < 0:
        return f"<tt>{label} {duration(secs):>7}   {dim('on charger')}</tt>{tail}"
    avg_w = used_wh / (secs / 3600)
    return (f"<tt>{label} {duration(secs):>7}   {used_wh:5.1f} Wh  {pct:3.0f}%  {avg_w:4.1f} W</tt>{tail}")


def pairs(events, start_kind, end_kind):
    """All (start, end) event pairs of the given kinds, oldest first."""
    start = None
    out = []
    for ev in events:
        if ev[1] == start_kind:
            start = ev
        elif ev[1] == end_kind and start is not None:
            out.append((start, ev))
            start = None
    return out


def last_pair(events, start_kind, end_kind):
    """Most recent (start, end) event pair of the given kinds, or None."""
    found = pairs(events, start_kind, end_kind)
    return found[-1] if found else None


def away_section(s, samples, events):
    lines = ["<b>Away</b>"]
    label_w = 11
    returns = [e for e in events if e[1] in ("back", "wake")]
    if returns:
        ts, _, charge, _, _ = returns[-1]
        line = period_line(dim("since back".ljust(label_w)), ts, s.ts, charge, s.charge, samples, s, now_ts=s.ts)
        if line:
            lines.append(line)
    away = last_pair(events, "away", "back")
    if away:
        (t0, _, c0, _, _), (t1, _, c1, _, _) = away
        line = period_line(dim("last away".ljust(label_w)), t0, t1, c0, c1, samples, s)
        if line:
            lines.append(line)
    if len(lines) == 1:
        lines.append(dim("no away periods recorded yet"))
    return lines


def sleep_section(s, samples, events):
    """The last SLEEP_ROWS suspends, most recent first."""
    lines = ["<b>Sleep</b>"]
    label_w = 11
    sleeps = [p for p in pairs(events, "sleep", "wake") if p[1][0] - p[0][0] >= SLEEP_MIN]
    for (t0, _, c0, _, _), (t1, _, c1, _, kind) in reversed(sleeps[-SLEEP_ROWS:]):
        line = period_line(" " * label_w, t0, t1, c0, c1, samples, s, note=kind)
        if line:
            lines.append(line)
    if len(lines) == 1:
        lines.append(dim("no sleeps recorded yet"))
    return lines


def spark_section(s, samples):
    now = s.ts
    window = SPARK_HOURS * 3600
    width = window / SPARK_BUCKETS
    sums = [0.0] * SPARK_BUCKETS
    counts = [0] * SPARK_BUCKETS
    for ts, _, power, st in samples:
        if ts < now - window or st != "D":
            continue
        i = min(SPARK_BUCKETS - 1, int((ts - (now - window)) / width))
        sums[i] += power / 1e6
        counts[i] += 1
    vals = [sums[i] / counts[i] if counts[i] else None for i in range(SPARK_BUCKETS)]
    spark = "".join(block(v / SPARK_MAX_W) if v is not None else dim("·") for v in vals)
    seen = [v for v in vals if v is not None]
    lines = [f"<tt>{dim('draw   ')} {s.power_w:5.1f} W  {spark}</tt>"]
    if seen:
        stats = f"min {min(seen):.1f}  avg {sum(seen) / len(seen):.1f}  max {max(seen):.1f} W  ·  last {SPARK_HOURS}h"
        lines.append(f"<tt>{' ' * 17}{dim(stats)}</tt>")
    return lines


# ---------------------------------------------------------------- rendering

def build(samples, events):
    s = Sample()
    append_line(SAMPLES, f"{s.ts} {s.charge} {s.power_uw} {s.status[:1]}")
    samples.append((s.ts, s.charge, s.power_uw, s.status[:1]))

    state = {"Discharging": "Discharging", "Charging": "Charging", "Full": "Full",
             "Not charging": "Plugged in"}.get(s.status, s.status)
    meta = [f"{s.capacity}%", f"{s.wh(s.charge):.1f} Wh"]
    if s.discharging or s.charging:
        meta.append(f"{s.power_w:.1f} W")
    left = s.hours_left()
    if left is not None:
        meta.append(f"{duration(left * 3600)} {'to full' if s.charging else 'left'}")
    lines = [f"<b>{state}</b>", dim("  ·  ".join(meta)), ""]

    if s.full:
        lines.append(f"<tt>{dim('charge ')} {bar(s.charge / s.full, 20)}  {s.charge / s.full * 100:3.0f}%  "
                     f"{s.wh(s.charge):.1f} / {s.wh(s.full):.1f} Wh</tt>")
    if s.full and s.design:
        health = f"{s.wh(s.full):.1f} / {s.wh(s.design):.1f} Wh design"
        if s.cycles:
            health += f"  ·  {s.cycles} cycles"
        lines.append(f"<tt>{dim('health ')} {bar(s.full / s.design, 20)}  {s.full / s.design * 100:3.0f}%  {health}</tt>")
    lines.append("")
    lines += spark_section(s, samples)
    lines.append("")
    lines += away_section(s, samples, events)
    lines.append("")
    lines += sleep_section(s, samples, events)

    cls = "normal"
    if s.charging:
        cls = "charging"
    elif s.discharging and s.capacity <= CRITICAL:
        cls = "critical"
    elif s.discharging and s.capacity <= WARNING:
        cls = "warning"
    icon = icon_for(s)
    show = s.charging or (s.discharging and (s.capacity <= SHOW_BELOW or (left is not None and left < SHOW_UNDER_HOURS)))
    return {
        "text": icon if show else "",
        "alt": f"{s.capacity}% {icon}",
        "tooltip": "\n".join(lines),
        "class": cls,
        "percentage": s.capacity,
    }


def brief():
    """One line for menus: icon, percent and time left / to full."""
    s = Sample()
    parts = [f"{s.capacity}%"]
    left = s.hours_left()
    if s.charging:
        parts.append(f"{duration(left * 3600)} to full" if left else "charging")
    elif s.discharging and left:
        parts.append(f"{duration(left * 3600)} left")
    elif not s.discharging:
        parts.append("plugged in")
    print(f"{icon_for(s)} Battery: {' · '.join(parts)}")


def info():
    """The tooltip rendered for a terminal (Pango markup -> ANSI)."""
    import re
    from html import unescape
    tip = build(load_samples(), load_events())["tooltip"]
    tip = re.sub(r"<span alpha='50%'>", "\033[2m", tip).replace("</span>", "\033[22m")
    tip = tip.replace("<b>", "\033[1m").replace("</b>", "\033[22m")
    tip = tip.replace("<i>", "\033[3m").replace("</i>", "\033[23m")
    tip = tip.replace("<tt>", "").replace("</tt>", "")
    print("\n" + "\n".join("  " + line for line in unescape(tip).splitlines()))


def main():
    if len(sys.argv) >= 2 and sys.argv[1] == "info":
        info()
        return
    if len(sys.argv) >= 3 and sys.argv[1] == "mark":
        mark(sys.argv[2])
        return
    if len(sys.argv) >= 2 and sys.argv[1] == "brief":
        brief()
        return
    once = "--once" in sys.argv
    samples = load_samples()
    n = 0
    while True:
        print(json.dumps(build(samples, load_events())), flush=True)
        if once:
            return
        n += 1
        if n % 360 == 0:  # about once an hour
            samples = trim_samples(samples)
        time.sleep(INTERVAL)


if __name__ == "__main__":
    main()
