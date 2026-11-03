#!/usr/bin/env bash
# Check: the CronJob has the required policy fields and keeps its schedule.
set -uo pipefail

if ! kubectl -n starfleet get cronjob shuttle-report >/dev/null 2>&1; then
  echo "FAIL: CronJob shuttle-report not found in starfleet"
  exit 1
fi

field() { kubectl -n starfleet get cronjob shuttle-report -o "jsonpath=$1" 2>/dev/null; }

fail=0
check() {
  local label="$1" want="$2" got="$3"
  if [ "$got" != "$want" ]; then
    echo "FAIL: $label is '$got', expected '$want'"
    fail=1
  fi
}
check schedule "0 6 * * *" "$(field '{.spec.schedule}')"
check concurrencyPolicy Forbid "$(field '{.spec.concurrencyPolicy}')"
check successfulJobsHistoryLimit 2 "$(field '{.spec.successfulJobsHistoryLimit}')"
check failedJobsHistoryLimit 1 "$(field '{.spec.failedJobsHistoryLimit}')"
check timeZone Europe/Copenhagen "$(field '{.spec.timeZone}')"
check startingDeadlineSeconds 120 "$(field '{.spec.startingDeadlineSeconds}')"

if [ "$fail" -ne 0 ]; then
  exit 1
fi
echo "PASS: shuttle-report has Forbid, history 2 and 1, Europe/Copenhagen and a 120 second deadline"
