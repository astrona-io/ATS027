---
draft: true
exam_objectives:
- Utilize persistent and ephemeral volumes
---
# Preserve Claim Data Across Pod Replacement

Observe persistent data surviving replacement while Pod-lifetime scratch data disappears. Use the isolated `starfleet` environment to verify the result.

## Objective

Observe persistent data surviving replacement while Pod-lifetime scratch data disappears.

## Starting state

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-040-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-040-01-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.


## Required result

Create bound claim `probe-data` requesting 128Mi with ReadWriteOnce access, and Pod `volume-reader` mounting it at `/data` and an emptyDir at `/scratch`. Write `persistent` to `/data/marker` and `ephemeral` to `/scratch/marker`, replace the Pod, then leave the replacement ready with the persistent marker present and no scratch marker. Do not recreate the claim.

## Verify The Result

The grader checks the stated resource fields and live evidence. Wait for controller convergence before submitting. Inspect actual results rather than relying on a sample transcript.
