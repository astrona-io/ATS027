# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know how a Job decides that it is complete, and that the Pod template of a Job cannot be edited after the Job exists.

The lab starts a single-node kind cluster (Kubernetes 1.35). It needs the image `busybox:1.37.0`, which is preloaded into the cluster.
