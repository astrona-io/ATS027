#!/usr/bin/env bash
# Starting state: a finished non-indexed Job and a CronJob with default policies. The learner fixes both.
set -euo pipefail

EXPECTED="kind-astro-ats-027-lab-020-05-01"
CURRENT="$(kubectl config current-context)"
if [ "$CURRENT" != "$EXPECTED" ]; then
  echo "Refusing to run: current context is '$CURRENT', expected '$EXPECTED'." >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet wait --for=condition=complete job/probe-scan --timeout=180s
echo "[lab] Ready."
