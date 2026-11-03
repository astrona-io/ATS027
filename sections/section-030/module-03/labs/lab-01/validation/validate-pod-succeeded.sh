#!/usr/bin/env bash
# Check: behaviour. The Pod of the Job ended in the phase Succeeded.
set -uo pipefail

phase=""
for attempt in 1 2 3 4 5 6 7 8 9 10 11 12; do
  phase="$(kubectl -n starfleet get pod -l job-name=nightly-report -o jsonpath='{.items[0].status.phase}' 2>/dev/null)"
  [ "$phase" = "Succeeded" ] && break
  sleep 5
done
if [ "$phase" != "Succeeded" ]; then
  echo "FAIL: the Pod phase is '${phase}', expected Succeeded"
  exit 1
fi
echo "PASS: the Pod of nightly-report is Succeeded"
