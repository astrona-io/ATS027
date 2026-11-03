#!/usr/bin/env bash
# Check: the labels file lists the Pod labels and the memory limit file holds 128.
set -uo pipefail

kubectl -n starfleet rollout status deployment/scout --timeout=120s >/dev/null 2>&1 || true
pod="$(kubectl -n starfleet get pod -l app=scout --field-selector=status.phase=Running --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1:].metadata.name}' 2>/dev/null || true)"
if [ -z "$pod" ]; then
  echo "FAIL: no running scout Pod in starfleet"
  exit 1
fi

labels="$(kubectl -n starfleet exec "$pod" -- cat /etc/scout/meta/labels 2>/dev/null || true)"
limit="$(kubectl -n starfleet exec "$pod" -- cat /etc/scout/meta/memory-limit 2>/dev/null | tr -d '[:space:]' || true)"

case "$labels" in
  *'tier="edge"'*) ;;
  *) echo "FAIL: meta/labels does not contain tier=\"edge\""; exit 1 ;;
esac
if [ "$limit" != "128" ]; then echo "FAIL: meta/memory-limit holds '${limit}', expected 128"; exit 1; fi

echo "PASS: meta/labels lists the Pod labels and meta/memory-limit is 128"
