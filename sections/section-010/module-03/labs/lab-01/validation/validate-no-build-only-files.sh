#!/usr/bin/env bash
# Check: the running container has none of the build-only files.
set -uo pipefail
found="$(kubectl -n starfleet exec site -c web -- find / -xdev \( -name render.sh -o -name catalog.txt -o -name build-notes.txt \) 2>/dev/null || true)"
if [ -n "$found" ]; then
  echo "FAIL: build-only files exist in the running container: ${found}"
  exit 1
fi
echo "PASS: render.sh, catalog.txt and build-notes.txt are not in the running container"
