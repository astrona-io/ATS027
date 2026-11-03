#!/usr/bin/env bash
# Check: structure. The report container is still the only application container
# and the Job has no deadline that would hide a stuck Pod.
set -uo pipefail

names="$(kubectl -n starfleet get job nightly-report -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null)"
if [ "$names" != "report" ]; then
  echo "FAIL: containers are '${names}', expected only 'report'"
  exit 1
fi
args="$(kubectl -n starfleet get job nightly-report -o jsonpath='{.spec.template.spec.containers[0].args}' 2>/dev/null)"
case "$args" in
  *"reading"*) ;;
  *) echo "FAIL: the report container no longer writes the readings"; exit 1 ;;
esac
deadline="$(kubectl -n starfleet get job nightly-report -o jsonpath='{.spec.activeDeadlineSeconds}' 2>/dev/null)"
if [ -n "$deadline" ]; then
  echo "FAIL: the Job sets activeDeadlineSeconds=${deadline}; fix the Pod, not the deadline"
  exit 1
fi
echo "PASS: report is unchanged and the Job has no deadline"
