#!/usr/bin/env python3
"""Waybar farv theme module.

Prints one JSON line and exits (waybar re-runs it on SIGRTMIN+10, which the
farv hook sends after every theme switch).
  text    - palette icon
  tooltip - current theme, light/dark, background, colour swatches from the
            theme's waybar palette, and click hints

  --pick   open a wofi picker with all themes and switch to the chosen one
"""
import json
import os
import re
import subprocess
import sys
from html import escape
from pathlib import Path

ICON = "\U000F03D8"  # palette
FARV = Path("~/.config/farv/current").expanduser()
WOFI_STYLE = FARV / "wofi-search.css"  # same look as the app launcher
THEME_DIRS = [Path("~/.config/farv/themes").expanduser(), Path("/usr/share/farv/themes")]
SWATCH_KEYS = ("base", "surface", "border", "text")


def dim(s):
    return f"<span alpha='50%'>{s}</span>"


def run(cmd, timeout=15, **kw):
    try:
        return subprocess.run(cmd, capture_output=True, text=True, timeout=timeout, **kw).stdout
    except (OSError, subprocess.TimeoutExpired):
        return ""


def themes():
    """[(name, category)] from `farv list -v`."""
    out = []
    for line in run(["farv", "list", "-v"]).splitlines():
        m = re.match(r"(\S+)\s+\((light|dark)", line)
        if m:
            out.append((m.group(1), m.group(2)))
    return out


def current():
    m = re.match(r"(\S+)\s+\((light|dark)", run(["farv", "current", "-v"]))
    return (m.group(1), m.group(2)) if m else ("unknown", "")


def palette():
    try:
        css = (FARV / "waybar.css").read_text()
    except OSError:
        return []
    return re.findall(r"@define-color\s+(\S+)\s+(#[0-9a-fA-F]{6,8})", css)


def theme_palette(name, category):
    """{colour name: hex} from the theme's own waybar.css, user dir first."""
    for base in THEME_DIRS:
        f = base / category / name / "waybar.css"
        if f.exists():
            try:
                return dict(re.findall(r"@define-color\s+(\S+)\s+(#[0-9a-fA-F]{6,8})", f.read_text()))
            except OSError:
                return {}
    return {}


def swatches(pal):
    return "".join(f"<span foreground='{pal[k]}'>\u2588\u2588</span>" for k in SWATCH_KEYS if k in pal)


def background():
    try:
        return os.path.basename(os.readlink(FARV / "backgrounds/current-background"))
    except OSError:
        return None


def build():
    name, category = current()
    all_themes = themes()
    lines = [f"<b>{escape(name)}</b>  {dim(category)}"]
    meta = [f"{len(all_themes)} themes"]
    bg = background()
    if bg:
        meta.append(f"background {escape(bg)}")
    lines.append(dim("  ·  ".join(meta)))
    lines.append("")
    colors = palette()
    if colors:
        lines.append("<tt>" + " ".join(f"<span foreground='{c}'>██</span>" for _, c in colors) + "</tt>")
        w = max(len(n) for n, _ in colors)
        lines += [f"<tt><span foreground='{c}'>█</span> {dim(n.ljust(w))} {c}</tt>" for n, c in colors]
        lines.append("")
    lines.append(dim("<i>click: pick theme  ·  right: next  ·  middle: random  ·  scroll: background</i>"))
    return {"text": ICON, "tooltip": "\n".join(lines), "class": category or "unknown"}


def pick():
    """wofi picker styled like the app launcher; rows carry each theme's palette."""
    cur, _ = current()
    entries, names = [], []
    for name, category in sorted(themes(), key=lambda t: (t[1] != "dark", t[0])):
        row = f"{escape(name):<20} {swatches(theme_palette(name, category))}  {dim(category)}"
        if name == cur:
            row += "  " + dim("\u25cf current")
        entries.append(row)
        names.append(name)
    cmd = ["wofi", "--show", "dmenu", "--prompt", "Theme...", "--allow-markup", "--insensitive",
           "--cache-file", "/dev/null"]
    if WOFI_STYLE.exists():
        cmd += ["--style", str(WOFI_STYLE)]
    choice = run(cmd, timeout=120, input="\n".join(entries))
    # wofi echoes the chosen line; the theme name is its first token
    tokens = choice.split()
    if not tokens or tokens[0] not in names:
        return
    if tokens[0] != cur:
        subprocess.run(["farv", "use", tokens[0]], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def main():
    if "--pick" in sys.argv:
        pick()
        return
    print(json.dumps(build()), flush=True)


if __name__ == "__main__":
    main()
