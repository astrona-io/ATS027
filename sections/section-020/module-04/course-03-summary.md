---
draft: true
exam_objectives:
- Choose and use the right workload resource (Deployment, DaemonSet, CronJob, etc.)
---
# Summary

A StatefulSet creates Pods with stable identities. Each Pod is named after the StatefulSet and an ordinal number that starts at zero. When a Pod is deleted, the controller creates a replacement with the same name, the same hostname and the same storage, but a new IP address.

A headless Service, which has `clusterIP: None`, publishes the names. The `serviceName` field links the StatefulSet to it, and the Service selector must match the Pod labels. The cluster DNS server then answers `<pod>.<service>.<namespace>.svc.cluster.local` with the address of one Pod, and the Service name alone with the addresses of all ready Pods. Clients must use the name and not the address.

The `podManagementPolicy` field sets the timing of scale operations. `OrderedReady` creates Pods one after another and waits for readiness, and it deletes them in reverse order. `Parallel` creates and deletes all Pods at once. The policy cannot be changed after creation.

The `volumeClaimTemplates` field gives each Pod its own PersistentVolumeClaim, named after the template and the Pod. A replacement Pod attaches the same claim, so its data survives. Claims are kept after scale down and after deletion of the StatefulSet unless `persistentVolumeClaimRetentionPolicy` sets `Delete` for `whenScaled` or `whenDeleted`.

Updates with `RollingUpdate` go from the highest ordinal down, one Pod at a time. A partition keeps Pods below a given ordinal on the old template, which allows a test on the last Pod first. The `OnDelete` type updates only Pods that the administrator deletes.

Key facts:

- Choose a StatefulSet for stable names, per-Pod storage or ordered start and update.
- Scale down removes the highest ordinal first.
- Default retention policy is `Retain` for both `whenScaled` and `whenDeleted`.
- `volumeClaimTemplates` and `podManagementPolicy` cannot be changed on an existing StatefulSet.

<!-- astrona:playground:destroy -->
