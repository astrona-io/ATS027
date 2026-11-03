#!/usr/bin/env bash
# Check: behaviour. shuttle requests the page through the probe Service.
set -uo pipefail
body="$(kubectl -n starfleet exec shuttle -- wget -q -T 5 -O - http://probe.starfleet.svc.cluster.local/ 2>/dev/null || true)"
case "$body" in
  *image-version=v2*) echo "PASS: the probe Service returns image-version=v2" ;;
  *) echo "FAIL: the probe Service did not return image-version=v2"; exit 1 ;;
esac
