#!/usr/bin/env bash
# Starting state for the native sidecar lab. Environment only: a Job whose
# ordinary log-shipper container never exits. The learner fixes it.
set -euo pipefail

expected_context="kind-astro-ats-027-lab-030-03-01"
if [ "$(kubectl config current-context)" != "$expected_context" ]; then
  echo "Refusing to run: current context is not $expected_context" >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet wait --for=jsonpath='{.status.phase}'=Running pod -l job-name=nightly-report --timeout=120s
echo "[lab] Ready."
