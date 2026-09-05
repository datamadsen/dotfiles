#!/usr/bin/env python3
"""Waybar network module with an informative tooltip.

Long-running: samples every INTERVAL seconds and prints one JSON line.
  text    - wifi strength / ethernet / disconnected icon (same glyphs as the
            built-in module)
  alt     - icon + current down/up rates (shown on right-click via format-alt)
  tooltip - network name, security and band, signal; IP, gateway and DNS;
            VPN interfaces; live bandwidth with a download sparkline, totals
            since boot; latency to the gateway and the internet (pinged in a
            background thread); click hint
  class   - "wifi", "ethernet", "disconnected" or "no-internet"

Run with --once to print a single line and exit.
"""
import json
import os
import re
import subprocess
import sys
import threading
import time
from html import escape
from pathlib import Path

WIFI_ICONS = ["\U000F092F", "\U000F091F", "\U000F0922", "\U000F0925", "\U000F0928"]
ETHERNET_ICON = "\U000F0002"
DISCONNECTED_ICON = "\U000F05AA"
INTERVAL = 3
HISTORY = 40
PING_INTERVAL = 10
INTERNET_HOST = "1.1.1.1"
VPN_PREFIXES = ("wg", "tun", "tailscale", "proton", "nordlynx")
BLOCKS = "▁▂▃▄▅▆▇█"
SYS_NET = Path("/sys/class/net")


def dim(s):
    return f"<span alpha='50%'>{s}</span>"


def run(cmd, timeout=5):
    try:
        return subprocess.run(cmd, capture_output=True, text=True, timeout=timeout).stdout
    except (OSError, subprocess.TimeoutExpired):
        return ""


def human_rate(bps):
    for unit in ("B/s", "kB/s", "MB/s", "GB/s"):
        if bps < 1000 or unit == "GB/s":
            return f"{bps:.0f} {unit}" if unit == "B/s" else f"{bps:.1f} {unit}"
        bps /= 1000
    return f"{bps:.1f} GB/s"


def human_size(n):
    for unit in ("B", "KiB", "MiB", "GiB", "TiB"):
        if n < 1024 or unit == "TiB":
            return f"{n:.0f} {unit}" if unit == "B" else f"{n:.1f} {unit}"
        n /= 1024
    return f"{n:.1f} TiB"


# ---------------------------------------------------------------- facts

def default_route():
    try:
        routes = json.loads(run(["ip", "-j", "route", "show", "default"]))
    except ValueError:
        return None, None
    routes = [r for r in routes if r.get("dev")]
    if not routes:
        return None, None
    r = min(routes, key=lambda r: r.get("metric", 0))
    return r["dev"], r.get("gateway")


def is_wireless(iface):
    return (SYS_NET / iface / "wireless").exists()


def wifi_info(iface):
    """SSID, security, frequency (MHz), RSSI (dBm), quality percent."""
    info = {}
    for line in run(["iwctl", "station", iface, "show"]).splitlines():
        m = re.match(r"\s*(Connected network|Frequency|Security|RSSI)\s{2,}(.+?)\s*$", line)
        if m:
            info[m.group(1)] = m.group(2)
    freq = int(info["Frequency"]) if info.get("Frequency", "").isdigit() else None
    rssi = None
    m = re.match(r"(-?\d+)", info.get("RSSI", ""))
    if m:
        rssi = int(m.group(1))
    quality = None
    try:
        for line in Path("/proc/net/wireless").read_text().splitlines()[2:]:
            parts = line.split()
            if parts[0].rstrip(":") == iface:
                quality = min(100, round(float(parts[2].rstrip(".")) / 70 * 100))
    except (OSError, ValueError, IndexError):
        pass
    if quality is None and rssi is not None:
        quality = max(0, min(100, 2 * (rssi + 100)))
    return info.get("Connected network"), info.get("Security"), freq, rssi, quality


def band(freq):
    if not freq:
        return None
    return "2.4 GHz" if freq < 3000 else ("5 GHz" if freq < 5900 else "6 GHz")


def link_speed(iface):
    try:
        mbit = int((SYS_NET / iface / "speed").read_text())
        return f"{mbit / 1000:g} Gbit/s" if mbit >= 1000 else f"{mbit} Mbit/s"
    except (OSError, ValueError):
        return None


def addresses(iface):
    v4, v6 = [], []
    try:
        for i in json.loads(run(["ip", "-j", "addr", "show", "dev", iface])):
            for a in i.get("addr_info", []):
                if a.get("scope") != "global":
                    continue
                (v4 if a.get("family") == "inet" else v6).append(a["local"])
    except (ValueError, KeyError):
        pass
    return v4, v6


def dns_servers(iface):
    out = run(["resolvectl", "status", iface])
    m = re.search(r"Current DNS Server:\s*(\S+)", out)
    if m:
        return [m.group(1)]
    m = re.search(r"DNS Servers:\s*(.+)", out)
    if m:
        return m.group(1).split()[:2]
    try:
        return [l.split()[1] for l in Path("/etc/resolv.conf").read_text().splitlines()
                if l.startswith("nameserver")][:2]
    except OSError:
        return []


def vpn_interfaces():
    out = []
    for p in SYS_NET.iterdir():
        if p.name.startswith(VPN_PREFIXES):
            try:
                if (p / "operstate").read_text().strip() in ("up", "unknown"):
                    v4, _ = addresses(p.name)
                    out.append((p.name, v4[0] if v4 else ""))
            except OSError:
                pass
    return out


def counters(iface):
    try:
        rx = int((SYS_NET / iface / "statistics/rx_bytes").read_text())
        tx = int((SYS_NET / iface / "statistics/tx_bytes").read_text())
        return rx, tx
    except (OSError, ValueError):
        return None


# ---------------------------------------------------------------- latency (threaded)

ping_lock = threading.Lock()
pings = {"gateway": None, "internet": None, "gateway_host": None}


def ping(host):
    out = run(["ping", "-c", "1", "-W", "1", "-n", host], timeout=3)
    m = re.search(r"time=([\d.]+)", out)
    return float(m.group(1)) if m else False  # False = unreachable


def ping_loop():
    while True:
        with ping_lock:
            gw = pings["gateway_host"]
        if gw is None:  # first sample hasn't found the route yet
            time.sleep(0.5)
            continue
        results = {"gateway": ping(gw), "internet": ping(INTERNET_HOST)}
        with ping_lock:
            pings.update(results)
        time.sleep(PING_INTERVAL)


def fmt_ping(v):
    if v is None:
        return dim("…")
    if v is False:
        return "unreachable"
    return f"{v:.0f} ms"


# ---------------------------------------------------------------- rendering

def build(state):
    iface, gateway = default_route()
    with ping_lock:
        pings["gateway_host"] = gateway
        pg, pi = pings["gateway"], pings["internet"]

    if not iface:
        state["prev"] = None
        return {"text": DISCONNECTED_ICON, "alt": f"{DISCONNECTED_ICON} offline",
                "tooltip": "<b>Disconnected</b>\n\n" + dim("<i>click to open impala</i>"),
                "class": "disconnected"}

    lines = []
    wireless = is_wireless(iface)
    if wireless:
        ssid, security, freq, rssi, quality = wifi_info(iface)
        icon = WIFI_ICONS[round((quality or 0) / 100 * (len(WIFI_ICONS) - 1))]
        meta = [x for x in (security, band(freq)) if x]
        lines.append(f"<b>{escape(ssid or iface)}</b>  {dim('  ·  '.join(escape(m) for m in meta))}")
        sig = []
        if rssi is not None:
            sig.append(f"{rssi} dBm")
        if quality is not None:
            sig.append(f"{quality}% signal")
        lines.append(dim(f"{iface}  ·  " + "  ·  ".join(sig)))
    else:
        icon = ETHERNET_ICON
        speed = link_speed(iface)
        lines.append(f"<b>Ethernet</b>  {dim(iface + ('  ·  ' + speed if speed else ''))}")
    lines.append("")

    v4, v6 = addresses(iface)
    rows = [("ip", ", ".join(v4) or "none")]
    if v6:
        rows.append(("ipv6", v6[0]))
    if gateway:
        rows.append(("gateway", gateway))
    dns = dns_servers(iface)
    if dns:
        rows.append(("dns", ", ".join(dns)))
    for name, addr in vpn_interfaces():
        rows.append(("vpn", f"{name}  {addr}".rstrip()))
    lines += [f"<tt>{dim(k.ljust(8))} {escape(v)}</tt>" for k, v in rows]
    lines.append("")

    # bandwidth
    now = time.monotonic()
    cur = counters(iface)
    prev = state.get("prev")
    down = up = 0.0
    if cur and prev and prev[0] == iface:
        dt = now - prev[1]
        if dt > 0:
            down = max(0, cur[0] - prev[2]) / dt
            up = max(0, cur[1] - prev[3]) / dt
    if cur:
        state["prev"] = (iface, now, cur[0], cur[1])
    hist = state.setdefault("hist", [])
    hist.append(down)
    del hist[:-HISTORY]
    peak = max(hist) or 1
    spark = "".join(BLOCKS[round(v / peak * (len(BLOCKS) - 1))] for v in hist)
    lines.append(f"<tt>{dim('down    ')} {'↓ ' + human_rate(down):>12}  {spark}</tt>")
    lines.append(f"<tt>{dim('up      ')} {'↑ ' + human_rate(up):>12}</tt>")
    if cur:
        lines.append(f"<tt>{dim('total   ')} ↓ {human_size(cur[0])}  ↑ {human_size(cur[1])}  {dim('since boot')}</tt>")
    lines.append(f"<tt>{dim('ping    ')} gateway {fmt_ping(pg)}  ·  internet {fmt_ping(pi)}</tt>")
    lines.append("")
    lines.append(dim("<i>click to open impala</i>"))

    cls = "wifi" if wireless else "ethernet"
    if pi is False:
        cls = "no-internet"
    return {
        "text": icon,
        "alt": f"{icon} ↓ {human_rate(down)} ↑ {human_rate(up)}",
        "tooltip": "\n".join(lines),
        "class": cls,
    }


def main():
    state = {}
    threading.Thread(target=ping_loop, daemon=True).start()
    if "--once" in sys.argv:
        build(state)
        time.sleep(1.5)  # let the counters and the first ping land
        print(json.dumps(build(state)), flush=True)
        return
    while True:
        print(json.dumps(build(state)), flush=True)
        time.sleep(INTERVAL)


if __name__ == "__main__":
    main()
