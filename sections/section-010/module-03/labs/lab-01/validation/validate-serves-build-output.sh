#!/usr/bin/env bash
# Check: behaviour. shuttle requests the page from the Pod IP on port 8080.
set -uo pipefail
pod_ip="$(kubectl -n starfleet get pod site -o jsonpath='{.status.podIP}' 2>/dev/null)"
if [ -z "$pod_ip" ]; then
  echo "FAIL: Pod site has no IP address"
  exit 1
fi
body="$(kubectl -n starfleet exec shuttle -- wget -q -T 5 -O - "http://${pod_ip}:8080/" 2>/dev/null || true)"
case "$body" in
  *generated-at-build*) echo "PASS: the Pod serves the page generated in the build stage" ;;
  *) echo "FAIL: the response from port 8080 does not contain generated-at-build"; exit 1 ;;
esac
