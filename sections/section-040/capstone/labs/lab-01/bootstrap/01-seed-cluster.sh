#!/usr/bin/env bash
# Starting state for the capstone: probe with a wrong claim, wrong mounts and a subPath file.
# No rollout wait: the Pod cannot start until the claim is fixed.
set -euo pipefail

expected="kind-astro-ats-027-lab-040-capstone"
current="$(kubectl config current-context 2>/dev/null || true)"
if [ "$current" != "$expected" ]; then
  echo "[lab] refusing to run: current context is '${current}', expected '${expected}'" >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet get deployment probe >/dev/null
echo "[lab] Ready."
