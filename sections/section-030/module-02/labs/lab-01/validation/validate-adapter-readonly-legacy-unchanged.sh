#!/usr/bin/env bash
# Check: structure. The adapter mounts the report read-only and the legacy
# container still runs the original program.
set -uo pipefail

NS=starfleet
wait_for_rollout() {
  kubectl -n "$NS" rollout status deployment/legacy-scout --timeout=120s >/dev/null 2>&1
}
find_pod() {
  kubectl -n "$NS" get pod -l app=legacy-scout --field-selector=status.phase=Running \
    -o jsonpath='{.items[0].metadata.name}' 2>/dev/null
}

flags="$(kubectl -n "$NS" get deployment legacy-scout -o jsonpath='{.spec.template.spec.containers[?(@.name=="adapter")].volumeMounts[*].readOnly}' 2>/dev/null)"
if [ -z "$flags" ]; then
  echo "FAIL: no container named adapter with volume mounts in the Pod template"
  exit 1
fi
for flag in $flags; do
  if [ "$flag" != "true" ]; then
    echo "FAIL: the adapter container has a volume mount that is not read-only"
    exit 1
  fi
done
args="$(kubectl -n "$NS" get deployment legacy-scout -o jsonpath='{.spec.template.spec.containers[?(@.name=="legacy")].args}' 2>/dev/null)"
case "$args" in
  *127.0.0.1:9000*) ;;
  *) echo "FAIL: the legacy container no longer calls 127.0.0.1:9000"; exit 1 ;;
esac
echo "PASS: the adapter mounts read-only and the legacy container is unchanged"
