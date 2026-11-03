#!/usr/bin/env bash
# Check: the Deployment is the original object and has been updated at least once.
set -uo pipefail
original="$(kubectl -n starfleet get configmap lab-baseline -o jsonpath='{.data.deployment-uid}' 2>/dev/null)"
current="$(kubectl -n starfleet get deployment probe -o jsonpath='{.metadata.uid}' 2>/dev/null)"
if [ -z "$original" ] || [ "$original" != "$current" ]; then
  echo "FAIL: Deployment probe was deleted and recreated; update the existing object"
  exit 1
fi
revision="$(kubectl -n starfleet get deployment probe -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}' 2>/dev/null)"
if [ -z "$revision" ] || [ "$revision" -lt 2 ]; then
  echo "FAIL: the Deployment is still on revision '${revision}'"
  exit 1
fi
echo "PASS: the original Deployment is on revision ${revision}"
