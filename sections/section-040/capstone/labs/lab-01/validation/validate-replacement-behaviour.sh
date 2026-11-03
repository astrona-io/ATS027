#!/usr/bin/env bash
# Behaviour: after the Pod is replaced the journal keeps both Pod names and the scratch directory is empty of old files.
set -uo pipefail

kubectl -n starfleet rollout status deployment/probe --timeout=120s >/dev/null 2>&1 || true
pod="$(kubectl -n starfleet get pod -l app=probe --field-selector=status.phase=Running --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1:].metadata.name}' 2>/dev/null || true)"
if [ -z "$pod" ]; then
  echo "FAIL: no running probe Pod in starfleet"
  exit 1
fi

old="$pod"
kubectl -n starfleet delete pod "$old" --wait=true --timeout=90s >/dev/null 2>&1 || true
kubectl -n starfleet rollout status deployment/probe --timeout=180s >/dev/null 2>&1 || true
new="$(kubectl -n starfleet get pod -l app=probe --field-selector=status.phase=Running --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1:].metadata.name}' 2>/dev/null || true)"
if [ -z "$new" ] || [ "$new" = "$old" ]; then
  echo "FAIL: no replacement Pod is running (old '${old}', new '${new}')"
  exit 1
fi

journal="$(kubectl -n starfleet exec "$new" -- cat /var/lib/probe/journal 2>/dev/null || true)"
case "$journal" in *"$old"*) ;; *) echo "FAIL: the journal lost the entry of the old Pod ${old}. Durable data is not on the claim"; exit 1 ;; esac
case "$journal" in *"$new"*) ;; *) echo "FAIL: the journal has no entry for the new Pod ${new}"; exit 1 ;; esac
if kubectl -n starfleet exec "$new" -- test -e "/scratch/work-${old}" 2>/dev/null; then
  echo "FAIL: scratch data of the old Pod survived replacement, so /scratch is not an emptyDir"
  exit 1
fi

echo "PASS: the journal survived Pod replacement and the scratch directory started empty"
