#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

EXPECTED="kind-astro-ats-027-lab-020-capstone"
CURRENT="$(kubectl config current-context)"
if [ "$CURRENT" != "$EXPECTED" ]; then
  echo "Refusing to run: current context is '$CURRENT', expected '$EXPECTED'." >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl -n starfleet delete deployment node-agent outpost-sweep ledger --wait=true
kubectl -n starfleet delete pod scout-web --wait=true
kubectl apply -f "$DIR/solution.yaml"
kubectl -n starfleet rollout status daemonset/node-agent --timeout=180s
kubectl -n starfleet rollout status deployment/scout-web --timeout=180s
kubectl -n starfleet rollout status statefulset/ledger --timeout=180s
echo "[solution] Applied."
