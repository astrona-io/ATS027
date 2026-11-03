#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

EXPECTED="kind-astro-ats-027-lab-020-03-01"
CURRENT="$(kubectl config current-context)"
if [ "$CURRENT" != "$EXPECTED" ]; then
  echo "[solution] Refusing to run: current context is '$CURRENT', expected '$EXPECTED'." >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl -n starfleet rollout undo deployment/probe
kubectl -n starfleet rollout status deployment/probe --timeout=120s
kubectl -n starfleet patch deployment probe --patch-file "$DIR/patch-probe-strategy.yaml"
kubectl -n starfleet scale deployment/probe --replicas=4
kubectl -n starfleet rollout status deployment/probe --timeout=120s
echo "[solution] Applied."
