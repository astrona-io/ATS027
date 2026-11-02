#!/usr/bin/env bash
set -euo pipefail
test "$(kubectl config current-context)" = "kind-astro-ats-027-playground-030-01"
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

mkdir -p "$(dirname pod-shared-work.yaml)"
cat > pod-shared-work.yaml <<'CKAD_FILE_END'
apiVersion: v1
kind: Pod
metadata:
  name: shared-work
  namespace: starfleet
spec:
  containers:
  - name: main
    image: docker.io/library/busybox:1.37.0
    command:
    - sh
    - -c
    - cat /shared/message; sleep 3600
    volumeMounts:
    - name: shared
      mountPath: /shared
  - name: observer
    image: docker.io/library/busybox:1.37.0
    command:
    - sh
    - -c
    - sleep 3600
    volumeMounts:
    - name: shared
      mountPath: /shared
  initContainers:
  - name: prepare
    image: docker.io/library/busybox:1.37.0
    command:
    - sh
    - -c
    - printf "prepared\n" > /shared/message
    volumeMounts:
    - name: shared
      mountPath: /shared
  volumes:
  - name: shared
    emptyDir: {}
CKAD_FILE_END
kubectl apply -f pod-shared-work.yaml
kubectl -n starfleet wait --for=condition=Ready pod/shared-work --timeout=120s
kubectl -n starfleet get pod shared-work -o yaml
kubectl -n starfleet logs shared-work -c main
kubectl -n starfleet exec shared-work -c observer -- cat /shared/message
kubectl -n starfleet logs shared-work -c prepare
kubectl -n starfleet exec shared-work -c observer -- sh -c 'printf "changed\n" > /shared/message'
kubectl -n starfleet exec shared-work -c main -- cat /shared/message
test "$(kubectl -n starfleet exec shared-work -c main -- cat /shared/message)" = changed
printf 'ATS027/030/01: live practice checks passed\n'
