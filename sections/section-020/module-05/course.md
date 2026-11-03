---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Job Parallelism, Completion Modes And CronJob Policies

A nightly scan must process three slices of data, but the cluster should run at most two slices at a time. A scan that crashes on one slice must not retry forever, and a scan that hangs must not hold a Pod for days. A report that runs every morning must not start a second copy while the first one is still running. A plain Pod or a Deployment cannot express any of this, because both try to keep a Pod running forever.

A Job runs Pods until a fixed number of them finish successfully. A CronJob creates Jobs on a clock. Both have fields that decide how many Pods run at once, how failures are counted, when work stops and how finished objects are removed. This module explains each field, the component that enforces it and the failure it prevents.

## Learning objectives

- Explain how the Job controller creates Pods and counts them with `completions` and `parallelism`.
- Use `completionMode: Indexed` and read the `JOB_COMPLETION_INDEX` environment variable.
- Limit retries with `backoffLimit`, and choose between `restartPolicy: Never` and `OnFailure`.
- Stop work with `activeDeadlineSeconds` and remove finished Jobs with `ttlSecondsAfterFinished`.
- Write a CronJob with a schedule, `timeZone`, `concurrencyPolicy` and `startingDeadlineSeconds`.
- Control history with `successfulJobsHistoryLimit` and `failedJobsHistoryLimit`, suspend a CronJob and create a Job from it by hand.

## Before you start

You need the module playground. It is a one-node Kubernetes 1.35 cluster with these objects:

| Namespace | Object | Purpose |
| --- | --- | --- |
| `starfleet` | Deployment `scout` | One long-running Pod, for comparison with Jobs |
| `outpost` | CronJob `outpost-sweep` | A CronJob that runs every ten minutes |

You should know what a Pod, a container and a controller are, and how to run `kubectl apply` and `kubectl get`.

## Reading order

1. Completions, parallelism and failure limits: how a Job decides how many Pods to create, how Indexed mode numbers them, and when a Job stops.
2. CronJob schedules and history policies: how a CronJob creates Jobs, what the overlap and deadline fields do, and how to suspend or trigger a CronJob.
3. Summary.

<!-- astrona:playground -->
