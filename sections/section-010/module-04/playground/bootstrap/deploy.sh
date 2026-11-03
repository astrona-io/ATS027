#!/usr/bin/env bash
# Builds the v1 image on the host, loads it into the kind cluster and applies
# the starting manifests. Needs podman, kind and kubectl on the host.
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-027-playground-010-04" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
base_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
podman build -t localhost/ckad-probe:v1 "$base_directory/bootstrap/image-v1"
archive_directory="$(mktemp -d)"
trap 'rm -rf "$archive_directory"' EXIT
podman save -o "$archive_directory/probe-v1.tar" localhost/ckad-probe:v1
KIND_EXPERIMENTAL_PROVIDER=podman kind load image-archive "$archive_directory/probe-v1.tar" --name "astro-ats-027-playground-010-04"
kubectl apply -f "$base_directory/manifests/environment.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s
kubectl -n outpost wait --for=condition=Ready pod/drifter --timeout=120s
