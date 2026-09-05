#!/usr/bin/env python3
"""Waybar CPU module with an informative tooltip.

Long-running: samples /proc every INTERVAL seconds and prints one JSON line.
  text    - icon only (turns accent-coloured via class "high" when busy)
  alt     - icon + usage percent (shown on right-click via format-alt)
  tooltip - CPU model, thread count, frequency and temperature; a usage history
            sparkline; per-thread bars; load averages; memory and swap; the
            busiest processes since the last sample; and a click hint.

Run with --once to print a single line and exit (handy for testing).
"""
import json
import os
import sys
import time
from html import escape
from pathlib import Path

ICON = "\U000F035B"
INTERVAL = 3
HISTORY = 40
HIGH_THRESHOLD = 80
TOP_PROCS = 4
BLOCKS = "▁▂▃▄▅▆▇█"
# hwmon chips to prefer for the CPU temperature, in order
TEMP_CHIPS = [("k10temp", "Tctl"), ("k10temp", "Tdie"), ("coretemp", "Package id 0"),
              ("zenpower", "Tdie"), ("acpitz", None), ("cpu_thermal", None)]

PROC = Path("/proc")


def dim(s):
    return f"<span alpha='50%'>{s}</span>"


def block(frac):
    frac = min(max(frac, 0.0), 1.0)
    return BLOCKS[round(frac * (len(BLOCKS) - 1))]


def bar(frac, width):
    filled = round(min(max(frac, 0.0), 1.0) * width)
    return "█" * filled + dim("░" * (width - filled))


# ---------------------------------------------------------------- sampling

def read_cpu_times():
    """Return {name: (busy, total)} for 'cpu' and each 'cpuN'."""
    out = {}
    for line in (PROC / "stat").read_text().splitlines():
        if not line.startswith("cpu"):
            break
        parts = line.split()
        vals = list(map(int, parts[1:]))
        idle = vals[3] + vals[4]  # idle + iowait
        total = sum(vals)
        out[parts[0]] = (total - idle, total)
    return out


def read_proc_times():
    """Return {pid: (name, utime+stime)} for all processes."""
    out = {}
    for p in PROC.iterdir():
        if not p.name.isdigit():
            continue
        try:
            stat = (p / "stat").read_text()
        except OSError:
            continue
        # comm may contain spaces/parens: it is everything between the first '(' and last ')'
        lpar, rpar = stat.index("("), stat.rindex(")")
        name = stat[lpar + 1:rpar]
        fields = stat[rpar + 2:].split()
        out[int(p.name)] = (name, int(fields[11]) + int(fields[12]))
    return out


def usage(prev, cur):
    busy = cur[0] - prev[0]
    total = cur[1] - prev[1]
    return busy / total if total > 0 else 0.0


def cpu_model():
    for line in (PROC / "cpuinfo").read_text().splitlines():
        if line.startswith("model name"):
            return line.split(":", 1)[1].strip()
    return "CPU"


def avg_mhz():
    mhz = []
    for line in (PROC / "cpuinfo").read_text().splitlines():
        if line.startswith("cpu MHz"):
            mhz.append(float(line.split(":", 1)[1]))
    return sum(mhz) / len(mhz) if mhz else None


def cpu_temp():
    chips = {}
    for h in Path("/sys/class/hwmon").glob("hwmon*"):
        try:
            chips.setdefault((h / "name").read_text().strip(), []).append(h)
        except OSError:
            pass
    for chip, label in TEMP_CHIPS:
        for h in chips.get(chip, []):
            for inp in sorted(h.glob("temp*_input")):
                lab = inp.with_name(inp.name.replace("_input", "_label"))
                try:
                    if label is None or (lab.exists() and lab.read_text().strip() == label):
                        return int(inp.read_text()) / 1000
                except OSError:
                    continue
    return None


def meminfo():
    info = {}
    for line in (PROC / "meminfo").read_text().splitlines():
        k, v = line.split(":", 1)
        info[k] = int(v.split()[0]) * 1024
    used = info["MemTotal"] - info["MemAvailable"]
    swap_used = info.get("SwapTotal", 0) - info.get("SwapFree", 0)
    return used, info["MemTotal"], swap_used, info.get("SwapTotal", 0)


def uptime():
    secs = float((PROC / "uptime").read_text().split()[0])
    d, rem = divmod(int(secs), 86400)
    h, rem = divmod(rem, 3600)
    m = rem // 60
    return f"{d}d {h}h" if d else (f"{h}h {m:02d}m" if h else f"{m}m")


def gib(n):
    return f"{n / 2**30:.1f}"


# ---------------------------------------------------------------- rendering

def build(prev_cpu, cur_cpu, prev_procs, cur_procs, history):
    total = usage(prev_cpu["cpu"], cur_cpu["cpu"])
    cores = [usage(prev_cpu[k], cur_cpu[k]) for k in sorted(
        (k for k in cur_cpu if k != "cpu"), key=lambda k: int(k[3:])) if k in prev_cpu]
    history.append(total)
    del history[:-HISTORY]

    meta = [f"{len(cores)} threads"]
    mhz = avg_mhz()
    if mhz:
        meta.append(f"{mhz / 1000:.1f} GHz")
    temp = cpu_temp()
    if temp is not None:
        meta.append(f"{temp:.0f}°C")
    meta.append(f"up {uptime()}")

    lines = [f"<b>{escape(cpu_model())}</b>", dim("  ·  ".join(meta)), ""]

    spark = "".join(block(v) for v in history)
    lines.append(f"<tt>{dim('usage ')} {total * 100:3.0f}%  {spark}</tt>")
    # per-thread bars, 12 per row
    per_row = 12 if len(cores) > 12 else len(cores)
    rows = ["".join(block(c) for c in cores[i:i + per_row]) for i in range(0, len(cores), per_row)]
    label = dim("cores ")
    for r in rows:
        lines.append(f"<tt>{label} {r}</tt>")
        label = dim("      ")
    load = Path("/proc/loadavg").read_text().split()[:3]
    lines.append(f"<tt>{dim('load  ')} {'  '.join(load)}</tt>")
    lines.append("")

    used, mem_total, swap_used, swap_total = meminfo()
    lines.append(f"<tt>{dim('memory')} {bar(used / mem_total, 20)} {gib(used)} / {gib(mem_total)} GiB</tt>")
    if swap_total and swap_used > 0:
        lines.append(f"<tt>{dim('swap  ')} {bar(swap_used / swap_total, 20)} {gib(swap_used)} / {gib(swap_total)} GiB</tt>")
    lines.append("")

    # top processes by CPU since last sample
    jiffies = cur_cpu["cpu"][1] - prev_cpu["cpu"][1]
    deltas = []
    for pid, (name, t) in cur_procs.items():
        if pid in prev_procs and jiffies > 0:
            d = t - prev_procs[pid][1]
            if d > 0:
                deltas.append((d / jiffies * len(cores) * 100, name))
    deltas.sort(reverse=True)
    lines.append("<b>Busiest processes</b>")
    if deltas:
        for pct, name in deltas[:TOP_PROCS]:
            lines.append(f"<tt>{pct:5.1f}%</tt>  {escape(name)}")
    else:
        lines.append(dim("idle"))
    lines.append("")
    lines.append(dim("<i>click to open btop</i>"))

    return {
        "text": ICON,
        "alt": f"{ICON} {total * 100:.0f}%",
        "tooltip": "\n".join(lines),
        "class": "high" if total * 100 >= HIGH_THRESHOLD else "normal",
        "percentage": round(total * 100),
    }


def main():
    once = "--once" in sys.argv
    history = []
    prev_cpu, prev_procs = read_cpu_times(), read_proc_times()
    time.sleep(1 if once else INTERVAL)
    while True:
        cur_cpu, cur_procs = read_cpu_times(), read_proc_times()
        print(json.dumps(build(prev_cpu, cur_cpu, prev_procs, cur_procs, history)), flush=True)
        if once:
            return
        prev_cpu, prev_procs = cur_cpu, cur_procs
        time.sleep(INTERVAL)


if __name__ == "__main__":
    main()
