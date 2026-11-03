#!/usr/bin/env bash
# Reference solution: recreate the claim (access modes are immutable), then apply the fixed Deployment.
set -euo pipefail

expected="kind-astro-ats-027-lab-040-capstone"
current="$(kubectl config current-context 2>/dev/null || true)"
if [ "$current" != "$expected" ]; then
  echo "[lab] refusing to run: current context is '${current}', expected '${expected}'" >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
kubectl -n starfleet delete deployment probe --wait=true --timeout=120s
kubectl -n starfleet delete pvc probe-data --wait=true --timeout=120s
kubectl apply -f "$DIR/solution/solution.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=240s
echo "[solution] Applied."
