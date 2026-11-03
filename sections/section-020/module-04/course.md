---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# StatefulSets And Stable Identity

Some applications cannot treat their Pods as interchangeable. A database replica must keep the same name after a restart, so the other replicas can find it. It must also get the same disk back. A Deployment cannot promise either, because its Pods get random names and share one Pod template. A StatefulSet is the workload resource built for this case.

This module shows what a StatefulSet adds to a set of Pods: a name with an ordinal number, a DNS record for each Pod through a headless Service, one PersistentVolumeClaim for each Pod, and ordered creation, update and deletion.

## Learning objectives

- Explain how a StatefulSet names its Pods and why the names stay the same after a restart.
- Create a headless Service and use the DNS name of a single Pod.
- Choose between the `OrderedReady` and `Parallel` Pod management policies.
- Use `volumeClaimTemplates` to give each Pod its own storage, and explain what happens to the claims when Pods are deleted or scaled down.
- Update a StatefulSet in order, and use a partition to update only some Pods.
- Set `persistentVolumeClaimRetentionPolicy` for scale down and deletion.

## Before you start

The playground is a single-node kind cluster. The default StorageClass is `standard`, which creates volumes on the node automatically, so StatefulSet claims are bound without any setup.

| Namespace | Contents |
| --- | --- |
| `starfleet` | Empty. You create the StatefulSets here |
| `outpost` | The `drifter` Deployment, a `busybox` Pod that you use to run DNS lookups from outside the StatefulSet |

You need the `astrona` command-line tool and `kubectl`, with the kubeconfig of the playground selected.

## Reading order

1. Stable names and headless Services: ordinals, DNS for each Pod and the two Pod management policies.
2. Volume claim templates and ordered updates: storage for each Pod, claim retention, partitions and scale down.
3. Summary.

<!-- astrona:playground -->
