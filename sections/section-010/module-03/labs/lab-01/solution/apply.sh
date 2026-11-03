#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-027-lab-010-03-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
podman build -t localhost/ckad-site:v1 "$lab_directory/solution/image"
archive_directory="$(mktemp -d)"
trap 'rm -rf "$archive_directory"' EXIT
podman save -o "$archive_directory/site.tar" localhost/ckad-site:v1
KIND_EXPERIMENTAL_PROVIDER=podman kind load image-archive "$archive_directory/site.tar" --name "astro-ats-027-lab-010-03-01"
kubectl apply -f "$lab_directory/solution/pod-site.yaml"
kubectl -n starfleet wait --for=condition=Ready pod/site --timeout=180s
