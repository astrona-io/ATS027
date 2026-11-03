---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Summary

An `emptyDir` is an empty directory that the kubelet creates when a Pod is scheduled to a node. Every container in the Pod can mount it. The directory survives container restarts, because the Pod stays on the node, and it is removed when the Pod is deleted, evicted or replaced. A new Pod always starts with a new, empty directory.

The `medium` field chooses where the data lives. The default is the node disk, which counts as node ephemeral storage. The value `Memory` creates a `tmpfs` in RAM, and its files count against the container memory limit. The `sizeLimit` field caps the volume: a disk volume above the limit leads to eviction of the Pod, and a memory volume is sized to the limit, so extra writes fail. A `hostPath` volume exposes a node directory instead, outlives the Pod and ties the Pod to one node, so it is risky for application data. A `subPath` mounts one subdirectory of a volume.

A generic ephemeral volume describes a PersistentVolumeClaim inside the Pod with `ephemeral.volumeClaimTemplate`. The ephemeral-volume controller in the `kube-controller-manager` creates a claim named `<pod>-<volume>` with the Pod as owner. The normal provisioning path binds it, and the garbage collector deletes the claim when the Pod is deleted. A normal claim is an independent object that outlives Pods.

Key facts:

- Container restart keeps `emptyDir` data, Pod replacement loses it.
- Memory-backed volumes count against the container memory limit.
- Generic ephemeral claims are named `<pod>-<volume>` and owned by the Pod.
- Use a normal claim for data that must outlive the Pod.

<!-- astrona:playground:destroy -->
