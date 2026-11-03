---
draft: true
exam_objectives:
- Understand multi-container Pod design patterns (e.g. sidecar, init and others)
---
# Convert A Log Shipper Into A Native Sidecar — Task

Solve this question on: `terminal`

The nightly report job of the `starfleet` namespace must finish, but its log shipper never exits. The Job `nightly-report` has two ordinary containers sharing an `emptyDir` volume named `logs`. The container `report` writes three readings and exits. The container `log-shipper` follows `/logs/report.log` and prints each line with the prefix `shipped:`. The Pod stays in the phase `Running` and the Job never completes.

1. Replace the Job `nightly-report` so that `log-shipper` runs as a native sidecar container: an init container that restarts for the life of the Pod and does not keep the Pod from finishing.
2. The `report` container must stay the only application container, and the `log-shipper` container must keep its image, its command and its read-only mount of the `logs` volume.
3. The Job must reach the condition `Complete` with one success and no failed Pods, and the logs of the sidecar must contain the `shipped:` lines for the readings.

Constraints: do not use `activeDeadlineSeconds`, do not use `kubectl delete pod` to force an end, and do not change the `report` container. The Job keeps the name `nightly-report` in the `starfleet` namespace. `kubectl` already points at the cluster as the cluster administrator.
