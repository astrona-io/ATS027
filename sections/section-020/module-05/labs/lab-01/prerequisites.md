# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know the Job fields `completions`, `parallelism`, `completionMode` and `backoffLimit`, and the CronJob fields `concurrencyPolicy`, `timeZone`, `startingDeadlineSeconds` and the history limits.

The lab starts a one-node kind cluster running Kubernetes 1.35.
