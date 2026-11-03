# Overview: Native Sidecar Containers And Pod Lifecycle (Playground)

This is a playground, not a lab. It starts a fresh cluster with a few workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Create Pods and Jobs, break them, run `astrona destroy` and start over.

## What is in the box

A single-node kind cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.

| Object | What it is |
| --- | --- |
| Namespace `starfleet` | Holds the workloads below |
| Namespace `outpost` | Holds the `drifter` client Pod |
| Deployment and Service `probe` | A small web server that answers every request with the text `probe-nominal` |
| Pods `shuttle` and `drifter` | Plain busybox client Pods |
| Job `stuck-report` | A Job with two ordinary containers. `report` writes three lines to a shared volume and exits. `log-shipper` follows the file forever and prints `shipped:` lines. Because the shipper never exits, the Job never completes |

## Helpers

Paste these into each new terminal. `pod_init_state` prints the name, started flag and ready flag of every init container of a Pod. `job_state` prints the active, succeeded and failed counters of a Job.

```sh
pod_init_state() {
  kubectl -n starfleet get pod "$1" \
    -o jsonpath='{range .status.initContainerStatuses[*]}{.name}{" started="}{.started}{" ready="}{.ready}{"\n"}{end}'
}
job_state() {
  kubectl -n starfleet get job "$1" \
    -o jsonpath='{"active="}{.status.active}{" succeeded="}{.status.succeeded}{" failed="}{.status.failed}{"\n"}'
}
```

Use them like this: `job_state stuck-report` and `pod_init_state <pod name>`.

## Practice tasks

- Read the state of `stuck-report` and find which container keeps the Pod alive.
- Start a Pod with one ordinary init container and one init container with `restartPolicy: Always`, and compare how their statuses change.
- Delete a Pod that has two sidecars and watch the order in which they stop.
- Give a sidecar a `startupProbe` that fails for a while and watch the main container wait.
