#!/usr/bin/env bash
set -euo pipefail
test "$(kubectl config current-context)" = "kind-astro-ats-027-playground-040-01"
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

mkdir -p "$(dirname pvc-probe-data.yaml)"
cat > pvc-probe-data.yaml <<'CKAD_FILE_END'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: probe-data
  namespace: starfleet
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 128Mi
CKAD_FILE_END
mkdir -p "$(dirname pod-volume-writer.yaml)"
cat > pod-volume-writer.yaml <<'CKAD_FILE_END'
apiVersion: v1
kind: Pod
metadata:
  name: volume-writer
  namespace: starfleet
spec:
  containers:
  - name: writer
    image: docker.io/library/busybox:1.37.0
    command:
    - sh
    - -c
    - sleep 3600
    volumeMounts:
    - name: data
      mountPath: /data
    - name: scratch
      mountPath: /scratch
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: probe-data
  - name: scratch
    emptyDir: {}
CKAD_FILE_END
kubectl apply -f pvc-probe-data.yaml
kubectl apply -f pod-volume-writer.yaml
kubectl -n starfleet wait --for=condition=Ready pod/volume-writer --timeout=120s
kubectl -n starfleet get pvc probe-data
kubectl -n starfleet exec volume-writer -- sh -c 'printf persistent > /data/marker; printf ephemeral > /scratch/marker'
kubectl -n starfleet exec volume-writer -- cat /data/marker /scratch/marker
kubectl -n starfleet delete pod volume-writer
kubectl apply -f pod-volume-writer.yaml
kubectl -n starfleet wait --for=condition=Ready pod/volume-writer --timeout=120s
kubectl -n starfleet exec volume-writer -- sh -c 'cat /data/marker; test ! -e /scratch/marker'
test "$(kubectl -n starfleet exec volume-writer -- cat /data/marker)" = persistent
printf 'ATS027/040/01: live practice checks passed\n'
