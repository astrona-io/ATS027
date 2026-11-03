# Overview: Dockerfile Instructions, Layer Cache And Multi-Stage Builds

This is an ungraded playground. It starts a single-node kind cluster running Kubernetes v1.35 with its own kubeconfig. Nothing is submitted for grading.

## What is in the box

| Namespace | Contents |
| --- | --- |
| `starfleet` | The `shuttle` client Pod (busybox) |
| `outpost` | The `drifter` client Pod (busybox) |

The images are built on your own machine with Podman, not in the cluster. The cluster node cannot see images in your Podman storage until you load them. Select the cluster first:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-playground-010-03)"
kubectl config current-context
```

The context must be `kind-astro-ats-027-playground-010-03`. The cluster name for loading is `astro-ats-027-playground-010-03`.

## Helpers

Paste these in a shell. `load_image` saves an image from Podman storage to the file `image-load.tar` in the current directory and loads it into the playground cluster. `pod_user` prints the user ID inside a Pod. `show_layers` prints the history of an image.

```sh
load_image() {
  podman save -o image-load.tar "$1"
  KIND_EXPERIMENTAL_PROVIDER=podman kind load image-archive image-load.tar --name astro-ats-027-playground-010-03
}
pod_user() {
  kubectl -n "$1" exec "$2" -- id -u
}
show_layers() {
  podman history "$1"
}
```

## Practice ideas

- Build one image twice and compare the cache messages. Change one file and build again.
- Move a `COPY` line above a `RUN` line and watch which steps run again.
- Build with `--target` to stop at the build stage, then compare the size of both images.
- Run a Pod from a loaded image with `imagePullPolicy: Never` and run `find / -name '*.sh'` inside it.

Destroy the environment and start again for a clean reset:

```sh
astrona destroy ats-027-playground-010-03
```
