---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Update A Deployment To A Derived Image With Overridden Arguments — Solution

The image of version 1 sets `ENTRYPOINT ["httpd", "-f", "-h", "/www"]` and `CMD ["-p", "8080"]`. The steps below derive version 2 from it, load it and update the Deployment.

## Step 1: Build version 2 from version 1

`FROM localhost/ckad-probe:v1` copies the whole configuration of version 1, including `ENTRYPOINT` and `CMD`. The `RUN` line only replaces the page.

Save this as `Dockerfile` in an empty directory:

```dockerfile
FROM localhost/ckad-probe:v1
RUN echo "image-version=v2" > /www/index.html
```

Build it:

```sh
podman build -t localhost/ckad-probe:v2 .
astrona submit
```

At this point most checks still fail, because the Deployment has not changed.

## Step 2: Load the image

```sh
podman save -o probe-v2.tar localhost/ckad-probe:v2
KIND_EXPERIMENTAL_PROVIDER=podman kind load image-archive probe-v2.tar --name astro-ats-027-lab-010-04-01
```

## Step 3: Update the Deployment

Changing the image starts a rolling update. The Deployment controller creates a new ReplicaSet and the new Pods start with the new image. Because the Service targets the named port `http` and the readiness probe checked port 8080, the container port and the probe must follow the new listening port. The fields `args` and `ports` need an edit, so use `kubectl edit`.

```sh
kubectl -n starfleet edit deployment probe
```

In the editor, change the container `web` to this:

```yaml
      - name: web
        image: localhost/ckad-probe:v2
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

Then check the result:

```sh
kubectl -n starfleet rollout status deployment/probe --timeout=120s
kubectl -n starfleet exec deploy/probe -- ps
kubectl -n starfleet exec shuttle -- wget -q -O - http://probe.starfleet.svc.cluster.local/
astrona submit
```

The process list shows `httpd -f -h /www -p 9090`: the entry point of the image plus the new arguments. The request prints `image-version=v2`. If the new Pods never become Ready, the readiness probe still checks port 8080.
