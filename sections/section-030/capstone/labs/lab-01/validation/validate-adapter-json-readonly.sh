#!/usr/bin/env bash
# Check: behaviour and structure. The adapter prints JSON lines and mounts the report read-only.
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
flags="$(kubectl -n "$NS" get deployment legacy-scout -o jsonpath='{.spec.template.spec.containers[?(@.name=="adapter")].volumeMounts[*].readOnly}' 2>/dev/null)"
if [ -z "$flags" ]; then
  echo "FAIL: no container named adapter with volume mounts in the Pod template"
  exit 1
fi
for flag in $flags; do
  if [ "$flag" != "true" ]; then
    echo "FAIL: the adapter container has a volume mount that is not read-only"
    exit 1
  fi
done
pod="$(find_pod)"
logs=""
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  logs="$(kubectl -n "$NS" logs "$pod" -c adapter 2>/dev/null || true)"
  case "$logs" in *'{"status":"ok"}'*) break ;; esac
  sleep 5
done
case "$logs" in
  *'{"status":"ok"}'*) echo "PASS: the adapter prints JSON lines from a read-only mount" ;;
  *) echo "FAIL: the logs of the adapter container have no {\"status\":\"ok\"} line"; exit 1 ;;
esac
