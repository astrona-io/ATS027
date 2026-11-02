---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Build And Load A Non-Root Image Solution

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-010-02-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-010-02-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.

## Inspect And Explain

The application and client fixtures are healthy. Complete the required change without replacing unrelated resources.

Inspect the relevant evidence:

```sh
podman image inspect localhost/ckad-probe:v1
kubectl -n starfleet get pod image-probe -o yaml
```

The image declares the process, content and default user. Loading an image archive into kind makes that content available without a registry pull. A Never pull policy turns a missing local image into a visible preparation failure. Check the actual process user and response after the Pod starts.


Save this as `image/Dockerfile`:

```dockerfile
FROM docker.io/library/python:3.13-alpine
WORKDIR /site
COPY index.html .
USER 1000:1000
EXPOSE 8000
CMD ["python", "-m", "http.server", "8000"]
```

Save this as `image/index.html`:

```text
image-version=v1
```

Save this as `pod-image-probe.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: image-probe
  namespace: starfleet
spec:
  restartPolicy: Never
  containers:
  - name: web
    image: localhost/ckad-probe:v1
    imagePullPolicy: Never
    ports:
    - name: http
      containerPort: 8000
```

Apply the required change:

```sh
podman build -t localhost/ckad-probe:v1 image
image_directory="$(mktemp -d)"
image_archive="$image_directory/probe.tar"
trap 'rm -rf "$image_directory"' EXIT
podman save -o "$image_archive" localhost/ckad-probe:v1
KIND_EXPERIMENTAL_PROVIDER=podman kind load image-archive "$image_archive" --name astro-ats-027-lab-010-02-01
kubectl apply -f pod-image-probe.yaml
```

## Verify The Result

Observe the actual result. A denied-request command returns a nonzero status when the denial works. Run denial checks separately from a shell sequence that stops on the first nonzero status.

```sh
kubectl -n starfleet wait --for=condition=Ready pod/image-probe --timeout=180s
kubectl -n starfleet exec image-probe -- id -u
```

Build image `localhost/ckad-probe:v1` from a Dockerfile based on Python 3.13 Alpine. Serve an index page containing `image-version=v1` on port 8000 as user 1000. Load the image into this lab cluster. Create Pod `image-probe` with container `web`, that image and `imagePullPolicy: Never`. It must run as user 1000 and serve the page. The grader checks the loaded image and running behavior; it does not inspect the local Dockerfile.

After recording the result, remove this independent lab with `astrona destroy ats-027-lab-010-02-01`.

## Common pitfalls

> [!WARNING]
> Load the archive into this lab cluster, and keep imagePullPolicy Never. Declaring a port does not start a listener. Check the running process user and content, not only the Dockerfile.
