#!/usr/bin/env bash
# Starting state for the StatefulSet lab: the namespaces and a normal
# (not headless) Service named shuttle. The learner builds the rest.
set -euo pipefail

EXPECTED="kind-astro-ats-027-lab-020-04-01"
CURRENT="$(kubectl config current-context)"
if [ "$CURRENT" != "$EXPECTED" ]; then
  echo "[lab] Refusing to run: current context is '$CURRENT', expected '$EXPECTED'." >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl get namespace starfleet outpost >/dev/null
echo "[lab] Ready."
