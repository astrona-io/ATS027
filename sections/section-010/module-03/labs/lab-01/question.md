---
draft: true
exam_objectives:
- Define, build and modify container images
---
# Build A Multi-Stage Image And Run It — Task

The `outpost` team must run a small status page in `starfleet`. The page is produced while the image is built, and the image that runs must not contain the files used to produce it.

Use a host shell with this lab's private kubeconfig. The cluster has the `starfleet` and `outpost` namespaces and a client Pod named `shuttle` in `starfleet`.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-027-lab-010-03-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-027-lab-010-03-01" || exit 1
```

## Build context

Create an empty directory on your machine and save these three files in it.

Save this as `catalog.txt`:

```text
scout 3
probe 2
```

Save this as `build-notes.txt`:

```text
These notes are only needed while the image is built.
```

Save this as `render.sh`. It reads `/src/catalog.txt` and writes `/out/index.html`:

```sh
#!/bin/sh
set -eu
mkdir -p /out
{
  echo "<html><body>"
  echo "<p>generated-at-build</p>"
  while read -r name count; do
    echo "<p>${name}=${count}</p>"
  done < /src/catalog.txt
  echo "</body></html>"
} > /out/index.html
```

## Requirements

1. Write a `Dockerfile` with two stages. The build stage uses `docker.io/library/python:3.13-alpine`, copies the three files to `/src` and runs `sh render.sh`. The final stage uses `docker.io/library/busybox:1.37.0`.
2. The final stage contains `/out/index.html` as `/www/index.html` and none of `catalog.txt`, `build-notes.txt` and `render.sh`.
3. The final image runs as a numeric non-root user and starts `httpd -f -p 8080 -h /www` by default.
4. Build it as `localhost/ckad-site:v1` with Podman and load it into this lab cluster, named `astro-ats-027-lab-010-03-01`.
5. Create the Pod `site` in the namespace `starfleet` with a container named `web`, that image and `imagePullPolicy: Never`.

## Constraints

- Do not change the `shuttle` Pod.
- Do not copy the build-only files into the final stage, and do not delete them with a later `RUN`.
- The grader checks the running container. It does not read your `Dockerfile`.

## Verify the result

A request from `shuttle` to the Pod IP address on port 8080 must return a page that contains `generated-at-build`. Inspect the running container yourself before you submit.
