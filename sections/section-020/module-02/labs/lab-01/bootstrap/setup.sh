#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-027-lab-020-02-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
bootstrap_directory="$(cd "$(dirname "$0")" && pwd)"
kubectl apply -f "$bootstrap_directory/manifests/start.yaml"
