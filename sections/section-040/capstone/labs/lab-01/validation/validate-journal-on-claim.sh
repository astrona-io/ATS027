#!/usr/bin/env bash
# Behaviour: the journal is written to the claim, not to the container layer or the scratch volume.
set -uo pipefail

kubectl -n starfleet rollout status deployment/probe --timeout=120s >/dev/null 2>&1 || true
pod="$(kubectl -n starfleet get pod -l app=probe --field-selector=status.phase=Running --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1:].metadata.name}' 2>/dev/null || true)"
if [ -z "$pod" ]; then
  echo "FAIL: no running probe Pod in starfleet"
  exit 1
fi

if ! kubectl -n starfleet exec "$pod" -- grep -q "$pod" /var/lib/probe/journal 2>/dev/null; then
  echo "FAIL: /var/lib/probe/journal does not contain the Pod name ${pod}"
  exit 1
fi
if kubectl -n starfleet exec "$pod" -- test -e /scratch/journal 2>/dev/null; then
  echo "FAIL: the journal was written into /scratch"
  exit 1
fi
if ! kubectl -n starfleet exec "$pod" -- test -f "/scratch/work-${pod}" 2>/dev/null; then
  echo "FAIL: the scratch file work-${pod} is not in /scratch"
  exit 1
fi

echo "PASS: the journal is in /var/lib/probe and the scratch file is in /scratch"
