#!/usr/bin/env bash
# Check: Pod site exists, uses a local image with pull policy Never and is Ready.
set -uo pipefail
image="$(kubectl -n starfleet get pod site -o jsonpath='{.spec.containers[?(@.name=="web")].image}' 2>/dev/null)"
policy="$(kubectl -n starfleet get pod site -o jsonpath='{.spec.containers[?(@.name=="web")].imagePullPolicy}' 2>/dev/null)"
ready="$(kubectl -n starfleet get pod site -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)"
case "$image" in
  localhost/*) ;;
  *) echo "FAIL: container web image is '${image}', expected a name starting with localhost/"; exit 1 ;;
esac
if [ "$policy" != "Never" ]; then
  echo "FAIL: imagePullPolicy is '${policy}', expected Never"
  exit 1
fi
if [ "$ready" != "True" ]; then
  echo "FAIL: Pod site is not Ready"
  exit 1
fi
echo "PASS: Pod site runs ${image} with imagePullPolicy Never and is Ready"
