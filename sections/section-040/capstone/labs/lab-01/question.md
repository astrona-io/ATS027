---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Persistent And Ephemeral Volumes Capstone

The `probe` Deployment in `starfleet` keeps a journal that must survive Pod replacement, uses a scratch directory that must not, and reads its settings from files. It does not start, and after you fix that, it still writes data to the wrong places. Repair it.

Use a host shell with this lab's private kubeconfig:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-040-capstone)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-040-capstone" || exit 1
```

Every script supplied by the lab refuses a different context.

## Requirements

1. The claim `probe-data` must use access mode `ReadWriteOnce`, request at least `1Gi`, use StorageClass `standard` and be `Bound`.
2. The app writes its journal to the directory in the environment variable `JOURNAL_DIR` and its scratch files to `SCRATCH_DIR`. Mount the claim `probe-data` at the journal directory. Mount an `emptyDir` at the scratch directory. Give the `emptyDir` a size limit of `128Mi`.
3. The settings must come from one `projected` volume mounted read-only at `/etc/probe`. It holds the key `probe.conf` of ConfigMap `probe-settings` as `probe.conf`, and the Pod labels as `labels`. Do not use `subPath`.
4. After a Pod replacement, the journal must still list the old and the new Pod, and the scratch directory must not hold the files of the old Pod.

## Constraints

- Do not change the container command, the environment variables, the image or the memory limit.
- Keep one replica. Do not use `hostPath`.
- Keep the Deployment name `probe` and the claim name `probe-data`.

Run `astrona submit` when you are ready. Wait until the new Pod is Running before you submit.
