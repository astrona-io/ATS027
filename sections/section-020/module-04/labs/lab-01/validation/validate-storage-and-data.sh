#!/usr/bin/env bash
# Check: each Pod has a bound claim and data survives deletion of a Pod.
set -uo pipefail

for ordinal in 0 1 2; do
  phase="$(kubectl -n starfleet get pvc "data-shuttle-${ordinal}" -o jsonpath='{.status.phase}' 2>/dev/null || true)"
  if [ "$phase" != "Bound" ]; then
    echo "FAIL: claim data-shuttle-${ordinal} is '${phase}', expected Bound"
    exit 1
  fi
done

marker="$(kubectl -n starfleet exec shuttle-1 -- sh -c 'if [ ! -f /data/grader-marker ]; then echo grader-kept > /data/grader-marker; fi; cat /data/grader-marker' 2>/dev/null || true)"
if [ "$marker" != "grader-kept" ]; then
  echo "FAIL: could not write to /data in shuttle-1"
  exit 1
fi

old_uid="$(kubectl -n starfleet get pod shuttle-1 -o jsonpath='{.metadata.uid}')"
kubectl -n starfleet delete pod shuttle-1 --wait=true >/dev/null 2>&1
if ! kubectl -n starfleet wait --for=condition=Ready pod/shuttle-1 --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: shuttle-1 did not become ready after deletion"
  exit 1
fi
new_uid="$(kubectl -n starfleet get pod shuttle-1 -o jsonpath='{.metadata.uid}')"
if [ "$old_uid" = "$new_uid" ]; then
  echo "FAIL: shuttle-1 was not replaced"
  exit 1
fi

after="$(kubectl -n starfleet exec shuttle-1 -- cat /data/grader-marker 2>/dev/null || true)"
if [ "$after" != "grader-kept" ]; then
  echo "FAIL: data in /data was lost after the Pod was replaced"
  exit 1
fi

echo "PASS: three bound claims and data kept after shuttle-1 was replaced"
