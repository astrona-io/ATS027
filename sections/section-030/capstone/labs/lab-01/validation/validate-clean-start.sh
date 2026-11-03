#!/usr/bin/env bash
# Check: behaviour. The legacy container never failed a call: the sidecar was
# ready before the application started.
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
report=""
for attempt in 1 2 3 4 5 6 7 8 9 10 11 12; do
  report="$(kubectl -n "$NS" exec "$pod" -c legacy -- cat /report/report.txt 2>/dev/null || true)"
  case "$report" in *status=ok*) break ;; esac
  sleep 5
done
case "$report" in
  *status=ok*) ;;
  *) echo "FAIL: the report of the legacy container has no status=ok line"; exit 1 ;;
esac
case "$report" in
  *status=error*) echo "FAIL: the report contains status=error, so the application started before the proxy was ready"; exit 1 ;;
esac
echo "PASS: the report has status=ok lines and no status=error line"
