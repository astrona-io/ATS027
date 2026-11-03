#!/usr/bin/env bash
# Starting state: four workloads that use the wrong workload kind. The learner replaces them.
set -euo pipefail

EXPECTED="kind-astro-ats-027-lab-020-capstone"
CURRENT="$(kubectl config current-context)"
if [ "$CURRENT" != "$EXPECTED" ]; then
  echo "Refusing to run: current context is '$CURRENT', expected '$EXPECTED'." >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
kubectl apply -f "$DIR/manifests/lab-start.yaml"
for name in node-agent outpost-sweep ledger; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n starfleet wait --for=condition=ready pod/scout-web --timeout=180s
echo "[lab] Ready."
