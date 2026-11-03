#!/usr/bin/env bash
# Check: behaviour. The sidecar shipped the readings before it was stopped.
set -uo pipefail

pod="$(kubectl -n starfleet get pod -l job-name=nightly-report -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)"
if [ -z "$pod" ]; then
  echo "FAIL: no Pod found for job nightly-report"
  exit 1
fi
logs="$(kubectl -n starfleet logs "$pod" -c log-shipper 2>/dev/null)"
case "$logs" in
  *"shipped: reading 1"*) echo "PASS: the log-shipper shipped the readings" ;;
  *) echo "FAIL: the logs of log-shipper contain no 'shipped: reading' line"; exit 1 ;;
esac
