# Lab: Build A Multi-Stage Image And Run It

UNTESTED: written statically, never run. The learner builds a multi-stage image with Podman, loads it into the kind cluster and runs it as Pod `site`.

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-027-lab-010-03-01
```

`astrona test -c .` builds the reference image in `solution/image` and applies the reference Pod.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-pod-runs-loaded-image.sh` | Pod `site` uses a `localhost/` image, `imagePullPolicy: Never`, and is Ready |
| `validate-serves-build-output.sh` | `shuttle` gets a page with `generated-at-build` from the Pod IP on port 8080 |
| `validate-no-build-only-files.sh` | `find` in the container finds none of `render.sh`, `catalog.txt`, `build-notes.txt` |
| `validate-runs-as-non-root.sh` | `id -u` in the container is not 0 |
