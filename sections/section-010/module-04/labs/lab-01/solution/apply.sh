#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-027-lab-010-04-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
podman build -t localhost/ckad-probe:v2 "$lab_directory/solution/image"
archive_directory="$(mktemp -d)"
trap 'rm -rf "$archive_directory"' EXIT
podman save -o "$archive_directory/probe-v2.tar" localhost/ckad-probe:v2
KIND_EXPERIMENTAL_PROVIDER=podman kind load image-archive "$archive_directory/probe-v2.tar" --name "astro-ats-027-lab-010-04-01"
kubectl apply -f "$lab_directory/solution/deployment-probe.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
