---
draft: true
exam_objectives:
- Understand multi-container Pod design patterns (e.g. sidecar, init and others)
---
# Initialize Data Shared By Two Containers

Complete initialization before two ordinary containers read the same Pod volume. Use the isolated `starfleet` environment to verify the result.

## Objective

Complete initialization before two ordinary containers read the same Pod volume.

## Starting state

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-030-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-030-01-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.


## Required result

Create Pod `shared-report` with init container `prepare` and ordinary containers `reader` and `observer`. The init container writes `initialized` to `/shared/message` on an emptyDir volume named `shared`. Both ordinary containers mount that same volume read-only and remain running. The reader must check the file before sleeping. Both containers must read the initialized value.

## Verify The Result

The grader checks the stated resource fields and live evidence. Wait for controller convergence before submitting. Inspect actual results rather than relying on a sample transcript.
