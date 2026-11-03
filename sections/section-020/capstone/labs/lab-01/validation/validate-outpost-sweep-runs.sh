#!/usr/bin/env bash
# Check: behaviour. A Job created from the CronJob template runs to completion.
set -uo pipefail

job="grader-sweep-$$"
if ! kubectl -n starfleet create job "$job" --from=cronjob/outpost-sweep >/dev/null 2>&1; then
  echo "FAIL: could not create a Job from cronjob/outpost-sweep"
  exit 1
fi

if kubectl -n starfleet wait --for=condition=complete "job/$job" --timeout=90s >/dev/null 2>&1; then
  kubectl -n starfleet delete job "$job" --wait=false >/dev/null 2>&1
  echo "PASS: a Job created from outpost-sweep completed"
  exit 0
fi

kubectl -n starfleet delete job "$job" --wait=false >/dev/null 2>&1
echo "FAIL: the Job created from outpost-sweep did not complete within 90 seconds"
exit 1
