# Overview: Deployment Updates, Scaling And Rollback

This playground starts a fresh Kubernetes cluster with one Deployment and then waits. There is no task and no grading. Change the Deployment, break it on purpose, run `astrona destroy` and start again.

## What is in the box

The cluster has one node and Kubernetes 1.35. `kubectl` uses the cluster administrator account.

| Namespace | Contents |
| --- | --- |
| `starfleet` | The `probe` Deployment: three replicas of a `busybox` container named `probe`, with the environment variable `VERSION` set to `v1` and a readiness probe that reads `/tmp/ready` |
| `outpost` | Empty |

## Helpers

Paste these into each new terminal. `show_revisions` lists the ReplicaSets of an application with their revision numbers and replica counts. `show_pods` lists its Pods with the template hash. `show_conditions` prints the conditions of a Deployment.

```sh
show_revisions() {
  kubectl -n starfleet get replicaset -l app="$1" \
    -o 'custom-columns=NAME:.metadata.name,REVISION:.metadata.annotations.deployment\.kubernetes\.io/revision,DESIRED:.spec.replicas,READY:.status.readyReplicas'
}
show_pods() {
  kubectl -n starfleet get pods -l app="$1" -L pod-template-hash
}
show_conditions() {
  kubectl -n starfleet get deployment "$1" -o jsonpath='{range .status.conditions[*]}{.type}={.status} {.reason}{"\n"}{end}'
}
```

Use them like this: `show_revisions probe`, `show_pods probe`, `show_conditions probe`.

## Practice tasks

- Predict how many Pods `show_pods probe` lists during a rollout with `maxSurge: 1` and `maxUnavailable: 0`, then watch it.
- Pause the Deployment, make two template changes, resume and count the new ReplicaSets.
- Set `revisionHistoryLimit` to `1` and make three changes. Count the old ReplicaSets that remain.
- Switch the strategy to `Recreate` with `kubectl patch` (the patch must also set `rollingUpdate` to `null`) and watch the Pods during an update.
