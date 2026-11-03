#!/usr/bin/env bash
# Behaviour: delete the Pod, wait for the replacement, and check that the new Pod
# has fresh emptyDir data and its own claim while the old claim is gone.
set -uo pipefail

old="$(kubectl -n starfleet get pod -l app=shuttle -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
if [ -z "$old" ]; then
  echo "FAIL: no shuttle Pod found in starfleet"
  exit 1
fi

kubectl -n starfleet delete pod "$old" --wait=true --timeout=90s >/dev/null 2>&1 || true
kubectl -n starfleet rollout status deployment/shuttle --timeout=180s >/dev/null 2>&1 || true

new="$(kubectl -n starfleet get pod -l app=shuttle --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
if [ -z "$new" ] || [ "$new" = "$old" ]; then
  echo "FAIL: no replacement Pod is running (old '${old}', new '${new}')"
  exit 1
fi

created="$(kubectl -n starfleet exec "$new" -- cat /cache/created 2>/dev/null || true)"
starts="$(kubectl -n starfleet exec "$new" -- sh -c 'wc -l < /cache/starts' 2>/dev/null | tr -d ' ' || true)"
if [ "$created" != "$new" ] || [ "$starts" != "1" ]; then
  echo "FAIL: replacement Pod has /cache/created='${created}' and ${starts} starts, expected '${new}' and 1 (empty emptyDir)"
  exit 1
fi

if kubectl -n starfleet get pvc "${old}-work" >/dev/null 2>&1; then
  echo "FAIL: claim ${old}-work still exists after the Pod was deleted"
  exit 1
fi
if ! kubectl -n starfleet get pvc "${new}-work" >/dev/null 2>&1; then
  echo "FAIL: claim ${new}-work does not exist for the replacement Pod"
  exit 1
fi

echo "PASS: replacement Pod ${new} has an empty /cache and its own claim; ${old}-work was removed"
