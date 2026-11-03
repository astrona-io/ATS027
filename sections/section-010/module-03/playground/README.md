# Dockerfile Instructions, Layer Cache And Multi-Stage Builds Playground

UNTESTED: written statically, never run.

A kind cluster with the namespaces `starfleet` and `outpost`, a `shuttle` Pod and a `drifter` Pod. The learner builds images on the host with Podman and loads them with `kind load image-archive`.

## Run it

```sh
astrona run -c .
astrona destroy ats-027-playground-010-03
```

`astrona destroy` takes the environment name, not the path. There is no grading.
