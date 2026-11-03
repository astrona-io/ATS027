#!/usr/bin/env bash
# Check: Deployment probe is fully rolled out on localhost/ckad-probe:v2.
set -uo pipefail
image="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)"
if [ "$image" != "localhost/ckad-probe:v2" ]; then
  echo "FAIL: the Deployment image is '${image}', expected localhost/ckad-probe:v2"
  exit 1
fi
if ! kubectl -n starfleet rollout status deployment/probe --timeout=90s >/dev/null 2>&1; then
  echo "FAIL: the rollout of Deployment probe did not complete in time"
  exit 1
fi
desired="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.replicas}')"
ready="$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.readyReplicas}')"
updated="$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.updatedReplicas}')"
if [ "${ready:-0}" != "$desired" ] || [ "${updated:-0}" != "$desired" ]; then
  echo "FAIL: desired ${desired}, updated ${updated:-0}, ready ${ready:-0}"
  exit 1
fi
echo "PASS: ${desired} replicas are updated and ready on ${image}"
