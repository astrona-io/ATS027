#!/usr/bin/env bash
# Check: kind and fields. outpost-sweep is a CronJob and no longer a Deployment.
set -uo pipefail

if kubectl -n starfleet get deployment outpost-sweep >/dev/null 2>&1; then
  echo "FAIL: a Deployment named outpost-sweep still exists"
  exit 1
fi
if ! kubectl -n starfleet get cronjob outpost-sweep >/dev/null 2>&1; then
  echo "FAIL: CronJob outpost-sweep not found in starfleet"
  exit 1
fi

field() { kubectl -n starfleet get cronjob outpost-sweep -o "jsonpath=$1" 2>/dev/null; }

fail=0
check() {
  local label="$1" want="$2" got="$3"
  if [ "$got" != "$want" ]; then
    echo "FAIL: $label is '$got', expected '$want'"
    fail=1
  fi
}
check schedule "*/15 * * * *" "$(field '{.spec.schedule}')"
check concurrencyPolicy Forbid "$(field '{.spec.concurrencyPolicy}')"
check failedJobsHistoryLimit 1 "$(field '{.spec.failedJobsHistoryLimit}')"

[ "$fail" -eq 0 ] || exit 1
echo "PASS: outpost-sweep is a CronJob with schedule */15 * * * *, Forbid and one failed Job kept"
