#!/usr/bin/env bash
# Reference solution: one projected volume with ConfigMap, Secret and downward API sources.
set -euo pipefail

expected="kind-astro-ats-027-lab-040-04-01"
current="$(kubectl config current-context 2>/dev/null || true)"
if [ "$current" != "$expected" ]; then
  echo "[lab] refusing to run: current context is '${current}', expected '${expected}'" >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
kubectl apply -f "$DIR/solution/deployment-scout.yaml"
kubectl -n starfleet rollout status deployment/scout --timeout=240s
echo "[solution] Applied."
