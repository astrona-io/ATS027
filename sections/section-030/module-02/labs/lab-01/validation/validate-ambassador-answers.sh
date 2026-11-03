#!/usr/bin/env bash
# Check: behaviour. The legacy container gets the probe answer on 127.0.0.1:9000.
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
answer=""
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  answer="$(kubectl -n "$NS" exec "$pod" -c legacy -- wget -q -T 3 -O - http://127.0.0.1:9000/ 2>/dev/null || true)"
  [ "$answer" = "probe-nominal" ] && break
  sleep 3
done
if [ "$answer" != "probe-nominal" ]; then
  echo "FAIL: http://127.0.0.1:9000/ from the legacy container returned '${answer}', expected 'probe-nominal'"
  exit 1
fi
echo "PASS: the legacy container reaches the probe Service through localhost:9000"
