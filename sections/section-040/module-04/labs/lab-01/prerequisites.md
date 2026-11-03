---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know how a ConfigMap and a Secret become files, how `items` and `mode` work, and what a projected volume and the downward API do.

The lab starts a single-node kind cluster (Kubernetes 1.35).
