#!/usr/bin/env bash
# Behaviour: the running app reports config-complete in its log.
set -uo pipefail

kubectl -n starfleet rollout status deployment/scout --timeout=120s >/dev/null 2>&1 || true
pod="$(kubectl -n starfleet get pod -l app=scout --field-selector=status.phase=Running --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1:].metadata.name}' 2>/dev/null || true)"
if [ -z "$pod" ]; then
  echo "FAIL: no running scout Pod in starfleet"
  exit 1
fi

deadline=$((SECONDS + 60))
while [ "$SECONDS" -lt "$deadline" ]; do
  if kubectl -n starfleet logs "$pod" --tail=5 2>/dev/null | grep -q 'config-complete memory=128Mi'; then
    echo "PASS: the app logs config-complete memory=128Mi"
    exit 0
  fi
  sleep 3
done

echo "FAIL: the app log does not show 'config-complete memory=128Mi'. It reports config-missing until all four files exist"
exit 1
