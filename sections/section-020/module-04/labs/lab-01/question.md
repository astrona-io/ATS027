---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Build A StatefulSet With Per-Pod Storage — Task

The `shuttle` service in the `starfleet` namespace must run as three members that keep their names and their data. A normal Service named `shuttle` already exists but gives the Pods no individual DNS names. Build the StatefulSet and fix the Service.

Use the kubeconfig of the lab environment:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-020-04-01)"
```

## Requirements

1. Make the Service `shuttle` in `starfleet` a headless Service that selects Pods with the label `app: shuttle`.
2. Create a StatefulSet named `shuttle` in `starfleet` with `3` replicas, governed by the Service `shuttle`. Use the image `docker.io/library/busybox:1.37.0`, the command `sh -c "sleep 36000"` and the label `app: shuttle` on the Pods.
3. Give each Pod its own storage with a volume claim template named `data`, `100Mi`, `ReadWriteOnce`, mounted at `/data`.
4. The Pods `shuttle-0`, `shuttle-1` and `shuttle-2` must be ready, and the name `shuttle-1.shuttle.starfleet.svc.cluster.local` must resolve to the IP address of `shuttle-1`.
5. Set the claim retention policy so that claims are deleted when the StatefulSet scales down and kept when the StatefulSet is deleted.

## Constraints

- Work in the `starfleet` namespace.
- Use the default StorageClass.
- Data written to `/data` must still exist after a Pod is deleted and replaced. The grader deletes `shuttle-1` to check this.

When you are ready, run `astrona submit`.
