---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Run Indexed Jobs And Set CronJob Policies — Solution

This walkthrough solves the lab in order. After each step, run `astrona submit` to see which checks pass.

## Step 1: select the lab cluster

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-020-05-01)"
kubectl config current-context
```

## Step 2: replace the Job

A Job's mode, counts and Pod template cannot be edited after creation, so delete the old Job first:

```sh
kubectl -n starfleet delete job probe-scan
```

Save this as `job-probe-scan.yaml`:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: probe-scan
  namespace: starfleet
spec:
  completions: 3
  parallelism: 2
  completionMode: Indexed
  backoffLimit: 2
  ttlSecondsAfterFinished: 600
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: scan
        image: docker.io/library/busybox:1.37.0
        command: ["sh", "-c", "echo scanned slice $JOB_COMPLETION_INDEX"]
```

Apply it:

```sh
kubectl apply -f job-probe-scan.yaml
```

Then check the result:

```sh
kubectl -n starfleet get job probe-scan -o jsonpath='{.status.succeeded} {.status.completedIndexes}{"\n"}'
```

The Job reaches 3 succeeded Pods and the completed indexes `0-2`. Run `astrona submit`; the first two checks pass.

## Step 3: set the CronJob policies

Save this as `cronjob-shuttle-report-patch.yaml`:

```yaml
spec:
  timeZone: "Europe/Copenhagen"
  concurrencyPolicy: Forbid
  startingDeadlineSeconds: 120
  successfulJobsHistoryLimit: 2
  failedJobsHistoryLimit: 1
```

Apply it:

```sh
kubectl -n starfleet patch cronjob shuttle-report --patch-file cronjob-shuttle-report-patch.yaml
```

Then check the result:

```sh
kubectl -n starfleet get cronjob shuttle-report -o jsonpath='{.spec.concurrencyPolicy} {.spec.timeZone} {.spec.startingDeadlineSeconds}{"\n"}'
```

Run `astrona submit`. All four checks pass.

## Why this works

The Job controller creates the Pods, numbers them in Indexed mode and counts each success. The CronJob controller reads the new policy fields on its next sync. The CronJob keeps its schedule and its name, so only the policy changes.
