#!/usr/bin/env bash
# Check: the container has a memory limit of at least 128Mi, so the memory-backed
# volume is covered by a limit that is larger than its size limit.
set -uo pipefail

limit="$(kubectl -n starfleet get deploy shuttle -o jsonpath='{.spec.template.spec.containers[?(@.name=="app")].resources.limits.memory}' 2>/dev/null || true)"
case "$limit" in
  128Mi|192Mi|256Mi|512Mi|1Gi) echo "PASS: container app has memory limit ${limit}" ;;
  *) echo "FAIL: container app has memory limit '${limit}', expected at least 128Mi"; exit 1 ;;
esac
