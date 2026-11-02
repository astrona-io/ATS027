---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Create And Complete A Job

The `starfleet` application needs this task completed in its isolated lab environment.

## Objective

Run finite work with a Job and verify successful completion and its log.

## Starting state

The `starfleet` namespace exists and no Job named `report` has been created. A Job is a controller that runs a finite task until its required number of successful completions is reached.

Use this lab's private kubeconfig. A kubeconfig contains the cluster address and credentials used by kubectl, the Kubernetes command-line tool. The lab has a separate kind cluster from the module playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-020-02-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-020-02-01" || exit 1
```

Keep this connection selected for every command below.

## Required result

Create Job `report` in `starfleet`. Use container `report` with image `docker.io/library/busybox:1.37.0`, command `sh -c` with the script `printf 'report-complete\n'`, Pod restart policy `Never`, one completion, parallelism one and `backoffLimit: 2`. Keep the completed Job for grading. It must report a successful Complete condition and its Pod log must contain a line `report-complete`.

## Verify the result

Inspect the required fields and observe the actual result. The grader checks both the resource contract and the running behavior. Wait for controller convergence before submitting.
