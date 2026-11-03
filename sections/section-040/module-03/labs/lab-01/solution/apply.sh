#!/usr/bin/env bash
# Reference solution: add the memory-backed emptyDir and the generic ephemeral volume.
set -euo pipefail

expected="kind-astro-ats-027-lab-040-03-01"
current="$(kubectl config current-context 2>/dev/null || true)"
if [ "$current" != "$expected" ]; then
  echo "[lab] refusing to run: current context is '${current}', expected '${expected}'" >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
kubectl apply -f "$DIR/solution/deployment-shuttle.yaml"
kubectl -n starfleet rollout status deployment/shuttle --timeout=240s
echo "[solution] Applied."
