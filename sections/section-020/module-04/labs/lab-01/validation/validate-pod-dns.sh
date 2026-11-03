#!/usr/bin/env bash
# Check: the DNS name of one Pod resolves to that Pod's IP address.
set -uo pipefail

pod_ip="$(kubectl -n starfleet get pod shuttle-1 -o jsonpath='{.status.podIP}' 2>/dev/null || true)"
if [ -z "$pod_ip" ]; then
  echo "FAIL: pod shuttle-1 has no IP address"
  exit 1
fi

answer="$(kubectl -n starfleet exec shuttle-0 -- nslookup shuttle-1.shuttle.starfleet.svc.cluster.local 2>&1 || true)"
if ! echo "$answer" | grep -q "$pod_ip"; then
  echo "FAIL: shuttle-1.shuttle.starfleet.svc.cluster.local did not resolve to ${pod_ip}"
  exit 1
fi

echo "PASS: shuttle-1.shuttle.starfleet.svc.cluster.local resolves to ${pod_ip}"
