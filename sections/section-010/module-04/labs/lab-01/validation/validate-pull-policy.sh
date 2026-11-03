#!/usr/bin/env bash
# Check: imagePullPolicy is Never on the Deployment.
set -uo pipefail
policy="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.containers[0].imagePullPolicy}' 2>/dev/null)"
if [ "$policy" != "Never" ]; then
  echo "FAIL: imagePullPolicy is '${policy}', expected Never"
  exit 1
fi
echo "PASS: imagePullPolicy is Never"
