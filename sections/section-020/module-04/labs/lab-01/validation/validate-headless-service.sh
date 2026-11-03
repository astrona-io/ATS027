#!/usr/bin/env bash
# Check: the Service shuttle is headless and selects the shuttle Pods.
set -uo pipefail

cluster_ip="$(kubectl -n starfleet get service shuttle -o jsonpath='{.spec.clusterIP}' 2>/dev/null || true)"
if [ "$cluster_ip" != "None" ]; then
  echo "FAIL: Service shuttle clusterIP is '${cluster_ip}', expected None"
  exit 1
fi

endpoints="$(kubectl -n starfleet get endpoints shuttle -o jsonpath='{range .subsets[*].addresses[*]}{.targetRef.name}{"\n"}{end}' 2>/dev/null | sort | tr '\n' ' ')"
if [ "$endpoints" != "shuttle-0 shuttle-1 shuttle-2 " ]; then
  echo "FAIL: Service endpoints are '${endpoints}', expected shuttle-0 shuttle-1 shuttle-2"
  exit 1
fi

echo "PASS: Service shuttle is headless and selects the three Pods"
