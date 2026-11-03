---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Build A Multi-Stage Image And Run It — Solution

The steps below build the image on your machine, load it into the lab cluster and run it. Run each step in the directory that holds `catalog.txt`, `build-notes.txt` and `render.sh`.

## Step 1: Write the Dockerfile

The build stage produces the page. The final stage starts from a clean base and copies only the finished page with `COPY --from=build`. Because the final stage never copies the three source files, they exist only in the build stage and do not reach the final image.

Save this as `Dockerfile`:

```dockerfile
FROM docker.io/library/python:3.13-alpine AS build
WORKDIR /src
COPY catalog.txt build-notes.txt render.sh ./
RUN sh render.sh

FROM docker.io/library/busybox:1.37.0
RUN adduser -D -u 10001 site
WORKDIR /www
COPY --from=build /out/index.html .
USER 10001
EXPOSE 8080
CMD ["httpd", "-f", "-p", "8080", "-h", "/www"]
```

Build and check it:

```sh
podman build -t localhost/ckad-site:v1 .
podman run --rm localhost/ckad-site:v1 id -u
```

The second command prints `10001`. Submit to check the first part of the work:

```sh
astrona submit
```

## Step 2: Load the image into the cluster

`podman save` writes the image to an archive file. `kind load image-archive` copies that archive into the node of the lab cluster, where the container runtime can start it.

```sh
podman save -o site.tar localhost/ckad-site:v1
KIND_EXPERIMENTAL_PROVIDER=podman kind load image-archive site.tar --name astro-ats-027-lab-010-03-01
```

## Step 3: Create the Pod

The image exists only on the node, so the Pod must not try to pull it.

Save this as `pod-site.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: site
  namespace: starfleet
  labels:
    app: site
spec:
  containers:
  - name: web
    image: localhost/ckad-site:v1
    imagePullPolicy: Never
    ports:
    - containerPort: 8080
```

Apply it:

```sh
kubectl apply -f pod-site.yaml
```

Then check the result:

```sh
kubectl -n starfleet wait --for=condition=Ready pod/site --timeout=120s
kubectl -n starfleet exec site -- find / -xdev -name render.sh
kubectl -n starfleet exec site -- id -u
astrona submit
```

The `find` command prints nothing, and `id -u` prints `10001`. If the Pod shows `ErrImageNeverPull`, the image is not on the node: repeat step 2 and check the `--name` value.
