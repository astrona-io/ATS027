#!/usr/bin/env bash
# Check: behaviour. /shared/upstream.txt holds the probe Service address and the
# ambassador container can read it.
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
upstream="$(kubectl -n "$NS" exec "$pod" -c ambassador -- cat /shared/upstream.txt 2>/dev/null || true)"
case "$upstream" in
  *probe.starfleet*) echo "PASS: /shared/upstream.txt holds '${upstream}'" ;;
  *) echo "FAIL: /shared/upstream.txt in the ambassador container holds '${upstream}', expected the probe Service in starfleet"; exit 1 ;;
esac
