#!/usr/bin/env bash
# Check: the rollout is complete and the Deployment is available.
set -uo pipefail

if ! kubectl -n starfleet rollout status deployment/probe --timeout=90s >/dev/null 2>&1; then
  echo "FAIL: the probe rollout is not complete"
  exit 1
fi

desired="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.replicas}')"
updated="$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.updatedReplicas}')"
available="$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.availableReplicas}')"
if [ "${updated:-0}" != "$desired" ] || [ "${available:-0}" != "$desired" ]; then
  echo "FAIL: desired=${desired} updated=${updated:-0} available=${available:-0}"
  exit 1
fi

echo "PASS: all ${desired} replicas are updated and available"
