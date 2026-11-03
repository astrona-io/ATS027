#!/usr/bin/env bash
# Starting state for the multi-container capstone. Environment only: the probe
# Service, the ambassador code and the legacy application as a single container.
set -euo pipefail

expected_context="kind-astro-ats-027-lab-030-capstone"
if [ "$(kubectl config current-context)" != "$expected_context" ]; then
  echo "Refusing to run: current context is not $expected_context" >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet rollout status deployment/legacy-scout --timeout=180s
echo "[lab] Ready."
