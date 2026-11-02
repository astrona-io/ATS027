#!/usr/bin/env bash
set -euo pipefail
test "$(kubectl config current-context)" = "kind-astro-ats-027-playground-010-02"
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

mkdir -p image-work
mkdir -p "$(dirname image-work/Dockerfile)"
cat > image-work/Dockerfile <<'CKAD_FILE_END'
FROM docker.io/library/python:3.13-alpine
WORKDIR /site
COPY index.html .
USER 1000:1000
EXPOSE 8000
CMD ["python", "-m", "http.server", "8000"]
CKAD_FILE_END
mkdir -p "$(dirname image-work/index.html)"
cat > image-work/index.html <<'CKAD_FILE_END'
image-version=v1
CKAD_FILE_END
podman build -t localhost/ats027-practice-probe:v1 image-work
podman image inspect localhost/ats027-practice-probe:v1
podman save -o probe-image.tar localhost/ats027-practice-probe:v1
KIND_EXPERIMENTAL_PROVIDER=podman kind load image-archive probe-image.tar --name astro-ats-027-playground-010-02
mkdir -p "$(dirname pod-image-probe.yaml)"
cat > pod-image-probe.yaml <<'CKAD_FILE_END'
apiVersion: v1
kind: Pod
metadata:
  name: image-probe
  namespace: starfleet
spec:
  containers:
  - name: web
    image: localhost/ats027-practice-probe:v1
    imagePullPolicy: Never
    ports:
    - containerPort: 8000
  restartPolicy: Never
CKAD_FILE_END
kubectl apply -f pod-image-probe.yaml
kubectl -n starfleet wait --for=condition=Ready pod/image-probe --timeout=120s
kubectl -n starfleet exec image-probe -- id
IMAGE_POD_IP=$(kubectl -n starfleet get pod image-probe -o jsonpath='{.status.podIP}')
wait_for_success kubectl -n starfleet exec shuttle -- wget -qO- "http://${IMAGE_POD_IP}:8000/"
test "$(kubectl -n starfleet exec image-probe -- id -u)" = 1000
printf 'ATS027/010/02: live practice checks passed\n'
