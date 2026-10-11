#!/usr/bin/env bash
set -euo pipefail
test "$(kubectl config current-context)" = "kind-astro-ats-027-playground-020-02"
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

mkdir -p "$(dirname job-batch-report.yaml)"
cat > job-batch-report.yaml <<'CKAD_FILE_END'
apiVersion: batch/v1
kind: Job
metadata:
  name: batch-report
  namespace: starfleet
spec:
  backoffLimit: 1
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: report
        image: docker.io/library/busybox:1.37.0
        command:
        - sh
        - -c
        - printf "completed-work\n"
CKAD_FILE_END
kubectl apply -f job-batch-report.yaml
kubectl -n starfleet wait --for=condition=Complete job/batch-report --timeout=120s
kubectl -n starfleet logs job/batch-report
mkdir -p "$(dirname cronjob-scheduled-report.yaml)"
cat > cronjob-scheduled-report.yaml <<'CKAD_FILE_END'
apiVersion: batch/v1
kind: CronJob
metadata:
  name: scheduled-report
  namespace: starfleet
spec:
  schedule: '*/5 * * * *'
  suspend: true
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      backoffLimit: 1
      template:
        spec:
          restartPolicy: Never
          containers:
          - name: report
            image: docker.io/library/busybox:1.37.0
            command:
            - sh
            - -c
            - printf "completed-work\n"
CKAD_FILE_END
kubectl apply -f cronjob-scheduled-report.yaml
kubectl -n starfleet create job scheduled-manual --from=cronjob/scheduled-report
kubectl -n starfleet wait --for=condition=Complete job/scheduled-manual --timeout=120s
kubectl -n starfleet get cronjob scheduled-report -o yaml
kubectl -n starfleet get pods -o wide
kubectl -n starfleet delete job batch-report scheduled-manual
kubectl -n starfleet delete cronjob scheduled-report
test -z "$(kubectl -n starfleet get jobs -o name)"
printf 'ATS027/020/02: live practice checks passed\n'
