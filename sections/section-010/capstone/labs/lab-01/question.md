---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Define, Build And Modify Container Images Capstone — Task

The `scout` application must run in `starfleet` from an image that your team builds, releases as version 1 and then modifies into version 2, with a record of the exact image that runs.

Use a host shell with this lab's private kubeconfig. The cluster has the `starfleet` and `outpost` namespaces, a client Pod `shuttle` in `starfleet` and a Service `scout` in `starfleet` (port 80, target port 8080, selector `app: scout`).

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-010-capstone)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-010-capstone" || exit 1
```

## Build context for version 1

Create an empty directory and save these files in it.

Save this as `catalog.txt`:

```text
probe 2
shuttle 1
```

Save this as `build-notes.txt`:

```text
Build-only notes. They must not reach the final image.
```

Save this as `render.sh`. It reads `/src/catalog.txt` and writes `/out/index.html`:

```sh
#!/bin/sh
set -eu
mkdir -p /out
{
  echo "<html><body>"
  echo "<p>release=v1</p>"
  while read -r name count; do
    echo "<p>${name}=${count}</p>"
  done < /src/catalog.txt
  echo "</body></html>"
} > /out/index.html
```

## Requirements

1. Build `localhost/ckad-scout:v1` with a two-stage `Dockerfile`. The build stage uses `docker.io/library/python:3.13-alpine` and runs `sh render.sh`. The final stage uses `docker.io/library/busybox:1.37.0`, contains only the generated page as `/www/index.html`, runs as a numeric non-root user, and sets `ENTRYPOINT ["httpd", "-f", "-h", "/www"]` with `CMD ["-p", "8080"]`.
2. Load the image into the cluster named `astro-ats-027-lab-010-capstone` and create the Deployment `scout` (2 replicas, label `app: scout`, container `web`, port name `http`, `imagePullPolicy: Never`). Wait until the rollout completes.
3. Build `localhost/ckad-scout:v2` with `FROM localhost/ckad-scout:v1`. It serves `release=v2` and still runs as the same numeric non-root user.
4. Load version 2 and update the existing Deployment to it. Replace only the arguments of the image: set `args` to `-p` and `9090`, and do not set `command`.
5. Make the Service `scout` reach the container on its new port, so `shuttle` gets `release=v2` from `http://scout.starfleet.svc.cluster.local/`.
6. Record the exact image of the running Pods in a ConfigMap `scout-release` in `starfleet` with the keys `version` (value `v2`) and `imageID` (the `imageID` that the running Pods report in their container status).

## Constraints

- Version 1 must be rolled out before version 2.
- Do not copy build-only files into the final image or delete them in a later layer.
- The grader checks the running Pods and the cluster objects. It does not read your `Dockerfile` files.
