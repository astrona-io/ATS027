---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Trigger A Job From A Suspended CronJob Solution

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-020-02-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-020-02-02" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.

## Inspect And Explain

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Inspect the relevant evidence:

```sh
kubectl -n starfleet get pods
kubectl -n starfleet get deployment probe -o yaml
```

A CronJob creates Jobs on a schedule. Suspending it blocks automatic scheduling but still allows an explicit Job creation from its template. The concurrency policy affects scheduled overlaps. Completing the manually triggered Job verifies the finite workload without a time-sensitive wait.


Save this as `cronjob-scheduled-report.yaml`:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: scheduled-report
  namespace: starfleet
spec:
  schedule: '*/5 * * * *'
  concurrencyPolicy: Forbid
  suspend: true
  jobTemplate:
    spec:
      backoffLimit: 2
      template:
        spec:
          restartPolicy: Never
          containers:
          - name: report
            image: docker.io/library/busybox:1.37.0
            command:
            - sh
            - -c
            - printf 'scheduled-report\n'
```

Apply the required change:

```sh
kubectl apply -f cronjob-scheduled-report.yaml
kubectl -n starfleet create job scheduled-once --from=cronjob/scheduled-report
```

## Verify The Result

Observe the actual result. A denied-request command returns a nonzero status when the denial works. Run denial checks separately from a shell sequence that stops on the first nonzero status.

```sh
kubectl -n starfleet wait --for=condition=Complete job/scheduled-once --timeout=180s
kubectl -n starfleet logs job/scheduled-once
```

Create suspended CronJob `scheduled-report` with schedule `*/5 * * * *`, `concurrencyPolicy: Forbid` and the shown finite report command. Keep it suspended so the exercise creates no automatic work. Trigger Job `scheduled-once` from its template. That Job must complete and log `scheduled-report`.

After recording the result, remove this independent lab with `astrona destroy ats-027-lab-020-02-02`.

## Common pitfalls

> [!WARNING]
> Keep the CronJob suspended to avoid automatic extra Jobs. Create the named one-off Job from its template. A printed log line alone does not prove successful process termination.
