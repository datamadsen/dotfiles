#!/usr/bin/env python3
"""Waybar clock with an informative tooltip.

Long-running: prints one JSON line per minute, aligned to the minute boundary.
  text    - "Sat Sep 05 14:32"
  alt     - same plus ISO week and year (shown on right-click via format-alt)
  tooltip - full date, month calendar with today marked, day-of-year,
            "On this day" events from Wikipedia (fetched once a day, cached),
            and a hint that clicking opens the calendar.

Run with --once to print a single line and exit (handy for testing).
"""
import calendar
import datetime as dt
import json
import random
import re
import sys
import textwrap
import time
import urllib.request
from html import escape
from pathlib import Path
import os

CACHE = Path(os.environ.get("XDG_CACHE_HOME", "~/.cache")).expanduser() / "waybar-onthisday.json"
WIKI_URL = "https://en.wikipedia.org/api/rest_v1/feed/onthisday/selected/{:%m/%d}"
EVENTS_SHOWN = 3
WRAP = 64

_last_fetch_attempt = 0.0


def dim(s):
    return f"<span alpha='50%'>{s}</span>"


def month_calendar(today):
    """Monday-first month grid with ISO week numbers and today highlighted."""
    cal = calendar.Calendar(firstweekday=0)
    lines = [f"    {today:%B %Y}".rstrip(), dim("wk") + "  Mo Tu We Th Fr Sa Su"]
    for week in cal.monthdatescalendar(today.year, today.month):
        cells = []
        for d in week:
            if d.month != today.month:
                cells.append("  ")
            elif d == today:
                cells.append(f"<b><u>{d.day:2d}</u></b>")
            else:
                cells.append(f"{d.day:2d}")
        wk = dim(f"{week[0].isocalendar()[1]:2d}")
        lines.append(f"{wk}  " + " ".join(cells))
    return "\n".join(lines)


def on_this_day(today):
    """Return a list of {'year', 'text'} for today, or None if unavailable."""
    global _last_fetch_attempt
    try:
        data = json.loads(CACHE.read_text())
        if data.get("date") == today.isoformat():
            return data["events"]
    except (OSError, ValueError, KeyError):
        pass
    # Don't hammer the API while offline: retry at most every 15 minutes
    if time.time() - _last_fetch_attempt < 900:
        return None
    _last_fetch_attempt = time.time()
    try:
        req = urllib.request.Request(
            WIKI_URL.format(today),
            headers={"User-Agent": "waybar-clock/1.0 (personal desktop status bar)"},
        )
        with urllib.request.urlopen(req, timeout=10) as resp:
            raw = json.load(resp).get("selected", [])
    except Exception:
        return None
    events = [
        {"year": e["year"], "text": re.sub(r"\s*\(pictured\)", "", e["text"])}
        for e in raw if e.get("year") and e.get("text")
    ]
    try:
        CACHE.parent.mkdir(parents=True, exist_ok=True)
        CACHE.write_text(json.dumps({"date": today.isoformat(), "events": events}))
    except OSError:
        pass
    return events


def format_events(events, today):
    if not events:
        return dim("On this day: nothing fetched yet (offline?)")
    # Stable random pick per day, oldest first
    rng = random.Random(today.toordinal())
    picked = sorted(rng.sample(events, min(EVENTS_SHOWN, len(events))), key=lambda e: e["year"])
    out = ["<b>On this day</b>"]
    for e in picked:
        year = f"{e['year']:>5}"
        body = textwrap.wrap(re.sub(r"\s*\(pictured\)", "", e["text"]), WRAP)
        out.append(f"<tt>{dim(year)}</tt>  {escape(body[0], quote=False)}")
        out.extend(f"<tt>       </tt>  {escape(line, quote=False)}" for line in body[1:])
    return "\n".join(out)


def build(now):
    today = now.date()
    day_of_year = today.timetuple().tm_yday
    days_in_year = 366 if calendar.isleap(today.year) else 365
    header = f"<b>{today:%A, %-d %B %Y}</b>"
    meta = dim(f"week {today.isocalendar()[1]}  ·  day {day_of_year} of {days_in_year}")
    tooltip = "\n".join([
        header,
        meta,
        "",
        f"<tt>{month_calendar(today)}</tt>",
        "",
        format_events(on_this_day(today), today),
        "",
        dim("<i>click to open the calendar</i>"),
    ])
    return {
        "text": f"{now:%a %b %d %H:%M}",
        "alt": f"{now:%a %b %d %H:%M · W%V %Y}",
        "tooltip": tooltip,
    }


def emit(now):
    print(json.dumps(build(now)), flush=True)


def main():
    if "--once" in sys.argv:
        emit(dt.datetime.now())
        return
    while True:
        emit(dt.datetime.now())
        time.sleep(60 - time.time() % 60 + 0.05)


if __name__ == "__main__":
    main()
