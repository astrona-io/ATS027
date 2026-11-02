---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Create And Complete A Job Solution

Use this lab's private kubeconfig. A kubeconfig contains the cluster address and credentials used by kubectl, the Kubernetes command-line tool. The lab has a separate kind cluster from the module playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-020-02-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-020-02-01" || exit 1
```

Keep this connection selected for every command below.

## Diagnose The Starting State

The `starfleet` namespace exists and no Job named `report` has been created. A Job is a controller that runs a finite task until its required number of successful completions is reached.

Inspect the relevant objects:

```sh
kubectl -n starfleet get jobs
```

The Job controller creates a Pod from the template and records successful completion after the process exits with status zero. `Never` leaves failed containers stopped; the Job controller can create another Pod within its retry limit. A log line alone does not prove successful termination.

Save this as `job-report.yaml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: report
  namespace: starfleet
spec:
  completions: 1
  parallelism: 1
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
        - printf 'report-complete\n'
```

Apply it:

```sh
kubectl apply -f job-report.yaml
```

## Verify The Result

Observe the actual result with these bounded checks. No example transcript is provided as evidence of a completed run.

```sh
kubectl -n starfleet wait --for=condition=Complete job/report --timeout=180s
kubectl -n starfleet logs job/report
```

Create Job `report` in `starfleet`. Use container `report` with image `docker.io/library/busybox:1.37.0`, command `sh -c` with the script `printf 'report-complete\n'`, Pod restart policy `Never`, one completion, parallelism one and `backoffLimit: 2`. Keep the completed Job for grading. It must report a successful Complete condition and its Pod log must contain a line `report-complete`.

After recording your result, remove this lab with `astrona destroy ats-027-lab-020-02-01`.

## Common pitfalls

> [!WARNING]
> Verify the lab context before making changes. A matching field alone does not prove the required behavior. Preserve the objects and access limits named in the task.
