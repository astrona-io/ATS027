#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

expected_context="kind-astro-ats-027-lab-030-03-01"
if [ "$(kubectl config current-context)" != "$expected_context" ]; then
  echo "Refusing to run: current context is not $expected_context" >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl -n starfleet delete job nightly-report --wait=true --timeout=120s
kubectl apply -f "$DIR/job-nightly-report.yaml"
kubectl -n starfleet wait --for=condition=Complete job/nightly-report --timeout=120s
echo "[solution] Applied."
