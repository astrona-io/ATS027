#!/usr/bin/env bash
# Check: the container process runs as a non-zero user ID.
set -uo pipefail
uid="$(kubectl -n starfleet exec site -c web -- id -u 2>/dev/null || true)"
if [ -z "$uid" ]; then
  echo "FAIL: could not read the user ID in the container"
  exit 1
fi
if [ "$uid" = "0" ]; then
  echo "FAIL: the container runs as user 0"
  exit 1
fi
echo "PASS: the container runs as user ${uid}"
