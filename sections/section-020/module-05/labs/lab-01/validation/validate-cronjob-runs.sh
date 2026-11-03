#!/usr/bin/env bash
# Check: behaviour. A Job created from the CronJob template runs to completion.
set -uo pipefail

suspended="$(kubectl -n starfleet get cronjob shuttle-report -o jsonpath='{.spec.suspend}' 2>/dev/null)"
if [ "$suspended" = "true" ]; then
  echo "FAIL: CronJob shuttle-report is suspended"
  exit 1
fi

job="grader-check-$$"
if ! kubectl -n starfleet create job "$job" --from=cronjob/shuttle-report >/dev/null 2>&1; then
  echo "FAIL: could not create a Job from cronjob/shuttle-report"
  exit 1
fi

if kubectl -n starfleet wait --for=condition=complete "job/$job" --timeout=90s >/dev/null 2>&1; then
  kubectl -n starfleet delete job "$job" --wait=false >/dev/null 2>&1
  echo "PASS: a Job created from shuttle-report completed"
  exit 0
fi

kubectl -n starfleet delete job "$job" --wait=false >/dev/null 2>&1
echo "FAIL: the Job created from shuttle-report did not complete within 90 seconds"
exit 1
