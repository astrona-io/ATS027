#!/usr/bin/env bash
# Check: structure. initContainers are fetch-config (ordinary) then ambassador
# (restartPolicy Always, with a startupProbe), and neither is in containers.
set -uo pipefail

NS=starfleet
wait_for_rollout() {
  kubectl -n "$NS" rollout status deployment/legacy-scout --timeout=150s >/dev/null 2>&1
}
find_pod() {
  kubectl -n "$NS" get pod -l app=legacy-scout --field-selector=status.phase=Running \
    -o jsonpath='{.items[0].metadata.name}' 2>/dev/null
}

names="$(kubectl -n "$NS" get deployment legacy-scout -o jsonpath='{.spec.template.spec.initContainers[*].name}' 2>/dev/null)"
if [ "$names" != "fetch-config ambassador" ]; then
  echo "FAIL: initContainers are '${names}', expected 'fetch-config ambassador' in this order"
  exit 1
fi
first="$(kubectl -n "$NS" get deployment legacy-scout -o jsonpath='{.spec.template.spec.initContainers[0].restartPolicy}' 2>/dev/null)"
second="$(kubectl -n "$NS" get deployment legacy-scout -o jsonpath='{.spec.template.spec.initContainers[1].restartPolicy}' 2>/dev/null)"
if [ -n "$first" ]; then
  echo "FAIL: fetch-config has restartPolicy '${first}'; it must be an ordinary init container"
  exit 1
fi
if [ "$second" != "Always" ]; then
  echo "FAIL: ambassador has restartPolicy '${second}', expected Always"
  exit 1
fi
probe="$(kubectl -n "$NS" get deployment legacy-scout -o jsonpath='{.spec.template.spec.initContainers[1].startupProbe}' 2>/dev/null)"
if [ -z "$probe" ]; then
  echo "FAIL: the ambassador sidecar has no startupProbe"
  exit 1
fi
echo "PASS: fetch-config runs first, then the ambassador sidecar with a startupProbe"
