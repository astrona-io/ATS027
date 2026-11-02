---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Build And Load A Non-Root Image

Build a local image, load it into the private cluster and verify its user and response. Use the isolated `starfleet` environment to verify the result.

## Objective

Build a local image, load it into the private cluster and verify its user and response.

## Starting state

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-010-02-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-010-02-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.


## Required result

Build image `localhost/ckad-probe:v1` from a Dockerfile based on Python 3.13 Alpine. Serve an index page containing `image-version=v1` on port 8000 as user 1000. Load the image into this lab cluster. Create Pod `image-probe` with container `web`, that image and `imagePullPolicy: Never`. It must run as user 1000 and serve the page. The grader checks the loaded image and running behavior; it does not inspect the local Dockerfile.

## Verify The Result

The grader checks the stated resource fields and live evidence. Wait for controller convergence before submitting. Inspect actual results rather than relying on a sample transcript.
