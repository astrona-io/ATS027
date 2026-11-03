#!/usr/bin/env bash
# Check: behaviour. Deleting ledger-0 brings back a Pod with the same name and the same data.
set -uo pipefail

if ! kubectl -n starfleet exec ledger-0 -- sh -c 'echo kept > /data/marker' >/dev/null 2>&1; then
  echo "FAIL: could not write /data/marker in ledger-0; mount the claim template data at /data"
  exit 1
fi

old_uid="$(kubectl -n starfleet get pod ledger-0 -o jsonpath='{.metadata.uid}')"
kubectl -n starfleet delete pod ledger-0 --wait=true >/dev/null 2>&1

for _ in $(seq 1 120); do
  new_uid="$(kubectl -n starfleet get pod ledger-0 -o jsonpath='{.metadata.uid}' 2>/dev/null)"
  if [ -n "$new_uid" ] && [ "$new_uid" != "$old_uid" ] \
    && kubectl -n starfleet wait --for=condition=ready pod/ledger-0 --timeout=2s >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! kubectl -n starfleet wait --for=condition=ready pod/ledger-0 --timeout=5s >/dev/null 2>&1; then
  echo "FAIL: ledger-0 did not come back ready within 2 minutes"
  exit 1
fi

new_uid="$(kubectl -n starfleet get pod ledger-0 -o jsonpath='{.metadata.uid}')"
if [ "$new_uid" = "$old_uid" ]; then
  echo "FAIL: ledger-0 was not replaced"
  exit 1
fi

content="$(kubectl -n starfleet exec ledger-0 -- cat /data/marker 2>/dev/null)"
if [ "$content" != "kept" ]; then
  echo "FAIL: /data/marker is '$content' after the Pod was replaced, expected 'kept'"
  exit 1
fi

echo "PASS: ledger-0 came back with the same name and its data"
