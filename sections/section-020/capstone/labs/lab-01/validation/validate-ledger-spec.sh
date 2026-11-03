#!/usr/bin/env bash
# Check: kind and fields. ledger is a StatefulSet with a headless Service and a claim template.
set -uo pipefail

if kubectl -n starfleet get deployment ledger >/dev/null 2>&1; then
  echo "FAIL: a Deployment named ledger still exists"
  exit 1
fi
if ! kubectl -n starfleet get statefulset ledger >/dev/null 2>&1; then
  echo "FAIL: StatefulSet ledger not found in starfleet"
  exit 1
fi

field() { kubectl -n starfleet get statefulset ledger -o "jsonpath=$1" 2>/dev/null; }

fail=0
[ "$(field '{.spec.replicas}')" = "2" ] || { echo "FAIL: replicas must be 2"; fail=1; }
[ "$(field '{.status.readyReplicas}')" = "2" ] || { echo "FAIL: both ledger Pods must be ready"; fail=1; }
[ "$(field '{.spec.serviceName}')" = "ledger" ] || { echo "FAIL: serviceName must be ledger"; fail=1; }
[ "$(field '{.spec.volumeClaimTemplates[0].metadata.name}')" = "data" ] || { echo "FAIL: the first volumeClaimTemplate must be named data"; fail=1; }

cluster_ip="$(kubectl -n starfleet get service ledger -o jsonpath='{.spec.clusterIP}' 2>/dev/null)"
[ "$cluster_ip" = "None" ] || { echo "FAIL: Service ledger must be headless (clusterIP None), found '$cluster_ip'"; fail=1; }

for pod in ledger-0 ledger-1; do
  phase="$(kubectl -n starfleet get pvc "data-$pod" -o jsonpath='{.status.phase}' 2>/dev/null)"
  [ "$phase" = "Bound" ] || { echo "FAIL: PersistentVolumeClaim data-$pod is '$phase', expected Bound"; fail=1; }
done

[ "$fail" -eq 0 ] || exit 1
echo "PASS: ledger is a StatefulSet with 2 ready Pods, a headless Service and bound volume claims"
