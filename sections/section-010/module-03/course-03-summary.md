---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Summary

A Dockerfile is a list of instructions that the image builder runs in order. `FROM` chooses the base image. `RUN`, `COPY` and `ADD` change the filesystem, and each of them creates a layer. `WORKDIR`, `ENV`, `USER`, `EXPOSE` and `CMD` record settings in the image metadata that the container runtime reads when it starts a container. `ARG` exists only while the build runs.

The builder stores the result of each instruction and reuses it when the instruction and its inputs have not changed. A change in one instruction makes every later instruction run again. For that reason, instructions that change rarely, such as installing dependencies, belong above instructions that change often, such as copying source files. The `.dockerignore` file removes files from the build context before the builder sees them, which keeps the context small and keeps unwanted files out of `COPY` instructions.

A multi-stage Dockerfile has more than one `FROM`. A stage can be named with `AS`, a later stage copies selected paths from it with `COPY --from`, and the builder discards every stage that the final stage does not use. The final image therefore contains only what the last stage copied, not the compilers, the source files or the notes of the build stage. The `--target` option builds up to one named stage, which is useful for inspecting what a stage contains.

A small image still needs a safe identity. A user created in the final stage and selected with a numeric `USER` makes the process run as a non-root user. A kind cluster cannot pull an image that exists only in local Podman storage, so the image is saved to an archive, loaded into the node with `kind load image-archive` and started by a Pod with `imagePullPolicy: Never`.

Key facts:

- `RUN`, `COPY` and `ADD` create layers; `ENV`, `WORKDIR`, `USER`, `EXPOSE` and `CMD` change metadata.
- A changed instruction invalidates the cache for itself and for every instruction after it.
- Files deleted in a later `RUN` stay in the earlier layer.
- `COPY --from=<stage>` copies only the named path into the current stage.
- `USER` with a numeric ID can be checked by the runtime; a user name cannot be checked against a non-root requirement.

<!-- astrona:playground:destroy -->
