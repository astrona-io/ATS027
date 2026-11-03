---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Summary

A Deployment manages Pods through ReplicaSets. Each distinct Pod template has its own ReplicaSet, and the name of the ReplicaSet ends with a hash of that template. A change to the template creates a new ReplicaSet and starts a rollout. A change to the replica count does not.

During a rolling update the Deployment controller scales the new ReplicaSet up and the old one down. The fields `maxSurge` and `maxUnavailable` limit how many Pods may be extra or missing at one time. Setting `maxUnavailable` to zero keeps the full capacity during the update, at the cost of one extra Pod. The `Recreate` strategy removes all old Pods first, so it causes downtime and suits only applications that cannot run two versions together.

A rollout moves forward only when the new Pods are available. A readiness probe decides when a Pod is ready, `minReadySeconds` adds a waiting time, and `progressDeadlineSeconds` sets how long the controller waits before it reports `ProgressDeadlineExceeded`. The controller reports the failure but does not roll back. The old Pods keep serving while the rollout is stuck.

The commands `kubectl rollout status`, `history`, `pause`, `resume` and `undo` control and inspect a rollout. The history lists the revisions that still have a ReplicaSet, limited by `revisionHistoryLimit`. The annotation `kubernetes.io/change-cause` gives each revision a readable reason. A rollback reuses an old ReplicaSet and gives it the next revision number.

Several tools can write `spec.replicas`: `kubectl scale`, `kubectl apply` and an autoscaler. The last writer wins, so a manifest that is managed together with an autoscaler should not contain the field.

Key facts:

- Default strategy: `RollingUpdate` with 25 percent for both `maxSurge` and `maxUnavailable`.
- Default `progressDeadlineSeconds`: 600. Default `revisionHistoryLimit`: 10.
- `kubectl rollout undo --to-revision=N` rolls back the Pod template only.

<!-- astrona:playground:destroy -->
