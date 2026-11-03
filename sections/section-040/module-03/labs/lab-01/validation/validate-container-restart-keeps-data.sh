#!/usr/bin/env bash
# Behaviour: stop the container process, wait for the kubelet to restart it in
# the same Pod, and check that /cache/created and the start counter survived.
set -uo pipefail

pod="$(kubectl -n starfleet get pod -l app=shuttle -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
if [ -z "$pod" ]; then
  echo "FAIL: no shuttle Pod found in starfleet"
  exit 1
fi

before="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null || echo 0)"
kubectl -n starfleet exec "$pod" -- kill 1 >/dev/null 2>&1 || true

target=$((before + 1))
deadline=$((SECONDS + 90))
while [ "$SECONDS" -lt "$deadline" ]; do
  now="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null || echo 0)"
  ready="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || true)"
  if [ "${now:-0}" -ge "$target" ] && [ "$ready" = "true" ]; then break; fi
  sleep 2
done

created="$(kubectl -n starfleet exec "$pod" -- cat /cache/created 2>/dev/null || true)"
starts="$(kubectl -n starfleet exec "$pod" -- sh -c 'wc -l < /cache/starts' 2>/dev/null | tr -d ' ' || true)"

if [ "$created" != "$pod" ]; then
  echo "FAIL: /cache/created holds '${created}', expected '${pod}'. Data in /cache did not survive the container restart"
  exit 1
fi
if [ -z "$starts" ] || [ "$starts" -lt 2 ]; then
  echo "FAIL: /cache/starts has '${starts}' lines, expected at least 2 after a container restart"
  exit 1
fi

echo "PASS: /cache data survived a container restart (${starts} starts in the same Pod)"
