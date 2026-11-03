#!/usr/bin/env bash
# Check: the running shuttle Pod has a memory-backed emptyDir named cache with
# a 64Mi size limit mounted at /cache.
set -uo pipefail

pod="$(kubectl -n starfleet get pod -l app=shuttle -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
if [ -z "$pod" ]; then
  echo "FAIL: no shuttle Pod found in starfleet"
  exit 1
fi

medium="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.spec.volumes[?(@.name=="cache")].emptyDir.medium}' 2>/dev/null || true)"
limit="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.spec.volumes[?(@.name=="cache")].emptyDir.sizeLimit}' 2>/dev/null || true)"
mount="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.spec.containers[?(@.name=="app")].volumeMounts[?(@.name=="cache")].mountPath}' 2>/dev/null || true)"

if [ "$medium" != "Memory" ]; then
  echo "FAIL: volume cache has medium '${medium}', expected Memory"
  exit 1
fi
if [ "$limit" != "64Mi" ]; then
  echo "FAIL: volume cache has sizeLimit '${limit}', expected 64Mi"
  exit 1
fi
if [ "$mount" != "/cache" ]; then
  echo "FAIL: volume cache is mounted at '${mount}', expected /cache"
  exit 1
fi

echo "PASS: memory-backed emptyDir cache (64Mi) mounted at /cache"
