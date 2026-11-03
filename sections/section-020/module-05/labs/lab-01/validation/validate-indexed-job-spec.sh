#!/usr/bin/env bash
# Check: the Job object has the required mode, counts and limits.
set -uo pipefail

field() { kubectl -n starfleet get job probe-scan -o "jsonpath=$1" 2>/dev/null; }

if ! kubectl -n starfleet get job probe-scan >/dev/null 2>&1; then
  echo "FAIL: Job probe-scan not found in starfleet"
  exit 1
fi

fail=0
check() {
  local label="$1" want="$2" got="$3"
  if [ "$got" != "$want" ]; then
    echo "FAIL: $label is '$got', expected '$want'"
    fail=1
  fi
}
check completionMode Indexed "$(field '{.spec.completionMode}')"
check completions 3 "$(field '{.spec.completions}')"
check parallelism 2 "$(field '{.spec.parallelism}')"
check backoffLimit 2 "$(field '{.spec.backoffLimit}')"
check ttlSecondsAfterFinished 600 "$(field '{.spec.ttlSecondsAfterFinished}')"
check restartPolicy Never "$(field '{.spec.template.spec.restartPolicy}')"

if [ "$fail" -ne 0 ]; then
  exit 1
fi
echo "PASS: probe-scan is Indexed with completions 3, parallelism 2, backoffLimit 2, ttl 600, restartPolicy Never"
