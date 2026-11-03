---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Recover A Failed Deployment Rollout — Task

A release of the `probe` Deployment in the `starfleet` namespace used an image tag that does not exist, and the rollout is stuck. Restore the application, make future updates safer and add capacity.

Use the kubeconfig of the lab environment:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-020-03-01)"
```

## Requirements

1. Return the `probe` Deployment to its last working Pod template, so that the container image is `docker.io/library/busybox:1.37.0` and no Pod uses the broken image.
2. Set the update strategy to `RollingUpdate` with `maxUnavailable` set to `0` and `maxSurge` set to `1`.
3. Scale the Deployment to `4` replicas.
4. The rollout must be complete: every replica is updated, ready and available.

## Constraints

- Work in the `starfleet` namespace.
- Do not delete the `probe` Deployment. Repair the existing object.
- Do not change the container name, the labels or the selector.

When you are ready, run `astrona submit`.
