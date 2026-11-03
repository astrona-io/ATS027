#!/usr/bin/env bash
# Check: no separate configMap or secret volume remains, and bundle is mounted read-only at /etc/scout.
set -uo pipefail

kubectl -n starfleet rollout status deployment/scout --timeout=120s >/dev/null 2>&1 || true
pod="$(kubectl -n starfleet get pod -l app=scout --field-selector=status.phase=Running --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1:].metadata.name}' 2>/dev/null || true)"
if [ -z "$pod" ]; then
  echo "FAIL: no running scout Pod in starfleet"
  exit 1
fi

cms="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.spec.volumes[*].configMap.name}' 2>/dev/null || true)"
secs="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.spec.volumes[*].secret.secretName}' 2>/dev/null || true)"
path="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.spec.containers[?(@.name=="app")].volumeMounts[?(@.name=="bundle")].mountPath}' 2>/dev/null || true)"
ro="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.spec.containers[?(@.name=="app")].volumeMounts[?(@.name=="bundle")].readOnly}' 2>/dev/null || true)"

if [ -n "$cms" ] || [ -n "$secs" ]; then
  echo "FAIL: the Pod still has a standalone ConfigMap ('${cms}') or Secret ('${secs}') volume"
  exit 1
fi
if [ "$path" != "/etc/scout" ]; then echo "FAIL: bundle is mounted at '${path}', expected /etc/scout"; exit 1; fi
if [ "$ro" != "true" ]; then echo "FAIL: bundle is not mounted read-only"; exit 1; fi

echo "PASS: only the projected volume remains, mounted read-only at /etc/scout"
