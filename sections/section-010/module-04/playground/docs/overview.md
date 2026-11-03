# Overview: ENTRYPOINT, CMD And Modifying A Deployed Image

This is an ungraded playground. It starts a single-node kind cluster running Kubernetes v1.35 with its own kubeconfig. Nothing is submitted for grading.

## What is in the box

| Namespace | Contents |
| --- | --- |
| `starfleet` | Deployment `probe` (2 replicas, image `localhost/ckad-probe:v1`, `imagePullPolicy: Never`), Service `probe` on port 80 and the `shuttle` client Pod |
| `outpost` | The `drifter` client Pod |

During start, a script on your machine builds `localhost/ckad-probe:v1` with Podman and loads it into the cluster. The image sets `ENTRYPOINT ["httpd", "-f", "-h", "/www"]` and `CMD ["-p", "8080"]` and serves `image-version=v1`.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-playground-010-04)"
kubectl config current-context
```

The context must be `kind-astro-ats-027-playground-010-04`. The cluster name for loading is `astro-ats-027-playground-010-04`.

## Helpers

`load_image` saves an image from Podman storage to `image-load.tar` in the current directory and loads it into the cluster. `probe_page` requests the page through the `probe` Service from `shuttle`. `probe_process` prints the process list of a `probe` container.

```sh
load_image() {
  podman save -o image-load.tar "$1"
  KIND_EXPERIMENTAL_PROVIDER=podman kind load image-archive image-load.tar --name astro-ats-027-playground-010-04
}
probe_page() {
  kubectl -n starfleet exec shuttle -- wget -q -O - http://probe.starfleet.svc.cluster.local/
}
probe_process() {
  kubectl -n starfleet exec deploy/probe -- ps
}
```

## Practice ideas

- Derive a `v2` image with `FROM localhost/ckad-probe:v1` and update the Deployment with `kubectl set image`.
- Set only `args`, then only `command`, then both, and read the process list each time.
- Roll back with `kubectl rollout undo` and check which image the Pods run.
- Load a changed image under the same tag and check whether running Pods change.

Destroy the environment and start again for a clean reset:

```sh
astrona destroy ats-027-playground-010-04
```
