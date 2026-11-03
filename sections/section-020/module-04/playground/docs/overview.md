# Overview: StatefulSets And Stable Identity

This playground starts a fresh Kubernetes cluster with an empty namespace and one client Pod, and then waits. There is no task and no grading. Create StatefulSets, delete Pods, run `astrona destroy` and start again.

## What is in the box

The cluster has one node and Kubernetes 1.35. `kubectl` uses the cluster administrator account. The default StorageClass is `standard`, so a PersistentVolumeClaim from a StatefulSet is bound when its Pod is scheduled.

| Namespace | Contents |
| --- | --- |
| `starfleet` | Empty. Create StatefulSets and headless Services here |
| `outpost` | The `drifter` Deployment: one `busybox` Pod that stays running, used for DNS lookups |

## Helpers

Paste these into each new terminal. `lookup_pod` asks the cluster DNS server for the address of one StatefulSet Pod from the `drifter` Pod. `lookup_service` asks for the addresses behind a headless Service. `show_claims` lists the PersistentVolumeClaims in `starfleet`.

```sh
lookup_pod() {
  kubectl -n outpost exec deploy/drifter -- nslookup "$1.$2.starfleet.svc.cluster.local"
}
lookup_service() {
  kubectl -n outpost exec deploy/drifter -- nslookup "$1.starfleet.svc.cluster.local"
}
show_claims() {
  kubectl -n starfleet get pvc
}
```

Use them like this: `lookup_pod scout-0 scout`, `lookup_service scout`, `show_claims`.

## Practice tasks

- Create a StatefulSet with three replicas and a headless Service. Compare the IP address from `lookup_pod` with the `IP` column of `kubectl get pods -o wide`.
- Delete one Pod and check that the name returns with a new address.
- Add `volumeClaimTemplates`, write a file in one Pod, delete the Pod and read the file again.
- Set a partition larger than the replica count and change the template. Find out why no Pod changes.
- Scale down with the default retention policy, then delete the StatefulSet and list the claims that remain.
