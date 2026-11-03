#!/usr/bin/env bash
# Check: ConfigMap scout-release matches the image ID of every running scout Pod.
set -uo pipefail
version="$(kubectl -n starfleet get configmap scout-release -o jsonpath='{.data.version}' 2>/dev/null)"
recorded="$(kubectl -n starfleet get configmap scout-release -o jsonpath='{.data.imageID}' 2>/dev/null)"
if [ "$version" != "v2" ] || [ -z "$recorded" ]; then
  echo "FAIL: ConfigMap scout-release needs version=v2 and a non-empty imageID"
  exit 1
fi
ids="$(kubectl -n starfleet get pods -l app=scout --field-selector=status.phase=Running -o jsonpath='{range .items[*]}{.status.containerStatuses[0].imageID}{"\n"}{end}' 2>/dev/null)"
if [ -z "$ids" ]; then
  echo "FAIL: no running scout Pods found"
  exit 1
fi
while IFS= read -r id; do
  if [ "$id" != "$recorded" ]; then
    echo "FAIL: a running Pod reports imageID '${id}', the record says '${recorded}'"
    exit 1
  fi
done <<< "$ids"
echo "PASS: the record matches the image ID of every running scout Pod"
