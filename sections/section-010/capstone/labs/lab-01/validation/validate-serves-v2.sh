#!/usr/bin/env bash
# Check: behaviour. shuttle requests the page through the scout Service.
set -uo pipefail
body="$(kubectl -n starfleet exec shuttle -- wget -q -T 5 -O - http://scout.starfleet.svc.cluster.local/ 2>/dev/null || true)"
case "$body" in
  *release=v2*) echo "PASS: the scout Service returns release=v2" ;;
  *) echo "FAIL: the scout Service did not return release=v2"; exit 1 ;;
esac
