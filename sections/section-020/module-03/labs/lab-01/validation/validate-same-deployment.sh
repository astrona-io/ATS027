#!/usr/bin/env bash
# Check: the original Deployment was repaired, not deleted and re-created, and
# its history shows at least the rollout, the bad release and the repair.
set -uo pipefail

original="$(kubectl -n starfleet get configmap lab-meta -o jsonpath='{.data.probe-uid}' 2>/dev/null || true)"
current="$(kubectl -n starfleet get deployment probe -o jsonpath='{.metadata.uid}' 2>/dev/null || true)"
if [ -z "$original" ] || [ "$original" != "$current" ]; then
  echo "FAIL: the probe Deployment was deleted and created again"
  exit 1
fi

revision="$(kubectl -n starfleet get deployment probe -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}' 2>/dev/null || true)"
if [ -z "$revision" ] || [ "$revision" -lt 3 ]; then
  echo "FAIL: Deployment revision is '${revision}', expected 3 or higher"
  exit 1
fi

echo "PASS: the original Deployment was repaired (revision ${revision})"
