#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-027-lab-010-02-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
solution_directory="$lab_directory/solution"
cluster_name="astro-ats-027-lab-010-02-01"
podman build -t localhost/ckad-probe:v1 "$solution_directory/image"
image_directory="$(mktemp -d)"
image_archive="$image_directory/probe.tar"
trap 'rm -rf "$image_directory"' EXIT
podman save -o "$image_archive" localhost/ckad-probe:v1
KIND_EXPERIMENTAL_PROVIDER=podman kind load image-archive "$image_archive" --name "$cluster_name"
kubectl apply -f "$solution_directory/pod-image-probe.yaml"
kubectl -n starfleet wait --for=condition=Ready pod/image-probe --timeout=180s
