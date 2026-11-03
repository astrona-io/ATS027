---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Summary

An image stores a default process in two parts. `ENTRYPOINT` is the executable and `CMD` holds the default arguments, or the whole command when no `ENTRYPOINT` exists. Both can be written in exec form, a JSON array that the container runtime starts directly, or in shell form, a plain string that the runtime wraps in `/bin/sh -c`. Exec form starts the program as the main process and passes it signals such as `SIGTERM` directly. Shell form makes the shell the main process, needs a shell in the image and applies shell parsing to the string.

A Pod can override both parts. The Pod field `command` replaces the image `ENTRYPOINT`, and the Pod field `args` replaces the image `CMD`. When only `args` is set, the image `ENTRYPOINT` stays and receives the new arguments. When only `command` is set, the image `CMD` is dropped as well. When neither is set, the image defaults run. The values are lists of strings that go to the program directly, so a pipe or a variable in a list item is not interpreted unless the command starts a shell.

A new version of an image can be derived from an existing one with `FROM`. The new image inherits the filesystem and the metadata, including `ENTRYPOINT`, `CMD`, `ENV` and `USER`, and adds its own changes on top. Each version gets its own tag. A tag is a movable name, so a new tag for new content keeps old and new versions distinguishable, and the `imageID` in a Pod status shows which content a container actually started from.

A kind cluster cannot pull an image that exists only in local Podman storage. The image is saved with `podman save` and copied into the node with `kind load image-archive`. The Pod then uses `imagePullPolicy: Never`, which tells the kubelet to use only what is on the node.

Changing the image field of a Deployment starts a rolling update. The Deployment controller creates a new ReplicaSet for the new Pod template and scales it up while it scales the old ReplicaSet down. `kubectl rollout status` waits for the result, `kubectl rollout history` lists the revisions and `kubectl rollout undo` returns to the previous revision.

Key facts:

- `command` replaces `ENTRYPOINT`; `args` replaces `CMD`.
- Setting only `command` also discards the image `CMD`.
- The default `imagePullPolicy` is `Always` for the tag `latest` or no tag, and `IfNotPresent` otherwise.
- Loading a changed image under an existing tag does not change running Pods.
- Only a change to the Pod template creates a new rollout revision.

<!-- astrona:playground:destroy -->
