---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Run Indexed Jobs And Set CronJob Policies — Task

The `starfleet` namespace holds a finished Job named `probe-scan` that ran as one plain Pod, and a CronJob named `shuttle-report` that uses default policies. The scan must now run as three numbered slices, and the report must never overlap itself.

Use the kubectl context of this lab:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-020-05-01)"
kubectl config current-context
```

The context must be `kind-astro-ats-027-lab-020-05-01`.

## Requirements

1. Replace the Job `probe-scan` in `starfleet` with a Job of the same name that uses `completionMode: Indexed`, `completions: 3` and `parallelism: 2`.
2. The Job must use `backoffLimit: 2`, `ttlSecondsAfterFinished: 600` and `restartPolicy: Never`.
3. Each Pod must print the line `scanned slice <index>`, where `<index>` is the value of the `JOB_COMPLETION_INDEX` environment variable. Use the image `docker.io/library/busybox:1.37.0`.
4. The Job must finish with completed indexes `0-2`.
5. Change the CronJob `shuttle-report` in `starfleet` so that it uses `concurrencyPolicy: Forbid`, `successfulJobsHistoryLimit: 2`, `failedJobsHistoryLimit: 1`, `timeZone: Europe/Copenhagen` and `startingDeadlineSeconds: 120`.
6. Keep the schedule `0 6 * * *`. Do not suspend the CronJob.

## Constraints

- Do not delete or recreate the CronJob.
- Do not change the namespace or the container image.
