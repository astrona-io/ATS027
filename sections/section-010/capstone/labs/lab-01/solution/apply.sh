#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-027-lab-010-capstone" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
solution_directory="$lab_directory/solution"
archive_directory="$(mktemp -d)"
trap 'rm -rf "$archive_directory"' EXIT
podman build -t localhost/ckad-scout:v1 "$solution_directory/image"
podman build -t localhost/ckad-scout:v2 "$solution_directory/image-v2"
for version in v1 v2; do
  podman save -o "$archive_directory/scout-$version.tar" "localhost/ckad-scout:$version"
  KIND_EXPERIMENTAL_PROVIDER=podman kind load image-archive "$archive_directory/scout-$version.tar" --name "astro-ats-027-lab-010-capstone"
done
kubectl apply -f "$solution_directory/deployment-scout-v1.yaml"
kubectl -n starfleet rollout status deployment/scout --timeout=180s
kubectl apply -f "$solution_directory/deployment-scout-v2.yaml"
kubectl apply -f "$solution_directory/service-scout.yaml"
kubectl -n starfleet rollout status deployment/scout --timeout=180s
pod_name="$(kubectl -n starfleet get pods -l app=scout -o jsonpath='{.items[0].metadata.name}')"
image_id="$(kubectl -n starfleet get pod "$pod_name" -o jsonpath='{.status.containerStatuses[0].imageID}')"
kubectl -n starfleet create configmap scout-release --from-literal=version=v2 --from-literal=imageID="$image_id" --dry-run=client -o yaml | kubectl apply -f -
