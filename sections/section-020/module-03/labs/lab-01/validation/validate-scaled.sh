#!/usr/bin/env bash
# Check: four replicas are requested and four Pods are ready.
set -uo pipefail

desired="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
if [ "$desired" != "4" ]; then
  echo "FAIL: spec.replicas is '${desired}', expected 4"
  exit 1
fi

ready_pods="$(kubectl -n starfleet get pods -l app=probe --field-selector=status.phase=Running -o jsonpath='{range .items[*]}{.status.containerStatuses[0].ready}{"\n"}{end}' 2>/dev/null | grep -c '^true$' || true)"
if [ "$ready_pods" != "4" ]; then
  echo "FAIL: ${ready_pods} ready Pods, expected 4"
  exit 1
fi

echo "PASS: probe has 4 replicas and 4 ready Pods"
