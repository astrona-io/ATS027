#!/usr/bin/env bash
# Check: behaviour. The adapter prints the report as JSON lines.
set -uo pipefail

NS=starfleet
wait_for_rollout() {
  kubectl -n "$NS" rollout status deployment/legacy-scout --timeout=120s >/dev/null 2>&1
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
logs=""
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  logs="$(kubectl -n "$NS" logs "$pod" -c adapter 2>/dev/null || true)"
  case "$logs" in *'{"status":"ok"}'*) break ;; esac
  sleep 5
done
case "$logs" in
  *'{"status":"ok"}'*) echo "PASS: the adapter container prints {\"status\":\"ok\"} lines" ;;
  *) echo "FAIL: the logs of the adapter container have no {\"status\":\"ok\"} line"; exit 1 ;;
esac
