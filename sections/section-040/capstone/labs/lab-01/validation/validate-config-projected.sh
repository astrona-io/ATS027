#!/usr/bin/env bash
# Check: /etc/probe is a read-only projected volume with probe.conf and labels, no subPath.
set -uo pipefail

kubectl -n starfleet rollout status deployment/probe --timeout=120s >/dev/null 2>&1 || true
pod="$(kubectl -n starfleet get pod -l app=probe --field-selector=status.phase=Running --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1:].metadata.name}' 2>/dev/null || true)"
if [ -z "$pod" ]; then
  echo "FAIL: no running probe Pod in starfleet"
  exit 1
fi

cv="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.spec.containers[?(@.name=="app")].volumeMounts[?(@.mountPath=="/etc/probe")].name}' 2>/dev/null || true)"
ro="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.spec.containers[?(@.name=="app")].volumeMounts[?(@.mountPath=="/etc/probe")].readOnly}' 2>/dev/null || true)"
sub="$(kubectl -n starfleet get pod "$pod" -o jsonpath='{.spec.containers[?(@.name=="app")].volumeMounts[*].subPath}' 2>/dev/null || true)"
cmn="$(kubectl -n starfleet get pod "$pod" -o jsonpath="{.spec.volumes[?(@.name==\"${cv}\")].projected.sources[*].configMap.name}" 2>/dev/null || true)"
dapi="$(kubectl -n starfleet get pod "$pod" -o jsonpath="{.spec.volumes[?(@.name==\"${cv}\")].projected.sources[*].downwardAPI.items[*].fieldRef.fieldPath}" 2>/dev/null || true)"

if [ -z "$cv" ]; then echo "FAIL: nothing is mounted at /etc/probe"; exit 1; fi
if [ "$cmn" != "probe-settings" ]; then echo "FAIL: the volume at /etc/probe has no projected ConfigMap source probe-settings (got '${cmn}')"; exit 1; fi
if [ "$dapi" != "metadata.labels" ]; then echo "FAIL: the volume at /etc/probe has no downward API source for metadata.labels (got '${dapi}')"; exit 1; fi
if [ "$ro" != "true" ]; then echo "FAIL: /etc/probe is not mounted read-only"; exit 1; fi
if [ -n "$sub" ]; then echo "FAIL: a volume mount still uses subPath '${sub}'"; exit 1; fi

conf="$(kubectl -n starfleet exec "$pod" -- cat /etc/probe/probe.conf 2>/dev/null || true)"
labels="$(kubectl -n starfleet exec "$pod" -- cat /etc/probe/labels 2>/dev/null || true)"
case "$conf" in *retention=7*) ;; *) echo "FAIL: /etc/probe/probe.conf does not contain retention=7"; exit 1 ;; esac
case "$labels" in *'app="probe"'*) ;; *) echo "FAIL: /etc/probe/labels does not contain app=\"probe\""; exit 1 ;; esac

echo "PASS: /etc/probe is a read-only projected volume with probe.conf and labels"
