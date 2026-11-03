---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Define, Build And Modify Container Images Capstone — Solution

The work has five parts: a multi-stage version 1, a first rollout, a derived version 2, an update with overridden arguments and a record of the image identity.

## Step 1: Build version 1

Save this as `Dockerfile` next to `catalog.txt`, `build-notes.txt` and `render.sh`:

```dockerfile
FROM docker.io/library/python:3.13-alpine AS build
WORKDIR /src
COPY catalog.txt build-notes.txt render.sh ./
RUN sh render.sh

FROM docker.io/library/busybox:1.37.0
RUN adduser -D -u 10001 scout
WORKDIR /www
COPY --from=build /out/index.html .
USER 10001
EXPOSE 8080
ENTRYPOINT ["httpd", "-f", "-h", "/www"]
CMD ["-p", "8080"]
```

Build and load it:

```sh
podman build -t localhost/ckad-scout:v1 .
podman save -o scout-v1.tar localhost/ckad-scout:v1
KIND_EXPERIMENTAL_PROVIDER=podman kind load image-archive scout-v1.tar --name astro-ats-027-lab-010-capstone
astrona submit
```

## Step 2: Roll out version 1

Save this as `deployment-scout.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
  namespace: starfleet
spec:
  replicas: 2
  selector:
    matchLabels:
      app: scout
  template:
    metadata:
      labels:
        app: scout
    spec:
      containers:
      - name: web
        image: localhost/ckad-scout:v1
        imagePullPolicy: Never
        ports:
        - name: http
          containerPort: 8080
        readinessProbe:
          httpGet:
            path: /
            port: http
          periodSeconds: 2
```

Apply it:

```sh
kubectl apply -f deployment-scout.yaml
```

Then check the result:

```sh
kubectl -n starfleet rollout status deployment/scout --timeout=120s
astrona submit
```

## Step 3: Derive and load version 2

The derived image starts as root for the `RUN` line, because the user of version 1 cannot write the page. It selects the numeric user again at the end, so the final image is non-root.

Save this as `Dockerfile` in a new, empty directory:

```dockerfile
FROM localhost/ckad-scout:v1
USER root
RUN sed -i 's/release=v1/release=v2/' /www/index.html
USER 10001
```

Build and load it:

```sh
podman build -t localhost/ckad-scout:v2 .
podman save -o scout-v2.tar localhost/ckad-scout:v2
KIND_EXPERIMENTAL_PROVIDER=podman kind load image-archive scout-v2.tar --name astro-ats-027-lab-010-capstone
```

## Step 4: Update the Deployment and the Service

Setting `args` replaces the `CMD` of the image and keeps its `ENTRYPOINT`. The container then listens on 9090, so the Service must target the named port `http`, which now points to 9090.

Save this as `deployment-scout.yaml` again, with these changes in the container:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
  namespace: starfleet
spec:
  replicas: 2
  selector:
    matchLabels:
      app: scout
  template:
    metadata:
      labels:
        app: scout
    spec:
      containers:
      - name: web
        image: localhost/ckad-scout:v2
        imagePullPolicy: Never
        args:
        - -p
        - "9090"
        ports:
        - name: http
          containerPort: 9090
        readinessProbe:
          httpGet:
            path: /
            port: http
          periodSeconds: 2
```

Apply it:

```sh
kubectl apply -f deployment-scout.yaml
```

Save this as `service-scout.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: scout
  namespace: starfleet
spec:
  selector:
    app: scout
  ports:
  - name: http
    port: 80
    targetPort: http
```

Apply it:

```sh
kubectl apply -f service-scout.yaml
```

Then check the result:

```sh
kubectl -n starfleet rollout status deployment/scout --timeout=120s
kubectl -n starfleet exec shuttle -- wget -q -O - http://scout.starfleet.svc.cluster.local/
astrona submit
```

## Step 5: Record the image identity

The `imageID` in the container status identifies the content that the container runtime started. Read it from a running Pod and store it:

```sh
POD="$(kubectl -n starfleet get pods -l app=scout -o jsonpath='{.items[0].metadata.name}')"
IMAGE_ID="$(kubectl -n starfleet get pod "$POD" -o jsonpath='{.status.containerStatuses[0].imageID}')"
kubectl -n starfleet create configmap scout-release --from-literal=version=v2 --from-literal=imageID="$IMAGE_ID"
astrona submit
```

All checks pass when `shuttle` gets `release=v2`, the Pods run as a non-zero user, the process list shows `httpd -f -h /www -p 9090` and the record matches the Pods.
