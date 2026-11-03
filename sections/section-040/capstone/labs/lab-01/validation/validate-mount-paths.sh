#!/usr/bin/env bash
# Check: the claim is mounted at /var/lib/probe and an emptyDir at /scratch.
set -uo pipefail

kubectl -n starfleet rollout status deployment/probe --timeout=120s >/dev/null 2>&1 || true
pod="$(kubectl -n starfleet get pod -l app=probe --field-selector=status.phase=Running --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1:].metadata.name}' 2>/dev/null || true)"
if [ -z "$pod" ]; then
  echo "FAIL: no running probe Pod in starfleet"
  exit 1
fi

dv="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.spec.containers[?(@.name=="app")].volumeMounts[?(@.mountPath=="/var/lib/probe")].name}' 2>/dev/null || true)"
sv="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.spec.containers[?(@.name=="app")].volumeMounts[?(@.mountPath=="/scratch")].name}' 2>/dev/null || true)"
if [ -z "$dv" ] || [ -z "$sv" ]; then echo "FAIL: nothing is mounted at /var/lib/probe ('${dv}') or /scratch ('${sv}')"; exit 1; fi

claim="$(kubectl -n starfleet get pod "$pod" -o jsonpath="{.spec.volumes[?(@.name==\"${dv}\")].persistentVolumeClaim.claimName}" 2>/dev/null || true)"
medium="$(kubectl -n starfleet get pod "$pod" -o jsonpath="{.spec.volumes[?(@.name==\"${sv}\")].emptyDir}" 2>/dev/null || true)"
if [ "$claim" != "probe-data" ]; then echo "FAIL: /var/lib/probe is backed by claim '${claim}', expected probe-data"; exit 1; fi
if [ -z "$medium" ]; then echo "FAIL: /scratch is not an emptyDir"; exit 1; fi

echo "PASS: probe-data is mounted at /var/lib/probe and an emptyDir at /scratch"
