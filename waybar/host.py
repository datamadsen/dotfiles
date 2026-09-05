#!/usr/bin/env python3
"""Waybar hostname module with a machine-health tooltip.

Long-running: refreshes every INTERVAL seconds and prints one JSON line.
  text    - icon + hostname (icon per machine, see ICONS)
  tooltip - OS/kernel/Hyprland/Waybar versions, IP addresses, disk usage,
            pending package updates (checked every UPDATE_INTERVAL in a
            background thread), failed systemd units, whether a reboot is
            needed, and the state of the dotfiles repo.
  class   - "attention" when something needs a look (failed unit, reboot
            needed, disk nearly full); otherwise "ok".

  --once   print one line and exit
  --click  open a terminal on the most relevant thing (failed units, or a
           system upgrade). Add --dry-run to just print the command.
"""
import json
import os
import re
import shutil
import socket
import subprocess
import sys
import threading
import time
from html import escape
from pathlib import Path

ICONS = {"defiant": "\U000F0322", "enterprise": "\U000F048B"}  # laptop, server
INTERVAL = 60
UPDATE_INTERVAL = 30 * 60
DISK_WARN_PCT = 90
DOTFILES = Path("~/dotfiles").expanduser()
CACHE = Path(os.environ.get("XDG_CACHE_HOME", "~/.cache")).expanduser() / "waybar-host-updates.json"
TERMINAL = ["alacritty", "-e"]


def dim(s):
    return f"<span alpha='50%'>{s}</span>"


def accent_color():
    """Accent colour from the current farv theme, for highlighting warnings."""
    try:
        css = Path("~/.config/farv/current/waybar.css").expanduser().read_text()
        m = re.search(r"@define-color\s+border\s+(#[0-9a-fA-F]{6,8})", css)
        return m.group(1) if m else None
    except OSError:
        return None


ACCENT = accent_color()


def warn(s):
    return f"<span foreground='{ACCENT}'>{s}</span>" if ACCENT else f"<b>{s}</b>"


def bar(frac, width):
    filled = round(min(max(frac, 0.0), 1.0) * width)
    return "█" * filled + dim("░" * (width - filled))


def run(cmd, timeout=10):
    try:
        return subprocess.run(cmd, capture_output=True, text=True, timeout=timeout).stdout
    except (OSError, subprocess.TimeoutExpired):
        return ""


def gib(n):
    return f"{n / 2**30:.0f}"


# ---------------------------------------------------------------- facts

def hostname():
    return socket.gethostname()


def versions():
    os_name = "Linux"
    try:
        for line in Path("/etc/os-release").read_text().splitlines():
            if line.startswith("PRETTY_NAME="):
                os_name = line.split("=", 1)[1].strip('"')
    except OSError:
        pass
    parts = [os_name, os.uname().release]
    try:
        parts.append("Hyprland " + json.loads(run(["hyprctl", "-j", "version"]))["tag"].lstrip("v"))
    except (ValueError, KeyError):
        pass
    m = re.search(r"Waybar v(\S+?)(?:-g[0-9a-f]+)?\s", run(["waybar", "--version"]) + " ")
    if m:
        parts.append("Waybar " + m.group(1))
    return parts


def addresses():
    try:
        data = json.loads(run(["ip", "-4", "-j", "addr"]))
    except ValueError:
        return []
    return [(i["ifname"], a["local"]) for i in data for a in i.get("addr_info", [])
            if a.get("scope") == "global"]


def disks():
    seen, out = set(), []
    for line in Path("/proc/mounts").read_text().splitlines():
        dev, mnt, fstype = line.split()[:3]
        if fstype not in ("ext4", "btrfs", "xfs", "f2fs") or dev in seen:
            continue
        seen.add(dev)
        st = os.statvfs(mnt)
        # Same maths as df: reserved blocks count as used, not available
        used = (st.f_blocks - st.f_bfree) * st.f_frsize
        avail = st.f_bavail * st.f_frsize
        out.append((mnt, used, used + avail))
    return out


def failed_units():
    out = []
    for scope in ([], ["--user"]):
        text = run(["systemctl", *scope, "--failed", "--no-legend", "--plain"])
        out += [(("user " if scope else "") + l.split()[0]) for l in text.splitlines() if l.strip()]
    return out


def reboot_needed():
    """True when the running kernel's modules dir is gone, i.e. the kernel was upgraded."""
    return not Path("/usr/lib/modules", os.uname().release).is_dir()


def last_upgrade():
    try:
        stamp = None
        for line in Path("/var/log/pacman.log").read_text(errors="replace").splitlines():
            if "starting full system upgrade" in line:
                stamp = line[1:17]
        if stamp:
            return time.strftime("%-d %b %H:%M", time.strptime(stamp, "%Y-%m-%dT%H:%M"))
    except (OSError, ValueError):
        pass
    return None


def dotfiles():
    if not (DOTFILES / ".git").exists():
        return None
    g = ["git", "-C", str(DOTFILES)]
    branch = run(g + ["rev-parse", "--abbrev-ref", "HEAD"]).strip()
    dirty = len([l for l in run(g + ["status", "--porcelain"]).splitlines() if l.strip()])
    ahead = run(g + ["rev-list", "--count", "@{u}..HEAD"]).strip()
    return branch, dirty, int(ahead) if ahead.isdigit() else 0


# ---------------------------------------------------------------- updates (slow, threaded)

updates_lock = threading.Lock()
updates = {"count": None, "names": [], "checked": 0.0}


def load_update_cache():
    try:
        data = json.loads(CACHE.read_text())
        if time.time() - data.get("checked", 0) < UPDATE_INTERVAL:
            updates.update(data)
    except (OSError, ValueError):
        pass


def check_updates():
    if shutil.which("checkupdates"):
        cmd = ["checkupdates"]
    elif shutil.which("yay"):
        cmd = ["yay", "-Qu"]
    else:
        cmd = ["pacman", "-Qu"]
    names = [l.split()[0] for l in run(cmd, timeout=120).splitlines() if l.strip()]
    with updates_lock:
        updates.update({"count": len(names), "names": names[:6], "checked": time.time()})
        try:
            CACHE.parent.mkdir(parents=True, exist_ok=True)
            CACHE.write_text(json.dumps(updates))
        except OSError:
            pass


def maybe_check_updates():
    if time.time() - updates["checked"] >= UPDATE_INTERVAL:
        updates["checked"] = time.time()  # don't re-spawn while a check is running
        threading.Thread(target=check_updates, daemon=True).start()


# ---------------------------------------------------------------- rendering

def build():
    host = hostname()
    icon = ICONS.get(host)
    text = f"{icon} {host}" if icon else f"@{host}"
    attention = []

    lines = [f"<b>{escape(host)}</b>", dim("  ·  ".join(escape(p) for p in versions())), ""]

    addrs = addresses()
    if addrs:
        w = max(len(i) for i, _ in addrs)
        lines += [f"<tt>{dim(i.ljust(w))}  {a}</tt>" for i, a in addrs]
        lines.append("")

    for mnt, used, total in disks():
        pct = used / total * 100
        label = f"{pct:.0f}%"
        if pct >= DISK_WARN_PCT:
            label = warn(label)
            attention.append(f"{mnt} is {pct:.0f}% full")
        lines.append(f"<tt>{dim(mnt.ljust(6))} {bar(used / total, 20)} {gib(used):>4} / {gib(total)} GiB  {label}</tt>")
    lines.append("")

    lines.append("<b>Status</b>")
    with updates_lock:
        count, names = updates["count"], updates["names"]
    last = last_upgrade()
    if count is None:
        upd = dim("checking…")
    elif count == 0:
        upd = "up to date"
    else:
        upd = f"{count} pending" + dim("  " + ", ".join(names) + ("…" if count > len(names) else ""))
    if last:
        upd += dim(f"  ·  last upgrade {last}")
    lines.append(f"<tt>{dim('updates ')}</tt> {upd}")

    failed = failed_units()
    if failed:
        lines.append(f"<tt>{dim('services')}</tt> {warn(f'{len(failed)} failed')}  {', '.join(escape(f) for f in failed)}")
        attention.append("failed unit" + ("s" if len(failed) > 1 else ""))
    else:
        lines.append(f"<tt>{dim('services')}</tt> all running")

    if reboot_needed():
        lines.append(f"<tt>{dim('kernel  ')}</tt> {warn('reboot needed')}  {dim('running ' + os.uname().release)}")
        attention.append("reboot needed")
    else:
        lines.append(f"<tt>{dim('kernel  ')}</tt> up to date")

    df = dotfiles()
    if df:
        branch, dirty, ahead = df
        state = []
        if dirty:
            state.append(f"{dirty} modified")
        if ahead:
            state.append(f"{ahead} unpushed")
        lines.append(f"<tt>{dim('dotfiles')}</tt> {'  ·  '.join(state) if state else 'clean'}  {dim(branch)}")

    lines.append("")
    if failed:
        hint = "click to inspect failed units"
    elif count:
        hint = "click to upgrade"
    else:
        hint = "click to run a system upgrade"
    lines.append(dim(f"<i>{hint}</i>"))

    return {
        "text": text,
        "tooltip": "\n".join(lines),
        "class": "attention" if attention else "ok",
    }


def click(dry_run):
    if failed_units():
        cmd = TERMINAL + ["sh", "-c",
                          "systemctl --failed; echo; systemctl --user --failed; echo; "
                          "echo 'press any key to close'; read -rsn1"]
    else:
        cmd = TERMINAL + ["sh", "-c", "yay -Syu; echo; echo 'press any key to close'; read -rsn1"]
    if dry_run:
        print(" ".join(cmd))
        return
    subprocess.Popen(cmd, start_new_session=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def main():
    if "--click" in sys.argv:
        click("--dry-run" in sys.argv)
        return
    load_update_cache()
    if "--once" in sys.argv:
        if updates["count"] is None:
            check_updates()
        print(json.dumps(build()), flush=True)
        return
    while True:
        maybe_check_updates()
        print(json.dumps(build()), flush=True)
        time.sleep(INTERVAL)


if __name__ == "__main__":
    main()
