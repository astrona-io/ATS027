#!/usr/bin/env bash
# Check: the Pod has one projected volume named bundle with ConfigMap, Secret and downward API sources.
set -uo pipefail

kubectl -n starfleet rollout status deployment/scout --timeout=120s >/dev/null 2>&1 || true
pod="$(kubectl -n starfleet get pod -l app=scout --field-selector=status.phase=Running --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1:].metadata.name}' 2>/dev/null || true)"
if [ -z "$pod" ]; then
  echo "FAIL: no running scout Pod in starfleet"
  exit 1
fi

cm="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.spec.volumes[?(@.name=="bundle")].projected.sources[*].configMap.name}' 2>/dev/null || true)"
sec="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.spec.volumes[?(@.name=="bundle")].projected.sources[*].secret.name}' 2>/dev/null || true)"
dapi="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.spec.volumes[?(@.name=="bundle")].projected.sources[*].downwardAPI.items[*].path}' 2>/dev/null || true)"

if [ "$cm" != "scout-settings" ]; then echo "FAIL: projected volume bundle has ConfigMap source '${cm}', expected scout-settings"; exit 1; fi
if [ "$sec" != "scout-credentials" ]; then echo "FAIL: projected volume bundle has Secret source '${sec}', expected scout-credentials"; exit 1; fi
case "$dapi" in
  *meta/labels*meta/memory-limit*|*meta/memory-limit*meta/labels*) ;;
  *) echo "FAIL: downward API items are '${dapi}', expected meta/labels and meta/memory-limit"; exit 1 ;;
esac

echo "PASS: projected volume bundle merges the ConfigMap, the Secret and the downward API"
