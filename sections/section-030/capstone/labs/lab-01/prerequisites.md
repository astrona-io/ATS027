# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know init containers, native sidecars (init containers with `restartPolicy: Always`), the ambassador and adapter patterns, shared `emptyDir` volumes and `startupProbe`.

The lab starts a single-node kind cluster (Kubernetes 1.35). It needs the images `busybox:1.37.0` and `python:3.13-alpine`, which are preloaded into the cluster.
