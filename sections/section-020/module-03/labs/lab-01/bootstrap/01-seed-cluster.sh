#!/usr/bin/env bash
# Starting state for the rollout lab. The probe Deployment is created with a
# working image, then updated to an image tag that does not exist, so the
# rollout is stuck. The learner repairs it.
set -euo pipefail

EXPECTED="kind-astro-ats-027-lab-020-03-01"
CURRENT="$(kubectl config current-context)"
if [ "$CURRENT" != "$EXPECTED" ]; then
  echo "[lab] Refusing to run: current context is '$CURRENT', expected '$EXPECTED'." >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s

# Remember the identity of the Deployment so a check can tell a rollback from a re-creation.
uid="$(kubectl -n starfleet get deployment probe -o jsonpath='{.metadata.uid}')"
kubectl -n starfleet create configmap lab-meta --from-literal=probe-uid="$uid" --dry-run=client -o yaml | kubectl apply -f -

# The bad release: an image tag that does not exist.
kubectl -n starfleet set image deployment/probe probe=docker.io/library/busybox:1.37.0-broken
echo "[lab] Ready. The probe rollout is stuck."
