#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

EXPECTED="kind-astro-ats-027-lab-020-05-01"
CURRENT="$(kubectl config current-context)"
if [ "$CURRENT" != "$EXPECTED" ]; then
  echo "Refusing to run: current context is '$CURRENT', expected '$EXPECTED'." >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl -n starfleet delete job probe-scan --wait=true
kubectl apply -f "$DIR/job-probe-scan.yaml"
kubectl apply -f "$DIR/cronjob-shuttle-report.yaml"
kubectl -n starfleet wait --for=condition=complete job/probe-scan --timeout=180s
echo "[solution] Applied."
