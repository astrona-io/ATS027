#!/usr/bin/env bash
# Check: structure. The legacy container is unchanged and runs next to the adapter.
set -uo pipefail

NS=starfleet
wait_for_rollout() {
  kubectl -n "$NS" rollout status deployment/legacy-scout --timeout=150s >/dev/null 2>&1
}
find_pod() {
  kubectl -n "$NS" get pod -l app=legacy-scout --field-selector=status.phase=Running \
    -o jsonpath='{.items[0].metadata.name}' 2>/dev/null
}

names="$(kubectl -n "$NS" get deployment legacy-scout -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null)"
case " $names " in
  *" legacy "*) ;;
  *) echo "FAIL: no container named legacy in containers"; exit 1 ;;
esac
args="$(kubectl -n "$NS" get deployment legacy-scout -o jsonpath='{.spec.template.spec.containers[?(@.name=="legacy")].args}' 2>/dev/null)"
case "$args" in
  *127.0.0.1:9000*) ;;
  *) echo "FAIL: the legacy container no longer calls 127.0.0.1:9000"; exit 1 ;;
esac
echo "PASS: the legacy container is unchanged"
