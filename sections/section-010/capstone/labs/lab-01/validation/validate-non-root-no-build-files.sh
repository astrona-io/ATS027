#!/usr/bin/env bash
# Check: the running scout container is non-root and has no build-only files.
set -uo pipefail
uid="$(kubectl -n starfleet exec deploy/scout -c web -- id -u 2>/dev/null || true)"
if [ -z "$uid" ]; then
  echo "FAIL: could not read the user ID in a scout container"
  exit 1
fi
if [ "$uid" = "0" ]; then
  echo "FAIL: the scout container runs as user 0"
  exit 1
fi
found="$(kubectl -n starfleet exec deploy/scout -c web -- find / -xdev \( -name render.sh -o -name catalog.txt -o -name build-notes.txt \) 2>/dev/null || true)"
if [ -n "$found" ]; then
  echo "FAIL: build-only files exist in the running container: ${found}"
  exit 1
fi
echo "PASS: the scout container runs as user ${uid} and holds no build-only files"
