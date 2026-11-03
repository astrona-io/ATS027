---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Add Ephemeral Volumes To A Deployment

The `shuttle` Deployment in `starfleet` writes small marker files, but it has no volumes, so its data sits in the container layer and a restart removes it. Add two ephemeral volumes and show how each behaves when the container restarts and when the Pod is replaced.

Use a host shell with this lab's private kubeconfig:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-040-03-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-040-03-01" || exit 1
```

Every script supplied by the lab refuses a different context.

## Requirements

1. Edit the Deployment `shuttle` in namespace `starfleet`. Do not change its container command.
2. Add an `emptyDir` volume named `cache` with `medium: Memory` and `sizeLimit: 64Mi`. Mount it at `/cache` in container `app`.
3. Set a memory limit of `128Mi` on container `app`, so the memory-backed volume is covered by a larger limit.
4. Add a generic ephemeral volume named `work` with a claim template: access mode `ReadWriteOnce`, StorageClass `standard`, request `1Gi`. Mount it at `/work` in container `app`.
5. The Deployment keeps one replica. After the change, a container restart must keep the files in `/cache`, and a Pod replacement must give the new Pod an empty `/cache` and a new claim named after the new Pod.

## Constraints

- Do not create a PersistentVolumeClaim object yourself.
- Do not use `hostPath`.
- Keep the Deployment name, labels and image.

Run `astrona submit` when you are ready. Wait until the new Pod is Running before you submit.
