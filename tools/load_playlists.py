#!/usr/bin/env python3
"""
    python3 load_playlists.py <playlist_dir> <sqlite_db>
"""

import os
import re
import sqlite3
import sys
from datetime import datetime, timezone


TOP_LEVEL_PLAYLISTS = ["id.m3u", "lnr.m3u", "pro.m3u", "psa.m3u", "soo.m3u"]

TIMESLOT_RE = re.compile(r"^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)-\d{4}\.m3u$")


def utc_now():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def category_name_from_filename(filename):
    return os.path.splitext(filename)[0]


def parse_m3u(path):
    entries = []
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#"):
                entries.append(line)
    return entries


def insert_category(cur, name, now):
    cur.execute(
        "INSERT INTO categories (name, inserted_at, updated_at) VALUES (?, ?, ?)",
        (name, now, now),
    )
    return cur.lastrowid


def insert_entries(cur, category_id, paths, now):
    cur.executemany(
        "INSERT INTO entries (path, category_id, inserted_at, updated_at) VALUES (?, ?, ?, ?)",
        [(p, category_id, now, now) for p in paths],
    )


def load_playlist(cur, playlist_path, category_name, now):
    entries = parse_m3u(playlist_path)
    if not entries:
        print(f"  Skipping {category_name}: no entries")
        return
    cat_id = insert_category(cur, category_name, now)
    insert_entries(cur, cat_id, entries, now)
    print(f"  {category_name}: {len(entries)} entries")


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <playlist_dir> <sqlite_db>")
        sys.exit(1)

    playlist_dir = sys.argv[1]
    db_path = sys.argv[2]
    now = utc_now()

    conn = sqlite3.connect(db_path)
    cur = conn.cursor()

    print("Loading top-level playlists:")
    for filename in TOP_LEVEL_PLAYLISTS:
        path = os.path.join(playlist_dir, filename)
        if os.path.isfile(path):
            load_playlist(cur, path, category_name_from_filename(filename), now)
        else:
            print(f"  Warning: {path} not found, skipping")

    default_dir = os.path.join(playlist_dir, "default")
    if os.path.isdir(default_dir):
        print("Loading genre playlists from default/:")
        for filename in sorted(os.listdir(default_dir)):
            if not filename.endswith(".m3u"):
                continue
            if TIMESLOT_RE.match(filename):
                continue
            path = os.path.join(default_dir, filename)
            load_playlist(cur, path, category_name_from_filename(filename), now)
    else:
        print(f"Warning: {default_dir} not found, skipping genre playlists")

    conn.commit()
    conn.close()
    print("Done.")


if __name__ == "__main__":
    main()
