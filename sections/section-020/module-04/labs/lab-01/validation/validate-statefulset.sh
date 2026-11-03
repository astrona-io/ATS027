#!/usr/bin/env bash
# Check: a StatefulSet named shuttle with three ready ordinal Pods.
set -uo pipefail

kind_name="$(kubectl -n starfleet get statefulset shuttle -o jsonpath='{.metadata.name}' 2>/dev/null || true)"
if [ "$kind_name" != "shuttle" ]; then
  echo "FAIL: StatefulSet shuttle not found in starfleet"
  exit 1
fi

replicas="$(kubectl -n starfleet get statefulset shuttle -o jsonpath='{.spec.replicas}')"
service_name="$(kubectl -n starfleet get statefulset shuttle -o jsonpath='{.spec.serviceName}')"
if [ "$replicas" != "3" ]; then
  echo "FAIL: replicas is '${replicas}', expected 3"
  exit 1
fi
if [ "$service_name" != "shuttle" ]; then
  echo "FAIL: serviceName is '${service_name}', expected shuttle"
  exit 1
fi

for ordinal in 0 1 2; do
  if ! kubectl -n starfleet wait --for=condition=Ready "pod/shuttle-${ordinal}" --timeout=90s >/dev/null 2>&1; then
    echo "FAIL: pod shuttle-${ordinal} is not ready"
    exit 1
  fi
done

echo "PASS: StatefulSet shuttle has Pods shuttle-0, shuttle-1 and shuttle-2 ready"
