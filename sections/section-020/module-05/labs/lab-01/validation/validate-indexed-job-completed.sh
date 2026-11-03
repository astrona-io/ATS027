#!/usr/bin/env bash
# Check: behaviour. The Job finished, each index ran once and each Pod saw its own index.
set -uo pipefail

if ! kubectl -n starfleet wait --for=condition=complete job/probe-scan --timeout=90s >/dev/null 2>&1; then
  echo "FAIL: Job probe-scan did not reach the Complete condition within 90 seconds"
  exit 1
fi

succeeded="$(kubectl -n starfleet get job probe-scan -o jsonpath='{.status.succeeded}')"
indexes="$(kubectl -n starfleet get job probe-scan -o jsonpath='{.status.completedIndexes}')"
if [ "$succeeded" != "3" ] || [ "$indexes" != "0-2" ]; then
  echo "FAIL: succeeded='$succeeded' completedIndexes='$indexes', expected 3 and 0-2"
  exit 1
fi

logs="$(kubectl -n starfleet logs -l job-name=probe-scan --tail=-1 2>/dev/null)"
for index in 0 1 2; do
  if ! printf '%s\n' "$logs" | grep -qx "scanned slice $index"; then
    echo "FAIL: no log line 'scanned slice $index' found in the Pods of probe-scan"
    exit 1
  fi
done

echo "PASS: probe-scan completed indexes 0-2 and each Pod printed its own slice"
