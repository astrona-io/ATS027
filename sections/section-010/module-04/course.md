---
draft: true
exam_objectives:
- Define, build and modify container images
---
# ENTRYPOINT, CMD And Modifying A Deployed Image

A team has an image in production and needs a new version of it, with a different listening port. Two questions follow. Which command does a container run, and what happens to the image defaults when the Pod specification sets its own `command` and `args`? And how does a changed image get from a developer machine to the running Pods of a Deployment without downtime? This module answers both.

## Learning objectives

- Explain the instructions `ENTRYPOINT` and `CMD`, and the difference between exec form and shell form.
- Predict the process that starts when a Pod sets `command`, `args`, both or neither.
- Derive a new image version from an existing image with `FROM`, and tag it.
- Move an image into a kind cluster with `podman save` and `kind load image-archive`.
- Update a Deployment to a new image, choose an `imagePullPolicy`, verify the rollout and roll back.

## Before you start

You need a shell on your own machine with `astrona`, `kubectl`, Podman and `kind`. When the playground starts, a script on your machine builds the image `localhost/ckad-probe:v1` with Podman, loads it into the cluster and creates the objects below. The image runs the busybox `httpd` web server and serves the text `image-version=v1`.

| Item | Where | Purpose |
| --- | --- | --- |
| `probe` Deployment | `starfleet` | Two replicas of `localhost/ckad-probe:v1` with `imagePullPolicy: Never` |
| `probe` Service | `starfleet` | Port 80, forwards to the container port named `http` |
| `shuttle` | `starfleet` | A busybox Pod for requests from inside the cluster |
| `drifter` | `outpost` | A busybox Pod in the second namespace |

## Reading order

The first part covers `ENTRYPOINT`, `CMD`, the two instruction forms and the way a Pod overrides them. The second part covers deriving, tagging and loading a new image version, updating the Deployment and verifying the rollout. The module ends with a summary.

<!-- astrona:playground -->
