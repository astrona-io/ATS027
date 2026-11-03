# Overview: Ephemeral Volumes (Playground)

This is a playground, not a lab. It starts a fresh cluster and waits. There is no task, no grading and no `astrona submit`. Change the workloads, break them, destroy the environment and start again.

## What is in the box

A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator. The default StorageClass is `standard`.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | The `scout` Deployment: one `busybox` container `app` with a memory limit of `128Mi`. Volume `scratch` is a disk-backed `emptyDir` mounted at `/scratch`. Volume `cache` is a memory-backed `emptyDir` with `sizeLimit: 32Mi` mounted at `/cache`. Volume `work` is a generic ephemeral volume of `1Gi` from the `standard` StorageClass, mounted at `/work`. The container appends a line to `/scratch/starts` every time it starts |
| `outpost` | The `drifter` Deployment, a plain client with no volumes |

## Helpers

Paste these once in each new terminal. `scout_pod` prints the name of the running `scout` Pod. `restart_scout_container` stops the main process of the container so the kubelet starts it again in the same Pod. `scout_volumes` lists the claims in `starfleet` with their owners.

```sh
scout_pod() {
  kubectl -n starfleet get pod -l app=scout -o jsonpath='{.items[0].metadata.name}'
}
restart_scout_container() {
  kubectl -n starfleet exec "$(scout_pod)" -- kill 1
}
scout_volumes() {
  kubectl -n starfleet get pvc -o custom-columns=NAME:.metadata.name,OWNER:.metadata.ownerReferences[0].kind,STATUS:.status.phase
}
```

## Practice tasks

- Write a file into `/scratch` and `/cache`, run `restart_scout_container`, and check which files survive.
- Delete the Pod and check which files survive in the new Pod.
- Run `df -h /cache /scratch` inside the container and compare the file system types and sizes.
- Write more than `32Mi` into `/cache` and read the error.
- Run `scout_volumes` before and after you delete the Pod and compare the claim names.
