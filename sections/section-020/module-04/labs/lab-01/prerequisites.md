# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use (Podman or Docker) and about 2 GiB of free memory.
- `kubectl`.
- You know what a headless Service is, how `volumeClaimTemplates` work and what `persistentVolumeClaimRetentionPolicy` does.

The lab starts a single-node kind cluster with Kubernetes 1.35 and the default StorageClass `standard`. The cluster context is `kind-astro-ats-027-lab-020-04-01`.
