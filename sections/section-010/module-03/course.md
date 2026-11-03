---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Dockerfile Instructions, Layer Cache And Multi-Stage Builds

A build that takes four minutes after a one-line change, an image that contains a compiler nobody needs at runtime, and a secret file that ended up inside an image are all caused by the same thing: the author did not know how the builder turns Dockerfile instructions into layers. This module explains what each common instruction does, how the builder decides to reuse earlier work, and how a multi-stage build keeps build tools out of the final image.

## Learning objectives

- Explain what the instructions `FROM`, `RUN`, `COPY`, `ADD`, `WORKDIR`, `ENV`, `ARG`, `USER` and `EXPOSE` do, and which of them run at build time and which describe the container.
- Predict which steps of a build the layer cache reuses and which it runs again after a change.
- Use a `.dockerignore` file to keep files out of the build context.
- Write a multi-stage Dockerfile with named stages, `COPY --from` and `--target`.
- Build an image on your own machine, load it into a kind cluster and run it as a non-root user.

## Before you start

You need a shell on your own machine with `astrona`, `kubectl`, Podman and `kind`. Podman is the tool that builds and stores the images. The module playground is a kind cluster that contains the namespaces `starfleet` and `outpost`, a `shuttle` Pod in `starfleet` and a `drifter` Pod in `outpost`. The cluster cannot see the images in your Podman storage until you load them.

| Item | Where | Purpose |
| --- | --- | --- |
| `shuttle` | `starfleet` | A busybox Pod for requests from inside the cluster |
| `drifter` | `outpost` | A second busybox Pod for requests from another namespace |

## Reading order

The first part covers the Dockerfile instructions, the build context and the layer cache. The second part covers multi-stage builds, named stages and a small final image that runs as a non-root user. The module ends with a summary.

<!-- astrona:playground -->
