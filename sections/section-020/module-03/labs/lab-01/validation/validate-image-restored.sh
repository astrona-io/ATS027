#!/usr/bin/env bash
# Check: the template uses the working image and no Pod runs the broken one.
set -uo pipefail

image="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
if [ "$image" != "docker.io/library/busybox:1.37.0" ]; then
  echo "FAIL: the probe template image is '${image}', expected docker.io/library/busybox:1.37.0"
  exit 1
fi

pod_images="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{range .items[*]}{.spec.containers[0].image}{"\n"}{end}' 2>/dev/null || true)"
if echo "$pod_images" | grep -q 'broken'; then
  echo "FAIL: a Pod still uses the broken image"
  exit 1
fi

echo "PASS: probe uses the working image and no Pod uses the broken one"
