#!/usr/bin/env bash
set -euo pipefail
test "$(kubectl config current-context)" = "kind-astro-ats-027-playground-020-01"
practice_directory="$(mktemp -d)"
cleanup() {
  if [[ -n "${PORT_FORWARD_PID:-}" ]]; then kill "$PORT_FORWARD_PID" 2>/dev/null || true; fi
  rm -rf "$practice_directory"
}
trap cleanup EXIT
cd "$practice_directory"
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}

kubectl get nodes -o wide
kubectl -n starfleet scale deployment/probe --replicas=3
kubectl -n starfleet rollout status deployment/probe --timeout=120s
kubectl -n starfleet get pods -o wide
mkdir -p "$(dirname daemonset-node-report.yaml)"
cat > daemonset-node-report.yaml <<'CKAD_FILE_END'
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-report
  namespace: starfleet
spec:
  selector:
    matchLabels:
      app: node-report
  template:
    metadata:
      labels:
        app: node-report
    spec:
      containers:
      - name: report
        image: docker.io/library/busybox:1.37.0
        command:
        - sh
        - -c
        - sleep 3600
CKAD_FILE_END
kubectl apply -f daemonset-node-report.yaml
kubectl -n starfleet rollout status daemonset/node-report --timeout=120s
kubectl -n starfleet get daemonset node-report -o yaml
kubectl -n starfleet get pods -l app=node-report -o wide
kubectl -n starfleet scale deployment/probe --replicas=2
kubectl -n starfleet delete daemonset node-report
kubectl -n starfleet rollout status deployment/probe --timeout=120s
test "$(kubectl -n starfleet get deploy probe -o jsonpath='{.spec.replicas}')" = 2
printf 'ATS027/020/01: live practice checks passed\n'
