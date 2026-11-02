---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Record A Running Container Image Identity Solution

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-010-01-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-010-01-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.

## Inspect And Explain

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Inspect the relevant evidence:

```sh
kubectl -n starfleet get deployment probe -o yaml
kubectl -n starfleet get pods -l app=probe -o json
```

The Pod specification requests an image reference. The runtime reports an image identity in container status after preparing it. Record both values rather than treating a mutable tag as proof of content. The report is checked against a ready application container at grading time.


Apply the required change:

```sh
runtime_image_id="$(kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[0].status.containerStatuses[0].imageID}')"
kubectl -n starfleet create configmap image-report --from-literal=requestedImage=docker.io/library/python:3.13-alpine --from-literal=runtimeImageID="$runtime_image_id"
```

## Verify The Result

Observe the actual result. A denied-request command returns a nonzero status when the denial works. Run denial checks separately from a shell sequence that stops on the first nonzero status.

```sh
kubectl -n starfleet get configmap image-report -o yaml
```

Keep the requested application image `docker.io/library/python:3.13-alpine`. Create ConfigMap `image-report` with keys `requestedImage` and `runtimeImageID`. Record the image reference and the actual nonempty `imageID` reported by a ready probe Pod. A tag is a requested reference; the running identity is reported separately by the runtime.

After recording the result, remove this independent lab with `astrona destroy ats-027-lab-010-01-01`.

## Common pitfalls

> [!WARNING]
> Record imageID from a ready container status. The requested image tag is a different value. Do not invent a digest or confuse it with a local build identifier.
