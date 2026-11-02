#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-027-lab-020-02-02" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
solution_directory="$lab_directory/solution"
cluster_name="astro-ats-027-lab-020-02-02"

kubectl apply -f "$solution_directory/cronjob-scheduled-report.yaml"
kubectl -n starfleet create job scheduled-once --from=cronjob/scheduled-report
kubectl -n starfleet wait --for=condition=Complete job/scheduled-once --timeout=180s
