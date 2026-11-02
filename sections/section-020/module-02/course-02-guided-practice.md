---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Complete A Job And Trigger Scheduled Work Deliberately

Finite work should produce completion evidence rather than remain as a continuously running application. You will run a Job and define a suspended CronJob whose template can be triggered manually. Suspension keeps the timed exercise predictable while preserving the scheduling contract for inspection.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

A successful process exit contributes to Job completion, while a continuously running process would prevent finite work from finishing. Inspect the Job's completion and retry settings independently of the CronJob schedule.

The practice schedule is suspended so it does not create repeated background work. Creating one Job from its template is a deliberate execution with its own lifecycle. That execution can still produce external effects, so real scheduled applications need safe repeated writes and an overlap policy matched to their duration.

<!-- astrona:playground:renew -->

For a timed catalog session, renew this module before continuing. Skip renewal for an untimed local author run:

```sh
astrona run renew astrona-io/ATS027/section-020/module-02/playground
```

Select the module environment and define a bounded retry helper:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-playground-020-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-playground-020-02"
kubectl -n starfleet get pods
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}
```

Save a Job that writes one report and exits. Its restart and retry policies constrain how failed work would be retried.

Save this as `job-batch-report.yaml`:

```yaml
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
```

Apply or use the saved input, then check the result:

```sh
kubectl apply -f job-batch-report.yaml
kubectl -n starfleet wait --for=condition=Complete job/batch-report --timeout=120s
kubectl -n starfleet logs job/batch-report
```

A completed Job is controller evidence for the finite operation. The log is application evidence. Neither proves that arbitrary external side effects are exactly once.

Save a suspended CronJob and create one explicit Job from its template. This lets you inspect the scheduled resource without waiting for a wall-clock boundary.

Save this as `cronjob-scheduled-report.yaml`:

```yaml
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
```

Apply or use the saved input, then check the result:

```sh
kubectl apply -f cronjob-scheduled-report.yaml
kubectl -n starfleet create job scheduled-manual --from=cronjob/scheduled-report
kubectl -n starfleet wait --for=condition=Complete job/scheduled-manual --timeout=120s
kubectl -n starfleet get cronjob scheduled-report -o yaml
```

Forbid controls overlapping Jobs from that CronJob scheduler. It is not a universal lock on every manually created Job or external operation.

Inspect owner and exit evidence, then remove the practice resources.

```sh
kubectl -n starfleet get pods -o wide
kubectl -n starfleet delete job batch-report scheduled-manual
kubectl -n starfleet delete cronjob scheduled-report
```

Deleting the controller resources removes the exercise objects. It cannot reverse messages or writes an application already produced outside Kubernetes.

Choose finite and scheduled controllers from the operation lifecycle. Retried work should tolerate duplicate attempts or use an appropriate idempotency contract. A schedule and concurrency setting reduce selected risks without proving global exactly-once execution.

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
