#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ $# -gt 0 ]]; then
  SOURCE_ROOT="$1"
elif [[ -n "${CODEX_SKILLS_SOURCE:-}" ]]; then
  SOURCE_ROOT="$CODEX_SKILLS_SOURCE"
else
  SOURCE_ROOT="$REPO_ROOT/../skills"
fi
SOURCE_ROOT="$(cd -- "$SOURCE_ROOT" && pwd)"

if [[ ! -d "$SOURCE_ROOT" ]]; then
  printf 'Source directory does not exist: %s\n' "$SOURCE_ROOT" >&2
  exit 2
fi
if [[ -n "$(git -C "$REPO_ROOT" status --porcelain)" ]]; then
  printf 'Destination has uncommitted changes; commit or stash them before syncing.\n' >&2
  exit 2
fi

git -C "$REPO_ROOT" remote set-url --push origin git@github.com:TRUSOGEN/Codex-skills.git
git -C "$REPO_ROOT" pull --ff-only origin main
rsync -a --delete \
  --exclude='.git/' \
  --exclude='.DS_Store' \
  --exclude='/README.md' \
  --exclude='/SOURCE_MANIFEST.csv' \
  --exclude='/scripts/sync_from_local.sh' \
  "$SOURCE_ROOT/" "$REPO_ROOT/"

python3 - "$SOURCE_ROOT" "$REPO_ROOT" <<'PY'
"""Write source modification times and content checksums for the synced tree."""
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo
import csv
import hashlib
import os
import sys

source_root = Path(sys.argv[1])
repo_root = Path(sys.argv[2])
manifest = repo_root / "SOURCE_MANIFEST.csv"
snapshot = datetime.now(ZoneInfo("Australia/Sydney")).isoformat(timespec="seconds")
rows = []
old_rows = {}
if manifest.is_file():
    with manifest.open(encoding="utf-8", newline="") as stream:
        old_rows = {row["path"]: row for row in csv.DictReader(stream)}
managed = {"README.md", ".gitattributes", "SOURCE_MANIFEST.csv"}
managed.add("scripts/sync_from_local.sh")

def local_time(path: Path) -> str:
    """Format a file modification time in the user's Sydney timezone."""
    stat = path.lstat() if path.is_symlink() else path.stat()
    return datetime.fromtimestamp(stat.st_mtime, ZoneInfo("Australia/Sydney")).isoformat(timespec="seconds")

for path in sorted(repo_root.rglob("*")):
    if (not path.is_file() and not path.is_symlink()) or path == manifest or ".git" in path.parts:
        continue
    relative = path.relative_to(repo_root)
    source_path = source_root / relative
    is_source = relative.as_posix() not in managed and (source_path.is_file() or source_path.is_symlink())
    link_target = os.readlink(path) if path.is_symlink() else ""
    data = link_target.encode("utf-8") if path.is_symlink() else path.read_bytes()
    row = {
        "path": relative.as_posix(),
        "entry_type": "symlink" if path.is_symlink() else "file",
        "link_target": link_target,
        "source_modified_at_sydney": local_time(source_path) if is_source else "",
        "size_bytes": len(data),
        "sha256": hashlib.sha256(data).hexdigest(),
    }
    previous = old_rows.get(row["path"], {})
    unchanged = all(previous.get(key) == value for key, value in row.items())
    row["snapshot_at_sydney"] = previous.get("snapshot_at_sydney", snapshot) if unchanged else snapshot
    rows.append(row)

tracked_fields = ("path", "entry_type", "link_target", "source_modified_at_sydney", "size_bytes", "sha256")
manifest_changed = len(rows) != len(old_rows) or any(
    any(old_rows.get(row["path"], {}).get(key) != row[key] for key in tracked_fields)
    for row in rows
)
if manifest_changed:
    with manifest.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=list(rows[0]), lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)
    print(f"Updated {manifest.name}: {len(rows)} files at {snapshot}")
else:
    print(f"No source changes in {len(rows)} files.")
PY

git -C "$REPO_ROOT" add -A
if git -C "$REPO_ROOT" diff --cached --quiet; then
  printf 'No skill file changes to sync.\n'
  exit 0
fi
SYNC_DATE="$(TZ=Australia/Sydney date '+%Y-%m-%d %H:%M %Z')"
git -C "$REPO_ROOT" commit -m "Sync local skills snapshot $SYNC_DATE"
git -C "$REPO_ROOT" push origin main
