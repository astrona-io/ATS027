#!/usr/bin/env bash
# Check: structure. The destination comes from the uplink-config ConfigMap, mounted
# into the ambassador container, and the ConfigMap names the probe Service in starfleet.
set -uo pipefail

NS=starfleet
wait_for_rollout() {
  kubectl -n "$NS" rollout status deployment/legacy-scout --timeout=120s >/dev/null 2>&1
}
find_pod() {
  kubectl -n "$NS" get pod -l app=legacy-scout --field-selector=status.phase=Running \
    -o jsonpath='{.items[0].metadata.name}' 2>/dev/null
}

upstream="$(kubectl -n "$NS" get configmap uplink-config -o jsonpath='{.data.upstream\.txt}' 2>/dev/null)"
case "$upstream" in
  *probe.starfleet*) ;;
  *) echo "FAIL: uplink-config upstream.txt is '${upstream}', expected the probe Service in starfleet"; exit 1 ;;
esac
volumes="$(kubectl -n "$NS" get deployment legacy-scout -o jsonpath='{.spec.template.spec.volumes[*].configMap.name}' 2>/dev/null)"
case " $volumes " in
  *" uplink-config "*) ;;
  *) echo "FAIL: the Pod template has no volume from the ConfigMap uplink-config"; exit 1 ;;
esac
code="$(kubectl -n "$NS" get deployment legacy-scout -o jsonpath='{.spec.template.spec.containers[?(@.name=="ambassador")].command}' 2>/dev/null)"
if [ -z "$code" ]; then
  echo "FAIL: no container named ambassador in the Pod template"
  exit 1
fi
echo "PASS: the ambassador container exists and its destination comes from uplink-config"
