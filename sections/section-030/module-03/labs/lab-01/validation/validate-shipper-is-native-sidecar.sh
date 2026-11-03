#!/usr/bin/env bash
# Check: structure. log-shipper is an init container with restartPolicy Always and
# no longer an ordinary container.
set -uo pipefail

policy="$(kubectl -n starfleet get job nightly-report -o jsonpath='{.spec.template.spec.initContainers[?(@.name=="log-shipper")].restartPolicy}' 2>/dev/null)"
if [ "$policy" != "Always" ]; then
  echo "FAIL: init container log-shipper has restartPolicy '${policy}', expected Always"
  exit 1
fi
names="$(kubectl -n starfleet get job nightly-report -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null)"
case " $names " in
  *" log-shipper "*) echo "FAIL: log-shipper is still in the containers list"; exit 1 ;;
esac
echo "PASS: log-shipper is a native sidecar"
