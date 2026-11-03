---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Deployment Updates, Scaling And Rollback

A Deployment is rarely created once and left alone. The image changes, the number of replicas changes, and sometimes a change is wrong. A developer must know what the cluster does during each of these events, how to watch it, and how to return to a working state without an outage.

This module follows the life of one Deployment after its first creation. It shows how a template change creates a new ReplicaSet, how the update strategy limits the number of Pods that are down or extra at one moment, and how the Deployment controller decides that a rollout succeeded or failed. It then covers scaling, the history of revisions and the rollback command.

## Learning objectives

- Explain how the Deployment controller uses one ReplicaSet for each revision of the Pod template.
- Choose between the `RollingUpdate` and `Recreate` strategies and set `maxSurge` and `maxUnavailable`.
- Use `minReadySeconds`, readiness probes and `progressDeadlineSeconds` to decide when a rollout counts as healthy or failed.
- Watch, pause, resume and inspect a rollout with `kubectl rollout`.
- Scale a Deployment and explain which tool owns the `replicas` field.
- Roll back to an earlier revision and diagnose a rollout that does not finish.

## Before you start

The playground is a single-node kind cluster with two namespaces and one running workload.

| Namespace | Contents |
| --- | --- |
| `starfleet` | The `probe` Deployment with three replicas of a `busybox` container that passes its readiness probe after it starts |
| `outpost` | An empty namespace for comparison |

You need the `astrona` command-line tool and `kubectl`. Use the kubeconfig that belongs to the playground for every command.

## Reading order

1. Rolling updates and rollout control: ReplicaSets per revision, the two strategies, readiness gating, pause and resume.
2. Scaling and rollback: the `replicas` field, revision history, rollback to a chosen revision and diagnosis of a failed rollout.
3. Summary.

<!-- astrona:playground -->
