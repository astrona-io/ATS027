#!/usr/bin/env bash
# Check: probe-data is Bound, ReadWriteOnce, at least 1Gi, class standard.
set -uo pipefail


phase="$(kubectl -n starfleet get pvc probe-data -o jsonpath='{.status.phase}' 2>/dev/null || true)"
modes="$(kubectl -n starfleet get pvc probe-data -o jsonpath='{.spec.accessModes[*]}' 2>/dev/null || true)"
size="$(kubectl -n starfleet get pvc probe-data -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null || true)"
class="$(kubectl -n starfleet get pvc probe-data -o jsonpath='{.spec.storageClassName}' 2>/dev/null || true)"

if [ "$modes" != "ReadWriteOnce" ]; then echo "FAIL: probe-data access modes are '${modes}', expected ReadWriteOnce"; exit 1; fi
case "$size" in
  1Gi|2Gi|5Gi|10Gi) ;;
  *) echo "FAIL: probe-data requests '${size}', expected at least 1Gi"; exit 1 ;;
esac
if [ "$class" != "standard" ]; then echo "FAIL: probe-data uses class '${class}', expected standard"; exit 1; fi
if [ "$phase" != "Bound" ]; then echo "FAIL: probe-data phase is '${phase}', expected Bound"; exit 1; fi

echo "PASS: probe-data is Bound, ReadWriteOnce, ${size}, class standard"
