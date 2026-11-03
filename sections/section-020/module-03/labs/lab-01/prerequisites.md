# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use (Podman or Docker) and about 2 GiB of free memory.
- `kubectl`.
- You know what a ReplicaSet is, how a rolling update works, and the commands `kubectl rollout status`, `history` and `undo`.

The lab starts a single-node kind cluster with Kubernetes 1.35. The cluster context is `kind-astro-ats-027-lab-020-03-01`.
