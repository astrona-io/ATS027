---
draft: true
exam_objectives:
- Understand multi-container Pod design patterns (e.g. sidecar, init and others)
---
# Summary

A native sidecar is an init container with `restartPolicy: Always`. It combines the order of an init container with the long life of an ordinary container. The kubelet starts it before the application containers, waits until it counts as started, and restarts it whenever it exits. A sidecar counts as started when its process runs, or when its `startupProbe` succeeds if one is defined.

Probes give the sidecar a voice in the lifecycle of the Pod. The `startupProbe` decides when the next container may start. The `readinessProbe` joins the readiness of the Pod, so a failing sidecar makes the whole Pod not ready and removes it from the endpoints of its Services. Sidecars report their state in `status.initContainerStatuses`, and `kubectl logs` and `kubectl exec` work on them by container name.

The scheduler counts resources by the effective request of the Pod. This is the higher of the sum of the requests of all sidecars and application containers, and the largest request of any ordinary init container. Sidecars are in the sum for the whole life of the Pod, so each replica pays for them.

Shutdown mirrors startup. The kubelet stops the application containers first, then the sidecars in the reverse order of the list. For each container it runs the `preStop` hook, sends SIGTERM, and sends SIGKILL when the grace period ends. `terminationGracePeriodSeconds` is one budget for the whole Pod. A process that ignores SIGTERM, such as a shell without a `trap`, uses the whole budget.

Jobs benefit most. A Job succeeds when its Pod reaches the phase `Succeeded`, which needs every container to end. An ordinary helper container never ends, so the Job never completes. A native sidecar does not block this, because the kubelet stops it once the application containers have finished.

Key facts:

- The field is `restartPolicy: Always` on an entry of `initContainers`.
- Start order follows the list. Stop order is reversed, and sidecars stop after the application containers.
- A `startupProbe` gates the next container. A `readinessProbe` joins Pod readiness.
- The effective request is the higher of the running sum and the largest init request.
- The pod template of a Job cannot change, so a conversion needs a new Job.

<!-- astrona:playground:destroy -->
