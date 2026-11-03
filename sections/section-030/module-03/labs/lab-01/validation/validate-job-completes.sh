#!/usr/bin/env bash
# Check: behaviour. The Job nightly-report completes with one success and no failure.
set -uo pipefail

if ! kubectl -n starfleet wait --for=condition=Complete job/nightly-report --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: job nightly-report did not reach the Complete condition within 120 seconds"
  exit 1
fi
succeeded="$(kubectl -n starfleet get job nightly-report -o jsonpath='{.status.succeeded}' 2>/dev/null)"
failed="$(kubectl -n starfleet get job nightly-report -o jsonpath='{.status.failed}' 2>/dev/null)"
if [ "$succeeded" != "1" ] || { [ -n "$failed" ] && [ "$failed" != "0" ]; }; then
  echo "FAIL: succeeded='${succeeded}' failed='${failed}', expected 1 success and no failure"
  exit 1
fi
echo "PASS: nightly-report completed with one success and no failure"
