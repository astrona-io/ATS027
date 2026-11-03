#!/usr/bin/env bash
# Check: behaviour. A rollout finishes and the available replicas never drop below 3.
set -uo pipefail

if ! kubectl -n starfleet get deployment scout-web >/dev/null 2>&1; then
  echo "FAIL: Deployment scout-web not found in starfleet"
  exit 1
fi

stamp="$(date +%s)"
if ! kubectl -n starfleet patch deployment scout-web --type merge \
  -p "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"grader-rollout\":\"$stamp\"}}}}}" >/dev/null 2>&1; then
  echo "FAIL: could not trigger a rollout of scout-web"
  exit 1
fi

for _ in $(seq 1 150); do
  available="$(kubectl -n starfleet get deployment scout-web -o jsonpath='{.status.availableReplicas}' 2>/dev/null)"
  if [ "${available:-0}" -lt 3 ]; then
    echo "FAIL: available replicas dropped to ${available:-0} during the rollout"
    exit 1
  fi
  if kubectl -n starfleet rollout status deployment/scout-web --timeout=1s >/dev/null 2>&1; then
    echo "PASS: the rollout finished and available replicas stayed at 3 or more"
    exit 0
  fi
  sleep 1
done

echo "FAIL: the rollout of scout-web did not finish within 150 seconds"
exit 1
