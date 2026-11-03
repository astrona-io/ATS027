#!/usr/bin/env bash
# Check: behaviour. The application itself now records success in its report.
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
report=""
for attempt in 1 2 3 4 5 6 7 8 9 10 11 12; do
  report="$(kubectl -n "$NS" exec "$pod" -c legacy -- tail -n 6 /report/report.txt 2>/dev/null || true)"
  case "$report" in *status=ok*) break ;; esac
  sleep 5
done
case "$report" in
  *status=ok*) echo "PASS: the report of the legacy container contains status=ok" ;;
  *) echo "FAIL: no status=ok line in the report of the legacy container"; exit 1 ;;
esac
