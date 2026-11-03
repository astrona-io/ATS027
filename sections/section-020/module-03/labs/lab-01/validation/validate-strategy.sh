#!/usr/bin/env bash
# Check: the strategy is RollingUpdate with maxUnavailable 0 and maxSurge 1.
set -uo pipefail

type="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.strategy.type}' 2>/dev/null || true)"
unavailable="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}' 2>/dev/null || true)"
surge="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}' 2>/dev/null || true)"

if [ "$type" != "RollingUpdate" ]; then
  echo "FAIL: strategy type is '${type}', expected RollingUpdate"
  exit 1
fi
if [ "$unavailable" != "0" ]; then
  echo "FAIL: maxUnavailable is '${unavailable}', expected 0"
  exit 1
fi
if [ "$surge" != "1" ]; then
  echo "FAIL: maxSurge is '${surge}', expected 1"
  exit 1
fi

echo "PASS: RollingUpdate with maxUnavailable 0 and maxSurge 1"
