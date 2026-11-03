#!/usr/bin/env bash
# Check: the files inside the running container have the required modes.
set -uo pipefail

kubectl -n starfleet rollout status deployment/scout --timeout=120s >/dev/null 2>&1 || true
pod="$(kubectl -n starfleet get pod -l app=scout --field-selector=status.phase=Running --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1:].metadata.name}' 2>/dev/null || true)"
if [ -z "$pod" ]; then
  echo "FAIL: no running scout Pod in starfleet"
  exit 1
fi

settings="$(kubectl -n starfleet exec "$pod" -- stat -L -c '%a' /etc/scout/settings/app.properties 2>/dev/null || true)"
secret="$(kubectl -n starfleet exec "$pod" -- stat -L -c '%a' /etc/scout/secret/api-key 2>/dev/null || true)"

if [ "$settings" != "444" ]; then echo "FAIL: settings/app.properties has mode '${settings}', expected 444"; exit 1; fi
if [ "$secret" != "400" ]; then echo "FAIL: secret/api-key has mode '${secret}', expected 400"; exit 1; fi

echo "PASS: settings/app.properties is 444 and secret/api-key is 400"
