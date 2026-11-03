#!/usr/bin/env bash
# Check: Deployment scout is fully rolled out on v2 and has more than one ReplicaSet.
set -uo pipefail
image="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)"
if [ "$image" != "localhost/ckad-scout:v2" ]; then
  echo "FAIL: the Deployment image is '${image}', expected localhost/ckad-scout:v2"
  exit 1
fi
if ! kubectl -n starfleet rollout status deployment/scout --timeout=90s >/dev/null 2>&1; then
  echo "FAIL: the rollout of Deployment scout did not complete in time"
  exit 1
fi
policy="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.containers[0].imagePullPolicy}')"
if [ "$policy" != "Never" ]; then
  echo "FAIL: imagePullPolicy is '${policy}', expected Never"
  exit 1
fi
count="$(kubectl -n starfleet get replicaset -l app=scout -o name 2>/dev/null | wc -l | tr -d ' ')"
if [ "${count:-0}" -lt 2 ]; then
  echo "FAIL: only ${count} ReplicaSet exists; v1 must be rolled out before v2"
  exit 1
fi
echo "PASS: scout is rolled out on ${image} with ${count} ReplicaSets"
