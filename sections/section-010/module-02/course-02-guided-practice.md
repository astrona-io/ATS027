---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Build And Load A Non-Root Application Image

You will build a small HTTP application image, inspect its runtime settings and load its archive into the module cluster. This makes the host-to-node distribution boundary explicit. The built application serves a file from an unprivileged port and runs under a numeric non-root identity.

Use the module playground and its private kubeconfig. The context check below prevents commands from being directed at an unrelated cluster. The helper retries a command for a bounded interval after controller or policy changes; it cannot turn a persistent failure into success. Read the actual errors when the interval expires.

<!-- astrona:playground:renew -->

For a timed catalog session, renew this module before continuing. Skip renewal for an untimed local author run:

```sh
astrona run renew astrona-io/ATS027/section-010/module-02/playground
```

Select the module environment and define a bounded retry helper:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-playground-010-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-playground-010-02"
kubectl -n starfleet get pods
wait_for_success() {
  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if "$@"; then return 0; fi
    sleep 1
  done
  return 1
}
```

Create an isolated build directory. Save the Dockerfile and application response there. The build context contains only the declared inputs, and the final command is a JSON array rather than an implicit shell.

```sh
mkdir -p image-work
```

Save this as `image-work/Dockerfile`:

```dockerfile
FROM docker.io/library/python:3.13-alpine
WORKDIR /site
COPY index.html .
USER 1000:1000
EXPOSE 8000
CMD ["python", "-m", "http.server", "8000"]
```

Save this as `image-work/index.html`:

```text
image-version=v1
```

The image exposes metadata about port 8000, but exposure does not publish that port automatically. The process itself must listen there.

Build with Podman, inspect the image and transfer its archive into this playground. The archive path avoids assuming that a host image is automatically present in kind nodes.

```sh
podman build -t localhost/ats027-practice-probe:v1 image-work
podman image inspect localhost/ats027-practice-probe:v1
podman save -o probe-image.tar localhost/ats027-practice-probe:v1
KIND_EXPERIMENTAL_PROVIDER=podman kind load image-archive probe-image.tar --name astro-ats-027-playground-010-02
```

The cluster name must match the module playground. Loading an archive changes node image availability, not the Deployment template or application configuration.

Save and create a separate Pod using Never pull policy, then inspect its identity and response. The policy deliberately makes missing node content visible instead of silently downloading a different tag.

Save this as `pod-image-probe.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: image-probe
  namespace: starfleet
spec:
  containers:
  - name: web
    image: localhost/ats027-practice-probe:v1
    imagePullPolicy: Never
    ports:
    - containerPort: 8000
  restartPolicy: Never
```

Apply or use the saved input, then check the result:

```sh
kubectl apply -f pod-image-probe.yaml
kubectl -n starfleet wait --for=condition=Ready pod/image-probe --timeout=120s
kubectl -n starfleet exec image-probe -- id
IMAGE_POD_IP=$(kubectl -n starfleet get pod image-probe -o jsonpath='{.status.podIP}')
wait_for_success kubectl -n starfleet exec shuttle -- wget -qO- "http://${IMAGE_POD_IP}:8000/"
```

The returned file content and numeric identity provide concrete runtime evidence. If the Pod reports image preparation failure, inspect archive loading and the exact image name before changing application code.

The build, image metadata, node loading and Pod execution are separate operations. A successful build is not a working deployment. Keep build credentials and personal files out of the context, and avoid interpreting EXPOSE as a network access or port-publication policy.

## Common pitfalls

> [!WARNING]
> Keep the selected module context and inspect the observed outcome. Resource acceptance does not establish readiness or a successful request. Reset this isolated environment if earlier experiments changed the required starting state.
