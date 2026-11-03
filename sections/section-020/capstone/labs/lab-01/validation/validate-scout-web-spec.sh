#!/usr/bin/env bash
# Check: kind and fields. scout-web is a Deployment with a safe rollout configuration.
set -uo pipefail

if ! kubectl -n starfleet get deployment scout-web >/dev/null 2>&1; then
  echo "FAIL: Deployment scout-web not found in starfleet"
  exit 1
fi
if kubectl -n starfleet get pod scout-web >/dev/null 2>&1; then
  echo "FAIL: the bare Pod scout-web still exists"
  exit 1
fi

field() { kubectl -n starfleet get deployment scout-web -o "jsonpath=$1" 2>/dev/null; }

fail=0
replicas="$(field '{.spec.replicas}')"
ready="$(field '{.status.readyReplicas}')"
strategy="$(field '{.spec.strategy.type}')"
unavailable="$(field '{.spec.strategy.rollingUpdate.maxUnavailable}')"
surge="$(field '{.spec.strategy.rollingUpdate.maxSurge}')"
probe="$(field '{.spec.template.spec.containers[0].readinessProbe}')"

[ "$replicas" = "3" ] || { echo "FAIL: replicas is '$replicas', expected 3"; fail=1; }
[ "${ready:-0}" = "3" ] || { echo "FAIL: readyReplicas is '${ready:-0}', expected 3"; fail=1; }
[ "$strategy" = "RollingUpdate" ] || { echo "FAIL: strategy is '$strategy', expected RollingUpdate"; fail=1; }
case "$unavailable" in
  0|0%) ;;
  *) echo "FAIL: maxUnavailable is '$unavailable', expected 0"; fail=1 ;;
esac
case "$surge" in
  ""|0|0%) echo "FAIL: maxSurge is '$surge', it must allow at least one extra Pod"; fail=1 ;;
esac
[ -n "$probe" ] || { echo "FAIL: the first container has no readinessProbe"; fail=1; }

[ "$fail" -eq 0 ] || exit 1
echo "PASS: scout-web is a Deployment with 3 ready replicas, a readiness probe, maxUnavailable 0 and a surge"
