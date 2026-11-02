#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-027-lab-040-02-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
solution_directory="$lab_directory/solution"
cluster_name="astro-ats-027-lab-040-02-01"

kubectl apply -f "$solution_directory/persistentvolumeclaim-probe-data.yaml"
kubectl -n starfleet wait --for=condition=Ready pod/volume-reader --timeout=180s
bound_volume="$(kubectl -n starfleet get pvc probe-data -o jsonpath='{.spec.volumeName}')"
kubectl patch pv "$bound_volume" --type=merge -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
kubectl -n starfleet wait --for=condition=Ready pod/volume-reader --timeout=180s
