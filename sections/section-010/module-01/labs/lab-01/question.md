---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Record A Running Container Image Identity

Distinguish a requested image reference from the identity reported for a running container. Use the isolated `starfleet` environment to verify the result.

## Objective

Distinguish a requested image reference from the identity reported for a running container.

## Starting state

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-010-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-010-01-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.


## Required result

Keep the requested application image `docker.io/library/python:3.13-alpine`. Create ConfigMap `image-report` with keys `requestedImage` and `runtimeImageID`. Record the image reference and the actual nonempty `imageID` reported by a ready probe Pod. A tag is a requested reference; the running identity is reported separately by the runtime.

## Verify The Result

The grader checks the stated resource fields and live evidence. Wait for controller convergence before submitting. Inspect actual results rather than relying on a sample transcript.
