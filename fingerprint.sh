#!/bin/sh
# Prints a short hash of what the command center depends on: the names of the top-level
# workflow folders (a folder with both CLAUDE.md and CONTEXT.md, not starting with _).
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
# sha1sum on Linux and Git Bash; macOS ships shasum instead.
if command -v sha1sum >/dev/null 2>&1; then SHA1="sha1sum"; else SHA1="shasum -a 1"; fi
{
for d in "$ROOT"/*/; do
  n="$(basename "$d")"
  case "$n" in _*) continue;; esac
  [ -f "$d/CLAUDE.md" ] && [ -f "$d/CONTEXT.md" ] && echo "$n"
  done
} | $SHA1 | cut -c1-12
