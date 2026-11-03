#!/usr/bin/env bash
# Check: behaviour. The Deployment rolled out and the Pod is Ready with the sidecar started.
set -uo pipefail

NS=starfleet
wait_for_rollout() {
  kubectl -n "$NS" rollout status deployment/legacy-scout --timeout=150s >/dev/null 2>&1
}
find_pod() {
  kubectl -n "$NS" get pod -l app=legacy-scout --field-selector=status.phase=Running \
    -o jsonpath='{.items[0].metadata.name}' 2>/dev/null
}

if ! wait_for_rollout; then
  echo "FAIL: deployment legacy-scout is not rolled out"
  exit 1
fi
pod="$(find_pod)"
ready="$(kubectl -n "$NS" get pod "$pod" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)"
started="$(kubectl -n "$NS" get pod "$pod" -o jsonpath='{.status.initContainerStatuses[?(@.name=="ambassador")].started}' 2>/dev/null)"
if [ "$ready" != "True" ] || [ "$started" != "true" ]; then
  echo "FAIL: Pod Ready='${ready}', ambassador started='${started}', expected True and true"
  exit 1
fi
echo "PASS: the Pod is Ready and the ambassador sidecar has started"
