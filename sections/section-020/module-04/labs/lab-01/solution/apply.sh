#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

EXPECTED="kind-astro-ats-027-lab-020-04-01"
CURRENT="$(kubectl config current-context)"
if [ "$CURRENT" != "$EXPECTED" ]; then
  echo "[solution] Refusing to run: current context is '$CURRENT', expected '$EXPECTED'." >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# The clusterIP of a Service cannot change, so the normal Service is replaced.
kubectl -n starfleet delete service shuttle
kubectl apply -f "$DIR/statefulset-shuttle.yaml"
kubectl -n starfleet rollout status statefulset/shuttle --timeout=240s
echo "[solution] Applied."
