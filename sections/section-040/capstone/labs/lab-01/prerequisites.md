---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know PersistentVolumeClaims, access modes, `emptyDir`, and projected volumes with the downward API.

The lab starts a single-node kind cluster (Kubernetes 1.35). The default StorageClass is `standard`.
