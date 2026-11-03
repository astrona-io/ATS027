#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

expected_context="kind-astro-ats-027-lab-030-02-01"
if [ "$(kubectl config current-context)" != "$expected_context" ]; then
  echo "Refusing to run: current context is not $expected_context" >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/uplink-config.yaml"
kubectl apply -f "$DIR/legacy-scout.yaml"
kubectl -n starfleet rollout status deployment/legacy-scout --timeout=180s
echo "[solution] Applied."
