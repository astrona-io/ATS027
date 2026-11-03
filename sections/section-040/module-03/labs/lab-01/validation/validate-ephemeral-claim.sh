#!/usr/bin/env bash
# Check: the Pod has a generic ephemeral volume named work. The claim
# <pod>-work exists, is owned by the Pod, is Bound and uses the standard class.
set -uo pipefail

pod="$(kubectl -n starfleet get pod -l app=shuttle -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
if [ -z "$pod" ]; then
  echo "FAIL: no shuttle Pod found in starfleet"
  exit 1
fi

tmpl="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.spec.volumes[?(@.name=="work")].ephemeral.volumeClaimTemplate.spec.storageClassName}' 2>/dev/null || true)"
if [ "$tmpl" != "standard" ]; then
  echo "FAIL: volume work has no ephemeral template with storageClassName standard (got '${tmpl}')"
  exit 1
fi

claim="${pod}-work"
phase="$(kubectl -n starfleet get pvc "$claim" -o jsonpath='{.status.phase}' 2>/dev/null || true)"
owner="$(kubectl -n starfleet get pvc "$claim" -o jsonpath='{.metadata.ownerReferences[0].kind}' 2>/dev/null || true)"
size="$(kubectl -n starfleet get pvc "$claim" -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null || true)"

if [ "$phase" != "Bound" ]; then
  echo "FAIL: claim ${claim} has phase '${phase}', expected Bound"
  exit 1
fi
if [ "$owner" != "Pod" ]; then
  echo "FAIL: claim ${claim} is owned by '${owner}', expected Pod"
  exit 1
fi
if [ "$size" != "1Gi" ]; then
  echo "FAIL: claim ${claim} requests '${size}', expected 1Gi"
  exit 1
fi

echo "PASS: claim ${claim} is Bound, 1Gi, owned by the Pod"
