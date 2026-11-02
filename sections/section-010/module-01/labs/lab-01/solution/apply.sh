#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-027-lab-010-01-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
solution_directory="$lab_directory/solution"
cluster_name="astro-ats-027-lab-010-01-01"

runtime_image_id="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].status.containerStatuses[0].imageID}')"
kubectl -n starfleet create configmap image-report --from-literal=requestedImage=docker.io/library/python:3.13-alpine --from-literal=runtimeImageID="$runtime_image_id"

