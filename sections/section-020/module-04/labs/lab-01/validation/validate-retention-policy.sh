#!/usr/bin/env bash
# Check: claims are deleted on scale down and kept when the StatefulSet is deleted.
set -uo pipefail

when_scaled="$(kubectl -n starfleet get statefulset shuttle -o jsonpath='{.spec.persistentVolumeClaimRetentionPolicy.whenScaled}' 2>/dev/null || true)"
when_deleted="$(kubectl -n starfleet get statefulset shuttle -o jsonpath='{.spec.persistentVolumeClaimRetentionPolicy.whenDeleted}' 2>/dev/null || true)"

if [ "$when_scaled" != "Delete" ]; then
  echo "FAIL: whenScaled is '${when_scaled}', expected Delete"
  exit 1
fi
if [ "$when_deleted" != "Retain" ]; then
  echo "FAIL: whenDeleted is '${when_deleted}', expected Retain"
  exit 1
fi

echo "PASS: whenScaled Delete and whenDeleted Retain"
